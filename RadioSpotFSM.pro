TEMPLATE = app         # application
TARGET   = RadioSpot   # application name

#############################################################
#                    include Qt6 modules                    #
QT += gui core widgets network quick qml quickcontrols2 websockets core5compat
CONFIG += qt c++2a
#############################################################

macx {
    CONFIG -= app_bundle
}

SOURCES += \
    source/ColorConverter/ColorConverter.cpp \
        source/main.cpp \
        source/Kernel.cpp \
        source/gui/GuiManager.cpp \

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resource/resource.qrc

#############################################################
#                  подключение Qt расширений                #
#############################################################
include(libs/qtsingleapplication/src/qtsingleapplication.pri)
include(libs/DxClusterClientFSM/DxClusterClientFSM.pri)
include(libs/QTelnet/QTelnet.pri)
include(libs/fsm/include/fsm/fsm.pri)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    qml/main.qml \

HEADERS += \
    source/ColorConverter/ColorConverter.h \
    source/Kernel.h \
    source/common.h \
    source/gui/GuiManager.h
