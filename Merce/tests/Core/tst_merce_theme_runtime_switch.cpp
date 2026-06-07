#include "MerceTheme.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QFontDatabase>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaProperty>
#include <QSignalSpy>
#include <QTemporaryDir>
#include <QVariantMap>
#include <QVariantList>
#include <QtTest/QtTest>

namespace {

bool writeJson(const QString &path, const QJsonObject &object)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    file.write(QJsonDocument(object).toJson(QJsonDocument::Compact));
    return true;
}

bool copyResource(const QString &resourcePath, const QString &targetPath)
{
    QFile::remove(targetPath);
    return QFile::copy(resourcePath, targetPath);
}

QJsonObject readJsonObject(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    return QJsonDocument::fromJson(file.readAll()).object();
}

QJsonObject themedManifestFromResource(const QString &resourcePath,
                                       const QString &themeName,
                                       const QString &variantName,
                                       const QString &backgroundBase,
                                       const QString &actionPrimary)
{
    QJsonObject manifest = readJsonObject(resourcePath);
    manifest.insert(QStringLiteral("theme"), themeName);
    if (variantName.isEmpty())
        manifest.remove(QStringLiteral("variant"));
    else
        manifest.insert(QStringLiteral("variant"), variantName);

    QJsonObject colors = manifest.value(QStringLiteral("colors")).toObject();
    QJsonObject background = colors.value(QStringLiteral("background")).toObject();
    background.insert(QStringLiteral("base"), backgroundBase);
    colors.insert(QStringLiteral("background"), background);

    QJsonObject action = colors.value(QStringLiteral("action")).toObject();
    action.insert(QStringLiteral("primary"), actionPrimary);
    colors.insert(QStringLiteral("action"), action);

    manifest.insert(QStringLiteral("colors"), colors);
    return manifest;
}

QString pathIn(QTemporaryDir &dir, const QString &fileName)
{
    return QDir(dir.path()).filePath(fileName);
}

QMetaProperty propertyByName(const QMetaObject *metaObject, const char *name)
{
    const int index = metaObject->indexOfProperty(name);
    Q_ASSERT(index >= 0);
    return metaObject->property(index);
}

QVariantMap mapByValue(const QVariantList &items, const QString &value)
{
    for (const QVariant &item : items) {
        const QVariantMap map = item.toMap();
        if (map.value(QStringLiteral("value")).toString() == value)
            return map;
    }
    return {};
}

} // namespace

class tst_merce_theme_runtime_switch : public QObject
{
    Q_OBJECT

private slots:
    void defaultStateIsMerceLight();
    void successfulSwitchesUpdateStateAndKeepObjectPointers();
    void invalidRequestsPreserveActiveStateAndValues();
    void registeredBrokenManifestAppliesFallbackState();
    void availableThemesExposeRegistryOptions();
    void externalThemeSourcesReloadAndClearAtRuntime();
    void metaObjectContractKeepsStablePointersAndValueNotifySignals();
};

void tst_merce_theme_runtime_switch::defaultStateIsMerceLight()
{
    MerceTheme theme;

    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
    QCOMPARE(theme.metaObject()->indexOfProperty("palette"), -1);
}

void tst_merce_theme_runtime_switch::successfulSwitchesUpdateStateAndKeepObjectPointers()
{
    MerceTheme theme;
    MerceColors *colors = theme.colors();
    MerceSpacing *spacing = theme.spacing();
    MerceRadius *radius = theme.radius();
    MerceTypography *typography = theme.typography();
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);

    QVERIFY(theme.setTheme(QStringLiteral("merce"), QStringLiteral("dark")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#1F1510")));
    QCOMPARE(activeThemeChanged.count(), 1);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    QVERIFY(theme.setTheme(QStringLiteral("merce"), QStringLiteral("light")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
    QCOMPARE(activeThemeChanged.count(), 2);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    QVERIFY(theme.setTheme(QStringLiteral("stripe")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("stripe"));
    QCOMPARE(theme.activeMode(), QString());
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#F6F9FC")));
    QCOMPARE(theme.radius()->button(), 8);
    QCOMPARE(activeThemeChanged.count(), 3);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    struct ReferenceThemeExpectation {
        QString brand;
        QColor backgroundBase;
        QColor actionPrimary;
        int buttonRadius;
    };

    const ReferenceThemeExpectation referenceThemes[] = {
        { QStringLiteral("apple"), QColor(QStringLiteral("#F5F5F7")), QColor(QStringLiteral("#0066CC")), 9999 },
        { QStringLiteral("claude"), QColor(QStringLiteral("#FAF9F5")), QColor(QStringLiteral("#CC785C")), 8 },
        { QStringLiteral("airbnb"), QColor(QStringLiteral("#FFFFFF")), QColor(QStringLiteral("#FF385C")), 8 },
    };

    int expectedSignalCount = activeThemeChanged.count();
    for (const ReferenceThemeExpectation &expectation : referenceThemes) {
        QVERIFY(theme.setTheme(expectation.brand));
        ++expectedSignalCount;
        QCOMPARE(theme.activeBrand(), expectation.brand);
        QCOMPARE(theme.activeMode(), QString());
        QCOMPARE(theme.colors()->background()->base(), expectation.backgroundBase);
        QCOMPARE(theme.colors()->action()->primary(), expectation.actionPrimary);
        QCOMPARE(theme.radius()->button(), expectation.buttonRadius);
        QCOMPARE(activeThemeChanged.count(), expectedSignalCount);
        QCOMPARE(theme.colors(), colors);
        QCOMPARE(theme.spacing(), spacing);
        QCOMPARE(theme.radius(), radius);
        QCOMPARE(theme.typography(), typography);
    }

    QVERIFY(theme.setTheme(QStringLiteral("linear")));
    ++expectedSignalCount;
    QCOMPARE(theme.activeBrand(), QStringLiteral("linear"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#08090A")));
    QCOMPARE(theme.colors()->action()->primary(), QColor(QStringLiteral("#5E6AD2")));
    QCOMPARE(theme.radius()->button(), 6);
    QCOMPARE(theme.typography()->fontBody(), QStringLiteral("Inter"));
    QCOMPARE(theme.typography()->fontMono(), QStringLiteral("IoskeleyMono Nerd Font"));
    QVERIFY(QFontDatabase::families().contains(QStringLiteral("IoskeleyMono Nerd Font")));
    QCOMPARE(activeThemeChanged.count(), expectedSignalCount);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    QVERIFY(theme.setTheme(QStringLiteral("linear"), QStringLiteral("light")));
    ++expectedSignalCount;
    QCOMPARE(theme.activeBrand(), QStringLiteral("linear"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#F7F8F8")));
    QCOMPARE(theme.colors()->text()->primary(), QColor(QStringLiteral("#08090A")));
    QCOMPARE(theme.colors()->action()->primaryHover(), QColor(QStringLiteral("#4B57C8")));
    QCOMPARE(activeThemeChanged.count(), expectedSignalCount);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);
}

void tst_merce_theme_runtime_switch::invalidRequestsPreserveActiveStateAndValues()
{
    MerceTheme theme;
    QVERIFY(theme.setTheme(QStringLiteral("stripe")));

    const QString activeBrand = theme.activeBrand();
    const QString activeMode = theme.activeMode();
    const QColor backgroundBase = theme.colors()->background()->base();
    const int buttonRadius = theme.radius()->button();
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);

    QVERIFY(!theme.setTheme(QStringLiteral("unknown"), QStringLiteral("dark")));
    QCOMPARE(theme.activeBrand(), activeBrand);
    QCOMPARE(theme.activeMode(), activeMode);
    QCOMPARE(theme.colors()->background()->base(), backgroundBase);
    QCOMPARE(theme.radius()->button(), buttonRadius);
    QCOMPARE(activeThemeChanged.count(), 0);

    QVERIFY(!theme.setTheme(QStringLiteral("merce"), QStringLiteral("unknown")));
    QCOMPARE(theme.activeBrand(), activeBrand);
    QCOMPARE(theme.activeMode(), activeMode);
    QCOMPARE(theme.colors()->background()->base(), backgroundBase);
    QCOMPARE(theme.radius()->button(), buttonRadius);
    QCOMPARE(activeThemeChanged.count(), 0);
}

void tst_merce_theme_runtime_switch::registeredBrokenManifestAppliesFallbackState()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QVERIFY(copyResource(QStringLiteral(":/merce/themes/merce.light.json"),
                         pathIn(dir, QStringLiteral("merce.light.json"))));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("broken.json")), QJsonObject{
        { QStringLiteral("schemaVersion"), 2 },
        { QStringLiteral("theme"), QStringLiteral("broken") },
    }));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), QJsonObject{
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("merce") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("merce"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Merce") },
                { QStringLiteral("defaultVariant"), QStringLiteral("light") },
                { QStringLiteral("variants"), QJsonObject{
                    { QStringLiteral("light"), QStringLiteral("merce.light.json") },
                } },
            } },
            { QStringLiteral("broken"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Broken") },
                { QStringLiteral("path"), QStringLiteral("broken.json") },
            } },
        } },
    }));

    MerceTheme theme(pathIn(dir, QStringLiteral("index.json")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));

    QVERIFY(theme.setTheme(QStringLiteral("broken")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
}

void tst_merce_theme_runtime_switch::availableThemesExposeRegistryOptions()
{
    MerceTheme theme;

    const QVariantList themes = theme.availableThemes();
    QCOMPARE(themes.size(), 6);

    const QVariantMap merce = mapByValue(themes, QStringLiteral("merce"));
    QCOMPARE(merce.value(QStringLiteral("label")).toString(), QStringLiteral("Merce"));
    QCOMPARE(merce.value(QStringLiteral("defaultMode")).toString(), QStringLiteral("light"));
    QCOMPARE(merce.value(QStringLiteral("hasModes")).toBool(), true);

    const QVariantList merceModes = merce.value(QStringLiteral("modes")).toList();
    QCOMPARE(merceModes.size(), 2);
    QVERIFY(!mapByValue(merceModes, QStringLiteral("light")).isEmpty());
    QVERIFY(!mapByValue(merceModes, QStringLiteral("dark")).isEmpty());

    const QVariantMap stripe = mapByValue(themes, QStringLiteral("stripe"));
    QCOMPARE(stripe.value(QStringLiteral("label")).toString(), QStringLiteral("Stripe Reference"));
    QCOMPARE(stripe.value(QStringLiteral("defaultMode")).toString(), QString());
    QCOMPARE(stripe.value(QStringLiteral("hasModes")).toBool(), false);
    QCOMPARE(stripe.value(QStringLiteral("modes")).toList().size(), 0);

    const QVariantMap apple = mapByValue(themes, QStringLiteral("apple"));
    QCOMPARE(apple.value(QStringLiteral("label")).toString(), QStringLiteral("Apple Reference"));
    QCOMPARE(apple.value(QStringLiteral("hasModes")).toBool(), false);

    const QVariantMap claude = mapByValue(themes, QStringLiteral("claude"));
    QCOMPARE(claude.value(QStringLiteral("label")).toString(), QStringLiteral("Claude Reference"));
    QCOMPARE(claude.value(QStringLiteral("hasModes")).toBool(), false);

    const QVariantMap airbnb = mapByValue(themes, QStringLiteral("airbnb"));
    QCOMPARE(airbnb.value(QStringLiteral("label")).toString(), QStringLiteral("Airbnb Reference"));
    QCOMPARE(airbnb.value(QStringLiteral("hasModes")).toBool(), false);

    const QVariantMap linear = mapByValue(themes, QStringLiteral("linear"));
    QCOMPARE(linear.value(QStringLiteral("label")).toString(), QStringLiteral("Linear Reference"));
    QCOMPARE(linear.value(QStringLiteral("defaultMode")).toString(), QStringLiteral("dark"));
    QCOMPARE(linear.value(QStringLiteral("hasModes")).toBool(), true);

    const QVariantList linearModes = linear.value(QStringLiteral("modes")).toList();
    QCOMPARE(linearModes.size(), 2);
    QCOMPARE(linearModes.constFirst().toMap().value(QStringLiteral("value")).toString(), QStringLiteral("dark"));
    QVERIFY(!mapByValue(linearModes, QStringLiteral("light")).isEmpty());
}

void tst_merce_theme_runtime_switch::externalThemeSourcesReloadAndClearAtRuntime()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("customer.dark.json")),
                      themedManifestFromResource(QStringLiteral(":/merce/themes/merce.dark.json"),
                                                 QStringLiteral("customer"),
                                                 QStringLiteral("dark"),
                                                 QStringLiteral("#101820"),
                                                 QStringLiteral("#44AAFF"))));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), QJsonObject{
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("customer") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("customer"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Customer Theme") },
                { QStringLiteral("defaultVariant"), QStringLiteral("dark") },
                { QStringLiteral("variants"), QJsonObject{
                    { QStringLiteral("dark"), QStringLiteral("customer.dark.json") },
                } },
            } },
        } },
    }));

    MerceTheme theme;
    QSignalSpy availableThemesChanged(&theme, &MerceTheme::availableThemesChanged);
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);

    QVERIFY(!theme.addThemeSource(QStringLiteral(":/merce/themes/index.json")));
    QVERIFY(theme.addThemeSource(pathIn(dir, QStringLiteral("index.json"))));
    QCOMPARE(availableThemesChanged.count(), 0);

    QVERIFY(theme.reloadThemes());
    QCOMPARE(availableThemesChanged.count(), 1);

    const QVariantMap customer = mapByValue(theme.availableThemes(), QStringLiteral("customer"));
    QCOMPARE(customer.value(QStringLiteral("label")).toString(), QStringLiteral("Customer Theme"));
    QCOMPARE(customer.value(QStringLiteral("defaultMode")).toString(), QStringLiteral("dark"));
    QCOMPARE(customer.value(QStringLiteral("hasModes")).toBool(), true);

    QVERIFY(theme.setTheme(QStringLiteral("customer")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("customer"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#101820")));
    QCOMPARE(theme.colors()->action()->primary(), QColor(QStringLiteral("#44AAFF")));
    QCOMPARE(activeThemeChanged.count(), 1);

    QTemporaryDir duplicateDir;
    QVERIFY(duplicateDir.isValid());
    QVERIFY(copyResource(QStringLiteral(":/merce/themes/stripe.json"),
                         pathIn(duplicateDir, QStringLiteral("stripe.json"))));
    QVERIFY(writeJson(pathIn(duplicateDir, QStringLiteral("index.json")), QJsonObject{
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("stripe") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("stripe"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Duplicate Stripe") },
                { QStringLiteral("path"), QStringLiteral("stripe.json") },
            } },
        } },
    }));

    const QVariantList themesBeforeDuplicateReload = theme.availableThemes();
    QVERIFY(theme.addThemeSource(pathIn(duplicateDir, QStringLiteral("index.json"))));
    QVERIFY(!theme.reloadThemes());
    QCOMPARE(theme.availableThemes(), themesBeforeDuplicateReload);
    QCOMPARE(theme.activeBrand(), QStringLiteral("customer"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#101820")));
    QCOMPARE(availableThemesChanged.count(), 1);
    QCOMPARE(activeThemeChanged.count(), 1);

    theme.clearThemeSources();
    QCOMPARE(availableThemesChanged.count(), 2);
    QCOMPARE(activeThemeChanged.count(), 2);
    QVERIFY(mapByValue(theme.availableThemes(), QStringLiteral("customer")).isEmpty());
    QVERIFY(!theme.setTheme(QStringLiteral("customer")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.colors()->background()->base(), QColor(QStringLiteral("#FAF8F6")));
}

void tst_merce_theme_runtime_switch::metaObjectContractKeepsStablePointersAndValueNotifySignals()
{
    MerceTheme theme;

    const QMetaObject *themeMetaObject = theme.metaObject();
    QCOMPARE(themeMetaObject->indexOfProperty("palette"), -1);
    QVERIFY(propertyByName(themeMetaObject, "colors").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "spacing").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "radius").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "typography").isConstant());
    QVERIFY(!propertyByName(themeMetaObject, "availableThemes").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "availableThemes").hasNotifySignal());

    QVERIFY(propertyByName(theme.colors()->background()->metaObject(), "base").hasNotifySignal());
    QVERIFY(propertyByName(theme.colors()->action()->metaObject(), "primary").hasNotifySignal());
    QVERIFY(propertyByName(theme.spacing()->metaObject(), "md").hasNotifySignal());
    QVERIFY(propertyByName(theme.radius()->metaObject(), "button").hasNotifySignal());
    QVERIFY(propertyByName(theme.typography()->metaObject(), "fontBody").hasNotifySignal());
}

QTEST_MAIN(tst_merce_theme_runtime_switch)

#include "tst_merce_theme_runtime_switch.moc"
