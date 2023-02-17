#include <cstdlib>
#include <QIcon>
#include <QtSingleApplication>
#include <QOperatingSystemVersion>
#include <QQuickWindow>
//#include <boost/predef.h>

#include "common.h"
#include "Kernel.h"

#if BOOST_OS_WINDOWS
static inline bool supportDirectX11()
{
    auto locations = QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
    if (locations.empty())
        return false;

    QString t_path = QString("%1\\Windows\\SysWOW64\\d3d11.dll").arg(locations.first().left(2));
    return QFileInfo::exists(t_path);
}


inline void applyGraphicsAPI(int argc, char *argv[])
{
    QStringList arguments;
    for (int i {0}; i < argc; ++i)
        arguments.push_back(QString(argv[i]));

    bool t_directX11 = true;

    for (auto &text : arguments) {
        if (text.contains("--graphics=")) {
            if (auto list = text.split("=", Qt::SkipEmptyParts); list.size() == 2) {
                if (auto t_api = list.last().toLower(); t_api == QStringLiteral("directx")) {
                    QQuickWindow::setGraphicsApi(QSGRendererInterface::Direct3D11Rhi);
                }
                else if (auto t_api = list.last().toLower(); t_api == QStringLiteral("vulkanapi")) {
                    QQuickWindow::setGraphicsApi(QSGRendererInterface::VulkanRhi);
                    t_directX11 = false;
                }
                else if (auto t_api = list.last().toLower(); t_api == QStringLiteral("opengl")) {
                    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);
                    t_directX11 = false;
                }
            }
        }
    }

    if (t_directX11 && !supportDirectX11())
        QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGLRhi);
}
#endif

/**
 * \brief Точка входа в программу.
 * \param argc - количество аргументов запуска.
 * \param argv - список аргументов запуска.
 * \return статус выполнения.
 */
int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
    applyGraphicsAPI(argc, argv);
    //if (QOperatingSystemVersion::current() < QOperatingSystemVersion::Windows8)
    //    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
#endif

    // создание экземпляра программы
    QtSingleApplication a(argc, argv);

    // отключаем завершение программы по закрытию последнего окна
    // если этого не сделать, то при закрытии последнего окна программы закроется и
    // сама программа, в этой программе этого не нужно, так как головной класс
    // выполняет сам эту работу
    a.setQuitOnLastWindowClosed(false);

    // установка иконки программы
    a.setWindowIcon(QIcon(":/main/logo.png"));

    // инициализация основных параметров программы
    // создание каталогов для хранения служебных файлов
    Common::initialize();

    // проверяем запущен ли уже другой экземпляр программы или нет
    if (a.isRunning()) {
        if (Common::isQuit())
            return EXIT_SUCCESS;
    }

    // запуск программы
    Kernel kernel;
    kernel.start();

    // вход в основной цикл обработки сообщений
    return a.exec();
}
