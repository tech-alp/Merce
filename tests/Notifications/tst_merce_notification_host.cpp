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

QVariantList callbackEvents(QObject *root)
{
    return root->property("callbackEvents").toList();
}

QVariantMap callbackEventAt(QObject *root, int index)
{
    const QVariantList list = callbackEvents(root);
    if (index < 0 || index >= list.size())
        return {};
    return list.at(index).toMap();
}

/**
 * The dialog is created per request and destroyed with it, so it is looked up
 * each time rather than cached.
 */
QObject *openDialog(QObject *root)
{
    return root->findChild<QObject *>(QStringLiteral("notificationHost.dialog"));
}

QObject *buttonWithText(QObject *dialog, const QString &text)
{
    for (QObject *candidate : dialog->findChildren<QObject *>()) {
        if (candidate->property("text").toString() == text)
            return candidate;
    }
    return nullptr;
}

QStringList variationNames(QObject *button)
{
    QStringList names;
    for (const QVariant &entry : button->property("styleVariations").toList())
        names.append(entry.toString());
    return names;
}

int visibleToastEntries(QObject *stack)
{
    int count = 0;
    for (QObject *child : stack->children()) {
        if (child->property("isToastStackEntry").toBool()
            && child->property("visible").toBool()) {
            ++count;
        }
    }
    return count;
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
    void acceptedFlowRunsCallSiteCallbacksExactlyOnce();
    void cancelledFlowRunsCallSiteCallbacksExactlyOnce();
    void timedOutFlowDoesNotRunCancelledCallback();
    void refusedFlowRunsItsCallSiteCallbackWithoutOpening();
    void destroyedOwnerSuppressesCallSiteCallbacks();
    void duplicateRequestIdDoesNotReplaceActiveCallbacks();
    void duplicateRequestIdWithoutCallbacksIsRefused();
    void prototypeLikeRequestIdStartsNormally();
    void reentrantBlockingRequestCannotReplacePending();
    void hostDestructionSettlesAndReleasesActiveRequest();
    void dialogActionsUseMerceButtonVariants();
    void notificationCenterEnumCreatesTypedToasts();
    void notificationCenterRejectsStringToastType();
    void notificationCenterShortcutsCreateTypedToasts();
    void notificationHostAcceptsLegacyStringToastType();
    void destroyedToastOwnerSuppressesClickCallback();
    void toastsResolveTheToastifyDependency();
    void keepsFiveSimultaneousToastsReadable();

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
    QCOMPARE(callbackEvents(m_root).size(), 0);
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

void tst_merce_notification_host::acceptedFlowRunsCallSiteCallbacksExactlyOnce()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("callback-accepted")),
                              Q_ARG(QVariant, 0), Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), QStringLiteral("callback-accepted"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QMetaObject::invokeMethod(dialog, "confirm");

    QTRY_COMPARE(callbackEvents(m_root).size(), 2);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("accepted"));
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("detail")).toString(),
             QStringLiteral("callback-accepted"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("closed"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("detail")).toString(),
             QStringLiteral("accepted:callback-accepted"));

    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(callbackEvents(m_root).size(), 2);
}

void tst_merce_notification_host::cancelledFlowRunsCallSiteCallbacksExactlyOnce()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("callback-cancelled")),
                              Q_ARG(QVariant, 0), Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), QStringLiteral("callback-cancelled"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QMetaObject::invokeMethod(dialog, "cancel");

    QTRY_COMPARE(callbackEvents(m_root).size(), 2);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("cancelled"));
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("detail")).toString(),
             QStringLiteral("callback-cancelled"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("closed"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("detail")).toString(),
             QStringLiteral("cancelled:callback-cancelled"));

    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(callbackEvents(m_root).size(), 2);
}

void tst_merce_notification_host::timedOutFlowDoesNotRunCancelledCallback()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("callback-timeout")),
                              Q_ARG(QVariant, 120), Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), QStringLiteral("callback-timeout"));

    QTRY_COMPARE(callbackEvents(m_root).size(), 2);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("timedOut"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("closed"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("detail")).toString(),
             QStringLiteral("timedOut:callback-timeout"));

    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(callbackEvents(m_root).size(), 2);
}

void tst_merce_notification_host::refusedFlowRunsItsCallSiteCallbackWithoutOpening()
{
    QCOMPARE(startedFlow(m_root, QStringLiteral("active")), QStringLiteral("active"));
    QTRY_VERIFY(m_host->property("busy").toBool());

    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("callback-refused")),
                              Q_ARG(QVariant, 0), Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), QString());

    QTRY_COMPARE(callbackEvents(m_root).size(), 1);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("refused"));
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("detail")).toString(),
             QStringLiteral("active"));
    QCOMPARE(m_host->property("activeRequestId").toString(), QStringLiteral("active"));

    QMetaObject::invokeMethod(m_host, "cancelActive");
    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(callbackEvents(m_root).size(), 1);
}

void tst_merce_notification_host::destroyedOwnerSuppressesCallSiteCallbacks()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithDisposableOwner",
                              Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("owner-destroyed")));
    QCOMPARE(returned.toString(), QStringLiteral("owner-destroyed"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QMetaObject::invokeMethod(m_root, "destroyDisposableOwner");
    QTest::qWait(1);
    QMetaObject::invokeMethod(dialog, "confirm");

    QTRY_VERIFY(!m_host->property("busy").toBool());
    QCOMPARE(results(m_root).size(), 1);
    QCOMPARE(callbackEvents(m_root).size(), 0);
}

void tst_merce_notification_host::duplicateRequestIdDoesNotReplaceActiveCallbacks()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("same-id")),
                              Q_ARG(QVariant, 0), Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), QStringLiteral("same-id"));

    QVariant duplicate;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, duplicate),
                              Q_ARG(QVariant, QStringLiteral("same-id")),
                              Q_ARG(QVariant, 0), Q_ARG(QVariant, false));
    QCOMPARE(duplicate.toString(), QString());
    QTRY_COMPARE(callbackEvents(m_root).size(), 1);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("refused"));
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("detail")).toString(),
             QStringLiteral("same-id"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QMetaObject::invokeMethod(dialog, "confirm");

    QTRY_COMPARE(callbackEvents(m_root).size(), 3);
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("accepted"));
    QCOMPARE(callbackEventAt(m_root, 2).value(QStringLiteral("kind")).toString(),
             QStringLiteral("closed"));
}

void tst_merce_notification_host::duplicateRequestIdWithoutCallbacksIsRefused()
{
    const QString requestId = QStringLiteral("same-id-without-callbacks");
    QCOMPARE(startedFlow(m_root, requestId), requestId);

    QVariant duplicate;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, duplicate),
                              Q_ARG(QVariant, requestId), Q_ARG(QVariant, 0),
                              Q_ARG(QVariant, true));
    QCOMPARE(duplicate.toString(), QString());
    QTRY_COMPARE(callbackEvents(m_root).size(), 1);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("refused"));
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("detail")).toString(),
             requestId);

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QCOMPARE(dialog->property("requestId").toString(), requestId);
    QMetaObject::invokeMethod(dialog, "confirm");
    QTRY_VERIFY(!m_host->property("busy").toBool());
}

void tst_merce_notification_host::prototypeLikeRequestIdStartsNormally()
{
    const QString requestId = QStringLiteral("constructor");
    QCOMPARE(startedFlow(m_root, requestId), requestId);

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QCOMPARE(dialog->property("requestId").toString(), requestId);
    QMetaObject::invokeMethod(dialog, "confirm");
    QTRY_VERIFY(!m_host->property("busy").toBool());
}

void tst_merce_notification_host::reentrantBlockingRequestCannotReplacePending()
{
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithReentrantBlocking",
                              Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("active")),
                              Q_ARG(QVariant, QStringLiteral("reentrant")));
    QCOMPARE(returned.toString(), QStringLiteral("active"));

    QCOMPARE(startedFlow(m_root, QStringLiteral("pending"), true),
             QStringLiteral("pending"));
    QTRY_COMPARE(callbackEvents(m_root).size(), 2);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("cancelled"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("reentrantRefused"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("detail")).toString(),
             QStringLiteral("pending"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QCOMPARE(dialog->property("requestId").toString(), QStringLiteral("pending"));
    QMetaObject::invokeMethod(dialog, "confirm");
    QTRY_VERIFY(!m_host->property("busy").toBool());
}

void tst_merce_notification_host::hostDestructionSettlesAndReleasesActiveRequest()
{
    const QString requestId = QStringLiteral("host-teardown");
    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, requestId), Q_ARG(QVariant, 0),
                              Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), requestId);
    QTRY_VERIFY(m_host->property("busy").toBool());

    QMetaObject::invokeMethod(m_root, "destroyHost");
    m_host = nullptr;
    QTRY_COMPARE(callbackEvents(m_root).size(), 2);
    QCOMPARE(callbackEventAt(m_root, 0).value(QStringLiteral("kind")).toString(),
             QStringLiteral("cancelled"));
    QCOMPARE(callbackEventAt(m_root, 1).value(QStringLiteral("kind")).toString(),
             QStringLiteral("closed"));

    QMetaObject::invokeMethod(m_root, "createHost");
    QTRY_VERIFY(m_host = m_root->findChild<QObject *>(QStringLiteral("notificationHost")));
    QMetaObject::invokeMethod(m_root, "reset");
    QCOMPARE(callbackEvents(m_root).size(), 0);

    QMetaObject::invokeMethod(m_root, "askWithCallbacks", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, requestId), Q_ARG(QVariant, 0),
                              Q_ARG(QVariant, false));
    QCOMPARE(returned.toString(), requestId);
    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QMetaObject::invokeMethod(dialog, "cancel");
    QTRY_VERIFY(!m_host->property("busy").toBool());
}

void tst_merce_notification_host::dialogActionsUseMerceButtonVariants()
{
    QCOMPARE(startedFlow(m_root, QStringLiteral("default-actions")),
             QStringLiteral("default-actions"));

    QObject *dialog = nullptr;
    QTRY_VERIFY(dialog = openDialog(m_root));
    QObject *cancelButton = buttonWithText(dialog, QStringLiteral("Cancel"));
    QObject *confirmButton = buttonWithText(dialog, QStringLiteral("Confirm"));
    QVERIFY(cancelButton);
    QVERIFY(confirmButton);
    QCOMPARE(variationNames(cancelButton), QStringList{QStringLiteral("outline")});
    QCOMPARE(variationNames(confirmButton), QStringList{});

    QMetaObject::invokeMethod(dialog, "cancel");
    QTRY_VERIFY(!m_host->property("busy").toBool());

    QVariant returned;
    QMetaObject::invokeMethod(m_root, "askDestructive", Q_RETURN_ARG(QVariant, returned),
                              Q_ARG(QVariant, QStringLiteral("destructive-actions")));
    QCOMPARE(returned.toString(), QStringLiteral("destructive-actions"));
    QTRY_VERIFY(dialog = openDialog(m_root));
    QTRY_VERIFY(dialog->property("opened").toBool());
    confirmButton = buttonWithText(dialog, QStringLiteral("Confirm"));
    QVERIFY(confirmButton);
    QCOMPARE(variationNames(confirmButton), QStringList{QStringLiteral("destructive")});

    QMetaObject::invokeMethod(dialog, "cancel");
}

void tst_merce_notification_host::notificationCenterEnumCreatesTypedToasts()
{
    for (int expectedType = 0; expectedType < 4; ++expectedType) {
        QVariant toastId;
        QMetaObject::invokeMethod(m_root, "notifyByType",
                                  Q_RETURN_ARG(QVariant, toastId),
                                  Q_ARG(QVariant, expectedType),
                                  Q_ARG(QVariant, QStringLiteral("typed-toast")));
        QVERIFY(!toastId.toString().isEmpty());

        QVariant actualType;
        QMetaObject::invokeMethod(m_root, "toastType",
                                  Q_RETURN_ARG(QVariant, actualType),
                                  Q_ARG(QVariant, toastId));
        QCOMPARE(actualType.toInt(), expectedType);
    }

    QMetaObject::invokeMethod(m_root, "reset");
}

void tst_merce_notification_host::notificationCenterRejectsStringToastType()
{
    QTest::ignoreMessage(QtWarningMsg,
                         "NotificationCenter.notify: invalid notification type");
    QVariant toastId;
    QMetaObject::invokeMethod(m_root, "notifyByType",
                              Q_RETURN_ARG(QVariant, toastId),
                              Q_ARG(QVariant, QStringLiteral("success")),
                              Q_ARG(QVariant, QStringLiteral("invalid-type")));

    QCOMPARE(toastId.toString(), QString());

    QTest::ignoreMessage(QtWarningMsg,
                         "NotificationCenter.notify: invalid notification type");
    QMetaObject::invokeMethod(m_root, "notifyByType",
                              Q_RETURN_ARG(QVariant, toastId),
                              Q_ARG(QVariant, 1.5),
                              Q_ARG(QVariant, QStringLiteral("fractional-type")));
    QCOMPARE(toastId.toString(), QString());
}

void tst_merce_notification_host::notificationCenterShortcutsCreateTypedToasts()
{
    const QStringList kinds{
        QStringLiteral("info"),
        QStringLiteral("success"),
        QStringLiteral("warning"),
        QStringLiteral("error")
    };

    for (int expectedType = 0; expectedType < kinds.size(); ++expectedType) {
        QVariant toastId;
        QMetaObject::invokeMethod(m_root, "notifyPersistentShortcut",
                                  Q_RETURN_ARG(QVariant, toastId),
                                  Q_ARG(QVariant, kinds.at(expectedType)),
                                  Q_ARG(QVariant, kinds.at(expectedType)));
        QVERIFY(!toastId.toString().isEmpty());

        QVariant actualType;
        QMetaObject::invokeMethod(m_root, "toastType",
                                  Q_RETURN_ARG(QVariant, actualType),
                                  Q_ARG(QVariant, toastId));
        QCOMPARE(actualType.toInt(), expectedType);
    }

    QMetaObject::invokeMethod(m_root, "reset");
}

void tst_merce_notification_host::notificationHostAcceptsLegacyStringToastType()
{
    QVariant toastId;
    QMetaObject::invokeMethod(m_root, "notifyLegacy", Q_RETURN_ARG(QVariant, toastId),
                              Q_ARG(QVariant, QStringLiteral("success")),
                              Q_ARG(QVariant, QStringLiteral("legacy-toast")));
    QVERIFY(!toastId.toString().isEmpty());

    QVariant actualType;
    QMetaObject::invokeMethod(m_root, "toastType", Q_RETURN_ARG(QVariant, actualType),
                              Q_ARG(QVariant, toastId));
    QCOMPARE(actualType.toInt(), 1);
}

void tst_merce_notification_host::destroyedToastOwnerSuppressesClickCallback()
{
    QVariant toastId;
    QMetaObject::invokeMethod(m_root, "notifyWithDisposableOwner",
                              Q_RETURN_ARG(QVariant, toastId), Q_ARG(QVariant, 0),
                              Q_ARG(QVariant, QStringLiteral("owned-toast")));
    QVERIFY(!toastId.toString().isEmpty());

    QMetaObject::invokeMethod(m_root, "destroyDisposableOwner");
    QTest::qWait(1);
    QMetaObject::invokeMethod(m_root, "clickToast",
                              Q_ARG(QVariant, toastId.toString()));
    QCOMPARE(callbackEvents(m_root).size(), 0);
}

void tst_merce_notification_host::toastsResolveTheToastifyDependency()
{
    // Merce.Notifications declares Toastify as a module dependency. If that
    // wiring is wrong the Toastify item fails to create and this returns nothing.
    QVariant toastId;
    QMetaObject::invokeMethod(m_root, "notify", Q_RETURN_ARG(QVariant, toastId),
                              Q_ARG(QVariant, 1),
                              Q_ARG(QVariant, QStringLiteral("Added")));
    QVERIFY(!toastId.toString().isEmpty());

    // A toast is not a flow: it neither blocks nor refuses one.
    QVERIFY(!m_host->property("busy").toBool());
    QCOMPARE(startedFlow(m_root, QStringLiteral("after-toast")),
             QStringLiteral("after-toast"));

    QObject *stack = nullptr;
    QTRY_VERIFY(stack = m_root->findChild<QObject *>(QStringLiteral("topCenterStack")));
    QMetaObject::invokeMethod(m_host, "dismissAllToasts");
    QTRY_COMPARE(stack->property("entryCount").toInt(), 0);
}

void tst_merce_notification_host::keepsFiveSimultaneousToastsReadable()
{
    for (int index = 0; index < 6; ++index) {
        QVariant toastId;
        QMetaObject::invokeMethod(m_root, "notifyPersistent",
                                  Q_RETURN_ARG(QVariant, toastId),
                                  Q_ARG(QVariant, 0),
                                  Q_ARG(QVariant, QStringLiteral("Toast %1").arg(index)));
        QVERIFY(!toastId.toString().isEmpty());
    }

    QObject *stack = nullptr;
    QTRY_VERIFY(stack = m_root->findChild<QObject *>(QStringLiteral("topCenterStack")));
    QTRY_COMPARE(stack->property("entryCount").toInt(), 6);
    QVERIFY(stack->property("expanded").toBool());
    QTRY_COMPARE(visibleToastEntries(stack), 5);

    int visibleEntries = 0;
    int readableEntries = 0;
    int coveredEntries = 0;
    for (QObject *child : stack->children()) {
        if (!child->property("isToastStackEntry").toBool()
            || !child->property("visible").toBool()) {
            continue;
        }

        ++visibleEntries;
        if (child->property("covered").toBool()) {
            ++coveredEntries;
            QVERIFY(!child->property("enabled").toBool());
        } else {
            ++readableEntries;
            QVERIFY(child->property("enabled").toBool());
        }
    }

    QCOMPARE(visibleEntries, 5);
    QCOMPARE(readableEntries, 5);
    QCOMPARE(coveredEntries, 0);
    QMetaObject::invokeMethod(m_host, "dismissAllToasts");
}

QTEST_MAIN(tst_merce_notification_host)

#include "tst_merce_notification_host.moc"
