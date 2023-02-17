#pragma once

#include <QObject>
#include <DxClusterClientFSM.h>

class DxClusterClientManager : public QObject
{
    Q_OBJECT
public:
    enum class Status : quint32
    {
        Disconnected,
        Disconnecting,
        Connecting,
        Connected,
        Authorizing,
        Authorized
    };

    explicit DxClusterClientManager(QObject *parent = nullptr);

public slots:
    void setConfig(const QJsonObject &json);
    void createConnection(quint64 uuid, const QJsonObject &config); //добавить json для setConfig и restore
    void connectToHost(quint64 uuid, const QString &addr, const QByteArray &callsign);
    void disconnectFromHost(quint64 uuid);
    void removeConnection(quint64 uuid);
    void removeAll();

signals:
    void telnetStatusChanged(quint64 uuid, quint32 status);
    void spotChanged(QString callsign, double frequency);

private:
    QList<DxClusterClientFSM*> m_connections;
};
