#!/bin/bash

# 反编译工具所在目录，首次使用时由 setup.sh 从官方 Release 下载
export TOOLS_DIR="${TOOLS_DIR:-$SCRIPT_DIR/tools}"

# 确保工具已安装，未安装或版本不一致时自动下载
function ensure_tool() {
	if ! command -v java > /dev/null 2>&1; then
		echo "Java is not installed. Please install JDK 17 or later and try again."
		exit 1
	fi
	if ! bash "$SCRIPT_DIR/setup.sh" "$1"; then
		echo "Failed to install $1, please check your network and run: bash setup.sh $1"
		exit 1
	fi
}

# 校验参数合法性
function check() {

	# 判断是否有参数
	if [ $# -ne 1 ];
		then
		echo "Please input an apk file"
		exit 1
	fi

	# 提取真实参数名称
	export param="$1"
	# 提取路径中的文件名
	export filename="${param##*/}"
	# 通过文件名命名目录
	export foldername="${filename%.apk}"

	# 参数长度
	local len=${#filename}

	# 判断参数长度是否合法（.apk占4个字符）
	if [ $len -le 4 ];
		then
		echo "Please input a correct apk file"
		exit 1
	fi

	# 判断参数后缀是否为.apk
	if [ "${filename##*.}"x != "apk"x ];
		then
		echo "Please input a correct apk file"
		exit 1
	fi

	# 判断文件是否存在
	if [ ! -f "$param" ];
		then
		echo "File not found: $param"
		exit 1
	fi

	# 获取参数的绝对路径
	export absolutename="$(cd "$(dirname "$param")" && pwd)/${filename}"

	# 创建output目录作为输出目录，并切换到该目录
	mkdir -p output
	cd output

}
