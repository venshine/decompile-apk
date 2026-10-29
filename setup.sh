#!/bin/bash
# 从各工具的官方 GitHub Release 下载反编译工具，并校验 SHA-256
# 用法：bash setup.sh [工具名...]，不带参数时安装全部工具；已安装且版本一致的工具会跳过
# 工具名：apktool dex2jar jd-gui jadx classyshark bytecode-viewer

SETUP_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${TOOLS_DIR:-$SETUP_SCRIPT_DIR/tools}"

# 工具名|下载地址|SHA-256
# 前四个的 SHA-256 取自 GitHub Release 附件的官方摘要；
# jd-gui 与 ClassyShark 上游已停更且未提供摘要，其值与本仓库 2019 年起内置的同版本 jar 一致
TOOLS=(
	"apktool|https://github.com/iBotPeaches/Apktool/releases/download/v3.0.3/apktool_3.0.3.jar|dbf930b076c6b9be08d57c449cacefc3bdd6b71ebd59b3066fc0e1f5b14f9423"
	"dex2jar|https://github.com/ThexXTURBOXx/dex2jar/releases/download/2.4.38/dex-tools-2.4.38.zip|5d88e269bd120852fec68de268f6900f5466601e06ca8c16611f4377c6254e5c"
	"jadx|https://github.com/skylot/jadx/releases/download/v1.5.6/jadx-1.5.6.zip|545ea2be9c242511bc145755cf4bda2485ade42966e096f8b4d3da2a230e8974"
	"bytecode-viewer|https://github.com/Konloch/bytecode-viewer/releases/download/v2.13.2/Bytecode-Viewer-2.13.2.jar|2e23ead17825711bfbf25ffbc6c6af32ca89b057a8e7ccb856cc096ed7f83516"
	"jd-gui|https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar|2c9d3efa8b06438a7284139f68f6efcbfb2a11e0b9d20a3370d50189685afc0b"
	"classyshark|https://github.com/google/android-classyshark/releases/download/8.2/ClassyShark.jar|b3bd94ce2177f2423183070c3dd096cb9b695a70e8e04d8d7d3cca530d9b855d"
)

# 输出某个工具的配置行，未知工具返回非零
function tool_entry() {
	local entry
	for entry in "${TOOLS[@]}"; do
		if [ "${entry%%|*}" = "$1" ]; then
			echo "$entry"
			return 0
		fi
	done
	return 1
}

# 计算文件的 SHA-256（兼容 macOS 与 Linux）
function sha256_of() {
	if command -v sha256sum > /dev/null 2>&1; then
		sha256sum "$1" | awk '{print $1}'
	else
		shasum -a 256 "$1" | awk '{print $1}'
	fi
}

# 下载文件并校验，校验失败时删除下载内容并返回非零
function download_verified() {
	local url="$1" sha="$2" dest="$3"
	if ! curl -fL --retry 3 --connect-timeout 20 -o "$dest" "$url"; then
		echo "Download failed: $url"
		rm -f "$dest"
		return 1
	fi
	local actual
	actual="$(sha256_of "$dest")"
	if [ "$actual" != "$sha" ]; then
		echo "Checksum mismatch for $url"
		echo "  expected: $sha"
		echo "  actual:   $actual"
		rm -f "$dest"
		return 1
	fi
}

# 安装记录与配置的校验值一致时视为已安装
function tool_installed() {
	local entry sha
	entry="$(tool_entry "$1")" || return 1
	sha="${entry##*|}"
	[ "$(cat "$TOOLS_DIR/$1/.sha256" 2>/dev/null)" = "$sha" ]
}

# 安装单个工具到 tools/<工具名>/
function install_tool() {
	local name="$1" entry url sha
	if ! entry="$(tool_entry "$name")"; then
		echo "Unknown tool: $name"
		return 1
	fi
	if tool_installed "$name"; then
		return 0
	fi
	url="${entry#*|}"
	url="${url%%|*}"
	sha="${entry##*|}"

	echo "Downloading $name from $url"
	mkdir -p "$TOOLS_DIR"
	local work
	work="$(mktemp -d "$TOOLS_DIR/.download-$name.XXXXXX")"
	local file="$work/${url##*/}"
	if ! download_verified "$url" "$sha" "$file"; then
		rm -rf "$work"
		return 1
	fi

	local target="$work/$name"
	mkdir -p "$target"
	case "$file" in
		*.zip)
			unzip -q "$file" -d "$target"
			# 压缩包只有一个顶层目录时（如 dex-tools-2.4.38/），去掉这一层
			local entries
			entries=("$target"/*)
			if [ ${#entries[@]} -eq 1 ] && [ -d "${entries[0]}" ]; then
				mv "${entries[0]}" "$work/flatten"
				rmdir "$target"
				mv "$work/flatten" "$target"
			fi
			;;
		*)
			# jar 统一按工具名命名，脚本中的路径不随版本变化
			mv "$file" "$target/$name.jar"
			;;
	esac
	echo "$sha" > "$target/.sha256"

	rm -rf "${TOOLS_DIR:?}/$name"
	mv "$target" "$TOOLS_DIR/$name"
	rm -rf "$work"
	echo "Installed $name"
}

# 直接执行时安装指定工具（默认全部）；被 source 时只提供函数
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	set -u
	if [ $# -eq 0 ]; then
		set -- $(for entry in "${TOOLS[@]}"; do echo "${entry%%|*}"; done)
	fi
	status=0
	for name in "$@"; do
		install_tool "$name" || status=1
	done
	exit $status
fi
