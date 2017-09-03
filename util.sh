#!/bin/sh

# 校验参数合法性
function check() {

	# 判断是否有参数
	if [ $# -ne 1 ]; 
		then
		echo "Please input an apk file"
		exit
	fi

	# 提取真实参数名称
	export param=$1
	# 提取路径中的文件名
	export filename=${param##*/}
	# 通过文件名命名目录
	export foldername=${filename%.apk}
	# 获取参数的绝对路径
	export absolutename=$(cd `dirname $param`; pwd)"/"${filename}

	# 参数长度
	local len=${#filename}

	# 判断参数长度是否合法（.apk占4个字符）
	if [ $len -le 4 ];
		then
		echo "Please input a correct apk file"
		exit
	fi

	# 判断参数后缀是否为.apk
	if [ "${filename##*.}"x != "apk"x ];
		then
		echo "Please input a correct apk file"
		exit
	fi

	# 创建output目录作为输出目录
	local output="output"
	if [ ! -d "$output" ];
		then
		mkdir $output
	fi

	# 切换到output目录
	cd $output

}