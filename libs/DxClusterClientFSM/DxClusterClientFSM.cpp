#include <DxClusterClientFSM.h>
#include <fsm_ecpp.h>
#include <QTelnet.h>
#include <cassert>

using namespace ecpp::fsm;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace fsm_events {
struct connect      {QString addr; QByteArray callsign;};
struct connected    {};
struct disconnect   {};
struct disconnected {};
struct authorize    {};
struct authorized   {};
struct message      {QString text;};
}

struct telnet_fsm_def {
    // Состояния
    struct idle : state<idle> {
        void on_enter(auto &fsm, auto &&){
            qDebug() << "idle";
            emit fsm.m_context.telnetStatusChanged(fsm.m_context.uuid(), static_cast<quint32>(DxClusterClientFSM::Status::Disconnected));
        }
    };

    struct connecting : state<connecting> {
        void on_enter(auto &fsm, auto &&){
            qDebug() << "connecting";
            fsm.m_socket.connectToHost(fsm.m_address, fsm.m_port);
            emit fsm.m_context.telnetStatusChanged(fsm.m_context.uuid(), static_cast<quint32>(DxClusterClientFSM::Status::Connecting));
        }

        struct on_disconnected : action<on_disconnected > {
            void operator()(auto &&, auto &) const {}

            void operator()(fsm_events::disconnected &&, auto &fsm) const {
                qDebug() << "reconnecting";
                fsm.m_socket.connectToHost(fsm.m_address, fsm.m_port);
            }
        };

        using internal_transitions = transition_table<
            //  Event                      Action
            in< fsm_events::disconnected,  on_disconnected  >
            >;
    };

    struct connected : state<connected> {
        void on_enter(auto &fsm, auto &&){
            qDebug() << "connected";
            emit fsm.m_context.telnetStatusChanged(fsm.m_context.uuid(), static_cast<quint32>(DxClusterClientFSM::Status::Connected));
        }

        struct on_message : action<on_message > {
            void operator()(auto &&event, auto &fsm) const {}

            void operator()(fsm_events::message &&event, auto &fsm) const {
                if (event.text.contains("Connected") || event.text.contains("Welcome") || event.text.contains("login:"))
                    fsm.process_event(fsm_events::authorize{});
                else
                    fsm.process_event(fsm_events::disconnect{});
            }
        };

        using internal_transitions = transition_table<
            //  Event                 Action
            in< fsm_events::message,  on_message  >
            >;
    };

    struct authorizing : state<authorizing> {
        void on_enter(auto &fsm, auto &&){
            qDebug() << "authorizing";
            fsm.send(fsm.m_callsign);
            emit fsm.m_context.telnetStatusChanged(fsm.m_context.uuid(), static_cast<quint32>(DxClusterClientFSM::Status::Authorizing));
        }

        struct on_message : action<on_message > {
            void operator()(auto &&event, auto &fsm) const {}

            void operator()(fsm_events::message &&event, auto &fsm) const {
                // ПРОВЕРКА НА СОДЕРЖАНИЕ В ПОЛУЧЕННОМ СООБЩЕНИИ СТРОЧКИ HELLO *callsign*
                if (isSetCallsign(event.text)) {
                    fsm.send(fsm.m_callsign);
                } else if (isAuthorized(event.text, fsm.m_callsign)) {
                    fsm.process_event(fsm_events::authorized{});
                } else if (isError(event.text)) {
                    qDebug() << "Error!";
                    fsm.process_event(fsm_events::disconnect{});
                } else {
                    qDebug() << "IDK";
                    fsm.process_event(fsm_events::disconnect{});
                }
            }

        private:
            bool isSetCallsign(const QString &text) const {
                if (text.contains("Please enter your call:") || text.contains("login:")) {
                    return true;
                }
                return false;
            }

            bool isAuthorized(const QString &text, const QByteArray &callsign) const {
                if (text.contains("Hello") || text.contains(callsign)) {
                    return true;
                }
                return false;
            }

            bool isError(const QString &text) const {
                return false;
            }
        };

        using internal_transitions = transition_table<
            //  Event                 Action
            in< fsm_events::message,  on_message  >
            >;
    };

    struct processing : state<processing> {
        void on_enter(auto &fsm, auto &&){
            qDebug() << "connected";
            emit fsm.m_context.telnetStatusChanged(fsm.m_context.uuid(), static_cast<quint32>(DxClusterClientFSM::Status::Authorized));
        }

        struct on_message : action<on_message > {
            void operator()(auto &&event, auto &fsm) const {}

            void operator()(fsm_events::message &&event, auto &fsm) const {
                auto list = event.text.split(' ', Qt::SkipEmptyParts);

                QString callsign = list.at(2);
                callsign = callsign.remove(":");

                qDebug() << callsign << list.at(3);

                emit fsm.m_context.spotChanged(callsign, list.at(3).toDouble());
            }
        };

        using internal_transitions = transition_table<
            //  Event                 Action
            in< fsm_events::message,  on_message  >
            >;
    };

    // Действия
    struct on_connect : action<on_connect> {
        void operator()(auto &&event, auto &fsm, const auto &/*source_state*/, const auto &/*target_state*/) const {
            // таким образом говорим компилятору, что тело if будет только для заданного типа event
            if constexpr (std::is_same_v<fsm_events::connect, std::decay_t<decltype(event)>>) {
                const auto list = event.addr.split(":", Qt::SkipEmptyParts);
                assert(list.size() == 2);
                fsm.m_address = list.at(0);
                fsm.m_port = list.at(1).toInt();
                fsm.m_callsign = event.callsign;
            }
        }
    };

    struct on_disconnect : action<on_disconnect> {
        void operator()(auto &&event, auto &fsm, const auto &/*source_state*/, const auto &/*target_state*/) const {
            // таким образом говорим компилятору, что тело if будет только для заданного типа event
            if constexpr (std::is_same_v<fsm_events::disconnect, std::decay_t<decltype(event)>>) {
                fsm.m_socket.close();
            }
        }
    };

    //====================================================================================
    // начальное состояние и таблица переходов
    using initial_state = idle;
    using transitions = ecpp::fsm::transition_table
        < //   State        Event                       Next           Action            Guard
            tr<idle       , fsm_events::connect     ,   connecting ,   on_connect                    >,
            tr<connecting , fsm_events::connected   ,   connected                                    >,
            tr<connected  , fsm_events::authorize   ,   authorizing                                  >,
            tr<authorizing, fsm_events::authorized  ,   processing                                   >,
            tr<connecting , fsm_events::disconnect  ,   idle       ,   on_disconnect                 >,
            tr<connected  , fsm_events::disconnect  ,   idle       ,   on_disconnect                 >,
            tr<authorizing, fsm_events::disconnect  ,   idle       ,   on_disconnect                 >,
            tr<processing , fsm_events::disconnect  ,   idle       ,   on_disconnect                 >,
            tr<connected  , fsm_events::disconnected,   connecting                                   >,
            tr<authorizing, fsm_events::disconnected,   connecting                                   >,
            tr<processing , fsm_events::disconnected,   connecting                                   >
            >;


    telnet_fsm_def(DxClusterClientFSM &context, QTelnet &socket)
        : m_context{context},
        m_socket{socket}
    {}

private:
    void send(const QByteArray &text) {
        m_socket.sendData(text + "\n");
    }

private:
    DxClusterClientFSM &m_context;
    QTelnet &m_socket;
    QByteArray m_callsign;
    QString m_address;
    quint16 m_port {0};
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
using fsm_t = state_machine<telnet_fsm_def>;

struct DxClusterClientFSM::impl final : fsm_t {
    impl(DxClusterClientFSM &context) : fsm_t{context, m_socket}{
        QObject::connect(&m_socket, &QTelnet::connected, &m_socket, [&](){
            process_event(fsm_events::connected{});
        });
        QObject::connect(&m_socket, &QTelnet::disconnected, &m_socket, [&](){
            process_event(fsm_events::disconnected{});
        });
        QObject::connect(&m_socket, &QTelnet::newData, &m_socket, [&](const char *buff, int len){
            process_event(fsm_events::message{QByteArray(buff, len)});
        });
    }

private:
    QTelnet m_socket;
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
DxClusterClientFSM::DxClusterClientFSM(quint64 uuid, QObject *parent)
    : QObject{parent},
    m_uuid{uuid},
    pImpl{std::make_unique<impl>(*this),}
{

}

DxClusterClientFSM::~DxClusterClientFSM() = default;

DxClusterClientFSM::Status DxClusterClientFSM::status() const
{
    return Status::Disconnected;
}

void DxClusterClientFSM::connectToHost(const QString &addr, const QByteArray &callsign)
{
    pImpl->process_event(fsm_events::connect{addr, callsign});
}

quint64 DxClusterClientFSM::uuid() const {
    return m_uuid;
}

void DxClusterClientFSM::close()
{
    pImpl->process_event(fsm_events::disconnect{});
}

void DxClusterClientFSM::setConfig(const QJsonObject &config)
{
    if (const auto t_uuid = static_cast<quint64>(config["uuidVal"].toDouble(0)); m_uuid == t_uuid) {
        // сохраняем настройки
        m_config = config;

        // запускаем если нужно
        if (m_config["switchOnVal"].toBool(false))
            pImpl->process_event(fsm_events::connect{config["hostVal"].toString() + ":" + config["portVal"].toString(), config["callsignVal"].toVariant().toByteArray()});
    }
}
