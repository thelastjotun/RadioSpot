#include "GuiManager.h"
#include <QCoreApplication>
#include <QMessageBox>
#include <QQmlContext>
#include <QDateTime>
#include <QFileDialog>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonObject>
#include <QJsonDocument>

GuiManager::GuiManager(QObject *parent) : QObject{parent}
{
    // восстанавливаем настройки
    //validate(m_settings.value(QStringLiteral("settings")).toJsonObject());

    //
    connect(&m_engine, &QQmlApplicationEngine::objectCreated, qApp, [&](QObject *obj, const QUrl &objUrl) {
            if (!obj && (QUrl(m_qmlUrl) == objUrl))
                QCoreApplication::exit(EXIT_FAILURE);
        }, Qt::QueuedConnection);

    m_engine.rootContext()->setContextProperty("main", this);
}

void GuiManager::show()
{
    // загрузка QML сцены
    if (m_qml.loadUrl(QUrl(m_qmlUrl)); m_qml.isReady()) {
        // создаём главное окно
        m_qml.create();
    }
    else {
        QMessageBox::critical(nullptr, qApp->applicationName(), tr("Failed to create GUI!"));
        qApp->quit();
    }
}

void GuiManager::onQuit()
{
//    // сохраняем настройки
//    m_settings.save();

    // закрываем программу
    qApp->quit();
}

QString GuiManager::applicationName() const
{
    return qApp->applicationName();
}

QString GuiManager::applicationVersion() const
{
    return qApp->applicationVersion();
}

void GuiManager::saveConfig(const QJsonObject &object)
{
    m_settings.setValue(QStringLiteral("settings"), object);
}

QJsonObject GuiManager::loadConfig() const
{
    return validate(m_settings.value(QStringLiteral("settings")).toJsonObject());
}

QJsonObject GuiManager::validate(const QJsonObject &obj) const
{
    // провек
    QJsonObject t_object{obj};

    for (auto &key : t_object.keys()) {
        QJsonObject t_param = t_object[key].toObject();
        // проверка настроек
        if (!t_param.contains("configTitleVal"))
            t_param["configTitleVal"] = QStringLiteral("Title");

        if (!t_param.contains("callsignVal"))
            t_param["callsignVal"] = QStringLiteral("K3KPG");

        if (!t_param.contains("hostVal"))
            t_param["hostVal"] = QStringLiteral("dxc.nc7j.com");

        if (!t_param.contains("portVal"))
            t_param["portVal"] = QStringLiteral("7373");

        if (!t_param.contains("switchOnVal"))
            t_param["switchOnVal"] = false;

        if (!t_param.contains("tciAddressVal"))
            t_param["tciAddressVal"] = QStringLiteral("localhost:50001");

        //
        t_object[key] = t_param;
    }

    return obj;
}

bool GuiManager::exportConfig(const QJsonObject &config)
{
    QString fileName = QFileDialog::getSaveFileName(nullptr, tr("Save Configuration"), "", tr("Configurations (*.jmc)"));
    if (fileName.isEmpty())
        return true;

    // открываем файл для чтения
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly))
        return false;

    // запись всех данных в файл
    QJsonDocument document(config);
    file.write(document.toJson(QJsonDocument::Indented));

    // закрываем файл
    file.close();

    //
    return true;
}

QJsonObject GuiManager::importConfig() const
{
    QString fileName = QFileDialog::getOpenFileName(nullptr, tr("Load Configuration"), "", tr("Configurations (*.jmc)"));
    if (fileName.isEmpty())
        return {};

    // открываем файл для чтения
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    // чтение всех данных файла
    QJsonDocument document(QJsonDocument::fromJson(file.readAll()));
    auto config = document.object();

    // закрываем файл
    file.close();

    return validate(config);
}

quint64 GuiManager::generateUuid() const
{
    return static_cast<quint64>(QDateTime::currentMSecsSinceEpoch());
}

void GuiManager::createConnection(quint64 uuid, const QJsonObject &config)
{
    emit create(uuid, config);
}

void GuiManager::removeConnection(quint64 uuid)
{
    emit remove(uuid);
}

void GuiManager::removeAllSync()
{
    emit removeAll();
}

void GuiManager::connectToHost(quint64 uuid, const QString &addr, const QByteArray &callsign)
{
    emit connectTo(uuid, addr, callsign);
}

void GuiManager::disconnectFromHost(quint64 uuid)
{
    emit disconnectFrom(uuid);
}

void GuiManager::updateConnection(quint64, const QJsonObject &config)
{
    emit configChanged(config);
}

QString GuiManager::urlToLocal(const QString &path) const
{
    return QDir::toNativeSeparators(QUrl(path).toLocalFile());
}

QString GuiManager::localToUrl(const QString &path) const
{
    return QUrl(path).toString();
}

quint32 GuiManager::convertFromHexdecimalToDecimal(const QString &hex)
{
    return m_colorConverter.convertFromHexdecimalToDecimal(hex);
}

void GuiManager::onCwMacrosTerminate(quint64 uuid)
{
    emit cwMacrosTerminated(uuid);
}

void GuiManager::onTxTerminate(quint64 uuid)
{
    emit txTerminated(uuid);
}





