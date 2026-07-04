pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell

Item {
	id: dateContainer
	implicitWidth: dateText.width
	implicitHeight: dateText.height
	final property DateClockStyle style: DateClockStyle {}
	// final property Date time: new Date()


	Text {
		id: dateText
		visible: !dateContainer.style.shadowEnabled
		text: Qt.formatDateTime(datetime.date, dateContainer.style.format)
		color: dateContainer.style.color
		font.family: dateContainer.style.fontFamily
		font.pixelSize: dateContainer.style.fontSize
		font.bold: dateContainer.style.fontBold
		font.weight: dateContainer.style.fontWeight
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
		visible: dateContainer.style.shadowEnabled
		source: dateText
		anchors.fill: dateText
		shadowEnabled: true
		shadowHorizontalOffset: 2
		shadowVerticalOffset: 2
		shadowBlur: 0.6
		shadowOpacity: 0.5
		shadowScale: 1.02
		shadowColor: dateContainer.style.shadowColor
	}
}

