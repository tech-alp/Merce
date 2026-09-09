#include "MerceTheme.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaProperty>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QtTest/QtTest>

#include <stdexcept>
#include <memory>

namespace {

bool writeJson(const QString &path, const QJsonObject &object)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    return file.write(QJsonDocument(object).toJson(QJsonDocument::Compact)) > 0;
}

bool writeRaw(const QString &path, const QByteArray &data)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    return file.write(data) == data.size();
}

QString pathIn(const QTemporaryDir &dir, const QString &fileName)
{
    return QDir(dir.path()).filePath(fileName);
}

QJsonObject tenantBrand(const QString &brandId, const QString &seed)
{
    return {
        {QStringLiteral("kind"), QStringLiteral("tenant-brand")},
        {QStringLiteral("tenantBrandSchemaVersion"), 1},
        {QStringLiteral("brandId"), brandId},
        {QStringLiteral("seed"), seed},
    };
}

QMetaProperty propertyByName(const QMetaObject *metaObject, const char *name)
{
    const int propertyIndex = metaObject->indexOfProperty(name);
    Q_ASSERT(propertyIndex >= 0);
    return metaObject->property(propertyIndex);
}

} // namespace

class tst_merce_theme_runtime_switch : public QObject
{
    Q_OBJECT

private slots:
    void defaultContextIsBundledAlGit();
    void successfulContextSwitchIsAtomicAndReevaluatesQmlBinding();
    void runtimeFailureKeepsLastKnownGoodContext();
    void invalidExternalStartupSourceKeepsBundledAlGit();
    void failedActiveReloadKeepsSnapshot();
    void failedClearKeepsActiveSourceRegistered();
    void duplicateBrandModeIsRejected();
    void missingBundledThemeFailsLoudly();
    void reentrantContextSwitchIsRejectedWithoutTearingSnapshot();
    void metaObjectContractUsesPointerNotifySignals();
    void shadowLayersCarryGeometryAndOpacityOnly();
};

// A shadow layer must stay colourless. Baking a colour back in would pin every
// theme to one hue again, and the breakage is invisible until someone opens a
// dark mode screenshot. spread has the same problem in reverse: it is easy to
// drop when transcribing a scale, and its absence just looks "a bit heavy".
void tst_merce_theme_runtime_switch::shadowLayersCarryGeometryAndOpacityOnly()
{
    MerceTheme theme;

    const QVariantList dialog = theme.shadows()->dialog();
    QCOMPARE(dialog.size(), 1);

    const QVariantMap layer = dialog.first().toMap();
    QVERIFY2(!layer.contains(QStringLiteral("color")),
             "shadow layers must not carry a colour; the hue is colors.surface.shadow");
    QCOMPARE(layer.value(QStringLiteral("yOffset")).toInt(), 25);
    QCOMPARE(layer.value(QStringLiteral("blur")).toInt(), 50);
    QCOMPARE(layer.value(QStringLiteral("spread")).toInt(), -12);
    QCOMPARE(layer.value(QStringLiteral("opacity")).toReal(), 0.25);

    // Two layers is the point of the scale: the wide one floats the surface,
    // the tight one draws its contact edge.
    const QVariantList dropdown = theme.shadows()->dropdown();
    QCOMPARE(dropdown.size(), 2);
    QCOMPARE(dropdown.at(0).toMap().value(QStringLiteral("spread")).toInt(), -5);
    QCOMPARE(dropdown.at(0).toMap().value(QStringLiteral("opacity")).toReal(), 0.16);
    QCOMPARE(dropdown.at(1).toMap().value(QStringLiteral("spread")).toInt(), -6);

    QCOMPARE(theme.shadows()->small().first().toMap()
                 .value(QStringLiteral("opacity")).toReal(), 0.10);
    QCOMPARE(theme.shadows()->medium().first().toMap()
                 .value(QStringLiteral("opacity")).toReal(), 0.12);
    QCOMPARE(theme.shadows()->large().first().toMap()
                 .value(QStringLiteral("opacity")).toReal(), 0.14);

    // The hue the layers deliberately leave out has to exist and be theme-owned.
    QVERIFY(theme.colors()->surface()->shadow().isValid());
}

void tst_merce_theme_runtime_switch::defaultContextIsBundledAlGit()
{
    MerceTheme theme;

    QCOMPARE(theme.activeBrand(), QStringLiteral("algit"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.activeProfile(), QStringLiteral("cart"));
    QCOMPARE(theme.generation(), quint64(1));
    QVERIFY(theme.colors()->action()->primary()->container().isValid());
    QCOMPARE(theme.size()->control()->minimum(), 64);
    // Fails if size.content is dropped from the profile manifest or the loader,
    // which would silently fall back to the C++ default instead of erroring.
    QCOMPARE(theme.size()->content()->maxWidth(), 480);
    QCOMPARE(theme.state()->layer()->hover(), 0.08);
    QCOMPARE(theme.state()->layer()->focus(), 0.10);
    QCOMPARE(theme.state()->layer()->pressed(), 0.10);
    QCOMPARE(theme.state()->layer()->selected(), 0.12);
    QCOMPARE(theme.state()->disabled()->containerOpacity(), 0.12);
    QCOMPARE(theme.state()->disabled()->contentOpacity(), 0.38);
}

void tst_merce_theme_runtime_switch::
    successfulContextSwitchIsAtomicAndReevaluatesQmlBinding()
{
    MerceTheme theme;
    MerceColors *oldColors = theme.colors();
    MerceSpacing *oldSpacing = theme.spacing();
    MerceRadius *oldRadius = theme.radius();
    MerceTypography *oldTypography = theme.typography();
    MerceSize *oldSize = theme.size();
    MerceState *oldState = theme.state();
    const QColor oldPrimary = oldColors->action()->primary()->container();

    QQmlEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("testTheme"), &theme);
    QQmlComponent component(&engine);
    component.setData(R"(
        import QtQml
        QtObject {
            property var observed: testTheme.colors.action.primary.container
            property int observedControlMinimum: testTheme.size.control.minimum
            property real observedHoverOpacity: testTheme.state.layer.hover
        }
    )",
                      QUrl());
    QTRY_VERIFY2(component.isReady(), qPrintable(component.errorString()));
    std::unique_ptr<QObject> bindingObject(component.create());
    QVERIFY2(bindingObject, qPrintable(component.errorString()));
    QCOMPARE(bindingObject->property("observed").value<QColor>(), oldPrimary);
    QSignalSpy bindingChanged(bindingObject.get(), SIGNAL(observedChanged()));

    QSignalSpy colorsChanged(&theme, &MerceTheme::colorsChanged);
    QSignalSpy spacingChanged(&theme, &MerceTheme::spacingChanged);
    QSignalSpy radiusChanged(&theme, &MerceTheme::radiusChanged);
    QSignalSpy typographyChanged(&theme, &MerceTheme::typographyChanged);
    QSignalSpy sizeChanged(&theme, &MerceTheme::sizeChanged);
    QSignalSpy stateChanged(&theme, &MerceTheme::stateChanged);
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);
    QSignalSpy generationChanged(&theme, &MerceTheme::generationChanged);
    QStringList signalOrder;
    connect(&theme, &MerceTheme::colorsChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("colors")); });
    connect(&theme, &MerceTheme::spacingChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("spacing")); });
    connect(&theme, &MerceTheme::radiusChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("radius")); });
    connect(&theme, &MerceTheme::typographyChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("typography")); });
    connect(&theme, &MerceTheme::stateChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("state")); });
    connect(&theme, &MerceTheme::sizeChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("size")); });
    connect(&theme, &MerceTheme::activeThemeChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("active")); });
    connect(&theme, &MerceTheme::generationChanged, this,
            [&signalOrder] { signalOrder.append(QStringLiteral("generation")); });

    QVERIFY(theme.setContext(QStringLiteral("algit"),
                             QStringLiteral("dark"),
                             QStringLiteral("ops")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("algit"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.activeProfile(), QStringLiteral("ops"));
    QCOMPARE(colorsChanged.size(), 1);
    QCOMPARE(spacingChanged.size(), 1);
    QCOMPARE(radiusChanged.size(), 1);
    QCOMPARE(typographyChanged.size(), 1);
    QCOMPARE(sizeChanged.size(), 1);
    QCOMPARE(stateChanged.size(), 1);
    QCOMPARE(activeThemeChanged.size(), 1);
    QCOMPARE(generationChanged.size(), 1);
    QCOMPARE(signalOrder,
             QStringList({QStringLiteral("colors"),
                          QStringLiteral("spacing"),
                          QStringLiteral("radius"),
                          QStringLiteral("typography"),
                          QStringLiteral("state"),
                          QStringLiteral("size"),
                          QStringLiteral("active"),
                          QStringLiteral("generation")}));
    QCOMPARE(bindingChanged.size(), 1);
    QCOMPARE(bindingObject->property("observed").value<QColor>(),
             theme.colors()->action()->primary()->container());
    QCOMPARE(bindingObject->property("observedControlMinimum").toInt(), 40);
    QCOMPARE(bindingObject->property("observedHoverOpacity").toDouble(), 0.08);
    QVERIFY(theme.colors() != oldColors);
    QVERIFY(theme.spacing() != oldSpacing);
    QVERIFY(theme.radius() != oldRadius);
    QVERIFY(theme.typography() != oldTypography);
    QVERIFY(theme.size() != oldSize);
    QVERIFY(theme.state() != oldState);
}

void tst_merce_theme_runtime_switch::runtimeFailureKeepsLastKnownGoodContext()
{
    MerceTheme theme;
    const QString brand = theme.activeBrand();
    const QString mode = theme.activeMode();
    const QString profile = theme.activeProfile();
    const quint64 generation = theme.generation();
    MerceColors *colors = theme.colors();
    const QColor background = colors->surface()->canvas();

    QVERIFY(!theme.setContext(QStringLiteral("missing"),
                              QStringLiteral("dark"),
                              QStringLiteral("ops")));
    QCOMPARE(theme.activeBrand(), brand);
    QCOMPARE(theme.activeMode(), mode);
    QCOMPARE(theme.activeProfile(), profile);
    QCOMPARE(theme.generation(), generation);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.colors()->surface()->canvas(), background);
}

void tst_merce_theme_runtime_switch::invalidExternalStartupSourceKeepsBundledAlGit()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QJsonObject invalid = tenantBrand(QStringLiteral("customer"), QStringLiteral("#006B63"));
    invalid.insert(QStringLiteral("tenantBrandSchemaVersion"), 2);
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("customer.json")), invalid));

    MerceTheme theme;
    MerceColors *colors = theme.colors();
    const quint64 generation = theme.generation();
    QVERIFY(theme.addThemeSource(pathIn(dir, QStringLiteral("customer.json"))));
    QVERIFY(!theme.reloadThemes());

    QCOMPARE(theme.activeBrand(), QStringLiteral("algit"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.activeProfile(), QStringLiteral("cart"));
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.generation(), generation);
}

void tst_merce_theme_runtime_switch::failedActiveReloadKeepsSnapshot()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString tenantPath = pathIn(dir, QStringLiteral("customer.json"));
    QVERIFY(writeJson(tenantPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"))));

    MerceTheme theme;
    QVERIFY(theme.addThemeSource(tenantPath));
    QVERIFY(theme.reloadThemes());
    QVERIFY(theme.setContext(QStringLiteral("customer"),
                             QStringLiteral("light"),
                             QStringLiteral("cart")));
    MerceColors *colors = theme.colors();
    const QColor background = colors->surface()->canvas();
    const quint64 generation = theme.generation();

    QVERIFY(writeRaw(tenantPath, QByteArrayLiteral("{ corrupt")));
    QVERIFY(!theme.reloadThemes());
    QCOMPARE(theme.activeBrand(), QStringLiteral("customer"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.activeProfile(), QStringLiteral("cart"));
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.colors()->surface()->canvas(), background);
    QCOMPARE(theme.generation(), generation);
}

void tst_merce_theme_runtime_switch::duplicateBrandModeIsRejected()
{
    QTemporaryDir first;
    QTemporaryDir second;
    QVERIFY(first.isValid());
    QVERIFY(second.isValid());
    QVERIFY(writeJson(pathIn(first, QStringLiteral("customer.json")),
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"))));
    QVERIFY(writeJson(pathIn(second, QStringLiteral("customer.json")),
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#0057B8"))));

    MerceTheme theme;
    QVERIFY(theme.addThemeSource(pathIn(first, QStringLiteral("customer.json"))));
    QVERIFY(theme.addThemeSource(pathIn(second, QStringLiteral("customer.json"))));
    QVERIFY(!theme.reloadThemes());
    QCOMPARE(theme.activeBrand(), QStringLiteral("algit"));
    QCOMPARE(theme.generation(), quint64(1));
}

void tst_merce_theme_runtime_switch::failedClearKeepsActiveSourceRegistered()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString tenantPath = pathIn(dir, QStringLiteral("customer.json"));
    QVERIFY(writeJson(tenantPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"))));

    MerceTheme theme;
    QVERIFY(theme.addThemeSource(tenantPath));
    QVERIFY(theme.reloadThemes());
    QVERIFY(theme.setContext(QStringLiteral("customer"),
                             QStringLiteral("light"),
                             QStringLiteral("cart")));

    theme.clearThemeSources();
    QCOMPARE(theme.activeBrand(), QStringLiteral("customer"));
    QCOMPARE(theme.m_externalThemeSourcePaths, QStringList{QFileInfo(tenantPath).absoluteFilePath()});
    QVERIFY(theme.reloadThemes());
}

void tst_merce_theme_runtime_switch::missingBundledThemeFailsLoudly()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString missingIndex = pathIn(dir, QStringLiteral("missing-index.json"));
    QVERIFY_THROWS_EXCEPTION(std::runtime_error, [&] {
        MerceTheme invalidTheme(missingIndex);
    }());
}

void tst_merce_theme_runtime_switch::reentrantContextSwitchIsRejectedWithoutTearingSnapshot()
{
    MerceTheme theme;
    bool nestedResult = true;
    QString observedMode;
    QString observedProfile;
    const QMetaObject::Connection connection =
        connect(&theme, &MerceTheme::colorsChanged, this, [&] {
            observedMode = theme.activeMode();
            observedProfile = theme.activeProfile();
            nestedResult = theme.setContext(QStringLiteral("algit"),
                                            QStringLiteral("light"),
                                            QStringLiteral("cart"));
        });

    QVERIFY(theme.setContext(QStringLiteral("algit"),
                             QStringLiteral("dark"),
                             QStringLiteral("ops")));
    disconnect(connection);
    QVERIFY(!nestedResult);
    QCOMPARE(observedMode, QStringLiteral("dark"));
    QCOMPARE(observedProfile, QStringLiteral("ops"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.activeProfile(), QStringLiteral("ops"));
    QCOMPARE(theme.size()->control()->minimum(), 40);
}

void tst_merce_theme_runtime_switch::metaObjectContractUsesPointerNotifySignals()
{
    MerceTheme theme;
    const QMetaObject *metaObject = theme.metaObject();

    for (const char *propertyName :
         {"colors", "spacing", "radius", "typography", "size", "state"}) {
        const QMetaProperty property = propertyByName(metaObject, propertyName);
        QVERIFY(!property.isConstant());
        QVERIFY(property.hasNotifySignal());
    }
    QVERIFY(propertyByName(metaObject, "generation").hasNotifySignal());
    QVERIFY(propertyByName(metaObject, "activeProfile").hasNotifySignal());
}

QTEST_MAIN(tst_merce_theme_runtime_switch)

#include "tst_merce_theme_runtime_switch.moc"
