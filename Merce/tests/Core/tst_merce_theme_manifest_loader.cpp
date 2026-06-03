#include "MerceThemeManifestLoader.h"
#include "MerceThemeRegistry.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>
#include <QtTest/QtTest>

namespace {

QJsonObject objectFromPairs(const QList<QPair<QString, QJsonValue>> &pairs)
{
    QJsonObject object;
    for (const auto &pair : pairs)
        object.insert(pair.first, pair.second);
    return object;
}

QJsonObject fullManifest(const QString &theme, const QString &variant = QString())
{
    QJsonObject manifest;
    manifest.insert(QStringLiteral("schemaVersion"), 1);
    manifest.insert(QStringLiteral("theme"), theme);
    if (!variant.isEmpty())
        manifest.insert(QStringLiteral("variant"), variant);

    manifest.insert(QStringLiteral("palette"), objectFromPairs({
        { QStringLiteral("textPrimary"), QStringLiteral("#111111") },
        { QStringLiteral("textSecondary"), QStringLiteral("#222222") },
        { QStringLiteral("textTertiary"), QStringLiteral("#333333") },
        { QStringLiteral("textInverse"), QStringLiteral("#ffffff") },
        { QStringLiteral("link"), QStringLiteral("#0000ff") },
        { QStringLiteral("backgroundBase"), QStringLiteral("#fafafa") },
        { QStringLiteral("backgroundSurface"), QStringLiteral("#ffffff") },
        { QStringLiteral("backgroundElevated"), QStringLiteral("#ffffff") },
        { QStringLiteral("backgroundHover"), QStringLiteral("#eeeeee") },
        { QStringLiteral("backgroundPressed"), QStringLiteral("#dddddd") },
        { QStringLiteral("actionPrimary"), QStringLiteral("#444444") },
        { QStringLiteral("actionPrimaryLight"), QStringLiteral("#555555") },
        { QStringLiteral("actionPrimaryDark"), QStringLiteral("#222222") },
        { QStringLiteral("actionSecondary"), QStringLiteral("#666666") },
        { QStringLiteral("borderBase"), QStringLiteral("#cccccc") },
        { QStringLiteral("borderStrong"), QStringLiteral("#999999") },
        { QStringLiteral("borderFocus"), QStringLiteral("#777777") },
        { QStringLiteral("statusError"), QStringLiteral("#ff0000") },
        { QStringLiteral("statusSuccess"), QStringLiteral("#00ff00") },
        { QStringLiteral("statusWarning"), QStringLiteral("#ffff00") },
        { QStringLiteral("statusInfo"), QStringLiteral("#0000ff") },
        { QStringLiteral("surfaceBase"), QStringLiteral("#ffffff") },
        { QStringLiteral("surfaceTinted"), QStringLiteral("#f0f0f0") },
    }));

    manifest.insert(QStringLiteral("spacing"), objectFromPairs({
        { QStringLiteral("base"), 8 },
        { QStringLiteral("none"), 0 },
        { QStringLiteral("xxs"), 4 },
        { QStringLiteral("xs"), 8 },
        { QStringLiteral("sm"), 12 },
        { QStringLiteral("md"), 16 },
        { QStringLiteral("lg"), 20 },
        { QStringLiteral("xl"), 24 },
        { QStringLiteral("xl2"), 32 },
        { QStringLiteral("xl3"), 40 },
        { QStringLiteral("xl4"), 48 },
        { QStringLiteral("xl5"), 64 },
        { QStringLiteral("xl6"), 80 },
        { QStringLiteral("componentGap"), 16 },
        { QStringLiteral("sectionGap"), 48 },
        { QStringLiteral("pagePadding"), 24 },
        { QStringLiteral("touchTarget"), 44 },
        { QStringLiteral("touchTargetCompact"), 36 },
        { QStringLiteral("gridGap"), 16 },
        { QStringLiteral("stackGap"), 12 },
        { QStringLiteral("inlineGap"), 8 },
    }));

    manifest.insert(QStringLiteral("radius"), objectFromPairs({
        { QStringLiteral("none"), 0 },
        { QStringLiteral("small"), 4 },
        { QStringLiteral("medium"), 8 },
        { QStringLiteral("large"), 12 },
        { QStringLiteral("xlarge"), 16 },
        { QStringLiteral("xxlarge"), 24 },
        { QStringLiteral("full"), 9999 },
        { QStringLiteral("button"), 12 },
        { QStringLiteral("input"), 8 },
        { QStringLiteral("card"), 16 },
        { QStringLiteral("badge"), 9999 },
        { QStringLiteral("dialog"), 24 },
        { QStringLiteral("tooltip"), 4 },
    }));

    manifest.insert(QStringLiteral("typography"), objectFromPairs({
        { QStringLiteral("displayFont"), QStringLiteral("Display") },
        { QStringLiteral("bodyFont"), QStringLiteral("Body") },
        { QStringLiteral("monoFont"), QStringLiteral("Mono") },
        { QStringLiteral("displayFontFallback"), QStringLiteral("serif") },
        { QStringLiteral("bodyFontFallback"), QStringLiteral("sans-serif") },
        { QStringLiteral("sizeXSmall"), 12 },
        { QStringLiteral("sizeSmall"), 14 },
        { QStringLiteral("sizeMedium"), 16 },
        { QStringLiteral("sizeLarge"), 18 },
        { QStringLiteral("sizeXLarge"), 20 },
        { QStringLiteral("size2XLarge"), 24 },
        { QStringLiteral("size3XLarge"), 30 },
        { QStringLiteral("size4XLarge"), 36 },
        { QStringLiteral("size5XLarge"), 48 },
        { QStringLiteral("size6XLarge"), 60 },
        { QStringLiteral("size7XLarge"), 72 },
        { QStringLiteral("weightRegular"), 400 },
        { QStringLiteral("weightMedium"), 500 },
        { QStringLiteral("weightSemibold"), 600 },
        { QStringLiteral("weightBold"), 700 },
        { QStringLiteral("leadingTight"), 1.2 },
        { QStringLiteral("leadingSnug"), 1.35 },
        { QStringLiteral("leadingNormal"), 1.5 },
        { QStringLiteral("leadingRelaxed"), 1.7 },
        { QStringLiteral("trackingTight"), -0.02 },
        { QStringLiteral("trackingNormal"), 0 },
        { QStringLiteral("trackingWide"), 0.02 },
        { QStringLiteral("trackingWider"), 0.05 },
        { QStringLiteral("trackingWidest"), 0.1 },
    }));

    return manifest;
}

QJsonObject indexForDefaultMerce(const QString &defaultPath)
{
    return {
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("merce") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("merce"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Merce") },
                { QStringLiteral("defaultVariant"), QStringLiteral("light") },
                { QStringLiteral("variants"), QJsonObject{
                    { QStringLiteral("light"), defaultPath },
                } },
            } },
        } },
    };
}

bool writeJson(const QString &path, const QJsonObject &object)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    file.write(QJsonDocument(object).toJson(QJsonDocument::Compact));
    return true;
}

bool writeRaw(const QString &path, const QByteArray &raw)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return false;
    file.write(raw);
    return true;
}

bool containsError(const QStringList &errors, const QString &needle)
{
    for (const QString &error : errors) {
        if (error.contains(needle))
            return true;
    }
    return false;
}

QString pathIn(QTemporaryDir &dir, const QString &fileName)
{
    return QDir(dir.path()).filePath(fileName);
}

} // namespace

class tst_merce_theme_manifest_loader : public QObject
{
    Q_OBJECT

private slots:
    void generatedResourceIndexLoads();
    void unknownThemeIsRejected();
    void unknownVariantIsRejected();
    void unsafeManifestPathsAreRejected_data();
    void unsafeManifestPathsAreRejected();
    void malformedJsonReportsParseError();
    void schemaVersionMismatchIsRejected();
    void activePaletteCannotBorrowMissingFieldsFromBase();
    void basePlusActiveSectionOverlaySucceeds();
    void requestedBadManifestFallsBackToRegistryDefault();
    void brokenDefaultReturnsFailure();
};

void tst_merce_theme_manifest_loader::generatedResourceIndexLoads()
{
    const MerceThemeLoadResult result = MerceThemeManifestLoader().loadDefault();

    QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
    QCOMPARE(result.theme, QStringLiteral("merce"));
    QCOMPARE(result.variant, QStringLiteral("light"));
    QVERIFY(result.finalManifest.contains(QStringLiteral("palette")));
}

void tst_merce_theme_manifest_loader::unknownThemeIsRejected()
{
    const MerceThemeLoadResult result = MerceThemeManifestLoader().load(QStringLiteral("unknown"));

    QVERIFY(!result.ok);
    QVERIFY(!result.usedFallback);
    QVERIFY(containsError(result.errors, QStringLiteral("theme 'unknown' is not registered")));
}

void tst_merce_theme_manifest_loader::unknownVariantIsRejected()
{
    const MerceThemeLoadResult result = MerceThemeManifestLoader().load(QStringLiteral("merce"), QStringLiteral("unknown"));

    QVERIFY(!result.ok);
    QVERIFY(!result.usedFallback);
    QVERIFY(containsError(result.errors, QStringLiteral("variant 'unknown' is not registered")));
}

void tst_merce_theme_manifest_loader::unsafeManifestPathsAreRejected_data()
{
    QTest::addColumn<QString>("manifestPath");

    QTest::newRow("absolute") << QStringLiteral("/tmp/merce.json");
    QTest::newRow("parent-directory") << QStringLiteral("../merce.json");
    QTest::newRow("slash-separated") << QStringLiteral("merce/light.json");
    QTest::newRow("resource-indirection") << QStringLiteral(":/outside.json");
}

void tst_merce_theme_manifest_loader::unsafeManifestPathsAreRejected()
{
    QFETCH(QString, manifestPath);

    const QJsonObject index = indexForDefaultMerce(manifestPath);
    const MerceThemeRegistryResult result = MerceThemeRegistry::fromJson(index, QStringLiteral(":/merce/themes/index.json"));

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, manifestPath));
}

void tst_merce_theme_manifest_loader::malformedJsonReportsParseError()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QVERIFY(writeRaw(pathIn(dir, QStringLiteral("index.json")), QByteArray("{ bad json")));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("parse error at byte")));
}

void tst_merce_theme_manifest_loader::schemaVersionMismatchIsRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QJsonObject manifest = fullManifest(QStringLiteral("merce"), QStringLiteral("light"));
    manifest.insert(QStringLiteral("schemaVersion"), 2);
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), manifest));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), indexForDefaultMerce(QStringLiteral("merce.light.json"))));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("schemaVersion must be 1")));
}

void tst_merce_theme_manifest_loader::activePaletteCannotBorrowMissingFieldsFromBase()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QVERIFY(writeJson(pathIn(dir, QStringLiteral("base.json")), fullManifest(QStringLiteral("merce"))));

    QJsonObject active;
    active.insert(QStringLiteral("schemaVersion"), 1);
    active.insert(QStringLiteral("theme"), QStringLiteral("merce"));
    active.insert(QStringLiteral("variant"), QStringLiteral("light"));
    active.insert(QStringLiteral("palette"), QJsonObject{
        { QStringLiteral("textPrimary"), QStringLiteral("#000000") },
    });
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("active.json")), active));

    const QJsonObject index = {
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("merce") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("merce"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Merce") },
                { QStringLiteral("basePath"), QStringLiteral("base.json") },
                { QStringLiteral("defaultVariant"), QStringLiteral("light") },
                { QStringLiteral("variants"), QJsonObject{
                    { QStringLiteral("light"), QStringLiteral("active.json") },
                } },
            } },
        } },
    };
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), index));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("missing required runtime field: palette.textSecondary")));
    QVERIFY(!containsError(result.errors, QStringLiteral("missing required runtime field: spacing.md")));
}

void tst_merce_theme_manifest_loader::basePlusActiveSectionOverlaySucceeds()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QJsonObject base = fullManifest(QStringLiteral("merce"));
    QJsonObject baseSpacing = base.value(QStringLiteral("spacing")).toObject();
    baseSpacing.insert(QStringLiteral("md"), 24);
    base.insert(QStringLiteral("spacing"), baseSpacing);
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("base.json")), base));

    QJsonObject active;
    active.insert(QStringLiteral("schemaVersion"), 1);
    active.insert(QStringLiteral("theme"), QStringLiteral("merce"));
    active.insert(QStringLiteral("variant"), QStringLiteral("light"));
    active.insert(QStringLiteral("palette"), fullManifest(QStringLiteral("merce"), QStringLiteral("light")).value(QStringLiteral("palette")));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("active.json")), active));

    const QJsonObject index = {
        { QStringLiteral("schemaVersion"), 1 },
        { QStringLiteral("defaultTheme"), QStringLiteral("merce") },
        { QStringLiteral("themes"), QJsonObject{
            { QStringLiteral("merce"), QJsonObject{
                { QStringLiteral("displayName"), QStringLiteral("Merce") },
                { QStringLiteral("basePath"), QStringLiteral("base.json") },
                { QStringLiteral("defaultVariant"), QStringLiteral("light") },
                { QStringLiteral("variants"), QJsonObject{
                    { QStringLiteral("light"), QStringLiteral("active.json") },
                } },
            } },
        } },
    };
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), index));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
    QCOMPARE(result.finalManifest.value(QStringLiteral("spacing")).toObject().value(QStringLiteral("md")).toInt(), 24);
    QCOMPARE(result.finalManifest.value(QStringLiteral("variant")).toString(), QStringLiteral("light"));
}

void tst_merce_theme_manifest_loader::requestedBadManifestFallsBackToRegistryDefault()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), fullManifest(QStringLiteral("merce"), QStringLiteral("light"))));

    QJsonObject broken = fullManifest(QStringLiteral("broken"));
    broken.insert(QStringLiteral("schemaVersion"), 2);
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("broken.json")), broken));

    const QJsonObject index = {
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
    };
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), index));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).load(QStringLiteral("broken"));

    QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
    QVERIFY(result.usedFallback);
    QCOMPARE(result.theme, QStringLiteral("merce"));
    QCOMPARE(result.variant, QStringLiteral("light"));
    QVERIFY(containsError(result.errors, QStringLiteral("schemaVersion must be 1")));
}

void tst_merce_theme_manifest_loader::brokenDefaultReturnsFailure()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());

    QJsonObject manifest = fullManifest(QStringLiteral("merce"), QStringLiteral("light"));
    manifest.remove(QStringLiteral("palette"));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("merce.light.json")), manifest));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("index.json")), indexForDefaultMerce(QStringLiteral("merce.light.json"))));

    const MerceThemeLoadResult result = MerceThemeManifestLoader(pathIn(dir, QStringLiteral("index.json"))).loadDefault();

    QVERIFY(!result.ok);
    QVERIFY(!result.usedFallback);
    QVERIFY(containsError(result.errors, QStringLiteral("missing required field: palette")));
}

QTEST_MAIN(tst_merce_theme_manifest_loader)

#include "tst_merce_theme_manifest_loader.moc"
