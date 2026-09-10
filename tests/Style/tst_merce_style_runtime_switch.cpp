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
    void spinBoxValuesFitOpsProfile();
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
    QQuickItem *spinBox = nullptr;
    QQuickItem *textArea = nullptr;
    QQuickItem *disabledCheckedButton = nullptr;
    QQuickItem *disabledCheckedCheckBox = nullptr;
    QQuickItem *disabledCheckedRadio = nullptr;
    QQuickItem *disabledCheckedSwitch = nullptr;
    QQuickItem *disabledCheckedItemDelegate = nullptr;
    QQuickItem *merceButton = nullptr;
    QQuickItem *rightIconButton = nullptr;
    QQuickItem *loadingButton = nullptr;
    QQuickItem *checkedOutlineButton = nullptr;
    QTRY_VERIFY(button = window->findChild<QQuickItem *>(QStringLiteral("styleButton")));
    QTRY_VERIFY(textField = window->findChild<QQuickItem *>(QStringLiteral("styleTextField")));
    QTRY_VERIFY(switchControl =
                    window->findChild<QQuickItem *>(QStringLiteral("styleSwitch")));
    QTRY_VERIFY(comboBox =
                    window->findChild<QQuickItem *>(QStringLiteral("styleComboBox")));
    QTRY_VERIFY(spinBox =
                    window->findChild<QQuickItem *>(QStringLiteral("styleSpinBox")));
    QTRY_VERIFY(textArea =
                    window->findChild<QQuickItem *>(QStringLiteral("styleTextArea")));
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
    QTRY_VERIFY(rightIconButton =
                    window->findChild<QQuickItem *>(QStringLiteral("rightIconButton")));
    QTRY_VERIFY(loadingButton =
                    window->findChild<QQuickItem *>(QStringLiteral("loadingButton")));
    QTRY_VERIFY(checkedOutlineButton =
                    window->findChild<QQuickItem *>(QStringLiteral("checkedOutlineButton")));
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
    QCOMPARE(qRound(window->property("styleSwitchWidth").toReal()),
             theme->size()->control()->medium());
    QTRY_COMPARE(qRound(button->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(switchControl->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(switchControl->property("implicitIndicatorWidth").toReal()),
                 theme->size()->control()->medium());
    QTRY_COMPARE(qRound(comboBox->implicitHeight()), theme->size()->control()->medium());
    QCOMPARE(qRound(window->property("styleSpinBoxHeight").toReal()),
             theme->size()->control()->medium());
    QCOMPARE(window->property("styleSpinBoxColor").value<QColor>(),
             theme->colors()->surface()->container());
    QCOMPARE(qRound(window->property("styleSpinBoxIndicatorSize").toReal()),
             theme->size()->icon()->small());
    QCOMPARE(window->property("styleSpinBoxIndicatorColor").value<QColor>(),
             theme->colors()->content()->secondary());
    QCOMPARE(qRound(window->property("styleTextAreaHeight").toReal()),
             theme->size()->control()->medium() * 2);
    QCOMPARE(window->property("styleTextAreaColor").value<QColor>(),
             theme->colors()->surface()->container());
    QTRY_COMPARE(qRound(spinBox->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(textArea->implicitHeight()), theme->size()->control()->medium() * 2);
    QCOMPARE(window->property("merceButtonVariations").toStringList(),
             QStringList({QStringLiteral("secondary"), QStringLiteral("small")}));
    QTRY_COMPARE(qRound(merceButton->implicitHeight()), theme->size()->control()->small());
    auto *rightIconContent =
        rightIconButton->property("contentItem").value<QObject *>();
    QVERIFY(rightIconContent);
    QVERIFY(rightIconContent->property("mirrored").toBool());
    // The property only matters if it moves the glyph. Assert the placement so a
    // flag nothing reads cannot pass for a working icon position again.
    auto *rightIcon = rightIconButton->findChild<QQuickItem *>(QStringLiteral("buttonIcon"));
    auto *rightLabel = rightIconButton->findChild<QQuickItem *>(QStringLiteral("buttonLabel"));
    QVERIFY(rightIcon && rightLabel);
    QTRY_VERIFY2(rightIcon->x() > rightLabel->x(),
                 "IconRight should place the glyph after the label");
    auto *loadingIndicator =
        loadingButton->findChild<QQuickItem *>(QStringLiteral("loadingIndicator"));
    QVERIFY(loadingIndicator);
    QVERIFY(loadingIndicator->isVisible());
    QVERIFY(loadingIndicator->property("running").toBool());
    // A spinner drawn over the label still reports visible and running, so
    // assert the two occupy different space rather than merely both existing.
    auto *loadingLabel = loadingButton->findChild<QQuickItem *>(QStringLiteral("buttonLabel"));
    QVERIFY(loadingLabel);
    QVERIFY2(!loadingIndicator
                  ->mapRectToItem(loadingButton,
                                  QRectF(0, 0, loadingIndicator->width(), loadingIndicator->height()))
                  .intersects(loadingLabel->mapRectToItem(
                      loadingButton, QRectF(0, 0, loadingLabel->width(), loadingLabel->height()))),
             "the loading spinner overlaps the label");
    QVERIFY(loadingButton->property("styleVariations")
                .toStringList()
                .contains(QStringLiteral("loading")));

    const QColor lightButton = renderedCenter(window, button);
    const QColor lightField = renderedCenter(window, textField);
    const QColor lightSwitch = renderedColorMatch(
        window, switchControl, theme->colors()->surface()->containerSunken());
    const QColor lightComboStyle = window->property("styleComboBoxColor").value<QColor>();
    const QColor lightCombo = renderedColorMatch(window, comboBox, lightComboStyle);
    const QColor lightSpinBox = renderedColorMatch(
        window, spinBox, window->property("styleSpinBoxColor").value<QColor>());
    const QColor lightTextArea = renderedCenter(window, textArea);
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
    QVERIFY(colorsNear(lightSpinBox,
                       window->property("styleSpinBoxColor").value<QColor>()));
    const QColor lightTextAreaStyle =
        window->property("styleTextAreaColor").value<QColor>();
    QVERIFY2(colorsNear(lightTextArea, lightTextAreaStyle),
             qPrintable(QStringLiteral("text area rendered %1, expected %2")
                            .arg(lightTextArea.name(), lightTextAreaStyle.name())));
    QVERIFY2(colorsNear(lightMerceButton, theme->colors()->action()->secondary()->container()),
             qPrintable(QStringLiteral("MButton rendered %1, expected %2")
                            .arg(lightMerceButton.name(),
                                 theme->colors()->action()->secondary()->container().name())));
    const QColor lightCheckedOutline = renderedCenter(window, checkedOutlineButton);
    QVERIFY2(colorsNear(lightCheckedOutline,
                        theme->colors()->action()->primary()->container()),
             qPrintable(QStringLiteral("checked outline MButton rendered %1, expected %2")
                            .arg(lightCheckedOutline.name(),
                                 theme->colors()->action()->primary()->container().name())));
    checkedOutlineButton->forceActiveFocus(Qt::TabFocusReason);
    QTRY_VERIFY(checkedOutlineButton->hasActiveFocus());
    const QColor lightFocusedCheckedOutline = renderedCenter(window, checkedOutlineButton);
    QVERIFY2(colorsNear(lightFocusedCheckedOutline,
                        theme->colors()->action()->primary()->container()),
             qPrintable(QStringLiteral(
                            "focused checked outline MButton rendered %1, expected %2")
                            .arg(lightFocusedCheckedOutline.name(),
                                 theme->colors()->action()->primary()->container().name())));
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
    QTRY_COMPARE(qRound(spinBox->implicitHeight()), theme->size()->control()->medium());
    QTRY_COMPARE(qRound(textArea->implicitHeight()), theme->size()->control()->medium() * 2);

    QColor darkButton;
    QColor darkField;
    QColor darkSwitch;
    QColor darkCombo;
    QColor darkSpinBox;
    QColor darkTextArea;
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
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkSpinBox = renderedColorMatch(
                       window,
                       spinBox,
                       window->property("styleSpinBoxColor").value<QColor>()),
                   window->property("styleSpinBoxColor").value<QColor>()),
        2000);
    QTRY_VERIFY_WITH_TIMEOUT(
        colorsNear(darkTextArea = renderedCenter(window, textArea),
                   window->property("styleTextAreaColor").value<QColor>()),
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
    QVERIFY(lightSpinBox != darkSpinBox);
    QVERIFY(lightTextArea != darkTextArea);
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

void tst_merce_style_runtime_switch::spinBoxValuesFitOpsProfile()
{
    QQmlApplicationEngine engine;
    auto *theme = engine.singletonInstance<MerceTheme *>("Merce.Theme", "Theme");
    QVERIFY(theme);
    QVERIFY(theme->setContext(QStringLiteral("algit"),
                              QStringLiteral("light"),
                              QStringLiteral("ops")));

    engine.loadFromModule("Merce.Tests.StyleKit", "StyleRuntimeProbe");
    QCOMPARE(engine.rootObjects().size(), 1);

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    QVERIFY(window);
    QQuickItem *spinBox = nullptr;
    QQuickItem *compactSpinBox = nullptr;
    QTRY_VERIFY(spinBox =
                    window->findChild<QQuickItem *>(QStringLiteral("styleSpinBox")));
    QTRY_VERIFY(compactSpinBox =
                    window->findChild<QQuickItem *>(QStringLiteral("compactStyleSpinBox")));

    renderedCenter(window, spinBox);
    renderedCenter(window, compactSpinBox);

    auto *spinBoxContent = qobject_cast<QQuickItem *>(
        spinBox->property("contentItem").value<QObject *>());
    auto *compactSpinBoxContent = qobject_cast<QQuickItem *>(
        compactSpinBox->property("contentItem").value<QObject *>());
    QVERIFY(spinBoxContent);
    QVERIFY(compactSpinBoxContent);
    QTRY_VERIFY(spinBoxContent->implicitWidth() > 0);
    QTRY_VERIFY(compactSpinBoxContent->implicitWidth() > 0);
    QVERIFY2(spinBoxContent->width() >= spinBoxContent->implicitWidth(),
             qPrintable(QStringLiteral("spin box content width %1, required %2")
                            .arg(spinBoxContent->width())
                            .arg(spinBoxContent->implicitWidth())));
    QVERIFY2(compactSpinBoxContent->width() >= compactSpinBoxContent->implicitWidth(),
             qPrintable(QStringLiteral("compact spin box content width %1, required %2")
                            .arg(compactSpinBoxContent->width())
                            .arg(compactSpinBoxContent->implicitWidth())));
}

QTEST_MAIN(tst_merce_style_runtime_switch)
#include "tst_merce_style_runtime_switch.moc"
