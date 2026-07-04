pragma ComponentBehavior: Bound

import QtQuick

QtObject {
	final property real width: 200
	final property real height: 48
	final property real scaledWidth: 280
	final property real scaledHeight: 54
	final property real offsetX: 0
	final property real offsetY: 0

	final property color bgColor: "#fffaf3"
	final property color disabledBgColor: "#eff1f5"

	final property color color: "#464261"
	final property color disabledColor: "#5c5f77"
	final property real fontSize: 16
	final property string fontFamily: ""

	final property string placeholderText: "Password"
	final property color placeholderColor: "#9893a5"
	final property real placeholderFontSize: 16
	final property string placeholderFontFamily: ""

	final property color eyeColor: "#333333"
	final property real eyeSize: 20

	final property color cursorColor: "#333333"

	final property BorderStyle border: BorderStyle {}

}