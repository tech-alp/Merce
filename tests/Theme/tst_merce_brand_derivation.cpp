#include "BrandDerivation.h"
#include "ThemeValidator.h"
#include "cpp/utils/utils.h"

#include <QJsonObject>
#include <QtTest>

#include <algorithm>
#include <functional>

namespace {

QJsonValue valueAtPath(const QJsonObject &root, const QString &path)
{
    QJsonValue value(root);
    for (const QString &part : path.split(QLatin1Char('.')))
        value = value.toObject().value(part);
    return value;
}

QJsonObject withColorAtPath(const QJsonObject &root, const QString &path, const QString &color)
{
    const QStringList parts = path.split(QLatin1Char('.'));
    std::function<QJsonObject(const QJsonObject &, qsizetype)> replace =
        [&](const QJsonObject &object, qsizetype index) {
            QJsonObject result = object;
            const QString &part = parts.at(index);
            if (index == parts.size() - 1) {
                result.insert(part, color);
            } else {
                result.insert(part, replace(object.value(part).toObject(), index + 1));
            }
            return result;
        };
    return replace(root, 0);
}

QStringList triplePaths(const QJsonObject &colors)
{
    QStringList paths;
    std::function<void(const QJsonObject &, const QString &)> visit =
        [&](const QJsonObject &object, const QString &prefix) {
            if (object.contains(QStringLiteral("container"))
                && object.contains(QStringLiteral("content"))) {
                paths.append(prefix);
                return;
            }
            for (const QString &key : object.keys()) {
                if (object.value(key).isObject())
                    visit(object.value(key).toObject(),
                          prefix.isEmpty() ? key : prefix + QLatin1Char('.') + key);
            }
        };
    visit(colors, {});
    return paths;
}

bool hasError(const ThemeValidationResult &result, const QString &code, const QString &path = {})
{
    return std::any_of(result.errors.cbegin(),
                       result.errors.cend(),
                       [&](const ThemeValidationError &error) {
                           return error.code == code && (path.isEmpty() || error.path == path);
                       });
}

double toneOf(const QColor &color)
{
    return color.lightnessF() * 100.0;
}

QJsonObject resolvedDocument(const QJsonObject &colors, const QJsonObject &state)
{
    return {
        {QStringLiteral("kind"), QStringLiteral("resolved-theme")},
        {QStringLiteral("resolvedThemeSchemaVersion"), 1},
        {QStringLiteral("brandId"), QStringLiteral("test-brand")},
        {QStringLiteral("mode"), QStringLiteral("light")},
        {QStringLiteral("identity"),
         QJsonObject{{QStringLiteral("mark"), QStringLiteral("#8A2BE2")}}},
        {QStringLiteral("colors"), colors},
        {QStringLiteral("state"), state},
    };
}

} // namespace

class MerceBrandDerivationTest : public QObject
{
    Q_OBJECT

private slots:
    void seedCorpus_data();
    void seedCorpus();
    void explorationBrandSeeds_data();
    void explorationBrandSeeds();
    void derivesCompleteRoleVocabulary();
    void interactionDirectionIsModeAware();
    void validatesEveryGeneratedContainerContentPair();
    void rejectsContrastFailures();
    void rejectsStatusProximity();
    void rejectsTenantAuthoredAction();
    void rejectsUnknownTenantFields();
    void rejectsUnsupportedSchemaVersions_data();
    void rejectsUnsupportedSchemaVersions();
    void rejectsInvisibleAdjacentOutline();
    void rejectsInvalidStateOpacity();
};

void MerceBrandDerivationTest::seedCorpus_data()
{
    QTest::addColumn<QString>("seed");
    QTest::addColumn<BrandMode>("mode");
    QTest::addColumn<QString>("expectedDerivationError");

    QTest::newRow("white-light") << QStringLiteral("#FFFFFF") << BrandMode::Light
                                  << QStringLiteral("seed.deviation_exceeded");
    QTest::newRow("black-light") << QStringLiteral("#000000") << BrandMode::Light << QString();
    QTest::newRow("black-dark") << QStringLiteral("#000000") << BrandMode::Dark
                                 << QStringLiteral("seed.deviation_exceeded");
    QTest::newRow("mid-grey-light") << QStringLiteral("#777777") << BrandMode::Light << QString();
    QTest::newRow("saturated-yellow-light") << QStringLiteral("#FFD600") << BrandMode::Light
                                             << QStringLiteral("seed.deviation_exceeded");
    QTest::newRow("low-chroma-light") << QStringLiteral("#60736E") << BrandMode::Light << QString();
    QTest::newRow("error-red-light") << QStringLiteral("#B3261E") << BrandMode::Light << QString();
    QTest::newRow("malformed") << QStringLiteral("not-a-colour") << BrandMode::Light
                                << QStringLiteral("seed.invalid");
}

void MerceBrandDerivationTest::seedCorpus()
{
    QFETCH(QString, seed);
    QFETCH(BrandMode, mode);
    QFETCH(QString, expectedDerivationError);

    const BrandDerivationResult result = BrandDerivation::derive(QColor(seed), mode);
    if (!expectedDerivationError.isEmpty()) {
        QVERIFY(!result.ok);
        QCOMPARE(result.errorCode, expectedDerivationError);
        QVERIFY(!result.errorMessage.isEmpty());
        return;
    }

    QVERIFY2(result.ok, qPrintable(result.errorMessage));
    const ThemeValidationResult validation = ThemeValidator::validateColors(result.colors);
    if (!validation.ok)
        QVERIFY(hasError(validation, QStringLiteral("color.status_proximity")));
    if (seed == QStringLiteral("#B3261E"))
        QVERIFY(hasError(validation, QStringLiteral("color.status_proximity")));
}

void MerceBrandDerivationTest::explorationBrandSeeds_data()
{
    QTest::addColumn<QString>("seed");

    // Fixtures are the primary values authored by the five exploration themes
    // currently present under tools/design-tokens/tokens/themes/.
    QTest::newRow("linear") << QStringLiteral("#5E6AD2");
    QTest::newRow("stripe") << QStringLiteral("#635BFF");
    QTest::newRow("apple") << QStringLiteral("#0066CC");
    QTest::newRow("airbnb") << QStringLiteral("#FF385C");
    QTest::newRow("claude") << QStringLiteral("#CC785C");
}

void MerceBrandDerivationTest::explorationBrandSeeds()
{
    QFETCH(QString, seed);

    for (BrandMode mode : {BrandMode::Light, BrandMode::Dark}) {
        const BrandDerivationResult result = BrandDerivation::derive(QColor(seed), mode);
        if (!result.ok) {
            QCOMPARE(result.errorCode, QStringLiteral("seed.deviation_exceeded"));
            continue;
        }

        const ThemeValidationResult validation = ThemeValidator::validateColors(result.colors);
        if (!validation.ok) {
            QVERIFY(hasError(validation, QStringLiteral("color.status_proximity")));
        }
    }
}

void MerceBrandDerivationTest::derivesCompleteRoleVocabulary()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QVERIFY2(result.ok, qPrintable(result.errorMessage));

    const QJsonObject colors = result.colors;
    QCOMPARE(colors.value(QStringLiteral("surface")).toObject().size(), 9);
    QCOMPARE(colors.value(QStringLiteral("content")).toObject().size(), 6);
    QCOMPARE(colors.value(QStringLiteral("action")).toObject().size(), 3);
    QCOMPARE(colors.value(QStringLiteral("status")).toObject().size(), 5);
    QCOMPARE(colors.value(QStringLiteral("outline")).toObject().size(), 3);

    for (const QString &path : triplePaths(colors)) {
        const QJsonObject triple = valueAtPath(colors, path).toObject();
        const QStringList tripleKeys = triple.keys();
        const QSet<QString> keys(tripleKeys.cbegin(), tripleKeys.cend());
        QCOMPARE(keys,
                 QSet<QString>({QStringLiteral("container"),
                                QStringLiteral("content"),
                                QStringLiteral("outline")}));
    }

    QCOMPARE(9 + 6 + triplePaths(colors).size() * 3 + 3, 42);
    QCOMPARE(result.state.value(QStringLiteral("layer")).toObject().size(), 4);
    QCOMPARE(result.state.value(QStringLiteral("disabled")).toObject().size(), 2);
    QVERIFY(ThemeValidator::validateResolvedTheme(
                resolvedDocument(result.colors, result.state))
                .ok);

    QJsonObject action = colors.value(QStringLiteral("action")).toObject();
    action.insert(QStringLiteral("primaryPressed"), QStringLiteral("#000000"));
    QJsonObject unexpected = colors;
    unexpected.insert(QStringLiteral("action"), action);
    QVERIFY(hasError(ThemeValidator::validateColors(unexpected),
                     QStringLiteral("schema.unexpected_role"),
                     QStringLiteral("colors.action.primaryPressed")));
}

void MerceBrandDerivationTest::interactionDirectionIsModeAware()
{
    const QColor seed(QStringLiteral("#8A2BE2"));
    const BrandDerivationResult light = BrandDerivation::derive(seed, BrandMode::Light);
    const BrandDerivationResult dark = BrandDerivation::derive(seed, BrandMode::Dark);
    QVERIFY(light.ok);
    QVERIFY(dark.ok);
    QVERIFY2(ThemeValidator::validateColors(light.colors).ok, "light colors must pass the gate");
    QVERIFY2(ThemeValidator::validateColors(dark.colors).ok, "dark colors must pass the gate");

    const double lightBase = toneOf(
        QColor(valueAtPath(light.colors, QStringLiteral("action.primary.container")).toString()));
    QVERIFY(toneOf(light.hoverContainer) < lightBase);
    QVERIFY(toneOf(light.pressedContainer) < toneOf(light.hoverContainer));

    const double darkBase = toneOf(
        QColor(valueAtPath(dark.colors, QStringLiteral("action.primary.container")).toString()));
    QVERIFY(toneOf(dark.hoverContainer) > darkBase);
    QVERIFY(toneOf(dark.pressedContainer) > toneOf(dark.hoverContainer));

    const BrandDerivationResult black =
        BrandDerivation::derive(QColor(QStringLiteral("#000000")), BrandMode::Light);
    QVERIFY(black.ok);
    const double blackBase = toneOf(
        QColor(valueAtPath(black.colors, QStringLiteral("action.primary.container")).toString()));
    QVERIFY(toneOf(black.hoverContainer) < blackBase);
    QVERIFY(toneOf(black.pressedContainer) < toneOf(black.hoverContainer));

    const BrandDerivationResult white =
        BrandDerivation::derive(QColor(QStringLiteral("#FFFFFF")), BrandMode::Dark);
    QVERIFY(white.ok);
    const double whiteBase = toneOf(
        QColor(valueAtPath(white.colors, QStringLiteral("action.primary.container")).toString()));
    QVERIFY(toneOf(white.hoverContainer) > whiteBase);
    QVERIFY(toneOf(white.pressedContainer) > toneOf(white.hoverContainer));
}

void MerceBrandDerivationTest::validatesEveryGeneratedContainerContentPair()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QVERIFY(result.ok);

    const QStringList paths = triplePaths(result.colors);
    QCOMPARE(paths.size(), 8);
    for (const QString &path : paths) {
        const QString container =
            valueAtPath(result.colors, path + QStringLiteral(".container")).toString();
        const QJsonObject invalid =
            withColorAtPath(result.colors, path + QStringLiteral(".content"), container);
        const ThemeValidationResult validation = ThemeValidator::validateColors(invalid);
        QVERIFY2(hasError(validation,
                          QStringLiteral("contrast.container_content"),
                          QStringLiteral("colors.%1.content").arg(path)),
                 qPrintable(path));
    }
}

void MerceBrandDerivationTest::rejectsContrastFailures()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QVERIFY(result.ok);

    QJsonObject colors = withColorAtPath(result.colors,
                                         QStringLiteral("content.primary"),
                                         valueAtPath(result.colors,
                                                     QStringLiteral("surface.canvas"))
                                             .toString());
    ThemeValidationResult validation = ThemeValidator::validateColors(colors);
    QVERIFY(hasError(validation,
                     QStringLiteral("contrast.body_primary"),
                     QStringLiteral("colors.content.primary")));

    colors = withColorAtPath(result.colors,
                             QStringLiteral("action.primary.container"),
                             valueAtPath(result.colors, QStringLiteral("surface.canvas")).toString());
    validation = ThemeValidator::validateColors(colors);
    QVERIFY(hasError(validation,
                     QStringLiteral("contrast.non_text"),
                     QStringLiteral("colors.action.primary.container")));

    colors = withColorAtPath(result.colors,
                             QStringLiteral("action.primary.container"),
                             QStringLiteral("#00FFFFFF"));
    validation = ThemeValidator::validateColors(colors);
    QVERIFY(hasError(validation,
                     QStringLiteral("schema.invalid_color"),
                     QStringLiteral("colors.action.primary.container")));
}

void MerceBrandDerivationTest::rejectsStatusProximity()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#B3261E")), BrandMode::Light);
    QVERIFY(result.ok);

    const ThemeValidationResult validation = ThemeValidator::validateColors(result.colors);
    QVERIFY(hasError(validation,
                     QStringLiteral("color.status_proximity"),
                     QStringLiteral("colors.action.primary.container")));
}

void MerceBrandDerivationTest::rejectsTenantAuthoredAction()
{
    const QJsonObject document{
        {QStringLiteral("kind"), QStringLiteral("tenant-brand")},
        {QStringLiteral("tenantBrandSchemaVersion"), 1},
        {QStringLiteral("brandId"), QStringLiteral("tenant")},
        {QStringLiteral("seed"), QStringLiteral("#8A2BE2")},
        {QStringLiteral("action"),
         QJsonObject{{QStringLiteral("primary"),
                      QJsonObject{{QStringLiteral("container"), QStringLiteral("#000000")}}}}},
    };

    ThemeValidationResult validation = ThemeValidator::validateTenantBrand(document);
    QVERIFY(!validation.ok);
    QVERIFY(hasError(validation,
                     QStringLiteral("tenant.forbidden_action"),
                     QStringLiteral("action")));

    QJsonObject nestedDocument = document;
    nestedDocument.remove(QStringLiteral("action"));
    nestedDocument.insert(
        QStringLiteral("colors"),
        QJsonObject{{QStringLiteral("action"),
                     QJsonObject{{QStringLiteral("primary"),
                                  QJsonObject{{QStringLiteral("container"),
                                               QStringLiteral("#000000")}}}}}});
    validation = ThemeValidator::validateTenantBrand(nestedDocument);
    QVERIFY(hasError(validation,
                     QStringLiteral("tenant.forbidden_action"),
                     QStringLiteral("colors.action")));
}

void MerceBrandDerivationTest::rejectsUnknownTenantFields()
{
    QJsonObject document = {
        {QStringLiteral("kind"), QStringLiteral("tenant-brand")},
        {QStringLiteral("tenantBrandSchemaVersion"), 1},
        {QStringLiteral("brandId"), QStringLiteral("tenant")},
        {QStringLiteral("seed"), QStringLiteral("#8A2BE2")},
        {QStringLiteral("identity"),
         QJsonObject{{QStringLiteral("mark"), QStringLiteral("#000000")}}},
    };

    const ThemeValidationResult validation = ThemeValidator::validateTenantBrand(document);
    QVERIFY(hasError(validation,
                     QStringLiteral("schema.unexpected_role"),
                     QStringLiteral("tenant-brand.identity")));

    QCOMPARE(QString::fromStdString(material_color_utilities::HexFromArgb(0x00000123u)),
             QStringLiteral("123"));
}

void MerceBrandDerivationTest::rejectsUnsupportedSchemaVersions_data()
{
    QTest::addColumn<int>("version");

    QTest::newRow("older") << 0;
    QTest::newRow("newer") << 2;
}

void MerceBrandDerivationTest::rejectsUnsupportedSchemaVersions()
{
    QFETCH(int, version);

    QJsonObject tenant = {
        {QStringLiteral("kind"), QStringLiteral("tenant-brand")},
        {QStringLiteral("tenantBrandSchemaVersion"), version},
        {QStringLiteral("brandId"), QStringLiteral("tenant")},
        {QStringLiteral("seed"), QStringLiteral("#8A2BE2")},
    };
    ThemeValidationResult validation = ThemeValidator::validateTenantBrand(tenant);
    QVERIFY(hasError(validation,
                     QStringLiteral("schema.unsupported_version"),
                     QStringLiteral("tenantBrandSchemaVersion")));

    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QJsonObject resolved = resolvedDocument(result.colors, result.state);
    resolved.insert(QStringLiteral("resolvedThemeSchemaVersion"), version);
    validation = ThemeValidator::validateResolvedTheme(resolved);
    QVERIFY(hasError(validation,
                     QStringLiteral("schema.unsupported_version"),
                     QStringLiteral("resolvedThemeSchemaVersion")));
}

void MerceBrandDerivationTest::rejectsInvisibleAdjacentOutline()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QVERIFY(result.ok);

    const QJsonObject colors =
        withColorAtPath(result.colors,
                        QStringLiteral("action.primary.outline"),
                        valueAtPath(result.colors, QStringLiteral("surface.canvas")).toString());
    const ThemeValidationResult validation = ThemeValidator::validateColors(colors);
    QVERIFY(hasError(validation,
                     QStringLiteral("outline.invisible_adjacent"),
                     QStringLiteral("colors.action.primary.outline")));

    const QJsonObject nearInvisible =
        withColorAtPath(result.colors,
                        QStringLiteral("action.primary.outline"),
                        QStringLiteral("#F5F3ED"));
    QVERIFY(hasError(ThemeValidator::validateColors(nearInvisible),
                     QStringLiteral("outline.invisible_adjacent"),
                     QStringLiteral("colors.action.primary.outline")));
}

void MerceBrandDerivationTest::rejectsInvalidStateOpacity()
{
    const BrandDerivationResult result =
        BrandDerivation::derive(QColor(QStringLiteral("#8A2BE2")), BrandMode::Light);
    QVERIFY(result.ok);

    QJsonObject invalidState = result.state;
    QJsonObject layer = invalidState.value(QStringLiteral("layer")).toObject();
    layer.insert(QStringLiteral("hover"), 1.1);
    invalidState.insert(QStringLiteral("layer"), layer);

    const ThemeValidationResult validation =
        ThemeValidator::validateResolvedTheme(
            resolvedDocument(result.colors, invalidState));
    QVERIFY(hasError(validation,
                     QStringLiteral("schema.invalid_opacity"),
                     QStringLiteral("state.layer.hover")));
}

QTEST_APPLESS_MAIN(MerceBrandDerivationTest)

#include "tst_merce_brand_derivation.moc"
