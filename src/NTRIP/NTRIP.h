/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "QGCToolbox.h"
#include <QTimer>
#include <QThread>
#include <QTcpSocket>
#include <QUrl>
#include "Drivers/src/rtcm.h"
#include "RTCMMavlink.h"
#include <QGeoCoordinate>


class NTRIPSettings;

class NTRIPTCPLink : public QThread
{
    Q_OBJECT

public:
    NTRIPTCPLink(const QUrl ntripUrl,
                 const QString& whitelist,
                 const bool vrsEnabled,
                 QObject* parent);
    ~NTRIPTCPLink();

signals:
    void error(const QString errorMsg);
    void RTCMDataUpdate(QByteArray message);

protected:
    void run(void) final;
	
private slots:
    void _readBytes(void);

private:
    enum class NTRIPState {
        uninitialised,
        waiting_for_http_response,
        waiting_for_rtcm_header,
        accumulating_rtcm_packet,
    };

    void _hardwareConnect(void);
    void _parse(const QByteArray &buffer);
    void _sendNMEA(QGeoCoordinate position = QGeoCoordinate(52,22,200));
    void _triggerVRSUpdate();
    QString _getCheckSum(QString line);

    QTcpSocket*     _socket =   nullptr;

    bool            _isVRSEnable;
    QUrl            _ntripUrl;
    QVector<int>    _whitelist;
	
    RTCMParsing *_rtcm_parsing{nullptr};
    QTimer* _vrsSendTimer{nullptr};
    static const int _vrsSendRateMSecs = 3000;
    NTRIPState _state;

    QGCToolbox* _toolbox{nullptr};
};

class NTRIP : public QGCTool {
    Q_OBJECT

public:
    NTRIP(QGCApplication* app, QGCToolbox* toolbox);

    // QGCTool overrides
    void setToolbox(QGCToolbox* toolbox) final;

public slots:
    void _tcpError          (const QString errorMsg);

private slots:

private:
    NTRIPTCPLink*                    _tcpLink = nullptr;
    RTCMMavlink*                     _rtcmMavlink = nullptr;
};