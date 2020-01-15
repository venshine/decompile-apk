#!/bin/sh

arg=$1

function input() {
	# true 显示以下信息，false不显示
	if [ $1 = true ]; 
		then
		echo "You can choose the following three ways to decompile an apk file"
		echo "1: using apktool/dex2jar/jd-gui to decompile apk"
		echo "2: using ClassyShark to decompile apk"
		echo "3: using jadx to decompile apk"
		echo "4: using bytecode-viewer to decompile apk"
		echo "q: exit"
	fi

	#echo "Please input your choice(1, 2, 3, 4):"
	read -p "Please input your choice(1, 2, 3, 4):" input
	
	case $input in
		1)
		## 执行jdgui-apk命令
		sh jdgui-apk.sh $arg
		;;
		2)
		## 执行classyshark-apk命令
		sh classyshark-apk.sh $arg
		;;
		3)
		## 执行jadx-apk命令
		sh jadx-apk.sh $arg
		;;
		4)
		## 执行bytecode-viewer-apk命令
		sh bytecode-viewer.sh $arg
		;;
		q)
		## 退出命令
		exit
		;;
		*)
		## 输入其他字符重新选择
		input false
		;;
	esac
}

input true