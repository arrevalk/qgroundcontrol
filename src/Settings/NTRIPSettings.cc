/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "NTRIPSettings.h"

#include <QQmlEngine>
#include <QtQml>

DECLARE_SETTINGGROUP(NTRIP, "NTRIP")
{
    qmlRegisterUncreatableType<NTRIPSettings>("QGroundControl.SettingsManager", 1, 0, "NTRIPSettings", "Reference only");
}

DECLARE_SETTINGSFACT(NTRIPSettings, ntripServerConnectEnabled)
DECLARE_SETTINGSFACT(NTRIPSettings, ntripUrl)
DECLARE_SETTINGSFACT(NTRIPSettings, ntripVRS)
DECLARE_SETTINGSFACT(NTRIPSettings, ntripWhitelist)
