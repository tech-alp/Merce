#include "MerceThemeManifestLoader.h"
#include "MerceThemeRegistry.h"
#include "ThemeValidator.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>
#include <QtTest/QtTest>

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

QJsonObject readJson(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return {};
    QJsonParseError error;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &error);
    return error.error == QJsonParseError::NoError && document.isObject()
        ? document.object() : QJsonObject{};
}

QString pathIn(const QTemporaryDir &dir, const QString &fileName)
{
    return QDir(dir.path()).filePath(fileName);
}

QJsonObject tenantBrand(const QString &brandId,
                        const QString &seed,
                        int schemaVersion = 1)
{
    return {
        {QStringLiteral("kind"), QStringLiteral("tenant-brand")},
        {QStringLiteral("tenantBrandSchemaVersion"), schemaVersion},
        {QStringLiteral("brandId"), brandId},
        {QStringLiteral("seed"), seed},
    };
}

bool containsError(const QStringList &errors, const QString &needle)
{
    for (const QString &error : errors) {
        if (error.contains(needle))
            return true;
    }
    return false;
}

} // namespace

class tst_merce_theme_manifest_loader : public QObject
{
    Q_OBJECT

private slots:
    void generatedResourceComposesColorAndProfileRegistries();
    void modeMissingFromABrandFallsBackToItsDefault();
    void bareTenantBrandSourceIsDiscoverable();
    void tenantSchemaVersionRejectsOlderAndNewer_data();
    void tenantSchemaVersionRejectsOlderAndNewer();
    void indexSchemaVersionRejectsOlderAndNewer_data();
    void indexSchemaVersionRejectsOlderAndNewer();
    void duplicateBrandModeIsRejectedWithoutProfileCoupling();
    void invalidProfileMetricsAreRejected();
    void invalidUnselectedResolvedThemeIsRejected();
    void oversizedDocumentIsRejected();
    void malformedJsonReportsMachineReadableError();
    void bundledThemesDeclareTheirTypefacesAndShipThem();
    void fontPathEscapingTheThemeDirectoryIsRejected();
};

// The bundled themes are the ones a device actually runs. If a brand names a
// family it does not ship, the runtime silently falls back and the product
// renders in the wrong typeface for as long as nobody looks closely — which is
// how Lexend went missing while every manifest claimed it.
void tst_merce_theme_manifest_loader::bundledThemesDeclareTheirTypefacesAndShipThem()
{
    const MerceThemeLoadResult result = MerceThemeManifestLoader().loadDefault();
    QVERIFY2(result.ok, qPrintable(result.errors.join(QStringLiteral("; "))));

    const QJsonObject typography =
        result.finalManifest.value(QStringLiteral("typography")).toObject();
    QVERIFY(!typography.value(QStringLiteral("bodyFont")).toString().trimmed().isEmpty());
    QVERIFY(!typography.value(QStringLiteral("displayFont")).toString().trimmed().isEmpty());
    QVERIFY(!typography.value(QStringLiteral("monoFont")).toString().trimmed().isEmpty());

    const QJsonArray fonts = result.finalManifest.value(QStringLiteral("fonts")).toArray();
    QVERIFY2(!fonts.isEmpty(), "a bundled theme must ship the font files it names");
    for (const QJsonValue &entry : fonts) {
        const QString relativePath = entry.toString();
        QVERIFY(!relativePath.isEmpty());
        QVERIFY2(QFile::exists(QStringLiteral(":/merce/themes/") + relativePath),
                 qPrintable(QStringLiteral("declared font is not bundled: ") + relativePath));
    }
}

// A manifest is data. It must not be able to point the font loader at a file
// outside the theme directory.
void tst_merce_theme_manifest_loader::fontPathEscapingTheThemeDirectoryIsRejected()
{
    for (const QString &path : {QStringLiteral("/etc/passwd"),
                                QStringLiteral("../../../etc/passwd"),
                                QStringLiteral("qrc:/elsewhere.ttf"),
                                QStringLiteral("  ")}) {
        QJsonObject document{
            {QStringLiteral("typography"),
             QJsonObject{{QStringLiteral("displayFont"), QStringLiteral("Lexend")},
                         {QStringLiteral("bodyFont"), QStringLiteral("Lexend")},
                         {QStringLiteral("monoFont"), QStringLiteral("JetBrains Mono")}}},
            {QStringLiteral("fonts"), QJsonArray{path}},
        };
        const ThemeValidationResult validation = ThemeValidator::validateResolvedTheme(document);
        QVERIFY2(!validation.ok, qPrintable(QStringLiteral("accepted unsafe path: ") + path));
    }
}

void tst_merce_theme_manifest_loader::
    generatedResourceComposesColorAndProfileRegistries()
{
    const MerceThemeLoadResult result = MerceThemeManifestLoader().loadDefault();

    QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
    QCOMPARE(result.brandId, QStringLiteral("algit"));
    QCOMPARE(result.mode, QStringLiteral("light"));
    QCOMPARE(result.profile, QStringLiteral("cart"));
    QCOMPARE(result.finalManifest.value(QStringLiteral("kind")).toString(),
             QStringLiteral("resolved-theme"));
    QVERIFY(result.finalManifest.value(QStringLiteral("colors")).isObject());
    QVERIFY(result.finalManifest.value(QStringLiteral("spacing")).isObject());
    QVERIFY(result.finalManifest.value(QStringLiteral("radius")).isObject());
    QVERIFY(result.finalManifest.value(QStringLiteral("typography")).isObject());
    QVERIFY(result.finalManifest.value(QStringLiteral("size")).isObject());

    const MerceThemeLoadResult ops =
        MerceThemeManifestLoader().load(QStringLiteral("algit"),
                                        QStringLiteral("dark"),
                                        QStringLiteral("ops"));
    QVERIFY2(ops.ok, qPrintable(ops.errors.join(QLatin1Char('\n'))));
    QCOMPARE(ops.profile, QStringLiteral("ops"));
    QVERIFY(ops.finalManifest.value(QStringLiteral("colors")).toObject()
                != QJsonObject{});
}

void tst_merce_theme_manifest_loader::modeMissingFromABrandFallsBackToItsDefault()
{
    // Migros ships light only, and a config that asks it for dark is a
    // plausible mistake. Refusing would drop the device profile with the
    // colours, leaving a kiosk with desktop-sized touch targets, so the brand's
    // own default answers instead and the resolved mode says what happened.
    const MerceThemeLoadResult result =
        MerceThemeManifestLoader().load(QStringLiteral("migros"),
                                        QStringLiteral("dark"),
                                        QStringLiteral("cart"));

    QVERIFY2(result.ok, qPrintable(result.errors.join(QLatin1Char('\n'))));
    QCOMPARE(result.brandId, QStringLiteral("migros"));
    QCOMPARE(result.mode, QStringLiteral("light"));
    QCOMPARE(result.profile, QStringLiteral("cart"));

    // An unregistered brand is still a failure: there is nothing to fall back to
    // that would not be another tenant's colours.
    const MerceThemeLoadResult unknown =
        MerceThemeManifestLoader().load(QStringLiteral("no-such-brand"),
                                        QStringLiteral("light"),
                                        QStringLiteral("cart"));
    QVERIFY(!unknown.ok);
}

void tst_merce_theme_manifest_loader::bareTenantBrandSourceIsDiscoverable()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString tenantPath = pathIn(dir, QStringLiteral("customer.json"));
    QVERIFY(writeJson(tenantPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"))));

    const MerceThemeRegistryLoadResult source =
        MerceThemeManifestLoader::loadRegistry(tenantPath);
    QVERIFY2(source.ok, qPrintable(source.errors.join(QLatin1Char('\n'))));
    QVERIFY(source.profileRegistry.isEmpty());
    QVERIFY(source.colorRegistry.lookup(QStringLiteral("customer"),
                                        QStringLiteral("light")).ok);
    QVERIFY(source.colorRegistry.lookup(QStringLiteral("customer"),
                                        QStringLiteral("dark")).ok);
}

void tst_merce_theme_manifest_loader::
    tenantSchemaVersionRejectsOlderAndNewer_data()
{
    QTest::addColumn<int>("version");
    QTest::newRow("older") << 0;
    QTest::newRow("newer") << 2;
}

void tst_merce_theme_manifest_loader::
    tenantSchemaVersionRejectsOlderAndNewer()
{
    QFETCH(int, version);
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString tenantPath = pathIn(dir, QStringLiteral("customer.json"));
    QVERIFY(writeJson(tenantPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"),
                                  version)));

    const MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadRegistry(tenantPath);
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("version")));
}

void tst_merce_theme_manifest_loader::
    indexSchemaVersionRejectsOlderAndNewer_data()
{
    QTest::addColumn<int>("version");
    QTest::newRow("older") << 0;
    QTest::newRow("newer") << 2;
}

void tst_merce_theme_manifest_loader::
    indexSchemaVersionRejectsOlderAndNewer()
{
    QFETCH(int, version);
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString indexPath = pathIn(dir, QStringLiteral("index.json"));
    QVERIFY(writeJson(indexPath, QJsonObject{
        {QStringLiteral("schemaVersion"), version},
        {QStringLiteral("brands"), QJsonObject{}},
    }));

    const MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadRegistry(indexPath);
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors,
                          QStringLiteral("index.unsupported_version")));
}

void tst_merce_theme_manifest_loader::
    duplicateBrandModeIsRejectedWithoutProfileCoupling()
{
    QTemporaryDir first;
    QTemporaryDir second;
    QVERIFY(first.isValid());
    QVERIFY(second.isValid());
    const QString firstPath = pathIn(first, QStringLiteral("customer.json"));
    const QString secondPath = pathIn(second, QStringLiteral("customer.json"));
    QVERIFY(writeJson(firstPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#006B63"))));
    QVERIFY(writeJson(secondPath,
                      tenantBrand(QStringLiteral("customer"),
                                  QStringLiteral("#0057B8"))));

    const MerceThemeRegistryLoadResult firstRegistry =
        MerceThemeManifestLoader::loadRegistry(firstPath);
    const MerceThemeRegistryLoadResult secondRegistry =
        MerceThemeManifestLoader::loadRegistry(secondPath);
    QVERIFY(firstRegistry.ok);
    QVERIFY(secondRegistry.ok);

    MerceThemeRegistry colors = firstRegistry.colorRegistry;
    QStringList errors;
    QVERIFY(!colors.appendRegistry(secondRegistry.colorRegistry, &errors));
    QVERIFY(containsError(errors, QStringLiteral("duplicate brand/mode")));

    MerceProfileRegistry profiles;
    QVERIFY(profiles.appendRegistry(firstRegistry.profileRegistry, &errors));
    QVERIFY(profiles.appendRegistry(secondRegistry.profileRegistry, &errors));
}

void tst_merce_theme_manifest_loader::malformedJsonReportsMachineReadableError()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString sourcePath = pathIn(dir, QStringLiteral("bad.json"));
    QVERIFY(writeRaw(sourcePath, QByteArrayLiteral("{ bad json")));

    const MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadRegistry(sourcePath);
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("parse_error")));
}

void tst_merce_theme_manifest_loader::invalidProfileMetricsAreRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QVERIFY(QDir(dir.path()).mkpath(QStringLiteral("themes")));
    QVERIFY(QDir(dir.path()).mkpath(QStringLiteral("profiles")));

    const QString themePath =
        pathIn(dir, QStringLiteral("themes/algit.light.json"));
    const QString profilePath =
        pathIn(dir, QStringLiteral("profiles/cart.json"));
    const QString indexPath =
        pathIn(dir, QStringLiteral("themes/index.json"));
    QVERIFY(writeJson(themePath, readJson(QStringLiteral(":/merce/themes/algit.light.json"))));

    const QJsonObject index{
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("defaultBrand"), QStringLiteral("algit")},
        {QStringLiteral("brands"),
         QJsonObject{{QStringLiteral("algit"),
                      QJsonObject{{QStringLiteral("defaultMode"), QStringLiteral("light")},
                                  {QStringLiteral("modes"),
                                   QJsonObject{{QStringLiteral("light"),
                                                QStringLiteral("algit.light.json")}}}}}}},
        {QStringLiteral("defaultProfile"), QStringLiteral("cart")},
        {QStringLiteral("profiles"),
         QJsonObject{{QStringLiteral("cart"),
                      QJsonObject{{QStringLiteral("path"), QStringLiteral("cart.json")}}}}},
    };
    QVERIFY(writeJson(indexPath, index));

    QJsonObject profile = readJson(QStringLiteral(":/merce/profiles/cart.json"));
    QJsonObject spacing = profile.value(QStringLiteral("spacing")).toObject();
    spacing.insert(QStringLiteral("md"), -1);
    profile.insert(QStringLiteral("spacing"), spacing);
    QVERIFY(writeJson(profilePath, profile));
    MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadMergedRegistry({indexPath});
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("profile.invalid_number")));

    profile = readJson(QStringLiteral(":/merce/profiles/cart.json"));
    QJsonObject size = profile.value(QStringLiteral("size")).toObject();
    size.insert(QStringLiteral("control"), QJsonObject{});
    profile.insert(QStringLiteral("size"), size);
    QVERIFY(writeJson(profilePath, profile));
    result = MerceThemeManifestLoader::loadMergedRegistry({indexPath});
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("profile.invalid_number")));

    profile = readJson(QStringLiteral(":/merce/profiles/cart.json"));
    QJsonObject radius = profile.value(QStringLiteral("radius")).toObject();
    radius.insert(QStringLiteral("medium"), 6.5);
    profile.insert(QStringLiteral("radius"), radius);
    QVERIFY(writeJson(profilePath, profile));
    result = MerceThemeManifestLoader::loadMergedRegistry({indexPath});
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("profile.invalid_number")));

    profile = readJson(QStringLiteral(":/merce/profiles/cart.json"));
    size = profile.value(QStringLiteral("size")).toObject();
    QJsonObject outline = size.value(QStringLiteral("outline")).toObject();
    outline.insert(QStringLiteral("focus"), 0);
    size.insert(QStringLiteral("outline"), outline);
    profile.insert(QStringLiteral("size"), size);
    QVERIFY(writeJson(profilePath, profile));
    result = MerceThemeManifestLoader::loadMergedRegistry({indexPath});
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("profile.invalid_number")));
}

void tst_merce_theme_manifest_loader::oversizedDocumentIsRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    const QString sourcePath = pathIn(dir, QStringLiteral("large.json"));
    QVERIFY(writeRaw(sourcePath, QByteArray(1024 * 1024 + 1, ' ')));

    const MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadRegistry(sourcePath);
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("too_large")));
}

void tst_merce_theme_manifest_loader::invalidUnselectedResolvedThemeIsRejected()
{
    QTemporaryDir dir;
    QVERIFY(dir.isValid());
    QVERIFY(QDir(dir.path()).mkpath(QStringLiteral("themes")));
    QVERIFY(QDir(dir.path()).mkpath(QStringLiteral("profiles")));

    const QJsonObject validTheme =
        readJson(QStringLiteral(":/merce/themes/algit.light.json"));
    QJsonObject invalidTheme = validTheme;
    invalidTheme.insert(QStringLiteral("brandId"), QStringLiteral("broken"));
    invalidTheme.insert(QStringLiteral("resolvedThemeSchemaVersion"), 2);
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("themes/algit.light.json")), validTheme));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("themes/broken.light.json")), invalidTheme));
    QVERIFY(writeJson(pathIn(dir, QStringLiteral("profiles/cart.json")),
                      readJson(QStringLiteral(":/merce/profiles/cart.json"))));

    const QJsonObject brandEntry{
        {QStringLiteral("defaultMode"), QStringLiteral("light")},
        {QStringLiteral("modes"),
         QJsonObject{{QStringLiteral("light"), QStringLiteral("algit.light.json")}}},
    };
    QJsonObject brokenEntry = brandEntry;
    brokenEntry.insert(
        QStringLiteral("modes"),
        QJsonObject{{QStringLiteral("light"), QStringLiteral("broken.light.json")}});
    const QJsonObject index{
        {QStringLiteral("schemaVersion"), 1},
        {QStringLiteral("defaultBrand"), QStringLiteral("algit")},
        {QStringLiteral("brands"),
         QJsonObject{{QStringLiteral("algit"), brandEntry},
                     {QStringLiteral("broken"), brokenEntry}}},
        {QStringLiteral("defaultProfile"), QStringLiteral("cart")},
        {QStringLiteral("profiles"),
         QJsonObject{{QStringLiteral("cart"),
                      QJsonObject{{QStringLiteral("path"), QStringLiteral("cart.json")}}}}},
    };
    const QString indexPath = pathIn(dir, QStringLiteral("themes/index.json"));
    QVERIFY(writeJson(indexPath, index));

    const MerceThemeRegistryLoadResult result =
        MerceThemeManifestLoader::loadMergedRegistry({indexPath});
    QVERIFY(!result.ok);
    QVERIFY(containsError(result.errors, QStringLiteral("unsupported_version")));
}

QTEST_MAIN(tst_merce_theme_manifest_loader)

#include "tst_merce_theme_manifest_loader.moc"
