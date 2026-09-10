#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QtTest>

class tst_merce_button_focus : public QObject
{
    Q_OBJECT

private slots:
    void mButtonUsesKeyboardOnlyFocus();
};

void tst_merce_button_focus::mButtonUsesKeyboardOnlyFocus()
{
    QQmlApplicationEngine engine;
    engine.loadFromModule("Merce.Tests.ButtonFocus", "ButtonFocusProbe");
    QCOMPARE(engine.rootObjects().size(), 1);

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    QVERIFY(window);
    QQuickItem *focusSink = nullptr;
    QQuickItem *button = nullptr;
    QTRY_VERIFY(focusSink = window->findChild<QQuickItem *>(QStringLiteral("focusSink")));
    QTRY_VERIFY(button = window->findChild<QQuickItem *>(QStringLiteral("button")));

    const int focusPolicy = button->property("focusPolicy").toInt();
    QVERIFY(focusPolicy & Qt::TabFocus);
    QVERIFY(!(focusPolicy & Qt::ClickFocus));
    focusSink->forceActiveFocus(Qt::OtherFocusReason);
    QTRY_VERIFY(focusSink->hasActiveFocus());

    QSignalSpy clickSpy(button, SIGNAL(clicked()));
    QVERIFY(clickSpy.isValid());
    const QPoint clickPosition = button->mapToScene(
        QPointF(button->width() / 2.0, button->height() / 2.0)).toPoint();
    QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, clickPosition);

    QTRY_COMPARE(clickSpy.count(), 1);
    QVERIFY(!button->hasActiveFocus());
    QVERIFY(!button->property("visualFocus").toBool());

    QTest::keyClick(window, Qt::Key_Tab);
    QTRY_VERIFY(button->hasActiveFocus());
    QTRY_VERIFY(button->property("visualFocus").toBool());
}

QTEST_MAIN(tst_merce_button_focus)
#include "tst_merce_button_focus.moc"
