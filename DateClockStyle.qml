pragma ComponentBehavior: Bound

import QtQuick

QtObject {
	final property color color: "#e2e2e2"
	final property string format: "hh:mm"
	final property string fontFamily: ""
	final property real fontSize: 48
	final property bool fontBold: true
	final property int fontWeight: 400
	final property bool shadowEnabled: true
	final property color shadowColor: "#333333"
	final property real offsetX: 0
	final property real offsetY: 0
}