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
    engine.loadFromModule("Merce.Playground", themeProbe ? "ThemeProbe" : "Main");

    if (themeProbe || app.arguments().contains("--smoke-test")) {
        QTimer::singleShot(250, &app, &QCoreApplication::quit);
    }

    return app.exec();
}
