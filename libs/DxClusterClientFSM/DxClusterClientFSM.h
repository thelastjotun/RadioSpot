#pragma once

#include <memory>
#include <QObject>
#include <QJsonObject>

class DxClusterClientFSM : public QObject
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

    explicit DxClusterClientFSM(quint64 uuid, QObject *parent = nullptr);
    ~DxClusterClientFSM() override;

public slots:

    quint64 uuid() const;
    Status status() const;

    void connectToHost(const QString &addr, const QByteArray &callsign);
    void close();

    void setConfig(const QJsonObject &config);

signals:
    void telnetStatusChanged(quint64 uuid, quint32 status);
    void spotChanged(QString callsign, double frequency);

private:
    quint64 m_uuid;
    QJsonObject m_config;
    struct impl;
    std::unique_ptr<impl> pImpl;
};
