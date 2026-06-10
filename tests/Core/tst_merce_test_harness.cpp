#include "MerceBuildInfo.h"
#include "MerceModuleRegistry.h"

#include <QtTest/qtest.h>

class tst_MerceTestHarness : public QObject
{
    Q_OBJECT

private slots:
    void verifiesQtTestHarness();
    void buildInfoExposesVersion();
    void moduleRegistryTracksRegisteredUris();
};

void tst_MerceTestHarness::verifiesQtTestHarness()
{
    QVERIFY(true);
    QCOMPARE(QStringLiteral("Merce"), QStringLiteral("Merce"));
}

void tst_MerceTestHarness::buildInfoExposesVersion()
{
    MerceBuildInfo buildInfo;

    QVERIFY(!buildInfo.version().isEmpty());
    QVERIFY(!buildInfo.qtVersion().isEmpty());
    QVERIFY(!buildInfo.buildType().isEmpty());
}

void tst_MerceTestHarness::moduleRegistryTracksRegisteredUris()
{
    MerceModuleRegistry registry;

    QVERIFY(registry.hasModule(QStringLiteral("Merce.Core")));
    QVERIFY(!registry.hasModule(QStringLiteral("Merce.Theme")));
    QVERIFY(registry.registerModule(QStringLiteral("Merce.Theme"), QStringLiteral("1.0")));
    QVERIFY(registry.hasModule(QStringLiteral("Merce.Theme")));
    QCOMPARE(registry.modules().size(), 2);
}

QTEST_MAIN(tst_MerceTestHarness)
#include "tst_merce_test_harness.moc"
