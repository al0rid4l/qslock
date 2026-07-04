pragma ComponentBehavior: Bound

import QtQuick

QtObject {
	final property real width: 280
	final property real offsetX: 0
	final property real offsetY: 0

	final property color color: "#f6c177"
	final property color errorColor: "#e64553"

	final property real fontSize: 22
	final property string fontFamily: ""

	final property string text: "Caps Lock is on."
}