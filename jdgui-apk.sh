#!/bin/sh

# 校验参数合法性
source util.sh
check $1

# 得到新的目录
newfoldername=$foldername
rm -rf $newfoldername

# 判断目录是否为空
function isEmptyDir(){ 
    return `ls -A $1|wc -w`
}

# 执行apktool命令
sh ../tools/apktool/apktool d -f $absolutename

# 判断目录是否存在，不存在证明执行apktool命令出现异常
if [ ! -d "$foldername" ];
	then
	echo "Resource files decompile failed"
	exit
fi

# 判断目录是否为空，为空证明执行apktool命令出现异常
if isEmptyDir $foldername;
	then
	echo "Resource files decompile failed"
	exit
fi

# 执行apktool命令成功
echo "Resource files decompile successful"

# 切换到之前文件名创建的目录中
cd $foldername
echo `pwd`

# 执行dex2jar命令
sh ../../tools/dex2jar/d2j-dex2jar.sh $absolutename
suffix="-dex2jar.jar"
jarname=${foldername}${suffix}

# 判断是否生成后缀为-dex2jar.jar的文件
if [ ! -f "$jarname" ];
	then
	echo "Dex file decompile failed"
	exit
fi

# 执行dex2jar命令成功
echo "Dex file decompile successful"

# 打印生成后缀为-dex2jar.jar的文件的路径
path=`pwd`
pathname=${path}"/"${jarname}
echo ${pathname}

# 通过jd-gui查看jar文件
echo "View the decompile file"

# 执行jd-gui命令
java -jar ../../tools/jd-gui/jd-gui.jar $jarname