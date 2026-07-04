pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell

Item {
	id: clockContainer
	implicitWidth: timeText.width
	implicitHeight: timeText.height
	final property DateClockStyle style: DateClockStyle {}

	Text {
		id: timeText
		visible: !clockContainer.style.shadowEnabled
		text: Qt.formatTime(datetime.date, clockContainer.style.format)
		color: clockContainer.style.color
		font.family: clockContainer.style.fontFamily
		font.pixelSize: clockContainer.style.fontSize
		font.bold: clockContainer.style.fontBold
		font.weight: clockContainer.style.fontWeight
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		textFormat: Text.PlainText
	}

	SystemClock {
		id: datetime
		precision: SystemClock.Minutes
	}

	MultiEffect {
		id: clockShadow
		visible: clockContainer.style.shadowEnabled
		source: timeText
		anchors.fill: timeText
		shadowEnabled: true
		shadowHorizontalOffset: 2
		shadowVerticalOffset: 2
		shadowBlur: 0.6
		shadowOpacity: 0.5
		shadowScale: 1.02
		shadowColor: clockContainer.style.shadowColor
	}
}

