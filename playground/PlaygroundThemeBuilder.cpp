#include "PlaygroundThemeBuilder.h"

#include <QDir>
#include <QFileInfo>
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

} // namespace

PlaygroundThemeBuilder::PlaygroundThemeBuilder(QObject *parent)
    : QObject(parent),
      m_outputRoot(defaultOutputRoot())
{
}

QVariantMap PlaygroundThemeBuilder::saveTheme(const QVariantMap &request) const
{
    Q_UNUSED(request);
    return failure(QStringLiteral(
        "custom resolved-theme authoring is disabled; tenant-brand v1 accepts only brandId and seed"));
}

QVariantMap PlaygroundThemeBuilder::failure(const QString &message) const
{
    return {
        { QStringLiteral("ok"), false },
        { QStringLiteral("error"), message },
    };
}
