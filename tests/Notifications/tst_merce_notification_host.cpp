#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTest>
#include <QVariantList>
#include <QVariantMap>

namespace {

QVariantList results(QObject *root)
{
    return root->property("results").toList();
}

QVariantMap resultAt(QObject *root, int index)
{
    const QVariantList list = results(root);
    if (index < 0 || index >= list.size())
        return {};
    return list.at(index).toMap();
}

QVariantList refusals(QObject *root)
{
    return root->property("refusals").toList();
}

/**
 * The dialog is created per request and destroyed with it, so it is looked up
 * each time rather than cached.
 */
QObject *openDialog(QObject *root)
{
    return root->findChild<QObject *>(QStringLiteral("notificationHost.dialog"));
}

QString startedFlow(QObject *root, const QString &id, bool blocking = false)
{
    QVariant returned;
    QMetaObject::invokeMethod(root, "ask", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, id), Q_ARG(QVariant, blocking));
    return returned.toString();
}

} // namespace

class tst_merce_notification_host : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();

    void deliversExactlyOneResultPerRequest();
    void aSecondFlowIsRefusedWhileOneIsOpen();
    void aRefusedFlowRunsOnceTheFirstIsResolved();
    void aFlowEndsOnItsTimeout();
    void blockingRequestPreemptsAndSettlesTheInterrupted();
    void toastsResolveTheToastifyDependency();

private:
    QQmlApplicationEngine *m_engine = nullptr;
    QObject *m_root = nullptr;
    QObject *m_host = nullptr;
};

void tst_merce_notification_host::initTestCase()
{
    // One engine for the whole class. Tearing an engine down per test crashed in
    // QQmlComponent: StyleKit's attached style and Toastify outlive the engine
    // that created them, and the next engine finds their stale Component.
    m_engine = new QQmlApplicationEngine;
    m_engine->loadFromModule("Merce.Tests.Notifications", "NotificationHostProbe");
    QCOMPARE(m_engine->rootObjects().size(), 1);
    m_root = m_engine->rootObjects().constFirst();
    QVERIFY(m_root);
    m_host = m_root->findChild<QObject *>(QStringLiteral("notificationHost"));
    QVERIFY(m_host);
}

void tst_merce_notification_host::cleanupTestCase()
{
    delete m_engine;
    m_engine = nullptr;
    m_root = nullptr;
    m_host = nullptr;
}

void tst_merce_notification_host::init()
{
    QMetaObject::invokeMethod(m_root, "reset");
    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(results(m_root).size(), 0);
    QCOMPARE(refusals(m_root).size(), 0);
}

void tst_merce_notification_host::deliversExactlyOneResultPerRequest()
{
    QCOMPARE(startedFlow(m_root, QStringLiteral("one")), QStringLiteral("one"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QTRY_VERIFY(dialog->property("opened").toBool());
    QCOMPARE(m_host->property("activeRequestId").toString(), QStringLiteral("one"));

    QMetaObject::invokeMethod(dialog, "confirm");
    QTRY_COMPARE(results(m_root).size(), 1);

    const QVariantMap first = resultAt(m_root, 0);
    QCOMPARE(first.value(QStringLiteral("requestId")).toString(), QStringLiteral("one"));
    QVERIFY(first.value(QStringLiteral("accepted")).toBool());
    // The payload round-trips, so callers need no side channel.
    QCOMPARE(first.value(QStringLiteral("tag")).toString(), QStringLiteral("one"));

    // Closing is not a second outcome, and the host goes idle.
    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(results(m_root).size(), 1);
}

void tst_merce_notification_host::aSecondFlowIsRefusedWhileOneIsOpen()
{
    QCOMPARE(startedFlow(m_root, QStringLiteral("first")), QStringLiteral("first"));
    QTRY_VERIFY(m_host->property("busy").toBool());

    // A customer scanning another item must not start a second flow. The refusal
    // is immediate and visible, not a silent deferral that surfaces later.
    QCOMPARE(startedFlow(m_root, QStringLiteral("second")), QString());
    QCOMPARE(refusals(m_root).size(), 1);
    QCOMPARE(refusals(m_root).at(0).toMap().value(QStringLiteral("requestId")).toString(),
             QStringLiteral("second"));
    QCOMPARE(refusals(m_root).at(0).toMap().value(QStringLiteral("activeRequestId")).toString(),
             QStringLiteral("first"));

    // The open flow is untouched: no result yet, and it still owns the screen.
    QCOMPARE(results(m_root).size(), 0);
    QCOMPARE(m_host->property("activeRequestId").toString(), QStringLiteral("first"));
}

void tst_merce_notification_host::aRefusedFlowRunsOnceTheFirstIsResolved()
{
    startedFlow(m_root, QStringLiteral("first"));
    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QTRY_VERIFY(dialog->property("opened").toBool());

    QCOMPARE(startedFlow(m_root, QStringLiteral("second")), QString());

    QMetaObject::invokeMethod(dialog, "cancel");
    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(results(m_root).size(), 1);

    // Retrying after the first flow resolved works: the refusal was about the
    // moment, not about the request.
    QCOMPARE(startedFlow(m_root, QStringLiteral("second")), QStringLiteral("second"));
    QObject *second = nullptr;
    QTRY_VERIFY(second = openDialog(m_root));
    QTRY_VERIFY(second->property("opened").toBool());
    QCOMPARE(second->property("requestId").toString(), QStringLiteral("second"));

    QMetaObject::invokeMethod(second, "confirm");
    QTRY_COMPARE(results(m_root).size(), 2);
    QVERIFY(!resultAt(m_root, 0).value(QStringLiteral("accepted")).toBool());
    QVERIFY(resultAt(m_root, 1).value(QStringLiteral("accepted")).toBool());
}

void tst_merce_notification_host::aFlowEndsOnItsTimeout()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithTimeout", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("abandoned")),
                              Q_ARG(QVariant, 120));
    QCOMPARE(returned.toString(), QStringLiteral("abandoned"));
    QTRY_VERIFY(m_host->property("busy").toBool());

    // Nobody decides. The flow must end by itself, or the cart is stuck.
    QTRY_COMPARE(results(m_root).size(), 1);
    QVERIFY(!resultAt(m_root, 0).value(QStringLiteral("accepted")).toBool());

    // A timeout is reported apart from the result, so "said no" and "walked
    // away" are distinguishable.
    const QVariantList timeouts = m_root->property("timeouts").toList();
    QCOMPARE(timeouts.size(), 1);
    QCOMPARE(timeouts.at(0).toString(), QStringLiteral("abandoned"));

    QTRY_VERIFY(!m_host->property("busy").toBool());
}

void tst_merce_notification_host::blockingRequestPreemptsAndSettlesTheInterrupted()
{
    startedFlow(m_root, QStringLiteral("browsing"));
    QObject *browsing = nullptr;
    QTRY_VERIFY(browsing = openDialog(m_root));
    QTRY_VERIFY(browsing->property("opened").toBool());

    // A fraud alert is the one thing allowed to interrupt an open flow.
    QCOMPARE(startedFlow(m_root, QStringLiteral("fraud"), true), QStringLiteral("fraud"));

    // The interrupted flow settles as not accepted rather than vanishing.
    QTRY_COMPARE(results(m_root).size(), 1);
    QCOMPARE(resultAt(m_root, 0).value(QStringLiteral("requestId")).toString(),
             QStringLiteral("browsing"));
    QVERIFY(!resultAt(m_root, 0).value(QStringLiteral("accepted")).toBool());
    // Pre-emption is not a refusal.
    QCOMPARE(refusals(m_root).size(), 0);

    QObject *fraud = nullptr;
    QTRY_VERIFY(fraud = openDialog(m_root));
    QTRY_VERIFY(fraud->property("opened").toBool());
    QCOMPARE(fraud->property("requestId").toString(), QStringLiteral("fraud"));
    // A blocking dialog offers no way out but its actions.
    QVERIFY(fraud->property("blocking").toBool());

    QMetaObject::invokeMethod(fraud, "confirm");
    QTRY_COMPARE(results(m_root).size(), 2);
    QVERIFY(resultAt(m_root, 1).value(QStringLiteral("accepted")).toBool());
}

void tst_merce_notification_host::toastsResolveTheToastifyDependency()
{
    // Merce.Notifications declares Toastify as a module dependency. If that
    // wiring is wrong the Toastify item fails to create and this returns nothing.
    QVariant toastId;
    QMetaObject::invokeMethod(m_root, "notify", Q_RETURN_ARG(QVariant, toastId),
                              Q_ARG(QVariant, QStringLiteral("success")),
                              Q_ARG(QVariant, QStringLiteral("Added")));
    QVERIFY(!toastId.toString().isEmpty());

    // A toast is not a flow: it neither blocks nor refuses one.
    QVERIFY(!m_host->property("busy").toBool());
    QCOMPARE(startedFlow(m_root, QStringLiteral("after-toast")),
             QStringLiteral("after-toast"));

    QMetaObject::invokeMethod(m_host, "dismissAllToasts");
}

QTEST_MAIN(tst_merce_notification_host)

#include "tst_merce_notification_host.moc"
