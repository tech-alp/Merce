#include <QtTest/qtest.h>

class tst_MerceTestHarness : public QObject
{
    Q_OBJECT

private slots:
    void verifiesQtTestHarness();
};

void tst_MerceTestHarness::verifiesQtTestHarness()
{
    QVERIFY(true);
    QCOMPARE(QStringLiteral("Merce"), QStringLiteral("Merce"));
}

QTEST_MAIN(tst_MerceTestHarness)
#include "tst_merce_test_harness.moc"
