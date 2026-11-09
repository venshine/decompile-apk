#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# 校验参数合法性
source "$SCRIPT_DIR/util.sh"
check "$@"
ensure_tool bytecode-viewer

# 通过Bytecode-Viewer查看apk文件
echo "View the decompiled file"

# 在 GUI 中打开 apk。不用 -i/-o/-t：2.13.2 的命令行反编译不可用，这些参数会被当成文件名打开
java -jar "$TOOLS_DIR/bytecode-viewer/bytecode-viewer.jar" "$absolutename"
