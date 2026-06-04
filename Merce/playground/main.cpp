#include <QDebug>
#include <QCoreApplication>
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
    const bool playgroundProbe = arguments.contains(QStringLiteral("--playground-probe"));
    const bool fontAwesomeIconProbe = arguments.contains(QStringLiteral("--fontawesome-icon-probe"));
    const bool fontAwesomeGridProbe = arguments.contains(QStringLiteral("--fontawesome-grid-probe"));
    const bool themeGalleryProbe = arguments.contains(QStringLiteral("--theme-gallery-probe"));
    const int exportThemeGalleryIndex = arguments.indexOf(QStringLiteral("--export-theme-gallery"));
    const bool exportThemeGallery = exportThemeGalleryIndex >= 0;

    engine.rootContext()->setContextProperty(
        QStringLiteral("playgroundMaterialIcons"),
        loadIconCodepoints(QStringLiteral(":/qt/qml/Merce/Foundation/fonts/MaterialSymbolsRounded/MaterialSymbolsRounded.codepoints")));

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
                                                                    : (fontAwesomeGridProbe ? "FontAwesomeGridProbe"
                                                                                            : (fontAwesomeIconProbe ? "FontAwesomeIconProbe"
                                                                                                                    : (playgroundProbe ? "PlaygroundProbe"
                                                                                                                                       : (themeSwitchProbe ? "ThemeSwitchProbe"
                                                                                                                                                           : (themeProbe ? "ThemeProbe" : "Main"))))));
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
    } else if (playgroundProbe) {
        QTimer::singleShot(3000, &app, []() {
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
    } else if (themeProbe || themeSwitchProbe || arguments.contains(QStringLiteral("--smoke-test"))) {
        QTimer::singleShot(250, &app, &QCoreApplication::quit);
    }

    return app.exec();
}
