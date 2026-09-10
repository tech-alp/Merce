#include "PlaygroundThemeBuilder.h"

#include <QDebug>
#include <QCoreApplication>
#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QIODevice>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

static QVariantList loadIconCodepoints(const QString &resourcePath)
{
    QFile file(resourcePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning().noquote() << "Could not load icon codepoints:" << resourcePath << file.errorString();
        return {};
    }

    QVariantList icons;
    while (!file.atEnd()) {
        const QString line = QString::fromUtf8(file.readLine()).trimmed();
        if (line.isEmpty())
            continue;

        const qsizetype separator = line.indexOf(QLatin1Char(' '));
        const QString name = separator >= 0 ? line.left(separator) : line;
        const QString codepoint = separator >= 0 ? line.sliced(separator + 1).trimmed() : QString();
        if (name.isEmpty())
            continue;

        QVariantMap icon;
        icon.insert(QStringLiteral("name"), name);
        icon.insert(QStringLiteral("codepoint"), codepoint);
        icons.append(icon);
    }

    return icons;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Merce Playground"));
    parser.addHelpOption();

    const QCommandLineOption themeProbeOption(QStringLiteral("theme-probe"),
                                              QStringLiteral("Run the theme smoke probe."));
    const QCommandLineOption themeSwitchProbeOption(QStringLiteral("theme-switch-probe"),
                                                    QStringLiteral("Run the runtime theme switch probe."));
    const QCommandLineOption playgroundProbeOption(QStringLiteral("playground-probe"),
                                                   QStringLiteral("Run the full playground probe."));
    const QCommandLineOption fontAwesomeIconProbeOption(QStringLiteral("fontawesome-icon-probe"),
                                                        QStringLiteral("Run the Font Awesome icon probe."));
    const QCommandLineOption fontAwesomeGridProbeOption(QStringLiteral("fontawesome-grid-probe"),
                                                        QStringLiteral("Run the Font Awesome grid probe."));
    const QCommandLineOption themeGalleryProbeOption(QStringLiteral("theme-gallery-probe"),
                                                     QStringLiteral("Run the theme gallery probe."));
    const QCommandLineOption themeBuilderProbeOption(QStringLiteral("theme-builder-probe"),
                                                     QStringLiteral("Run the theme builder save/apply probe."));
    const QCommandLineOption smokeTestOption(QStringLiteral("smoke-test"),
                                             QStringLiteral("Load the default shell and exit shortly."));
    const QCommandLineOption exportThemeGalleryOption(QStringLiteral("export-theme-gallery"),
                                                      QStringLiteral("Export the theme gallery to a directory."),
                                                      QStringLiteral("output-dir"));
    const QCommandLineOption themeSourceOption(QStringLiteral("theme-source"),
                                               QStringLiteral("Load an external theme index.json source."),
                                               QStringLiteral("index.json"));

    parser.addOptions({
        themeProbeOption,
        themeSwitchProbeOption,
        playgroundProbeOption,
        fontAwesomeIconProbeOption,
        fontAwesomeGridProbeOption,
        themeGalleryProbeOption,
        themeBuilderProbeOption,
        smokeTestOption,
        exportThemeGalleryOption,
        themeSourceOption,
    });
    parser.process(app);

    QQmlApplicationEngine engine;
    PlaygroundThemeBuilder themeBuilder;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    const bool themeProbe = parser.isSet(themeProbeOption);
    const bool themeSwitchProbe = parser.isSet(themeSwitchProbeOption);
    const bool playgroundProbe = parser.isSet(playgroundProbeOption);
    const bool fontAwesomeIconProbe = parser.isSet(fontAwesomeIconProbeOption);
    const bool fontAwesomeGridProbe = parser.isSet(fontAwesomeGridProbeOption);
    const bool themeGalleryProbe = parser.isSet(themeGalleryProbeOption);
    const bool themeBuilderProbe = parser.isSet(themeBuilderProbeOption);
    const bool exportThemeGallery = parser.isSet(exportThemeGalleryOption);
    const bool smokeTest = parser.isSet(smokeTestOption);

    engine.rootContext()->setContextProperty(
        QStringLiteral("playgroundMaterialIcons"),
        loadIconCodepoints(
            QStringLiteral(":/merce/playground/MaterialSymbolsRounded.codepoints")));
    engine.rootContext()->setContextProperty(
        QStringLiteral("playgroundThemeSourcePaths"),
        parser.values(themeSourceOption));
    engine.rootContext()->setContextProperty(QStringLiteral("playgroundThemeBuilder"), &themeBuilder);

    if (exportThemeGallery) {
        if (parser.value(exportThemeGalleryOption).trimmed().isEmpty()) {
            qCritical().noquote() << "--export-theme-gallery requires an output directory";
            return 2;
        }

        QDir outputDir(QDir::current().absoluteFilePath(parser.value(exportThemeGalleryOption)));
        if (!outputDir.exists() && !outputDir.mkpath(QStringLiteral("."))) {
            qCritical().noquote() << "Could not create theme gallery output directory:" << outputDir.absolutePath();
            return 2;
        }

        engine.rootContext()->setContextProperty(QStringLiteral("themeGalleryOutputDir"), outputDir.absolutePath());
    }

    const char *component = exportThemeGallery ? "ThemeGalleryExport"
                                               : (themeBuilderProbe ? "ThemeBuilderProbe"
                                                                    : (themeGalleryProbe ? "ThemeGalleryProbe"
                                                                                         : (fontAwesomeGridProbe ? "FontAwesomeGridProbe"
                                                                                                                 : (fontAwesomeIconProbe ? "FontAwesomeIconProbe"
                                                                                                                                         : (playgroundProbe ? "PlaygroundProbe"
                                                                                                                                                            : (themeSwitchProbe ? "ThemeSwitchProbe"
                                                                                                                                                                                : (themeProbe ? "ThemeProbe" : "Main")))))));
    engine.loadFromModule("Merce.Playground", component);

    if (exportThemeGallery) {
        QTimer::singleShot(6000, &app, []() {
            qCritical().noquote() << "Theme gallery export timed out";
            QCoreApplication::exit(3);
        });
    } else if (themeGalleryProbe) {
        QTimer::singleShot(3000, &app, []() {
            qCritical().noquote() << "Theme gallery probe timed out";
            QCoreApplication::exit(3);
        });
    } else if (themeBuilderProbe) {
        QTimer::singleShot(3000, &app, []() {
            qCritical().noquote() << "Theme builder probe timed out";
            QCoreApplication::exit(3);
        });
    } else if (playgroundProbe) {
        QTimer::singleShot(6000, &app, []() {
            qCritical().noquote() << "Playground probe timed out";
            QCoreApplication::exit(3);
        });
    } else if (fontAwesomeIconProbe) {
        QTimer::singleShot(3000, &app, []() {
            qCritical().noquote() << "Font Awesome icon probe timed out";
            QCoreApplication::exit(3);
        });
    } else if (fontAwesomeGridProbe) {
        QTimer::singleShot(5000, &app, []() {
            qCritical().noquote() << "Font Awesome grid probe timed out";
            QCoreApplication::exit(3);
        });
    } else if (themeProbe || themeSwitchProbe || smokeTest) {
        QTimer::singleShot(250, &app, &QCoreApplication::quit);
    }

    return app.exec();
}
