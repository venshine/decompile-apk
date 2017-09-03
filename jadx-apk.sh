#!/bin/sh

# 校验参数合法性
source util.sh
check $1

# 得到新的目录
newfoldername=${foldername}"-jadx"
rm -rf $newfoldername

# 通过jadx-gui查看apk文件
echo "View the decompile file"

# 执行jadx命令
#sh ../tools/jadx/bin/jadx -d $newfoldername $absolutename

# 执行jadx-gui命令
sh ../tools/jadx/bin/jadx-gui $absolutename