#include "MerceTheme.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaProperty>
#include <QSignalSpy>
#include <QTemporaryDir>
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

} // namespace

class tst_merce_theme_runtime_switch : public QObject
{
    Q_OBJECT

private slots:
    void defaultStateIsMerceLight();
    void successfulSwitchesUpdateStateAndKeepObjectPointers();
    void invalidRequestsPreserveActiveStateAndValues();
    void registeredBrokenManifestAppliesFallbackState();
    void metaObjectContractKeepsStablePointersAndValueNotifySignals();
};

void tst_merce_theme_runtime_switch::defaultStateIsMerceLight()
{
    MerceTheme theme;

    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.palette()->backgroundBase(), QColor(QStringLiteral("#FAF8F6")));
}

void tst_merce_theme_runtime_switch::successfulSwitchesUpdateStateAndKeepObjectPointers()
{
    MerceTheme theme;
    MercePalette *palette = theme.palette();
    MercePalette *colors = theme.colors();
    MerceSpacing *spacing = theme.spacing();
    MerceRadius *radius = theme.radius();
    MerceTypography *typography = theme.typography();
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);

    QVERIFY(theme.setTheme(QStringLiteral("merce"), QStringLiteral("dark")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme.palette()->backgroundBase(), QColor(QStringLiteral("#1F1510")));
    QCOMPARE(activeThemeChanged.count(), 1);
    QCOMPARE(theme.palette(), palette);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    QVERIFY(theme.setTheme(QStringLiteral("merce"), QStringLiteral("light")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("merce"));
    QCOMPARE(theme.activeMode(), QStringLiteral("light"));
    QCOMPARE(theme.palette()->backgroundBase(), QColor(QStringLiteral("#FAF8F6")));
    QCOMPARE(activeThemeChanged.count(), 2);
    QCOMPARE(theme.palette(), palette);
    QCOMPARE(theme.colors(), colors);
    QCOMPARE(theme.spacing(), spacing);
    QCOMPARE(theme.radius(), radius);
    QCOMPARE(theme.typography(), typography);

    QVERIFY(theme.setTheme(QStringLiteral("stripe")));
    QCOMPARE(theme.activeBrand(), QStringLiteral("stripe"));
    QCOMPARE(theme.activeMode(), QString());
    QCOMPARE(theme.palette()->backgroundBase(), QColor(QStringLiteral("#F6F9FC")));
    QCOMPARE(theme.radius()->button(), 8);
    QCOMPARE(activeThemeChanged.count(), 3);
    QCOMPARE(theme.palette(), palette);
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
    const QColor backgroundBase = theme.palette()->backgroundBase();
    const int buttonRadius = theme.radius()->button();
    QSignalSpy activeThemeChanged(&theme, &MerceTheme::activeThemeChanged);

    QVERIFY(!theme.setTheme(QStringLiteral("unknown"), QStringLiteral("dark")));
    QCOMPARE(theme.activeBrand(), activeBrand);
    QCOMPARE(theme.activeMode(), activeMode);
    QCOMPARE(theme.palette()->backgroundBase(), backgroundBase);
    QCOMPARE(theme.radius()->button(), buttonRadius);
    QCOMPARE(activeThemeChanged.count(), 0);

    QVERIFY(!theme.setTheme(QStringLiteral("merce"), QStringLiteral("unknown")));
    QCOMPARE(theme.activeBrand(), activeBrand);
    QCOMPARE(theme.activeMode(), activeMode);
    QCOMPARE(theme.palette()->backgroundBase(), backgroundBase);
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
    QCOMPARE(theme.palette()->backgroundBase(), QColor(QStringLiteral("#FAF8F6")));
}

void tst_merce_theme_runtime_switch::metaObjectContractKeepsStablePointersAndValueNotifySignals()
{
    MerceTheme theme;

    const QMetaObject *themeMetaObject = theme.metaObject();
    QVERIFY(propertyByName(themeMetaObject, "palette").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "colors").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "spacing").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "radius").isConstant());
    QVERIFY(propertyByName(themeMetaObject, "typography").isConstant());

    QVERIFY(propertyByName(theme.palette()->metaObject(), "backgroundBase").hasNotifySignal());
    QVERIFY(propertyByName(theme.spacing()->metaObject(), "md").hasNotifySignal());
    QVERIFY(propertyByName(theme.radius()->metaObject(), "button").hasNotifySignal());
    QVERIFY(propertyByName(theme.typography()->metaObject(), "fontBody").hasNotifySignal());
}

QTEST_MAIN(tst_merce_theme_runtime_switch)

#include "tst_merce_theme_runtime_switch.moc"
