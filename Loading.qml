pragma ComponentBehavior: Bound
import QtQuick

Item {
	id: loading

	width: size
	height: size

	final property real size: 40
	final property color color: "#444444"
	final property bool show: false

	FontLoader {
		id: loadingfont
		source: "./icon/lockfont.ttf"
	}

	Text {
		id: loadingIcon
		anchors.fill: parent

		visible: loading.show
		text: "\ue608"
		color: loading.color
		font.family: "lockfont"
		font.pixelSize: size
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		textFormat: Text.PlainText
		transformOrigin: Item.Center
	}

	RotationAnimation {
		id: iconRotation
		target: loadingIcon
		from: 0
		to: 360
		duration: 1000
		loops: Animation.Infinite
		easing.type: Easing.Linear
		running: loading.visible
	}
}

