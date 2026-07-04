pragma ComponentBehavior: Bound

import QtQuick

QtObject {
	final property real width: 4
	final property real radius: 10
	final property real scaledRadius: 16

	final property ColorState focus: ColorState {
		color: "#89b4fa"
		shadowColor: "#232136"
	}
	final property ColorState normal: ColorState {
		color: "#c4a7e7"
		shadowColor: "#232136"
	}
	final property ColorState error: ColorState {
		color: "#ed8796"
		shadowColor: "#232136"
	}
	final property ColorState disable: ColorState {
		color: "#9ca0b0"
		shadowColor: "#232136"
	}
}