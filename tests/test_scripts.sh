#!/bin/bash
# 端到端回归测试：用假的 java 命令替代 GUI 工具，只校验脚本的路径与目录处理
set -eu
ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 假 java：记录参数后直接返回
mkdir -p "$WORK/bin"
cat > "$WORK/bin/java" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$JAVA_ARGS_LOG"
EOF
chmod +x "$WORK/bin/java"
export PATH="$WORK/bin:$PATH"
export JAVA_ARGS_LOG="$WORK/java_args.log"

# 预先放好「已安装」的工具，避免测试时真的下载
export TOOLS_DIR="$WORK/tools"
source "$ROOT/setup.sh"
for entry in "${TOOLS[@]}"; do
	name="${entry%%|*}"
	mkdir -p "$TOOLS_DIR/$name"
	echo "${entry##*|}" > "$TOOLS_DIR/$name/.sha256"
done

FAILED=0
fail() {
	echo "FAIL $1"
	FAILED=1
}

# 准备一个带空格路径的 apk，并从仓库以外的目录调用脚本
mkdir -p "$WORK/my apks" "$WORK/run dir"
echo "dummy" > "$WORK/my apks/sample.apk"
cd "$WORK/run dir"

# 1. classyshark 不应删除 jd-gui 方式的输出目录 output/sample
mkdir -p output/sample
touch output/sample/keep
bash "$ROOT/classyshark-apk.sh" "$WORK/my apks/sample.apk" > /dev/null 2>&1 || fail "classyshark-apk.sh exited with error"
[ -f output/sample/keep ] || fail "classyshark-apk.sh removed output/sample"
[ -d output/sample-classyshark ] || fail "classyshark-apk.sh did not create output dir"
grep -qx "$WORK/my apks/sample.apk" "$JAVA_ARGS_LOG" 2>/dev/null || fail "classyshark-apk.sh passed wrong apk path"

# 2. bytecode-viewer 应能在任意目录下运行，并且同样不删除 output/sample
rm -f "$JAVA_ARGS_LOG"
bash "$ROOT/bytecode-viewer.sh" "$WORK/my apks/sample.apk" > /dev/null 2>&1 || fail "bytecode-viewer.sh exited with error"
[ -f output/sample/keep ] || fail "bytecode-viewer.sh removed output/sample"
grep -qx "$TOOLS_DIR/bytecode-viewer/bytecode-viewer.jar" "$JAVA_ARGS_LOG" 2>/dev/null || fail "bytecode-viewer.sh used wrong jar path"

# 3. 参数错误时应返回非零退出码
if bash "$ROOT/jadx-apk.sh" "$WORK/my apks/missing.apk" > /dev/null 2>&1; then
	fail "jadx-apk.sh should fail for a missing apk"
fi
if bash "$ROOT/jadx-apk.sh" > /dev/null 2>&1; then
	fail "jadx-apk.sh should fail without arguments"
fi

if [ "$FAILED" -ne 0 ]; then
	exit 1
fi
echo "all tests passed"
