#include <QGuiApplication>
#include <QQmlApplicationEngine>
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

    const bool themeProbe = app.arguments().contains("--theme-probe");
    const bool themeSwitchProbe = app.arguments().contains("--theme-switch-probe");
    const bool themeGalleryProbe = app.arguments().contains("--theme-gallery-probe");
    const char *component = themeGalleryProbe ? "ThemeGalleryProbe"
                                              : (themeSwitchProbe ? "ThemeSwitchProbe"
                                                                  : (themeProbe ? "ThemeProbe" : "Main"));
    engine.loadFromModule("Merce.Playground", component);

    if (themeGalleryProbe) {
        QTimer::singleShot(1500, &app, &QCoreApplication::quit);
    } else if (themeProbe || themeSwitchProbe || app.arguments().contains("--smoke-test")) {
        QTimer::singleShot(250, &app, &QCoreApplication::quit);
    }

    return app.exec();
}
