#include "MerceTheme.h"

#include <QFile>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QtTest>
#include <memory>

namespace {
bool colorsNear(const QColor &a, const QColor &b, int tolerance = 3)
{
    return a.isValid() && b.isValid()
        && qAbs(a.red() - b.red()) <= tolerance
        && qAbs(a.green() - b.green()) <= tolerance
        && qAbs(a.blue() - b.blue()) <= tolerance;
}

QColor sample(const QImage &image, QQuickWindow *window, QQuickItem *item,
              const QPointF &point)
{
    if (image.isNull())
        return {};
    const QPointF scene = item->mapToScene(point);
    // grabWindow's physical size follows the render target's device ratio.
    return image.pixelColor(qFloor(scene.x() * image.width() / window->width()),
                            qFloor(scene.y() * image.height() / window->height()));
}
}

class tst_merce_effects : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanupTestCase();
    void moduleAndShaderResource();
    void compositionAndThemes_data();
    void compositionAndThemes();
    void pointerAndKeyboardBehavior();
    void softwareFallback();
    void sweepLifecycle();
    void shaderPixels();

private:
    void enterButton();
    void leaveButton();
    std::unique_ptr<QQmlApplicationEngine> engine;
    QQuickWindow *window = nullptr;
    QQuickItem *button = nullptr;
    QQuickItem *plain = nullptr;
    QQuickItem *background = nullptr;
    QObject *policy = nullptr;
};

void tst_merce_effects::initTestCase()
{
    QTest::failOnWarning(QRegularExpression(
        ".*(SheenBackground|MerceEffectsStyle|MSheen)\\.qml.*"));
    engine = std::make_unique<QQmlApplicationEngine>();
    engine->loadFromModule("Merce.Tests.Effects", "EffectsProbe");
    QCOMPARE(engine->rootObjects().size(), 1);
    window = qobject_cast<QQuickWindow *>(engine->rootObjects().constFirst());
    QVERIFY(window);
    QTRY_VERIFY(button = window->findChild<QQuickItem *>("effectButton"));
    QTRY_VERIFY(plain = window->findChild<QQuickItem *>("plainButton"));
    QTRY_VERIFY(background = button->findChild<QQuickItem *>("merce.sheen.background"));
    policy = window->property("effectPolicy").value<QObject *>();
    QVERIFY(policy);
    QVERIFY(QTest::qWaitForWindowExposed(window));
    if (qEnvironmentVariableIsSet("MERCE_REQUIRE_SHADER_RENDERING"))
        QTRY_VERIFY_WITH_TIMEOUT(background->property("shaderSupported").toBool(), 3000);
    leaveButton();
}

void tst_merce_effects::init()
{
    // StyleKit owns one application-global active style. Keep its engine alive
    // for the suite, just as the application does, and reset consumer state.
    window->show();
    button->setVisible(true);
    button->setEnabled(true);
    button->setProperty("down", false);
    button->setProperty("variant", 1);
    button->setProperty("size", 0);
    button->setProperty("loading", false);
    policy->setProperty("enabled", true);
    policy->setProperty("reducedMotion", false);
    auto *focusSink = window->findChild<QQuickItem *>("focusSink");
    QVERIFY(focusSink);
    focusSink->forceActiveFocus(Qt::OtherFocusReason);
    leaveButton();
}

void tst_merce_effects::cleanupTestCase()
{
    engine.reset();
    window = nullptr;
    button = plain = background = nullptr;
    policy = nullptr;
}

void tst_merce_effects::enterButton()
{
    QTest::mouseMove(window, button->mapToScene(
        QPointF(button->width() / 2, button->height() / 2)).toPoint());
    QTRY_VERIFY(button->property("hovered").toBool());
}

void tst_merce_effects::leaveButton()
{
    QTest::mouseMove(window, QPoint(500, 300));
    QTRY_VERIFY(!button->property("hovered").toBool());
}

void tst_merce_effects::moduleAndShaderResource()
{
    QVERIFY(!plain->findChild<QQuickItem *>("merce.sheen.background"));
    for (const char *name : {"rawButton", "flatButton"}) {
        auto *control = window->findChild<QQuickItem *>(name);
        QVERIFY(control);
        // StyleKit creates a flat button's background lazily on first hover.
        QTest::mouseMove(window, control->mapToScene(
            QPointF(control->width() / 2, control->height() / 2)).toPoint());
        QTRY_VERIFY(control->property("hovered").toBool());
        QTRY_VERIFY2(control->findChild<QQuickItem *>("merce.sheen.background"), name);
    }
    leaveButton();
    QFile shader(":/qt/qml/Merce/Effects/shaders/sheen.frag.qsb");
    QVERIFY(shader.open(QIODevice::ReadOnly));
    QVERIFY(shader.size() > 100);
    QVERIFY(policy->property("enabled").toBool());
    QVERIFY(!policy->property("reducedMotion").toBool());
}

void tst_merce_effects::compositionAndThemes_data()
{
    QTest::addColumn<QString>("brand");
    QTest::addColumn<QString>("mode");
    for (const QString &brand : {QStringLiteral("merce"), QStringLiteral("algit")}) {
        for (const QString &mode : {QStringLiteral("light"), QStringLiteral("dark")})
            QTest::newRow(qPrintable(brand + '-' + mode)) << brand << mode;
    }
}

void tst_merce_effects::compositionAndThemes()
{
    QFETCH(QString, brand);
    QFETCH(QString, mode);
    auto *theme = engine->singletonInstance<MerceTheme *>("Merce.Theme", "Theme");
    QVERIFY(theme);
    // Switch the already-created style so stale theme bindings cannot pass.
    QVERIFY(theme->setTheme(brand == "merce" ? "algit" : "merce", "light"));
    QVERIFY(theme->setTheme(brand, mode));

    for (int variant = 0; variant < 5; ++variant) {
        QVERIFY(button->setProperty("variant", variant));
        QVERIFY(button->setProperty("size", variant == 1 ? 0 : variant % 3));
        QVERIFY(button->setProperty("loading", variant == 1));
        for (const char *property : {"implicitWidth", "implicitHeight", "leftPadding",
                                     "rightPadding", "topPadding", "bottomPadding"})
            QTRY_COMPARE(button->property(property), plain->property(property));
        auto *plainBackground = plain->property("background").value<QQuickItem *>();
        QVERIFY(plainBackground);
        QTRY_COMPARE(background->width(), plainBackground->width());
        QTRY_COMPARE(background->height(), plainBackground->height());
        QTest::qWait(30);
        const QImage frame = window->grabWindow();
        QVERIFY(!frame.isNull());
        const QPointF platePoint(8, button->height() / 2);
        QVERIFY(colorsNear(sample(frame, window, button, platePoint),
                           sample(frame, window, plain, platePoint)));
        QVERIFY(!background->property("shaderLoaded").toBool());
        if (variant == 1) {
            auto *spinner = button->findChild<QQuickItem *>("loadingIndicator");
            auto *label = button->findChild<QQuickItem *>("buttonLabel");
            QVERIFY(spinner && label);
            QVERIFY(spinner->isVisible() && spinner->property("running").toBool());
            QVERIFY(!spinner->mapRectToItem(button, spinner->boundingRect())
                         .intersects(label->mapRectToItem(button, label->boundingRect())));
            QCOMPARE(button->property("styleVariations").toStringList(),
                     QStringList({"secondary", "small", "loading", "sheen"}));
        }
    }
    button->setEnabled(false);
    QTest::qWait(30);
    const QImage disabledFrame = window->grabWindow();
    QVERIFY(colorsNear(sample(disabledFrame, window, button, QPointF(8, button->height() / 2)),
                       sample(disabledFrame, window, plain, QPointF(8, plain->height() / 2))));
}

void tst_merce_effects::pointerAndKeyboardBehavior()
{
    auto *focusSink = window->findChild<QQuickItem *>("focusSink");
    QVERIFY(focusSink);
    focusSink->forceActiveFocus(Qt::OtherFocusReason);
    QSignalSpy clicks(button, SIGNAL(clicked()));
    QVERIFY(clicks.isValid());
    const QPoint center = button->mapToScene(QPointF(button->width() / 2,
                                                    button->height() / 2)).toPoint();
    QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, center);
    QTRY_COMPARE(clicks.count(), 1);
    QVERIFY(!button->hasActiveFocus());
    QVERIFY(!button->property("visualFocus").toBool());
    QTest::keyClick(window, Qt::Key_Tab);
    QTRY_VERIFY(button->hasActiveFocus());
    QTRY_VERIFY(button->property("visualFocus").toBool());
    QTest::keyClick(window, Qt::Key_Space);
    QTRY_COMPARE(clicks.count(), 2);
    button->setProperty("loading", true);
    QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, center);
    QTRY_COMPARE(clicks.count(), 3);
    button->setEnabled(false);
    QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, center);
    QCOMPARE(clicks.count(), 3);
}

void tst_merce_effects::softwareFallback()
{
    if (window->rendererInterface()->graphicsApi() != QSGRendererInterface::Software)
        QSKIP("This check is for Qt Quick's software renderer.");
    enterButton();
    QVERIFY(!background->property("shaderSupported").toBool());
    QVERIFY(!background->property("sweepRunning").toBool());
    QVERIFY(!background->property("shaderLoaded").toBool());
    policy->setProperty("enabled", false);
    policy->setProperty("enabled", true);
    leaveButton();
    enterButton();
    QVERIFY(!background->property("shaderLoaded").toBool());
}

void tst_merce_effects::sweepLifecycle()
{
    if (!background->property("shaderSupported").toBool()) {
        QVERIFY2(!qEnvironmentVariableIsSet("MERCE_REQUIRE_SHADER_RENDERING"),
                 "Rendering was required but no supported RHI backend is active.");
        QSKIP("Run the rendering CTest on an RHI backend to exercise the sweep.");
    }
    enterButton();
    QTRY_VERIFY(background->property("sweepRunning").toBool());
    QTRY_VERIFY(background->property("shaderLoaded").toBool());
    QTRY_VERIFY_WITH_TIMEOUT(!background->property("sweepRunning").toBool(), 1500);
    QTRY_VERIFY(!background->property("shaderLoaded").toBool());
    QTest::qWait(600);
    QVERIFY(!background->property("sweepRunning").toBool());
    QVERIFY(button->property("hovered").toBool());

    // Policy/press recovery does not replay while the existing hover remains.
    for (int interruption = 0; interruption < 4; ++interruption) {
        leaveButton();
        enterButton();
        QTRY_VERIFY(background->property("sweepRunning").toBool());
        switch (interruption) {
        case 0: policy->setProperty("enabled", false); break;
        case 1: policy->setProperty("reducedMotion", true); break;
        case 2: button->setProperty("down", true); break;
        case 3: button->setEnabled(false); break;
        }
        QTRY_VERIFY(!background->property("sweepRunning").toBool());
        QTRY_VERIFY(!background->property("shaderLoaded").toBool());
        switch (interruption) {
        case 0: policy->setProperty("enabled", true); break;
        case 1: policy->setProperty("reducedMotion", false); break;
        case 2: button->setProperty("down", false); break;
        case 3: button->setEnabled(true); break;
        }
        QTest::qWait(100);
        QVERIFY(!background->property("sweepRunning").toBool());
    }

    // Hiding can clear hover; reappearing under the pointer can then produce
    // a new entry. Move outside before restoring visibility to test that
    // interruption releases the shader without depending on hover event timing.
    for (bool hideWindow : {false, true}) {
        leaveButton();
        enterButton();
        QTRY_VERIFY(background->property("sweepRunning").toBool());
        if (hideWindow)
            window->hide();
        else
            button->setVisible(false);
        QTRY_VERIFY(!background->property("sweepRunning").toBool());
        QTRY_VERIFY(!background->property("shaderLoaded").toBool());
        if (hideWindow) {
            button->setVisible(false);
            window->show();
            QVERIFY(QTest::qWaitForWindowExposed(window));
        }
        leaveButton();
        button->setVisible(true);
        QTest::qWait(100);
        QVERIFY(!background->property("sweepRunning").toBool());
        enterButton();
        QTRY_VERIFY(background->property("sweepRunning").toBool());
    }
    leaveButton();
    enterButton();
    QTRY_VERIFY(background->property("sweepRunning").toBool());
    leaveButton();
    QTRY_VERIFY(!background->property("shaderLoaded").toBool());
}

void tst_merce_effects::shaderPixels()
{
    if (!background->property("shaderSupported").toBool()) {
        QVERIFY2(!qEnvironmentVariableIsSet("MERCE_REQUIRE_SHADER_RENDERING"),
                 "Rendering was required but no supported RHI backend is active.");
        QSKIP("Shader pixels require an RHI backend; software fallback is tested separately.");
    }
    QQmlApplicationEngine renderEngine;
    renderEngine.loadFromModule("Merce.Tests.Effects", "SheenRenderProbe");
    QCOMPARE(renderEngine.rootObjects().size(), 1);
    auto *renderWindow = qobject_cast<QQuickWindow *>(renderEngine.rootObjects().constFirst());
    QVERIFY(renderWindow && QTest::qWaitForWindowExposed(renderWindow));
    auto *primitive = renderWindow->findChild<QQuickItem *>("primitive");
    QVERIFY(primitive);
    const QPointF center(primitive->width() / 2, primitive->height() / 2);
    const QColor canvas("#204060");
    auto pixel = [&](const QPointF &point) {
        renderWindow->requestUpdate();
        QTest::qWait(50);
        return sample(renderWindow->grabWindow(), renderWindow, primitive, point);
    };

    // 50% alpha color * 50% intensity, source-over #204060.
    QVERIFY(colorsNear(pixel(center), QColor(88, 74, 85)));
    primitive->setOpacity(0.5);
    QVERIFY(colorsNear(pixel(center), QColor(60, 69, 90)));
    primitive->setOpacity(1);
    for (double progress : {-10.0, 0.0, 1.0, 10.0}) {
        primitive->setProperty("progress", progress);
        QVERIFY(colorsNear(pixel(center), canvas));
    }
    primitive->setProperty("progress", 0.5);
    primitive->setProperty("intensity", -1.0);
    QVERIFY(colorsNear(pixel(center), canvas));
    primitive->setProperty("intensity", 0.5);
    primitive->setProperty("bandWidth", 1.0);
    primitive->setProperty("progress", 0.25);
    const QPointF topLeft(2, 2);
    QVERIFY(colorsNear(pixel(topLeft), canvas));
    primitive->setProperty("topLeftRadius", 0.0);
    QVERIFY(!colorsNear(pixel(topLeft), canvas, 8));
    primitive->setProperty("topLeftRadius", 10000.0);
    QVERIFY(colorsNear(pixel(topLeft), canvas));
    // The opposite square corner must stay square with a rounded top left.
    primitive->setProperty("progress", 0.75);
    QVERIFY(!colorsNear(pixel(QPointF(primitive->width() - 2, 2)), canvas, 8));
    primitive->setWidth(0);
    QVERIFY(!renderWindow->grabWindow().isNull());
    primitive->setWidth(2);
    primitive->setProperty("bandWidth", 0.0);
    QVERIFY(pixel(QPointF(1, 20)).isValid());
}

QTEST_MAIN(tst_merce_effects)
#include "tst_merce_effects.moc"
