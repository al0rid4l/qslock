pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
	id: inputContainer
	anchors.horizontalCenter: parent.horizontalCenter
	anchors.verticalCenter: parent.verticalCenter
	width: inputContainer.style.width
	height: inputContainer.style.height

	signal submit(text: string)
	signal blur
	signal focused
	signal textChange(text: string)

	final readonly property string text: passwordInputField.text
	final property bool showPassword: false
	final property bool showCursor: true
	final property bool disable: false
	final property bool error: false
	final property bool capslockOn: false
	final property bool initialFocus: false
	// FIX: focus error
	final property alias focusStatus: passwordInputField.activeFocus
	final property InputStyle style: InputStyle {}

	// FIX: focus error
	function setFocus(value: bool) {
		passwordInputField.focus = value;
	}


	QtObject {
		id: state
		final property bool showCursor: !inputContainer.disable && inputContainer.showCursor && passwordInputField.activeFocus
	}

	FontLoader {
		id: iconFont
		source: "./icon/lockfont.ttf"
	}

	Rectangle {
		id: inputRect
		visible: false
		// anchors.fill: parent
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		width: passwordInputField.activeFocus ? inputContainer.style.scaledWidth : inputContainer.style.width
		height: passwordInputField.activeFocus ? inputContainer.style.scaledHeight : inputContainer.style.height
		// width: passwordInput.activeFocus ? inputContainer.width < 200 ? inputContainer.width * 1.5 : inputContainer.width + 80 : inputContainer.width
		// height: passwordInput.activeFocus ? inputContainer.height + 4 : inputContainer.height
		color: inputContainer.disable ? inputContainer.style.disabledBgColor : inputContainer.style.bgColor
		z: 3
		border.color: {
			if (inputContainer.error) {
				return inputContainer.style.border.error.color;
			} else if (inputContainer.disable) {
				return inputContainer.style.border.disable.color;
			} else if (passwordInputField.activeFocus) {
				return inputContainer.style.border.focus.color;
			} else {
				return inputContainer.style.border.normal.color;
			}
		}
		border.width: inputContainer.style.border.width
		// radius: Math.round((passwordInputField.activeFocus ? inputContainer.height + 4 : inputContainer.height) / 2)
		radius: passwordInputField.activeFocus ? inputContainer.style.border.scaledRadius : inputContainer.style.border.radius
		Behavior on width {
			NumberAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}

		Behavior on height {
			NumberAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}

		Behavior on radius {
			NumberAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}

		Behavior on color {
			ColorAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}

		Behavior on border.color {
			ColorAnimation {
				easing.type: Easing.OutQuad
				duration: 400
			}
		}
		//
		// Image {
		// 	id: eyeOff
		// 	anchors.right: inputRect.right
		// 	anchors.rightMargin: Math.round(inputRect.height / 2) - 8
		// 	anchors.verticalCenter: inputRect.verticalCenter
		// 	width: inputContainer.font.size + 4
		// 	z: 5
		// 	visible: inputContainer.showPassword
		// 	asynchronous: true
		// 	cache: true
		// 	currentFrame: 0
		// 	mipmap: true
		// 	retainWhileLoading: true
		// 	fillMode: Image.PreserveAspectFit
		// 	horizontalAlignment: Image.AlignHCenter
		// 	verticalAlignment: Image.AlignVCenter
		// 	source: "./icon/eye-off.svg"
		// }

	}

	MouseArea {
		id: eyeToggle
		z: 2
		width: inputContainer.height + inputContainer.style.eyeSize
		anchors.top: inputRect.top
		anchors.right: inputRect.right
		anchors.bottom: inputRect.bottom

		onClicked: () => inputContainer.showPassword = !inputContainer.showPassword;
	}

	TextInput {
		id: passwordInputField
		z: 2
		anchors.fill: inputRect
		anchors.leftMargin: Math.round(inputContainer.style.scaledHeight / 2)
		anchors.rightMargin: Math.round(inputContainer.style.scaledHeight / 2) + inputContainer.style.eyeSize
		clip: true
		echoMode: inputContainer.showPassword ? TextInput.Normal : TextInput.Password
		readOnly: inputContainer.disable
		focus: inputContainer.initialFocus
		focusPolicy: Qt.StrongFocus
		inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhHiddenText | Qt.ImhSensitiveData
		color: inputContainer.disable ? inputContainer.style.disabledColor : inputContainer.style.color
		font.family: inputContainer.style.fontFamily
		font.pixelSize: inputContainer.style.fontSize
		// font.bold: true
		// font.weight
		// font.letterSpacing
		wrapMode: TextInput.NoWrap
		passwordMaskDelay: 1000
		// topPadding
		// rightPadding: Math.round(inputContainer.height / 2) + 2
		// leftPadding: Math.round(inputContainer.height / 2) + 2
		// bottomPadding
		horizontalAlignment: inputContainer.showCursor ? TextInput.AlignLeft : TextInput.AlignHCenter
		verticalAlignment: TextInput.AlignVCenter
		cursorDelegate: Component {
			Rectangle {
				id: cursor
				width: inputContainer.showCursor ? 2 : 0
				color: inputContainer.style.cursorColor
				radius: 2
				visible: state.showCursor
				Component.onCompleted: () => {
					if (inputContainer.showCursor) breath.start();
				}
				SequentialAnimation {
					id: breath
					loops: Animation.Infinite
					NumberAnimation {
						target: cursor
						properties: "opacity"
						from: 0
						to: 1
						easing.type: Easing.InQuart
						duration: 750
					}

					NumberAnimation {
						target: cursor
						properties: "opacity"
						from: 1
						to: 0
						easing.type: Easing.InQuart
						duration: 750
					}
				}
			}
		}
		// passwordCharacter
		onTextEdited: () => inputContainer.textChange(passwordInputField.text);

		onActiveFocusChanged: () => {
			if (passwordInputField.activeFocus) {
				inputContainer.focused();
			} else {
				inputContainer.blur();
			}
		}

		onAccepted: () => {
			if (!inputContainer.disable) {
				inputContainer.submit(passwordInputField.text);
			}
		}

		Keys.onEscapePressed: e => {
			passwordInputField.focus = false;
			e.accepted = true;
		}

		Keys.onPressed: e => {
			if (e.key === Qt.Key_CapsLock) {
				inputContainer.capslockOn = !inputContainer.capslockOn;
				return;
			}

			if (e.text.length > 0) {
				let charStr = e.text;

				if (/^[a-zA-Z]$/.test(charStr)) {
					let isUpper = (charStr === charStr.toUpperCase());
					let isShiftPressed = (e.modifiers & Qt.ShiftModifier) !== 0;

					if ((isUpper && !isShiftPressed) || (!isUpper && isShiftPressed)) {
						inputContainer.capslockOn = true;
					} else {
						inputContainer.capslockOn = false;
					}
				}
			}
		}
	}

	Text {
		id: placeholder
		z: 2
		anchors.fill: inputRect
		visible: passwordInputField.text.length === 0
		text: inputContainer.style.placeholderText
		color: inputContainer.style.placeholderColor
		font.family: inputContainer.style.placeholderFontFamily
		font.pixelSize: inputContainer.style.placeholderFontSize
		// font.bold: true
		// font.weight
		// font.letterSpacing
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		textFormat: Text.PlainText
		// topPadding
		// rightPadding
		// leftPadding
		// bottomPadding
	}

	Text {
		id: eyeOn
		z: 2
		anchors.right: inputRect.right
		anchors.rightMargin: Math.round((inputRect.height - inputContainer.style.eyeSize) / 2)
		anchors.verticalCenter: inputRect.verticalCenter

		visible: !inputContainer.showPassword
		text: "\ue648"
		color: inputContainer.style.eyeColor
		font.family: "lockfont"
		font.pixelSize: inputContainer.style.eyeSize
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		textFormat: Text.PlainText
	}

	Text {
		id: eyeOff
		z: 2
		anchors.right: inputRect.right
		anchors.rightMargin: Math.round((inputRect.height - inputContainer.style.eyeSize) / 2)
		anchors.verticalCenter: inputRect.verticalCenter

		visible: inputContainer.showPassword
		text: "\ue67f"
		color: inputContainer.style.eyeColor
		font.family: "lockfont"
		font.pixelSize: inputContainer.style.eyeSize
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		textFormat: Text.PlainText
	}

	MultiEffect {
		id: rectShadow
		source: inputRect
		z: 1
		anchors.fill: inputRect
		shadowEnabled: true
		shadowHorizontalOffset: 0
		shadowVerticalOffset: 4
		shadowBlur: 0.9
		shadowOpacity: 0.5
		shadowScale: 1.05
		shadowColor: {
			if (inputContainer.error) {
				return inputContainer.style.border.error.shadowColor;
			} else if (passwordInputField.activeFocus) {
				return inputContainer.style.border.focus.shadowColor;
			} else {
				return inputContainer.style.border.normal.shadowColor;
			}
		}

		states: State {
			name: "shadowChanged"
			when: passwordInputField.activeFocus
			PropertyChanges {
				target: rectShadow
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

}
