#include "ColorConverter.h"
#include <QDebug>

ColorConverter::ColorConverter(QObject *parent)
    : QObject{parent}
{

}

quint32 ColorConverter::convertFromHexdecimalToDecimal(const QString &hex)
{
    QString changedColor = hex;

    bool isConverted;

    changedColor.remove("#");

    return changedColor.toUInt(&isConverted, 16);
}
