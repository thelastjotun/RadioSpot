#ifndef COLORCONVERTER_H
#define COLORCONVERTER_H

#include <QObject>
#include <QString>

class ColorConverter : public QObject
{
    Q_OBJECT
public:
    explicit ColorConverter(QObject *parent = nullptr);

public slots:
    quint32 convertFromHexdecimalToDecimal(const QString &hex);

signals:
    void colorChanged(quint32 decimalColor);
};

#endif // COLORCONVERTER_H
