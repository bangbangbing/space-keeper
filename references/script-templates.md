# 一键脚本模板（按需读取）

> 仅在用户要求"生成脚本"时读取。生成前先遵守主提示词「一键脚本六条铁律」。
> 核心：扫描脚本只读不删；清理脚本删除路径**硬编码为白名单**、删除前二次确认。

---

## 模板一（macOS）：一键空间扫描（只读）

保存路径：`~/Desktop/空间扫描.sh`，编码 UTF-8。

```bash
#!/bin/bash
# 空间扫描工具：只收集信息，不删任何文件
REPORT="$HOME/Desktop/空间扫描报告.txt"
{
echo "======================================"
echo "空间扫描报告  生成时间：$(date '+%Y-%m-%d %H:%M')"
echo "（含用户名与路径，发给别人前可自行删减）"
echo "======================================"
echo ""
echo "[1] 磁盘总览"
df -h / 2>&1
echo ""
echo "[2] 用户缓存大小（~/Library/Caches 各子目录）"
du -sh "$HOME/Library/Caches"/* 2>/dev/null | sort -rh | head -20
echo ""
echo "[3] 废纸篓"
du -sh "$HOME/.Trash" 2>/dev/null || echo "废纸篓为空"
echo ""
echo "[4] 系统临时目录"
du -sh /tmp 2>/dev/null
echo ""
echo "[5] 常见应用缓存"
for app in "com.apple.Safari" "Google" "com.tencent.xinWeChat" "com.tencent.qq" "Zoom"; do
  du -sh "$HOME/Library/Caches/$app" 2>/dev/null && echo "  ↑ $app"
done
echo ""
echo "[6] Downloads 大文件 Top10"
du -sh "$HOME/Downloads"/* 2>/dev/null | sort -rh | head -10
} > "$REPORT" 2>&1
echo "扫描完成，报告已存到桌面《空间扫描报告.txt》"
echo "把内容发给我，我给你出空间分析报告和清理清单。"
read -p "按回车键退出..."
```

> 若环境不支持写入文件，给用户"复制到文本编辑 → 另存为 .sh → 终端运行 `bash ~/Desktop/空间扫描.sh`"指引。

---

## 模板二（macOS）：一键清理脚本（需用户确认清单）

```bash
#!/bin/bash
# 清理脚本：只删你确认过的白名单路径
# 用法：先看扫描报告，勾选要清的项目，再把对应行取消注释

set -u
echo "⚠️ 本脚本将删除以下路径（删除前请确认）："
echo "  1. 废纸篓内容"
echo "  2. ~/Library/Caches 下的明确缓存子目录（不含应用数据）"
echo ""
read -p "确认清理？输入 Y 继续，其他退出：" GO
if [ "$GO" != "Y" ] && [ "$GO" != "y" ]; then
  echo "已取消，未删除任何文件。"
  read -p "按回车退出..."
  exit 0
fi

LOG="$HOME/Desktop/清理日志.txt"
: > "$LOG"

# 以下路径按需取消注释（示例，实际以报告确认为准）
# rm -rf "$HOME/.Trash"/* && echo "已清空废纸篓" >> "$LOG"
# rm -rf "$HOME/Library/Caches/com.apple.Safari"/* 2>/dev/null && echo "已清 Safari 缓存" >> "$LOG"

echo "清理完成，日志在桌面《清理日志.txt》"
echo "⚠️ 提醒：缓存删除后应用会重新生成，可能需要重新下载部分数据。"
read -p "按回车退出..."
```

> **铁律**：脚本中的删除路径必须来自用户确认的清单；绝不写入 `rm -rf ~`、`rm -rf /`、通配符全盘扫描。

---

## 模板三（Windows）：一键空间扫描（只读）

保存路径：`%USERPROFILE%\Desktop\空间扫描.bat`，编码 **UTF-8**（首行 `chcp 65001`）。

```bat
@echo off
chcp 65001 >nul
title 空间扫描工具
set REPORT=%USERPROFILE%\Desktop\空间扫描报告.txt
set PS=powershell -NoProfile -Command "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"

echo ============================== > "%REPORT%"
echo 空间扫描报告  生成时间：%date% %time% >> "%REPORT%"
echo （含用户名与路径，发给别人前可自行删减） >> "%REPORT%"
echo ============================== >> "%REPORT%"
echo. >> "%REPORT%"

echo [第 1 步] 各盘剩余空间
echo. >> "%REPORT%"
echo ===== 磁盘总览 ===== >> "%REPORT%"
%PS% "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { '{0} 总容量 {1:N1}GB，剩余 {2:N1}GB，剩余 {3:N0}%' -f $_.DeviceID, ($_.Size/1GB), ($_.FreeSpace/1GB), ($_.FreeSpace/$_.Size*100) }" >> "%REPORT%" 2>&1

echo [第 2 步] 用户临时文件（%TEMP%）
echo. >> "%REPORT%"
echo ===== 用户临时文件 ===== >> "%REPORT%"
%PS% "$t=[Environment]::GetFolderPath('LocalApplicationData')+'\Temp'; '{0:N1} MB' -f ((Get-ChildItem $t -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB)" >> "%REPORT%" 2>&1

echo [第 3 步] Windows 临时目录
echo. >> "%REPORT%"
echo ===== 系统临时文件 ===== >> "%REPORT%"
%PS% "'{0:N1} MB' -f ((Get-ChildItem 'C:\Windows\Temp' -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB)" >> "%REPORT%" 2>&1

echo [第 4 步] 常见应用缓存
echo. >> "%REPORT%"
echo ===== 应用缓存 ===== >> "%REPORT%"
%PS% "$paths=@('$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache','$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache','$env:APPDATA\Tencent\WeChat','$env:APPDATA\Tencent\QQ'); foreach($p in $paths){ if(Test-Path $p){ $s=(Get-ChildItem $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum/1MB; '{0}  {1:N1} MB' -f $p,$s } }" >> "%REPORT%" 2>&1

echo [第 5 步] 回收站
echo. >> "%REPORT%"
echo ===== 回收站 ===== >> "%REPORT%"
%PS% "(New-Object -ComObject Shell.Application).Namespace(10).Items() | Measure-Object -Property Size -Sum | ForEach-Object { '{0:N1} MB' -f ($_.Sum/1MB) }" >> "%REPORT%" 2>&1

echo.
echo ----------------------------------------
echo 扫描完成，报告已存到桌面《空间扫描报告.txt》
echo 把内容发给我，我给你出空间分析报告和清理清单。
echo ----------------------------------------
pause
```

---

## 模板四（Windows）：一键清理脚本（需用户确认清单）

```bat
@echo off
chcp 65001 >nul
title 空间清理工具
set LOG=%USERPROFILE%\Desktop\清理日志.txt

echo ⚠️ 本脚本将删除以下路径（删除前请确认）：
echo   1. 回收站内容
echo   2. %TEMP% 下的临时文件
echo.
set /p GO=确认清理？输入 Y 继续，其他退出：
if /i not "%GO%"=="Y" (
  echo 已取消，未删除任何文件。
  pause
  exit
)

echo ============================== > "%LOG%"
echo 清理日志  时间：%date% %time% >> "%LOG%"
echo ============================== >> "%LOG%"

echo [1/2] 正在清空回收站...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" && echo 回收站已清空 >> "%LOG%"

echo [2/2] 正在清理用户临时文件...
del /f /q "%TEMP%\*" >nul 2>&1
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" 2>nul
echo 临时文件已清理 >> "%LOG%"

echo.
echo ----------------------------------------
echo 清理完成，日志在桌面《清理日志.txt》
echo ⚠️ 提醒：正在运行的软件可能锁住部分文件，没删掉的重启后再试。
echo ----------------------------------------
pause
```

> 若用户确认了更多白名单路径（如某应用 Cache 子目录），按"绝对路径"逐行追加到脚本，禁止通配符扫盘。

---

## 裁剪原则

- 用户只要报告 → 只给扫描模板（一/三），不给清理脚本。
- 用户确认清理 → 先展示清理脚本全文并逐段解释 → 用户自行运行。
- 用户想自己敲命令 → 不给脚本，直接给命令块 + 打开方式说明。
- 任何模板都**不得**包含：删除非白名单路径、`rm -rf /`、`rm -rf ~`、注册表修改、系统目录删除。
