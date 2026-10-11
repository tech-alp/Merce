#include <QGuiApplication>
#include <QFile>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.loadFromModule("Merce.PackageConsumer", "Main");
    if (engine.rootObjects().size() != 1)
        return 1;
#ifdef MERCE_CONSUMER_STYLE_EFFECTS
    engine.loadFromModule("Merce.PackageConsumer", "EffectsProbe");
    if (engine.rootObjects().size() != 2
        || !engine.rootObjects().constLast()->findChild<QObject *>("merce.sheen.background"))
        return 2;
#endif
    // MSheen's compiled shader belongs to Merce.Effects even with the adapter off.
    return QFile::exists(":/qt/qml/Merce/Effects/shaders/sheen.frag.qsb") ? 0 : 3;
}
