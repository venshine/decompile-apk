#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# 校验参数合法性：jadx 除了 apk，还支持 dex / jar / aar
source "$SCRIPT_DIR/util.sh"
CHECK_EXTENSIONS="apk dex jar aar"
check "$@"
ensure_tool jadx

# 得到新的目录
newfoldername="${foldername}-jadx"
rm -rf "$newfoldername"

# 通过jadx-gui查看apk文件
echo "View the decompile file"

# 执行jadx命令
#sh "$TOOLS_DIR/jadx/bin/jadx" -d "$newfoldername" "$absolutename"

# 执行jadx-gui命令
sh "$TOOLS_DIR/jadx/bin/jadx-gui" "$absolutename"
