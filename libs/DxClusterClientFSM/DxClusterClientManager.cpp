#include "DxClusterClientManager.h"
#include <QDebug>

DxClusterClientManager::DxClusterClientManager(QObject *parent)
    : QObject{parent}
{

}

void DxClusterClientManager::setConfig(const QJsonObject &json)
{
    for (auto connection : m_connections){
        connection->setConfig(json);
    }
}

void DxClusterClientManager::createConnection(quint64 uuid, const QJsonObject &config)
{
    if (auto itter = std::find_if(m_connections.begin(), m_connections.end(), [uuid](auto p){ return p->uuid() == uuid; }); itter == m_connections.end()) {
        m_connections.append(std::make_unique<DxClusterClientFSM>(uuid, this).release());
        //
        connect(m_connections.last(), &DxClusterClientFSM::telnetStatusChanged, this, &DxClusterClientManager::telnetStatusChanged);
        connect(m_connections.last(), &DxClusterClientFSM::spotChanged, this, &DxClusterClientManager::spotChanged);
        //
        m_connections.last()->setConfig(config);
    }
}

void DxClusterClientManager::connectToHost(quint64 uuid, const QString &addr, const QByteArray &callsign)
{
    if (auto itter = std::find_if(m_connections.begin(), m_connections.end(), [uuid](auto p){ return p->uuid() == uuid; }); itter != m_connections.end()) {
        m_connections.at(std::distance(m_connections.begin(), itter))->connectToHost(addr, callsign);
    }
}

void DxClusterClientManager::disconnectFromHost(quint64 uuid)
{
    if (auto itter = std::find_if(m_connections.begin(), m_connections.end(), [uuid](auto p){ return p->uuid() == uuid; }); itter != m_connections.end()) {
        m_connections.at(std::distance(m_connections.begin(), itter))->close();
    }
}

void DxClusterClientManager::removeConnection(quint64 uuid)
{
    if (auto itter = std::find_if(m_connections.begin(), m_connections.end(), [uuid](auto p){ return p->uuid() == uuid; }); itter != m_connections.end()) {
        (*itter)->deleteLater();
        m_connections.removeAt(std::distance(m_connections.begin(), itter));
    }
}

void DxClusterClientManager::removeAll()
{
    for (auto connection : m_connections)
        connection->deleteLater();
    m_connections.clear();
}
