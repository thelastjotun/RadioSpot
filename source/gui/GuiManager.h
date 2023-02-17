#pragma once

#include <QString>
#include <QObject>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <source/ColorConverter/ColorConverter.h>
//#include <settings.h>
#include "../common.h"

class GuiManager final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(GuiManager)

public:
    explicit GuiManager(QObject *parent = nullptr);

signals:
    void configChanged(QJsonObject);
    void create(quint64 uuid, const QJsonObject &config); //добавть json
    void remove(quint64 uuid);
    void connectTo(quint64 uuid, const QString &addr, const QByteArray &callsign);
    void disconnectFrom(quint64 uuid);
    void removeAll();
    void spotChanged(QString spot, double frequency);
    void telnetStatusChanged(quint64 uuid, int status);
    void tciStatusChanged(quint64 uuid, int status);
    void transceiverEnabledChanged(quint64 uuid, bool state);
    void txAvaliableChanged(quint64 uuid, bool state);
    void trxChanged(quint64 uuid, bool state);
    void tuneChanged(quint64 uuid, bool state);
    void modulationChanged(quint64 uuid, QString mode);
    void txTerminated(quint64 uuid);
    void cwMacrosTerminated(quint64 uuid);
    void cwSpeedChanged(quint64 uuid, quint32 wpm);
    void sendCwSpeed(quint64 uuid, quint32 wpm);
    void colorChanged(quint32 decimalColor);

public slots:
    void show();

    Q_INVOKABLE void onQuit();
    Q_INVOKABLE QString applicationName() const;
    Q_INVOKABLE QString applicationVersion() const;
    Q_INVOKABLE quint64 generateUuid() const;

    Q_INVOKABLE void saveConfig(const QJsonObject &config);
    Q_INVOKABLE QJsonObject loadConfig() const;

    Q_INVOKABLE bool exportConfig(const QJsonObject &config);
    Q_INVOKABLE QJsonObject importConfig() const;

    Q_INVOKABLE void createConnection(quint64 uuid, const QJsonObject &config); //добавить json
    Q_INVOKABLE void removeConnection(quint64 uuid);
    Q_INVOKABLE void removeAllSync();
    Q_INVOKABLE void connectToHost(quint64 uuid, const QString &addr, const QByteArray &callsign);
    Q_INVOKABLE void disconnectFromHost(quint64 uuid);
    Q_INVOKABLE void updateConnection(quint64 uuid, const QJsonObject &config);

    Q_INVOKABLE void onCwMacrosTerminate(quint64 uuid);
    Q_INVOKABLE void onTxTerminate(quint64 uuid);

    Q_INVOKABLE QString urlToLocal(const QString &path) const;
    Q_INVOKABLE QString localToUrl(const QString &path) const;

    Q_INVOKABLE quint32 convertFromHexdecimalToDecimal(const QString &hex);

private:
    QJsonObject validate(const QJsonObject &obj) const;

private:
    QQmlApplicationEngine m_engine;
    QQmlComponent m_qml {&m_engine};
    QString m_qmlUrl {"qrc:/qml/main.qml"};
    ColorConverter m_colorConverter;
    QSettings m_settings {Common::settingsFile()};
};

