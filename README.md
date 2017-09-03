# decompile-apk
The decompile-apk tool consists of some scripts and different tools, it can provider auto decompile function for produce Java source code and resources from Android Apk files that displayed on GUI.

## Tools
* Apktool : v2.2.4
* dex2jar : v2.1
* jd-gui : v1.4.0
* jadx : v0.6.1
* android-classyshark : v8.0

## Platforms
* Mac
* Linux / Unix

## Usage

```bash
# using integrated tools to decompile apk
sh decompile-apk.sh apk_to_decompile.apk

# using apktool/dex2jar/jd-gui to decompile apk
sh jdgui-apk.sh apk_to_decompile.apk

# using jadx to decompile apk
sh jadx-apk.sh apk_to_decompile.apk

# using classyshark to decompile apk
sh classyshark-apk.sh apk_to_decompile.apk

```

## Todo
* more decompile tools
* support decompile dex/aar/jar files

## About
[venshine.cn@gmail.com](venshine.cn@gmail.com)

## License
[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)