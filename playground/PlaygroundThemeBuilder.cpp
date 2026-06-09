#include "PlaygroundThemeBuilder.h"

#include <QDir>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>
#include <QStandardPaths>
#include <QtGlobal>

namespace {

QString defaultOutputRoot()
{
    const QString overrideRoot = qEnvironmentVariable("MERCE_PLAYGROUND_THEME_OUTPUT_DIR").trimmed();
    if (!overrideRoot.isEmpty())
        return QFileInfo(overrideRoot).absoluteFilePath();

    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!appData.isEmpty())
        return QDir(appData).filePath(QStringLiteral("themes"));

    return QDir(QDir::tempPath()).filePath(QStringLiteral("merce-playground/themes"));
}

QVariantMap requiredMap(const QVariantMap &request, const QString &key, QString *error)
{
    const QVariant value = request.value(key);
    if (!value.canConvert<QVariantMap>()) {
        *error = QStringLiteral("missing required object: %1").arg(key);
        return {};
    }

    const QVariantMap map = value.toMap();
    if (map.isEmpty())
        *error = QStringLiteral("empty required object: %1").arg(key);
    return map;
}

} // namespace

PlaygroundThemeBuilder::PlaygroundThemeBuilder(QObject *parent)
    : QObject(parent),
      m_outputRoot(defaultOutputRoot())
{
}

QVariantMap PlaygroundThemeBuilder::saveTheme(const QVariantMap &request) const
{
    const QString displayName = request.value(QStringLiteral("displayName")).toString().trimmed();
    const QString requestedTheme = request.value(QStringLiteral("theme")).toString().trimmed();
    const QString theme = slugify(requestedTheme.isEmpty() ? displayName : requestedTheme);
    const QString mode = slugify(request.value(QStringLiteral("mode")).toString().trimmed().isEmpty()
                                 ? QStringLiteral("custom")
                                 : request.value(QStringLiteral("mode")).toString());

    if (theme.isEmpty())
        return failure(QStringLiteral("theme name is required"));
    if (mode.isEmpty())
        return failure(QStringLiteral("theme mode is required"));

    QString error;
    const QVariantMap colors = requiredMap(request, QStringLiteral("colors"), &error);
    if (!error.isEmpty())
        return failure(error);
    const QVariantMap spacing = requiredMap(request, QStringLiteral("spacing"), &error);
    if (!error.isEmpty())
        return failure(error);
    const QVariantMap radius = requiredMap(request, QStringLiteral("radius"), &error);
    if (!error.isEmpty())
        return failure(error);
    const QVariantMap typography = requiredMap(request, QStringLiteral("typography"), &error);
    if (!error.isEmpty())
        return failure(error);

    QDir rootDir(m_outputRoot);
    if (!rootDir.mkpath(QStringLiteral(".")))
        return failure(QStringLiteral("could not create output directory: %1").arg(m_outputRoot));

    const QString themeDirectoryPath = rootDir.filePath(theme);
    QDir themeDir(themeDirectoryPath);
    if (!themeDir.mkpath(QStringLiteral(".")))
        return failure(QStringLiteral("could not create theme directory: %1").arg(themeDirectoryPath));

    const QString manifestFileName = QStringLiteral("%1.%2.json").arg(theme, mode);
    const QString manifestPath = themeDir.filePath(manifestFileName);
    const QString indexPath = themeDir.filePath(QStringLiteral("index.json"));

    QVariantMap manifest;
    manifest.insert(QStringLiteral("schemaVersion"), 1);
    manifest.insert(QStringLiteral("theme"), theme);
    manifest.insert(QStringLiteral("variant"), mode);
    manifest.insert(QStringLiteral("colors"), colors);
    manifest.insert(QStringLiteral("spacing"), spacing);
    manifest.insert(QStringLiteral("radius"), radius);
    manifest.insert(QStringLiteral("typography"), typography);

    if (!writeJsonFile(manifestPath, manifest, &error))
        return failure(error);

    QVariantMap themeEntry;
    themeEntry.insert(QStringLiteral("displayName"), displayName.isEmpty() ? theme : displayName);
    themeEntry.insert(QStringLiteral("defaultVariant"), mode);
    themeEntry.insert(QStringLiteral("variants"), QVariantMap{{mode, manifestFileName}});

    QVariantMap index;
    index.insert(QStringLiteral("schemaVersion"), 1);
    index.insert(QStringLiteral("defaultTheme"), theme);
    index.insert(QStringLiteral("themes"), QVariantMap{{theme, themeEntry}});

    if (!writeJsonFile(indexPath, index, &error))
        return failure(error);

    return {
        { QStringLiteral("ok"), true },
        { QStringLiteral("theme"), theme },
        { QStringLiteral("mode"), mode },
        { QStringLiteral("displayName"), themeEntry.value(QStringLiteral("displayName")) },
        { QStringLiteral("indexPath"), indexPath },
        { QStringLiteral("manifestPath"), manifestPath },
    };
}

QString PlaygroundThemeBuilder::slugify(const QString &value) const
{
    QString slug;
    bool lastWasSeparator = false;

    for (const QChar character : value.trimmed().toLower()) {
        if ((character >= QLatin1Char('a') && character <= QLatin1Char('z'))
            || (character >= QLatin1Char('0') && character <= QLatin1Char('9'))) {
            slug.append(character);
            lastWasSeparator = false;
        } else if (!lastWasSeparator && !slug.isEmpty()) {
            slug.append(QLatin1Char('-'));
            lastWasSeparator = true;
        }
    }

    while (slug.endsWith(QLatin1Char('-')))
        slug.chop(1);

    return slug.left(48);
}

QVariantMap PlaygroundThemeBuilder::failure(const QString &message) const
{
    return {
        { QStringLiteral("ok"), false },
        { QStringLiteral("error"), message },
    };
}

bool PlaygroundThemeBuilder::writeJsonFile(const QString &path, const QVariantMap &object, QString *error) const
{
    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        *error = QStringLiteral("could not open %1: %2").arg(path, file.errorString());
        return false;
    }

    const QJsonDocument document(QJsonObject::fromVariantMap(object));
    file.write(document.toJson(QJsonDocument::Indented));
    if (!file.commit()) {
        *error = QStringLiteral("could not write %1: %2").arg(path, file.errorString());
        return false;
    }

    return true;
}
