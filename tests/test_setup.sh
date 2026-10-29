#!/bin/bash
# setup.sh 回归测试：用本地 file:// 地址代替官方下载地址，不访问网络
set -eu
ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export TOOLS_DIR="$WORK/tools"
source "$ROOT/setup.sh"

FAILED=0
fail() {
	echo "FAIL $1"
	FAILED=1
}

# 准备假的 jar 和带单个顶层目录的 zip
mkdir -p "$WORK/src/fake-tools-1.0/bin"
echo "jar" > "$WORK/src/fake.jar"
echo "run" > "$WORK/src/fake-tools-1.0/bin/run.sh"
(cd "$WORK/src" && zip -qr fake-tools-1.0.zip fake-tools-1.0)
JAR_SHA="$(sha256_of "$WORK/src/fake.jar")"
ZIP_SHA="$(sha256_of "$WORK/src/fake-tools-1.0.zip")"

TOOLS=(
	"fakejar|file://$WORK/src/fake.jar|$JAR_SHA"
	"fakezip|file://$WORK/src/fake-tools-1.0.zip|$ZIP_SHA"
	"badsha|file://$WORK/src/fake.jar|0000000000000000000000000000000000000000000000000000000000000000"
)

# 1. jar 按工具名保存，并记录校验值
install_tool fakejar > /dev/null || fail "install fakejar"
[ -f "$TOOLS_DIR/fakejar/fakejar.jar" ] || fail "jar should be saved as fakejar.jar"
tool_installed fakejar || fail "fakejar should be marked installed"

# 2. zip 只有一个顶层目录时去掉这一层
install_tool fakezip > /dev/null || fail "install fakezip"
[ -f "$TOOLS_DIR/fakezip/bin/run.sh" ] || fail "zip top-level directory should be flattened"

# 3. 校验值不匹配时安装失败，且不留下任何安装内容
if install_tool badsha > /dev/null; then
	fail "checksum mismatch should fail"
fi
[ ! -e "$TOOLS_DIR/badsha" ] || fail "failed install should not leave files"
[ -z "$(ls -A "$TOOLS_DIR" | grep '^\.download-' || true)" ] || fail "temporary download dir should be removed"

# 4. 已安装时跳过下载：把来源删掉后再次安装仍然成功
rm "$WORK/src/fake.jar"
install_tool fakejar > /dev/null || fail "installed tool should be skipped"

# 5. 未知工具返回非零
if install_tool unknown > /dev/null; then
	fail "unknown tool should fail"
fi

if [ "$FAILED" -ne 0 ]; then
	exit 1
fi
echo "all tests passed"
