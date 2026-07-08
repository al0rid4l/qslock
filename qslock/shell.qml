//@ pragma ShellId qslock
//@ pragma AppId qslock
pragma ComponentBehavior: Bound

// import Quickshell
import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pam


WlSessionLock {
	id: screenlock
	locked: true
	final property string token: ""
	final property int uid: 1000

	function compare(str1: string, str2: string): bool {
		let lengthMismatch = (str1.length !== str2.length);
		let a = lengthMismatch ? str1 : str1;
		let b = lengthMismatch ? str1 : str2;

		let result = 0;
		let maxLength = Math.max(a.length, b.length);

		for (let i = 0; i < maxLength; i++) {
			let charA = i < a.length ? a.charCodeAt(i) : 0;
			let charB = i < b.length ? b.charCodeAt(i) : 0;
			result |= (charA ^ charB);
		}
		return (result === 0) && !lengthMismatch;
	}

	IpcHandler {
		target: 'qslock'

		function unlock(token: string): bool {
			let resultl = screenlock.compare(token, screenlock.token);
			if (result) {
				ipcUnlockTimer.interval = 1000 + Math.random() * 2000;
				ipcUnlockTimer.restart();
			}
			return result;
		}
	}

	WlSessionLockSurface {
		id: screen
		color: "transparent"

		onVisibleChanged: () => {
			// 亮屏触发howdy
			if (!auth.active && !auth.firstStart && screen.visible && !passwordInput.disable && !bgImgIn.running) {
				auth.start();
			}
		}

		Component.onCompleted: () => {
			uidFetcher.running = true;
		}

		Process {
			id: uidFetcher
			command: ["sh", "-c", "id -u"]
			stdout: StdioCollector {
				onStreamFinished: function() {
					screenlock.uid = this.text;
					tokenGen.running = true;
				}
			}
		}


		Process {
			id: fileWriter
			command: []
		}


		Process {
			id: tokenGen
			command: ["sh", "-c", "head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'"]
			stdout: StdioCollector {
				onStreamFinished: function() {
					screenlock.token = this.text.trim();
					let file = '/run/user/' + screenlock.uid + '/qslocktoken';
					let cmd = "echo '" + screenlock.token + "' >" + file + " && chmod 600 " + file;
					fileWriter.command = ["sh", "-c", cmd];
					fileWriter.running = true;
				}
			}
		}

		Timer {
			id: ipcUnlockTimer
			interval: 3000
			onTriggered: () => screenlock.locked = false;
		}

		// 快捷键触发howdy
		Shortcut {
			id: howdyShortcut
			enabled: {
				if (QSLockConfig.howdyKeys && QSLockConfig.howdyKeys.length > 0) {
					for (const key of QSLockConfig.howdyKeys) {
						let normalizedStr = key.toString().toLowerCase().trim();
						if (normalizedStr === 'enter' || normalizedStr === 'return') {
							return false;
						}
					}
					return true;
				} else {
					return false;
				}
			}
			sequences: QSLockConfig.howdyKeys
			onActivated: e => {
				if (!auth.active && !bgImgIn.running) {
					auth.firstStart = false;
					auth.start();
				}
			}
		}

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
					id: debugMsg
					z: 5
					visible: false
					color: '#ffffff'
					font.pixelSize: 60
					text: 'DEBUG'
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
						return true;
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

				Timer {
					id: howdyCoolDownTimer
					interval: QSLockConfig.howdyCooldown
					onTriggered: () => {
						if (!auth.active && !lockwrapper.showLoading) {
							auth.start();
						}
					}
				}

				PamContext {
					id: auth
					// user
					configDirectory: QSLockConfig.pamDir
					config: QSLockConfig.pamFile

					final property string allMsg: ""
					final property string maxTriesMsg: ""
					final property bool firstStart: true
					final property var authQueue: []

					onPamMessage: () => {
						if (auth.responseRequired) {
							if (auth.authQueue.length) {
								let request = auth.authQueue.shift();
								request();
							} else {
								// howdy失败或没有howdy的第一次后台认证失败不需要处理
							}
						} else {
							// 不重要的消息不需要处理
						}

						if (/locked/g.test(auth.message)) {
							auth.maxTriesMsg = auth.message;
						}
						auth.allMsg += auth.message + "\n";
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
							case PamResult.MaxTries:
								if (auth.maxTriesMsg.length > 0) {
									hintMsg.errorMsg(auth.maxTriesMsg);
									// passwordInput.disable = true;
									// maxTriesLock.start();
								}
								if (auth.authQueue.length) {
									let request = auth.authQueue.shift();
									request();
									break;
								}
								passwordInput.disable = false;
								passwordInput.error = true;
								passwordInput.setFocus(true);
								shakeAnim.start();
								console.error("PAM Message: " + auth.allMsg);
								console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
								break;
							case PamResult.Error:
								passwordInput.disable = false;
								passwordInput.error = true;
								shakeAnim.start();
								console.error("QSLockError: Unknown error.");
								console.error("PAM Message: " + auth.allMsg);
								console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
								break;
							default:
								console.log("QSLockCompleted: unreachable");
								break;
						}
						auth.allMsg = "";
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
						console.error("PAM Message: " + auth.allMsg);
						console.error("PAM file: " + auth.configDirectory + "/" + auth.config);
						auth.allMsg = "";
					}

					Component.onCompleted: () => {
						howdyCoolDownTimer.restart();
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
					triggeredOnStart: true
					onTriggered: () => hintMsg.clear() && (passwordInput.disable = false);
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

				function debug(text: string) {
					debugMsg.visible = true;
					debugMsg.text = text;
					console.log("QSLock DEBUG: " + text);
				}

				function submit(text: string) {
					if (text.length === 0) {
						passwordInput.error = true;
						return;
					} else if (passwordInput.disable || bgImgIn.running) {
						return;
					} else {
						passwordInput.error = false;
						passwordInput.disable = true;
						lockwrapper.showLoading = true

						if (auth.active) {
							if (auth.responseRequired) {
								auth.respond(text);
							} else {
								// howdy
								auth.authQueue.push(() => {
									auth.respond(text);
								});
							}
						} else {
							auth.authQueue.push(() => {
								auth.respond(text);
							});
							if (!auth.start()) {
								shakeAnim.start();
								lockwrapper.showLoading = false;
							}
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
