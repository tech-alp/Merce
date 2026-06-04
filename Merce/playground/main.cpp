#include <QDebug>
#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStringList>
#include <QTimer>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    const QStringList arguments = app.arguments();
    const bool themeProbe = arguments.contains(QStringLiteral("--theme-probe"));
    const bool themeSwitchProbe = arguments.contains(QStringLiteral("--theme-switch-probe"));
    const bool themeGalleryProbe = arguments.contains(QStringLiteral("--theme-gallery-probe"));
    const int exportThemeGalleryIndex = arguments.indexOf(QStringLiteral("--export-theme-gallery"));
    const bool exportThemeGallery = exportThemeGalleryIndex >= 0;

    if (exportThemeGallery) {
        if (exportThemeGalleryIndex + 1 >= arguments.size()
            || arguments.at(exportThemeGalleryIndex + 1).trimmed().isEmpty()
            || arguments.at(exportThemeGalleryIndex + 1).startsWith(QLatin1String("--"))) {
            qCritical().noquote() << "--export-theme-gallery requires an output directory";
            return 2;
        }

        QDir outputDir(QDir::current().absoluteFilePath(arguments.at(exportThemeGalleryIndex + 1)));
        if (!outputDir.exists() && !outputDir.mkpath(QStringLiteral("."))) {
            qCritical().noquote() << "Could not create theme gallery output directory:" << outputDir.absolutePath();
            return 2;
        }

        engine.rootContext()->setContextProperty(QStringLiteral("themeGalleryOutputDir"), outputDir.absolutePath());
    }

    const char *component = exportThemeGallery ? "ThemeGalleryExport"
                                               : (themeGalleryProbe ? "ThemeGalleryProbe"
                                                                    : (themeSwitchProbe ? "ThemeSwitchProbe"
                                                                                        : (themeProbe ? "ThemeProbe" : "Main")));
    engine.loadFromModule("Merce.Playground", component);

    if (exportThemeGallery) {
        QTimer::singleShot(6000, &app, &QCoreApplication::quit);
    } else if (themeGalleryProbe) {
        QTimer::singleShot(1500, &app, &QCoreApplication::quit);
    } else if (themeProbe || themeSwitchProbe || arguments.contains(QStringLiteral("--smoke-test"))) {
        QTimer::singleShot(250, &app, &QCoreApplication::quit);
    }

    return app.exec();
}
