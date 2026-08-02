#include "MerceTheme.h"

#include <QImage>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QtTest>

namespace {

QColor renderedAt(QQuickWindow *window, QQuickItem *item, const QPointF &itemPoint)
{
    window->requestUpdate();
    QCoreApplication::processEvents(QEventLoop::AllEvents, 50);
    QTest::qWait(20);

    const QImage image = window->grabWindow();
    if (image.isNull())
        return {};

    const QPointF scenePoint = item->mapToScene(itemPoint);
    return image.pixelColor(qRound(scenePoint.x()), qRound(scenePoint.y()));
}

QColor renderedCenter(QQuickWindow *window, QQuickItem *item)
{
    return renderedAt(window, item, QPointF(item->width() / 2.0, item->height() / 2.0));
}

bool colorsNear(const QColor &actual, const QColor &expected)
{
    constexpr int tolerance = 2;
    return actual.isValid()
        && qAbs(actual.red() - expected.red()) <= tolerance
        && qAbs(actual.green() - expected.green()) <= tolerance
        && qAbs(actual.blue() - expected.blue()) <= tolerance;
}

QColor renderedColorMatch(QQuickWindow *window, QQuickItem *item, const QColor &expected)
{
    window->requestUpdate();
    QCoreApplication::processEvents(QEventLoop::AllEvents, 50);
    QTest::qWait(20);

    const QImage image = window->grabWindow();
    if (image.isNull())
        return {};

    const QRect bounds =
        item->mapRectToScene(item->boundingRect()).toAlignedRect().intersected(image.rect());
    for (int y = bounds.top(); y <= bounds.bottom(); ++y) {
        for (int x = bounds.left(); x <= bounds.right(); ++x) {
            const QColor actual = image.pixelColor(x, y);
            if (colorsNear(actual, expected))
                return actual;
        }
    }
    return {};
}

} // namespace

class tst_merce_style_runtime_switch : public QObject
{
    Q_OBJECT

private slots:
    void existingStyleKitControlsRepaintAfterContextSwitch();
};

void tst_merce_style_runtime_switch::existingStyleKitControlsRepaintAfterContextSwitch()
{
    QQmlApplicationEngine engine;
    engine.loadFromModule("Merce.Tests.StyleKit", "StyleRuntimeProbe");
    QCOMPARE(engine.rootObjects().size(), 1);

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    QVERIFY(window);
    QQuickItem *button = nullptr;
    QQuickItem *textField = nullptr;
    QQuickItem *switchControl = nullptr;
    QQuickItem *comboBox = nullptr;
    QQuickItem *disabledCheckedButton = nullptr;
    QQuickItem *disabledCheckedCheckBox = nullptr;
    QQuickItem *disabledCheckedRadio = nullptr;
    QQuickItem *disabledCheckedSwitch = nullptr;
    QQuickItem *disabledCheckedItemDelegate = nullptr;
    QQuickItem *merceButton = nullptr;
    QTRY_VERIFY(button = window->findChild<QQuickItem *>(QStringLiteral("styleButton")));
    QTRY_VERIFY(textField = window->findChild<QQuickItem *>(QStringLiteral("styleTextField")));
    QTRY_VERIFY(switchControl =
                    window->findChild<QQuickItem *>(QStringLiteral("styleSwitch")));
    QTRY_VERIFY(comboBox =
                    window->findChild<QQuickItem *>(QStringLiteral("styleComboBox")));
    QTRY_VERIFY(disabledCheckedButton =
                    window->findChild<QQuickItem *>(QStringLiteral("disabledCheckedButton")));
    QTRY_VERIFY(disabledCheckedCheckBox =
                    window->findChild<QQuickItem *>(QStringLiteral("disabledCheckedCheckBox")));
    QTRY_VERIFY(disabledCheckedRadio =
                    window->findChild<QQuickItem *>(QStringLiteral("disabledCheckedRadio")));
    QTRY_VERIFY(disabledCheckedSwitch =
                    window->findChild<QQuickItem *>(QStringLiteral("disabledCheckedSwitch")));
    QTRY_VERIFY(disabledCheckedItemDelegate =
                    window->findChild<QQuickItem *>(
                        QStringLiteral("disabledCheckedItemDelegate")));
    QTRY_VERIFY(merceButton = window->findChild<QQuickItem *>(QStringLiteral("merceButton")));
    auto *theme = engine.singletonInstance<MerceTheme *>("Merce.Theme", "Theme");
    QVERIFY(theme);
    QCOMPARE(theme->activeBrand(), QStringLiteral("algit"));
    QCOMPARE(theme->activeMode(), QStringLiteral("light"));
    QCOMPARE(theme->activeProfile(), QStringLiteral("cart"));

    QObject *styleBefore = window->property("activeStyle").value<QObject *>();
    QVERIFY(styleBefore);
    QCOMPARE(qRound(window->property("styleButtonHeight").toReal()),
             theme->size()->control()->medium());
    QCOMPARE(window->property("styleButtonColor").value<QColor>(),
             theme->colors()->action()->primary()->container());
    QTRY_COMPARE(qRound(button->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(switchControl->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(comboBox->implicitHeight()), theme->size()->control()->medium());
    QCOMPARE(window->property("merceButtonVariations").toStringList(),
             QStringList({QStringLiteral("secondary"), QStringLiteral("small")}));
    QTRY_COMPARE(qRound(merceButton->implicitHeight()), theme->size()->control()->small());

    const QColor lightButton = renderedCenter(window, button);
    const QColor lightField = renderedCenter(window, textField);
    const QColor lightSwitch = renderedColorMatch(
        window, switchControl, theme->colors()->surface()->containerSunken());
    const QColor lightComboStyle = window->property("styleComboBoxColor").value<QColor>();
    const QColor lightCombo = renderedColorMatch(window, comboBox, lightComboStyle);
    const QColor lightMerceButton = renderedCenter(window, merceButton);
    const QColor lightDisabledButtonStyle =
        window->property("disabledCheckedButtonColor").value<QColor>();
    const QColor lightDisabledCheckBoxStyle =
        window->property("disabledCheckedCheckBoxColor").value<QColor>();
    const QColor lightDisabledRadioStyle =
        window->property("disabledCheckedRadioColor").value<QColor>();
    const QColor lightDisabledSwitchStyle =
        window->property("disabledCheckedSwitchColor").value<QColor>();
    const QColor lightDisabledItemDelegateStyle =
        window->property("disabledCheckedItemDelegateColor").value<QColor>();
    QVERIFY2(colorsNear(lightButton, theme->colors()->action()->primary()->container()),
             qPrintable(QStringLiteral("button rendered %1, expected %2")
                            .arg(lightButton.name(),
                                 theme->colors()->action()->primary()->container().name())));
    QVERIFY2(colorsNear(lightField, theme->colors()->surface()->container()),
             qPrintable(QStringLiteral("field rendered %1, expected %2")
                            .arg(lightField.name(), theme->colors()->surface()->container().name())));
    QVERIFY2(colorsNear(lightSwitch, theme->colors()->surface()->containerSunken()),
             qPrintable(QStringLiteral("switch rendered %1, expected %2")
                            .arg(lightSwitch.name(),
                                 theme->colors()->surface()->containerSunken().name())));
    QVERIFY2(colorsNear(lightCombo, lightComboStyle),
             qPrintable(QStringLiteral("combo rendered %1, expected %2")
                            .arg(lightCombo.name(), lightComboStyle.name())));
    QVERIFY2(colorsNear(lightMerceButton, theme->colors()->action()->secondary()->container()),
             qPrintable(QStringLiteral("MButton rendered %1, expected %2")
                            .arg(lightMerceButton.name(),
                                 theme->colors()->action()->secondary()->container().name())));
    QVERIFY(colorsNear(renderedColorMatch(window,
                                          disabledCheckedButton,
                                          lightDisabledButtonStyle),
                       lightDisabledButtonStyle));
    QVERIFY(colorsNear(renderedColorMatch(window,
                                          disabledCheckedCheckBox,
                                          lightDisabledCheckBoxStyle),
                       lightDisabledCheckBoxStyle));
    QVERIFY(colorsNear(renderedColorMatch(window,
                                          disabledCheckedRadio,
                                          lightDisabledRadioStyle),
                       lightDisabledRadioStyle));
    QVERIFY(colorsNear(renderedColorMatch(window,
                                          disabledCheckedSwitch,
                                          lightDisabledSwitchStyle),
                       lightDisabledSwitchStyle));
    QVERIFY(colorsNear(renderedColorMatch(window,
                                          disabledCheckedItemDelegate,
                                          lightDisabledItemDelegateStyle),
                       lightDisabledItemDelegateStyle));

    const quint64 generationBefore = theme->generation();
    QVERIFY(theme->setContext(QStringLiteral("algit"),
                              QStringLiteral("dark"),
                              QStringLiteral("cart")));
    QCOMPARE(theme->generation(), generationBefore + 1);
    QCOMPARE(theme->activeMode(), QStringLiteral("dark"));
    QCOMPARE(theme->activeProfile(), QStringLiteral("cart"));
    QCOMPARE(window->property("activeStyle").value<QObject *>(), styleBefore);
    QTRY_COMPARE(qRound(button->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(switchControl->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(comboBox->implicitHeight()), theme->size()->control()->medium());

    QColor darkButton;
    QColor darkField;
    QColor darkSwitch;
    QColor darkCombo;
    QColor darkMerceButton;
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkButton = renderedCenter(window, button),
                   theme->colors()->action()->primary()->container()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkField = renderedCenter(window, textField),
                   theme->colors()->surface()->container()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkSwitch = renderedColorMatch(
                       window, switchControl, theme->colors()->surface()->containerSunken()),
                   theme->colors()->surface()->containerSunken()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkCombo = renderedColorMatch(
                       window,
                       comboBox,
                       window->property("styleComboBoxColor").value<QColor>()),
                   window->property("styleComboBoxColor").value<QColor>()),
        2000);
    QTRY_COMPARE(qRound(merceButton->implicitHeight()), theme->size()->control()->small());
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkMerceButton = renderedCenter(window, merceButton),
                   theme->colors()->action()->secondary()->container()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(renderedColorMatch(
                       window,
                       disabledCheckedButton,
                       window->property("disabledCheckedButtonColor").value<QColor>()),
                   window->property("disabledCheckedButtonColor").value<QColor>()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(renderedColorMatch(
                       window,
                       disabledCheckedCheckBox,
                       window->property("disabledCheckedCheckBoxColor").value<QColor>()),
                   window->property("disabledCheckedCheckBoxColor").value<QColor>()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(renderedColorMatch(
                       window,
                       disabledCheckedRadio,
                       window->property("disabledCheckedRadioColor").value<QColor>()),
                   window->property("disabledCheckedRadioColor").value<QColor>()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(renderedColorMatch(
                       window,
                       disabledCheckedSwitch,
                       window->property("disabledCheckedSwitchColor").value<QColor>()),
                   window->property("disabledCheckedSwitchColor").value<QColor>()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(renderedColorMatch(
                       window,
                       disabledCheckedItemDelegate,
                       window->property("disabledCheckedItemDelegateColor").value<QColor>()),
                   window->property("disabledCheckedItemDelegateColor").value<QColor>()),
        2000);
    QVERIFY(lightButton != darkButton);
    QVERIFY(lightField != darkField);
    QVERIFY(lightSwitch != darkSwitch);
    QVERIFY(lightCombo != darkCombo);
    QVERIFY(lightMerceButton != darkMerceButton);

    QVERIFY(theme->setContext(QStringLiteral("algit"),
                              QStringLiteral("dark"),
                              QStringLiteral("ops")));
    QCOMPARE(qRound(window->property("styleSwitchHeight").toReal()),
             theme->size()->control()->medium());
    QEXPECT_FAIL("",
                 "Qt 6.11.1 StyleReader leaves an existing Switch's "
                 "implicitBackgroundHeight at its construction-time profile",
                 Continue);
    QCOMPARE(qRound(switchControl->implicitHeight()), theme->size()->control()->medium());
}

QTEST_MAIN(tst_merce_style_runtime_switch)
#include "tst_merce_style_runtime_switch.moc"
