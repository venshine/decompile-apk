#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# 校验参数合法性
source "$SCRIPT_DIR/util.sh"
check "$@"
ensure_tool classyshark

# 得到新的目录，清理上次的输出（只删除本工具自己的目录）
newfoldername="${foldername}-classyshark"
rm -rf "$newfoldername"
mkdir -p "$newfoldername"

# 切换到创建的目录
cd "$newfoldername"

# 打印该目录的路径
pwd

# 通过ClassyShark查看apk文件
echo "View the decompile file"

# 执行ClassyShark命令
#java -jar "$TOOLS_DIR/classyshark/classyshark.jar" -export "$absolutename"
java -jar "$TOOLS_DIR/classyshark/classyshark.jar" -open "$absolutename"
