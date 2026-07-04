//@ pragma ShellId QSLock
//@ pragma AppId QSLock
pragma ComponentBehavior: Bound

// import Quickshell
import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Services.Pam


WlSessionLock {
	id: screenlock
	locked: true

	WlSessionLockSurface {
		id: screen
		color: "transparent"

		Rectangle {
			id: lockMask
			color: "transparent"
			anchors.fill: parent
			clip: true

			final property bool bgImgTimeout: false

			Rectangle {
				id: lockwrapper
				color: "transparent"
				width: screen.width
				height: screen.height
				x: 0
				y: QSLockConfig.inAnimationEnabled ? -screen.height : 0;

				final property bool showLoading: false


				NumberAnimation {
					id: bgImgIn
					target: lockwrapper
					properties: "y"
					from: -screen.height
					to: 0
					easing.type: Easing.OutBounce
					duration: 600
					onStopped: () => QSLockConfig.autoFocus && passwordInput.setFocus(true);
				}

				NumberAnimation {
					id: bgImgOut
					target: lockwrapper
					properties: "y"
					from: 0
					to: -screen.height
					easing.type: Easing.OutQuad
					duration: 300
					onStopped: () => (screenlock.locked = false, Qt.quit());
				}

				Image {
					id: bgImg
					visible: false
					anchors.fill: parent
					// focus: false
					z: 0
					asynchronous: true
					cache: true
					currentFrame: 0
					mipmap: true
					retainWhileLoading: true
					fillMode: Image.PreserveAspectCrop
					horizontalAlignment: Image.AlignHCenter
					verticalAlignment: Image.AlignVCenter
					source: QSLockConfig.wallpaper
					onStatusChanged: () => {
						if (QSLockConfig.inAnimationEnabled && !lockMask.bgImgTimeout && bgImg.status === Image.Ready) {
							bgImgIn.start();
						} else if (bgImg.status === Image.Error) {
							lockwrapper.y = 0;
							lockMask.color = "#ffffff"
							errorMsg.visible = true;
						}
					}
				}

				MultiEffect {
					id: imageBlur
					z: 1
					visible: true
					source: bgImg
					anchors.fill: parent
					autoPaddingEnabled: false
					blurEnabled: blur > 0.0
					blur: 0.0
					blurMax: QSLockConfig.wallpaperBlur
					paddingRect: Qt.rect(0, 0, screen.width, screen.height)


					states: State {
						name: "blurChanged"
						when: passwordInput.focusStatus
						PropertyChanges {
							target: imageBlur
							blur: 1.0
						}
					}

					transitions: Transition {
						NumberAnimation {
							properties: "blur"
							easing.type: Easing.OutQuad
							duration: 400
						}
					}
				}

				Avatar {
					id: avatar
					z: 2
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenterOffset: QSLockConfig.avatarStyle.offsetX
					anchors.verticalCenterOffset: QSLockConfig.avatarStyle.offsetY
					visible: QSLockConfig.avatarEnabled
					style: QSLockConfig.avatarStyle
					transformStart: passwordInput.focusStatus
					src: QSLockConfig.avatarImage
				}

				PasswordInput {
					id: passwordInput
					z: 2
					anchors.horizontalCenterOffset: QSLockConfig.passwordInputStyle.offsetX
					anchors.verticalCenterOffset: QSLockConfig.passwordInputStyle.offsetY
					initialFocus: QSLockConfig.inAnimationEnabled ? false : QSLockConfig.autoFocus
					showPassword: QSLockConfig.showPassword
					showCursor: QSLockConfig.showCursor
					style: QSLockConfig.passwordInputStyle
					onSubmit: text => {
						lockwrapper.submit(text);
					}

					onTextChange: (text) => {
						if (text.length > 0) {
							passwordInput.error = false;
						}
					}

					onBlur: () => hintMsg.clear();
				}

				Text {
					id: hintMsg
					z: 2
					anchors.horizontalCenter: passwordInput.horizontalCenter
					anchors.top: passwordInput.bottom
					anchors.topMargin: QSLockConfig.hintStyle.offsetY
					visible: passwordInput.focusStatus && (passwordInput.capslockOn || hintMsg.error)
					width: QSLockConfig.hintStyle.width
					text: QSLockConfig.hintStyle.text
					color: QSLockConfig.hintStyle.color
					font.family: QSLockConfig.hintStyle.fontFamily
					font.pixelSize: QSLockConfig.hintStyle.fontSize
					// font.bold: true
					// font.weight
					// font.letterSpacing
					wrapMode: Text.WordWrap
					// width
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					textFormat: Text.PlainText
					// topPadding  
					// rightPadding  
					// leftPadding  
					// bottomPadding  

					readonly property color errorColor: QSLockConfig.hintStyle.errorColor
					readonly property color warnColor: QSLockConfig.hintStyle.color
					property bool error: false

					function errorMsg(msg: string) {
						hintMsg.text = msg;
						hintMsg.error = true;
						hintMsg.color = QSLockConfig.hintStyle.errorColor;
					}

					function clear() {
						hintMsg.text = QSLockConfig.hintStyle.text;
						hintMsg.error = false;
						hintMsg.color = QSLockConfig.hintStyle.color;
					}
				}

				Loading {
					z: 2
					color: QSLockConfig.loadingColor
					size: QSLockConfig.loadingSize
					show: lockwrapper.showLoading
					anchors.left: passwordInput.right
					anchors.leftMargin: QSLockConfig.loadingOffsetX
					anchors.verticalCenter: passwordInput.verticalCenter
					anchors.topMargin: QSLockConfig.loadingOffsetY
				}

				Clock {
					id: clock
					z: 2
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.topMargin: QSLockConfig.clockStyle.offsetY
					anchors.leftMargin: QSLockConfig.clockStyle.offsetX
					style: QSLockConfig.clockStyle
					visible: QSLockConfig.clockEnabled
				}

				Date {
					z: 2
					anchors.top: clock.bottom
					anchors.horizontalCenter: clock.horizontalCenter
					anchors.topMargin: QSLockConfig.dateStyle.offsetY
					style: QSLockConfig.dateStyle
					visible: QSLockConfig.dateEnabled
				}

				SequentialAnimation {
					id: shakeAnim
					NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; from: 0;   to: 10;  duration: 50; easing.type: Easing.OutQuad }
					NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; from: 10;  to: -10; duration: 50; easing.type: Easing.OutQuad }
					NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; from: -10; to: 10;  duration: 50; easing.type: Easing.OutQuad }
					NumberAnimation { target: passwordInput; property: "anchors.horizontalCenterOffset"; from: 10;  to: 0;   duration: 50; easing.type: Easing.OutQuad }
				}

				PamContext {
					id: auth
					// user
					configDirectory: QSLockConfig.pamDir
					config: QSLockConfig.pamFile

					final property string msg: ""

					onPamMessage: () => {
						if (auth.responseRequired) {
							auth.respond(passwordInput.text);
						}
						auth.msg += auth.message + "\n";
						console.log("PAM: " + auth.message);
					}

					onCompleted: result => {
						lockwrapper.showLoading = false;
						passwordInput.setFocus(true);
						switch (result) {
							case PamResult.Success:
								passwordInput.disable = false;
								if (QSLockConfig.outAnimationEnabled) {
									bgImgOut.start();
								} else {
									screenlock.locked = false;
									Qt.quit();
								}
								break;
							case PamResult.Failed:
								passwordInput.disable = false;
								passwordInput.error = true;
								passwordInput.setFocus(true);
								shakeAnim.start();
								console.error("PAM Message: " + auth.msg);
								console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
								break;
							case PamResult.MaxTries:
								passwordInput.disable = true;
								passwordInput.error = true;
								maxTriesLock.start();
								hintMsg.errorMsg("Too many failed attempts. Please try again later.");
								console.error("QSLockError: Too many failed attempts. Please try again later.");
								console.error("PAM Message: " + auth.msg);
								break;
							case PamResult.Error:
								passwordInput.disable = false;
								passwordInput.error = true;
								shakeAnim.start();
								console.error("QSLockError: Unknown error.");
								console.error("PAM Message: " + auth.msg);
								console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
								break;
							default:
								console.log("QSLockCompleted: unreachable");
								break;
						}
						auth.msg = "";
					}
					onError: err => {
						lockwrapper.showLoading = false;
						passwordInput.disable = false;
						passwordInput.error = true;
						passwordInput.setFocus(true);
						shakeAnim.start();
						if (err == PamError.InternalError) {
							hintMsg.errorMsg("An error occurred inside quickshell’s pam interface.");
							console.error("QSLockError: An error occurred inside quickshell’s pam interface.");
						} else if (err == PamError.TryAuthFailed) {
							hintMsg.errorMsg("QSLockError: TryAuthFailed.");
							console.error("QSLockError: TryAuthFailed.");
						} else if (err == PamError.StartFailed) {
							hintMsg.errorMsg("QSLockError: StartFailed.");
							console.error("QSLockError: StartFailed.");
						} else {
							console.log("QSLockError: unreachable");
						}
						console.error("PAM Message: " + auth.msg);
						console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
						auth.msg = "";
					}
				}

				IdleMonitor {
					id: autoBlur
					enabled: QSLockConfig.autoBlurTimeout > 0
					timeout: QSLockConfig.autoBlurTimeout

					onIsIdleChanged: () => autoBlur.isIdle && passwordInput.setFocus(false);
				}

				Timer {
					id: maxTriesLock
					interval: QSLockConfig.maxTriesLockedTimeout * 1000

					onTriggered: () => passwordInput.disable = false;
				}

				Shortcut {
					sequences: ["Return", "Enter"]
					onActivated: e => {
						if (passwordInput.text.length === 0) {
							passwordInput.setFocus(true);
						} else {
							lockwrapper.submit(passwordInput.text);
						}
					}
				}


				function submit(text: string) {
					if (text.length === 0) {
						passwordInput.error = true;
						return;
					} else if (auth.active || passwordInput.disable) {
						return;
					} else {
						passwordInput.error = false;
						passwordInput.disable = true;
						lockwrapper.showLoading = true

						if (!auth.start()) {
							shakeAnim.start();
							lockwrapper.showLoading = false;
						}
					}
				}

			}

			Text {
				id: errorMsg
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 200
				visible: false
				width: 500
				text: "Failed to load image: " + QSLockConfig.wallpaper
				color: "#333333"
				font.pixelSize: 24
				wrapMode: Text.WordWrap
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				textFormat: Text.PlainText
			}


			Timer {
				id: whiteBg
				interval: 1000

				onTriggered: () => !bgImgIn.running && (lockMask.color = "#ffffff", lockMask.bgImgTimeout = true)
			}

		}
	}

}
