pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick

QtObject {
	// 背景图URL
	final readonly property url wallpaper: "/home/aidev/bg.png"
	// 背景图模糊半径
	final readonly property int wallpaperBlur: 50
	// PAM文件名,不包含目录
	final readonly property string pamFile: "login"
	// PAM路径名
	final readonly property string pamDir: "/etc/pam.d"
	// 自动聚焦密码输入框
	final readonly property bool autoFocus: true
	// 超时密码输入框自动失去焦点,秒,0则不自动失焦
	final readonly property real autoBlurTimeout: 300
	// 最大尝试次数锁定时间,秒
	final readonly property int maxTriesLockedTimeout: 600
	// 是否启用载入动画
	final readonly property bool inAnimationEnabled: true
	final readonly property bool outAnimationEnabled: false

	// 显示明文密码
	final readonly property bool showPassword: false
	// 显示光标
	final readonly property bool showCursor: true
	// 密码输入框样式
	final readonly property InputStyle passwordInputStyle: InputStyle {
		// 默认宽高
		width: 200
		height: 48
		// 缩放后宽高
		scaledWidth: 260
		scaledHeight: 54
		// 相对屏幕中心偏移
		offsetX: 0
		offsetY: 80

		// 输入框背景色
		bgColor: "#fffaf3"
		// disable时输入框背景色
		disabledBgColor: "#eff1f5"

		// 文本颜色
		color: "#464261"
		// disable时文本颜色
		disabledColor: "#5c5f77"
		fontSize: 18
		fontFamily: ""

		// placeholder文本
		placeholderText: "Password"
		placeholderColor: "#9893a5"
		placeholderFontSize: 18
		placeholderFontFamily: ""

		// 眼睛图标颜色和大小
		eyeColor: "#393552"
		eyeSize: 22

		// 光标颜色
		cursorColor: "#2a273f"

		// 边框样式
		border {
			width: 4
			radius: 54
			//缩放后圆角半径
			scaledRadius: 16

			focus {
				color: "#907aa9"
				shadowColor: "#232136"
			}

			normal {
				color: "#8caaee"
				shadowColor: "#5c5f77"
			}

			error {
				color: "#ed8796"
				shadowColor: "#5c5f77"
			}

			disable {
				color: "#9ca0b0"
				shadowColor: "#5c5f77"
			}
		}
	}
	// 错误提示样式
	final readonly property HintStyle hintStyle: HintStyle {
		width: 400
		// 相对密码输入框偏移
		offsetX: 0
		offsetY: 20

		color: "#df8e1d"
		errorColor: "#e64553"

		fontSize: 22
		fontFamily: ""

		text: "Caps Lock is on."
	}

	// loading样式
	final readonly property color loadingColor: "#444444"
	final readonly property real loadingSize: 32
	// 相对密码输入框右边框偏移
	final readonly property real loadingOffsetX: 60
	final readonly property real loadingOffsetY: 0

	// 头像设置
	final readonly property bool avatarEnabled: true
	final readonly property url avatarImage: "/usr/local/share/avatar/avatar-1.jpg"
	final readonly property AvatarStyle avatarStyle: AvatarStyle {
		width: 160
		height: 160
		// 相对屏幕中心
		offsetX: 0
		offsetY: -70
		// 密码输入框焦点时缩放大小
		scale: 1.1
		// hover时旋转角度
		rotation: 60

		border {
			width: 4
			radius: 150

			normal {
				color: "#cad3f5"
				shadowColor: "#414559"
			}

			focus {
				color: "#cad3f5"
				shadowColor: "#414559"
			}
		}
	}


	// 时钟配置
	final readonly property bool clockEnabled: true
	final readonly property DateClockStyle clockStyle: DateClockStyle {
		color: "#f2e9e1"
		format: "hh:mm"
		fontFamily: ""
		fontSize: 120
		fontBold: true
		fontWeight: 500
		shadowEnabled: true
		shadowColor: "#464261"
		// 相对屏幕中心,需要其他对齐方式去代码改吧
		offsetX: 80
		offsetY: 120
	}

	// 日期配置
	final readonly property bool dateEnabled: true
	final readonly property DateClockStyle dateStyle: DateClockStyle {
		color: "#faf4ed"
		format: "ddd,MMM dd"
		fontFamily: ""
		fontSize: 48
		fontBold: true
		fontWeight: 400
		shadowEnabled: true
		shadowColor: "#797593"
		// 相对时钟center bottom,需要其他对齐方式去代码改吧
		offsetY: 10
	}
}
