#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# 校验参数合法性
source "$SCRIPT_DIR/util.sh"
check "$@"
ensure_tool apktool
ensure_tool dex2jar
ensure_tool jd-gui

# 得到新的目录
newfoldername="$foldername"
rm -rf "$newfoldername"

# 判断目录是否为空
function isEmptyDir(){
	[ -z "$(ls -A "$1")" ]
}

# 执行apktool命令（apktool 3 默认输出到 <apk>.out，这里显式指定目录名）
java -jar "$TOOLS_DIR/apktool/apktool.jar" d -f "$absolutename" -o "$foldername"

# 判断目录是否存在，不存在证明执行apktool命令出现异常
if [ ! -d "$foldername" ];
	then
	echo "Resource files decompile failed"
	exit 1
fi

# 判断目录是否为空，为空证明执行apktool命令出现异常
if isEmptyDir "$foldername";
	then
	echo "Resource files decompile failed"
	exit 1
fi

# 执行apktool命令成功
echo "Resource files decompile successful"

# 切换到之前文件名创建的目录中
cd "$foldername"
pwd

# 执行dex2jar命令
suffix="-dex2jar.jar"
jarname="${foldername}${suffix}"
sh "$TOOLS_DIR/dex2jar/d2j-dex2jar.sh" -f -o "$jarname" "$absolutename"

# 判断是否生成后缀为-dex2jar.jar的文件
if [ ! -f "$jarname" ];
	then
	echo "Dex file decompile failed"
	exit 1
fi

# 执行dex2jar命令成功
echo "Dex file decompile successful"

# 打印生成后缀为-dex2jar.jar的文件的路径
echo "$(pwd)/${jarname}"

# 通过jd-gui查看jar文件
echo "View the decompile file"

# 执行jd-gui命令
java -jar "$TOOLS_DIR/jd-gui/jd-gui.jar" "$jarname"
