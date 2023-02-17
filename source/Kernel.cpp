#include "Kernel.h"
#include <memory>

Kernel::Kernel(QObject *parent)
    : QObject{parent},
    //pSyncManager(std::make_unique<SyncManager>(this).release()),
    pGuiManager(std::make_unique<GuiManager>(this).release()),
    pDxClusterClientManager(std::make_unique<DxClusterClientManager>(this).release())
{
    connect(pGuiManager,  &GuiManager::configChanged,  pDxClusterClientManager, &DxClusterClientManager::setConfig);
    connect(pGuiManager,  &GuiManager::remove,         pDxClusterClientManager, &DxClusterClientManager::removeConnection);
    connect(pGuiManager,  &GuiManager::create,         pDxClusterClientManager, &DxClusterClientManager::createConnection);
    connect(pGuiManager,  &GuiManager::connectTo,      pDxClusterClientManager, &DxClusterClientManager::connectToHost);
    connect(pGuiManager,  &GuiManager::disconnectFrom, pDxClusterClientManager, &DxClusterClientManager::disconnectFromHost);
    connect(pGuiManager,  &GuiManager::removeAll,      pDxClusterClientManager, &DxClusterClientManager::removeAll);

    connect(pDxClusterClientManager, &DxClusterClientManager::telnetStatusChanged, pGuiManager, &GuiManager::telnetStatusChanged);
    connect(pDxClusterClientManager, &DxClusterClientManager::spotChanged,         pGuiManager, &GuiManager::spotChanged);
}

void Kernel::start()
{
    pGuiManager->show();
}
