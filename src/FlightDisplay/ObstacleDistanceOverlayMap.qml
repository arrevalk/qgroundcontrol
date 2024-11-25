/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick

import QGroundControl
import QGroundControl.SettingsManager

Item {
    id: root

    anchors.fill: parent
    property bool useGradient: false
    property var showText: obstacleDistance._showText

    property real maxPixelRange: obstacleDistance._maxRadiusMeters * pixelsPerMeter
    property real dangerRange: 1.0
    property real warningRange: 2.0

    property real pixelsPerMeter: width / 2 / obstacleDistance._maxRadiusMeters

    //Draws a range circle with given color and range
    function drawRange(ctx, center, radius, color, showText = true){
        ctx.beginPath();
        ctx.strokeStyle = color
        ctx.arc(center.x, center.y, pixelsPerMeter * radius, 0, 2 * Math.PI, false)
        if(showText) ctx.text(radius + "m", center.x + pixelsPerMeter * radius, center.y)
        ctx.stroke();
    }

    function drawRanges(ctx, center){
        ctx.globalAlpha = 0.5
        drawRange(ctx, center, 5.0, "gray")
        drawRange(ctx, center, 10.0, "gray")
        drawRange(ctx, center, dangerRange, "red", false)
        drawRange(ctx, center, warningRange, "orange", false)
    }

    function getColorForDistance(distance, alpha = 1){
        if(distance <= dangerRange){
            return Qt.rgba(1, 0, 0, alpha)
        } else if(distance > dangerRange && distance <=warningRange) {
            return Qt.rgba(1, 0.64, 0, alpha)
        }
        return Qt.rgba(0, 1, 0, alpha)
    }

    function toRad(degrees){
        return degrees * Math.PI / 180.0
    }

    function drawObstacleSection(ctx, center,angle, distance){
        if(distance < obstacleDistance._maxRadiusMeters){
            let pixelDistance = distance * pixelsPerMeter
            //Caluclate key points
            let innerA = Qt.point(
                    center.x + pixelDistance * Math.cos(toRad(angle)),
                    center.y + pixelDistance * Math.sin(toRad(angle)))
            let innerB = Qt.point(
                    center.x + ( pixelDistance) * Math.cos(toRad(angle + obstacleDistance._incrementDeg)),
                    center.y + ( pixelDistance) * Math.sin(toRad(angle + obstacleDistance._incrementDeg)))
            let outerA = Qt.point(
                    center.x + maxPixelRange * Math.cos(toRad(angle)),
                    center.y + maxPixelRange * Math.sin(toRad(angle)))
            let outerB = Qt.point(
                    center.x + maxPixelRange * Math.cos(toRad(angle + obstacleDistance._incrementDeg)),
                    center.y + maxPixelRange * Math.sin(toRad(angle + obstacleDistance._incrementDeg)))

            ctx.beginPath();
            ctx.globalAlpha = 1
            if(!useGradient) {
                //context.fillStyle = getColorForDistance(distance)
                var grad = ctx.createRadialGradient(center.x, center.y, 0, center.x, center.y, maxPixelRange)
                grad.addColorStop(0, getColorForDistance(distance))
                grad.addColorStop(0.3, getColorForDistance(distance, 0.3))
                grad.addColorStop(1, getColorForDistance(distance, 0))
                ctx.fillStyle = grad
            }
            ctx.moveTo(innerA.x, innerA.y)
            ctx.lineTo(outerA.x, outerA.y)
            ctx.lineTo(outerB.x, outerB.y)

            ctx.lineTo(innerB.x, innerB.y)

            ctx.fill()
        }
    }

    function paintObstacleOverlay(ctx) {
        const vehiclePoint = _root.fromCoordinate(_activeVehicle.coordinate, false)
        drawRanges(ctx, vehiclePoint)

        if(useGradient){
            var grad = ctx.createRadialGradient(vehiclePoint.x, vehiclePoint.y, 0, vehiclePoint.x, vehiclePoint.y, maxPixelRange)
            grad.addColorStop(0, Qt.rgba(1, 0, 0, 1))
            grad.addColorStop(dangerRange / obstacleDistance._maxRadiusMeters, Qt.rgba(1, 0, 0, 0.7))   //Koniec strefy zagrożenia
            grad.addColorStop(0.07, Qt.rgba(1, 0.64, 0, 0.7))
            grad.addColorStop(warningRange / obstacleDistance._maxRadiusMeters, Qt.rgba(1, 0.64, 0, 0.3))  //Koniec strefy ostrzerzenia
            grad.addColorStop(0.14, Qt.rgba(0, 1, 0, 0.3))
            grad.addColorStop(1, Qt.rgba(0, 1, 0, 0))

            ctx.fillStyle = grad
        }

        for(let idx = 0; idx < obstacleDistance._rangesLen; idx++){
            drawObstacleSection(ctx, vehiclePoint, 360 - idx * obstacleDistance._incrementDeg + obstacleDistance._heading + obstacleDistance._offsetDeg - 90, obstacleDistance._ranges[idx] / 100 )
        }
    }

    ObstacleDistanceOverlay{
        id: obstacleDistance
    }
}
