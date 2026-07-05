pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects

Item {
	id: avatarContainer

	width: style.width
	height: style.height

	transformOrigin: Item.Center
	scale: transformStart ? style.scale : 1


	final property url src: ""
	final property AvatarStyle style: AvatarStyle {}
	final property bool transformStart: false

	Behavior on scale {
		NumberAnimation {
			easing.type: Easing.OutQuad
			duration: 400
		}
	}

	Rectangle {
		id: radiusMask
		anchors.fill: parent
		radius: avatarContainer.style.border.radius
		layer.enabled: true
	}

	Image {
		id: avatarImg
		anchors.fill: parent
		visible: false
		asynchronous: true
		cache: true
		currentFrame: 0
		mipmap: true
		retainWhileLoading: true
		fillMode: Image.PreserveAspectCrop
		horizontalAlignment: Image.AlignHCenter
		verticalAlignment: Image.AlignVCenter
		source: avatarContainer.src
		onStatusChanged: () => {
			if (avatarImg.status === Image.Error) {
				console.error("QSLockError: Failed to load image: " + avatarContainer.src);
			}
		}

	}

	Rectangle {
		id: borderRect
		z: 1
		visible: false
		anchors.centerIn: parent
		width: avatarContainer.width + avatarContainer.style.border.width * 2
		height: avatarContainer.height + avatarContainer.style.border.width * 2
		color: avatarContainer.transformStart ? avatarContainer.style.border.focus.color : avatarContainer.style.border.normal.color
		radius: avatarContainer.style.border.radius

		Behavior on color {
			ColorAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}
	}

	MultiEffect {
		z: 2
		anchors.fill: parent
		source: avatarImg
		maskThresholdMin: 0.5
		maskSpreadAtMin: 1.0
		maskEnabled: true
		maskSource: radiusMask
		transformOrigin: Item.Center
		rotation: hoverHdr.hovered ? avatarContainer.style.rotation : 0

		Behavior on rotation {
			RotationAnimation {
				easing.type: Easing.OutCubic
				duration: 300
			}
		}
	}

	MultiEffect {
		id: focusEffect
		z: 1
		source: borderRect
		anchors.centerIn: parent
		width: avatarContainer.width + avatarContainer.style.border.width * 2
		height: avatarContainer.height + avatarContainer.style.border.width * 2
		shadowEnabled: true
		shadowHorizontalOffset: 4
		shadowVerticalOffset: 4
		shadowBlur: 0.9
		shadowOpacity: 0.5
		shadowScale: 1.03
		shadowColor: {
			if (avatarContainer.transformStart) {
				return avatarContainer.style.border.focus.shadowColor;
			} else {
				return avatarContainer.style.border.normal.shadowColor;
			}
		}

		states: State {
			name: "shadowChanged"
			when: avatarContainer.transformStart
			PropertyChanges {
				target: focusEffect
				shadowBlur: 0.95
				shadowOpacity: 0.6
			}
		}

		transitions: Transition {
			NumberAnimation {
				properties: "shadowBlur,shadowOpacity"
				easing.type: Easing.OutQuad
				duration: 400
			}
		}
	}

	HoverHandler {
		id: hoverHdr
		enabled: true
	}
}

