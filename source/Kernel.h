#pragma once

#include <QObject>
#include "gui/GuiManager.h"
#include "DxClusterClientManager.h"

class Kernel final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY_MOVE(Kernel)

public:
    Kernel(QObject *parent = nullptr);

    void start();

private:
    GuiManager *pGuiManager;
    DxClusterClientManager *pDxClusterClientManager;
};

