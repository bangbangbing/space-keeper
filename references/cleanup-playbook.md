# 双平台清理处置参考（按需读取）

> 本文件是空间管家的高频处置骨架。读取后必须结合用户平台、版本、扫描结果做裁剪，禁止整段照抄。
> 路径差异标注：`[macOS]` / `[Win11]` / `[Win10]` 表示入口不同；未标注表示基本一致。

---

## 一、平台差异速查

### 磁盘占用入口

- `[macOS]` 苹果菜单 → 系统设置 → 通用 → 存储空间（查看各分类占用、优化存储）
- `[Win11]` 设置 → 系统 → 存储
- `[Win10]` 设置 → 系统 → 存储

### 临时文件入口

- `[macOS]` 系统临时目录：`/tmp`、`/var/folders`（需管理员）；用户缓存：`~/Library/Caches`（只清子目录，不清整个文件夹）
- `[Win11]` 设置 → 系统 → 存储 → 临时文件（勾选项删除）
- `[Win10]` 设置 → 系统 → 存储 → 临时文件；或运行 `cleanmgr`（磁盘清理）

### 大文件定位

- `[macOS]` 访达 → 存储空间 → 文档/大文件；或终端 `du -sh ~/Downloads/* | sort -rh | head`
- `[Windows]` 资源管理器 → 此电脑 → 搜索 → 大小: 巨大；或 PowerShell `Get-ChildItem -Recurse | Sort Length -Desc | Select -First 20`

### 回收站 / 废纸篓

- `[macOS]` 废纸篓 → 清倒废纸篓（Option+清倒 可跳过"是否确定"）
- `[Windows]` 桌面 → 回收站 → 右键 → 清空回收站

---

## 二、应用缓存清单（核心·扩充版）

> **用途**：识别哪些应用缓存可安全清理。**总原则：只清 `Cache`/`Caches`/`Temp`/`Logs`/`tmp` 类子目录；`Application Support`/`AppData`(整体)/`Preferences`/`Data`/`Databases`/`Documents`/`index`/`logs`(业务日志目录) 一律不碰。**
>
> **判定口诀**：目录名带 Cache/Temp/Log 的，多半是"可再生废料"；目录名带 Support/Data/Config/DB 的，多半是"应用家当"。**拿不准 = 不删。**

### 0. 通用识别方法论（先读这个）

当清单里没有某个应用时，按以下顺序判断，**每一步都过不了就归 🟡 或问用户**：

1. **看目录名关键字**：
   - 安全（可考虑清）：`Cache` / `Caches` / `Temp` / `tmp` / `Trash` / `Crash`（崩溃报告） / `Logs`（纯日志） / `thumbcache` / `DerivedData` / `__pycache__` / `.npm` / `.gradle`(缓存部分)
   - 危险（绝不碰）：`Application Support` / `AppData`(整层) / `Preferences` / `Data` / `Databases` / `Documents` / `Config` / `Settings` / `Keychain` / `Passwords` / `Cookies`(登录态) / `index` / `workspace` / `backup`
2. **看是否有"重建"迹象**：一个目录如果删掉后应用能自动重建（缓存、临时、日志类），就是安全的；删掉后应用报错、要求重新登录、丢配置的，就是家当。
3. **看大小分布**：单个超大目录（>5GB）且名字不像用户文档的，多半是缓存/下载缓存，但也可能是数据目录——先确认再删。
4. **看修改时间**：近 7 天没被访问的缓存目录，删除风险更低。
5. **仍不确定 → 一律标 🟡（谨慎）并让用户确认，绝不标 🟢。** 宁可少清，不可多删。

### 1. 系统级临时文件（🟢 可放心清）

| 平台 | 路径 | 说明 |
|---|---|---|
| macOS | `/tmp`、`/var/folders`（系统临时）、`~/Library/Logs`、`~/Library/Logs/DiagnosticReports`（崩溃报告） | 系统自动管理，可清；崩溃报告删了无影响 |
| macOS | `~/Library/Caches` 下的**各子目录内容** | 只清子目录里的文件，不删整个 `Caches` 层 |
| Windows | `%TEMP%`、`C:\Windows\Temp`（部分需管理员） | 运行中软件会锁住部分文件，删不掉的跳过即可 |
| Windows | `C:\ProgramData\Microsoft\Windows\WER`（错误报告） | 可清，无影响 |
| Windows | 缩略图缓存 `%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db` | 重启后自动重建 |

### 2. 浏览器缓存（🟢 清缓存，🔴 保登录态）

| 平台 | 可清理路径（🟢） | 不可动（🔴） |
|---|---|---|
| macOS Safari | `~/Library/Caches/com.apple.Safari` | `~/Library/Safari`（书签/历史/密码）、`~/Library/Preferences/com.apple.Safari.plist` |
| macOS Chrome | `~/Library/Caches/Google/Chrome/*/Cache` | `~/Library/Application Support/Google/Chrome`（登录态/书签/密码/扩展） |
| macOS Edge | `~/Library/Caches/Microsoft Edge/*/Cache` | `~/Library/Application Support/Microsoft Edge` |
| macOS Firefox | `~/Library/Caches/Firefox/Profiles/*/cache2` | `~/Library/Application Support/Firefox/Profiles/*`（书签/登录） |
| Windows Chrome | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache` | `User Data` 其余目录（Cookies/Login Data/Bookmarks） |
| Windows Edge | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache` | `User Data` 其余目录 |
| Windows Firefox | `%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2` | Profiles 其余内容 |

> ⚠️ 清浏览器缓存 = 网页图片/视频重新加载，**不影响**书签、密码、登录态。若用户抱怨"清了浏览器后要重新登录"，多半是清到了 `Cookies` 目录——**绝对禁止清 Cookies**。

### 3. 聊天软件（🟡 谨慎，先备份聊天记录）

| 平台 | 可清理路径（🟡） | 不可动（🔴） |
|---|---|---|
| macOS 微信 | `~/Library/Containers/com.tencent.xinWeChat/Data/Library/Caches` | 聊天记录目录（`Message`/`FileStorage` 下的非 Cache 部分） |
| macOS QQ | `~/Library/Containers/com.tencent.qq/Data/Library/Caches` | 聊天记录、接收的文件 |
| macOS 钉钉 | `~/Library/Containers/com.alibaba.DingTalk/Data/Library/Caches` | 聊天记录、工作文件 |
| Windows 微信 | `%APPDATA%\Tencent\WeChat\...\FileStorage\Cache` | `FileStorage\Msg`/`File`/`Video`（聊天记录与文件本体） |
| Windows QQ | `%APPDATA%\Tencent\QQ\...\Cache` 或 `%APPDATA%\Tencent\QQ\...\FileStorage\Cache` | 聊天记录、文件 |
| Windows 钉钉 | `%APPDATA%\DingTalk\...\Cache` | 聊天记录、工作文件 |

> **铁律**：清聊天软件缓存**必须先提醒备份聊天记录**（微信：设置 → 聊天 → 聊天记录备份与迁移；QQ：消息管理器 → 导出）。图片/视频缓存删了会重新下载，**聊天记录本体删了找不回**。

### 4. 网盘 / 云同步（🟡 谨慎，勿动同步文件夹本体）

| 平台 | 可清理路径（🟡） | 不可动（🔴） |
|---|---|---|
| macOS 百度网盘 | `~/Library/Caches/com.baidu.BaiduNetdisk` | 同步目录（默认 `~/百度网盘`）里的文件 |
| macOS OneDrive | `~/Library/Caches/com.microsoft.OneDrive` | `~/OneDrive` 里的文件（离线可用文件） |
| macOS Dropbox | `~/Library/Caches/com.dropbox.Dropbox` | `~/Dropbox` 里的文件 |
| Windows 百度网盘 | `%LOCALAPPDATA%\BaiduYunGuanjia\...\Cache` | 同步目录里的文件 |
| Windows OneDrive | `%LOCALAPPDATA%\Microsoft\OneDrive\...\Cache` | `%USERPROFILE%\OneDrive` 里的文件 |
| Windows 坚果云 | `%APPDATA%\Nutstore\...\Cache` | 同步目录里的文件 |

> ⚠️ 清网盘缓存 = 已下载的"可离线查看"文件变回"仅云端"，**需要重新下载才能打开**。清理前必须说明这一点，或建议只清"使用中缓存"而非"离线文件"。

### 5. 开发工具（🟢/🟡 可清，会重新生成）

| 平台 | 可清理路径 | 说明 |
|---|---|---|
| macOS Xcode | `~/Library/Developer/Xcode/DerivedData` | 编译缓存，删了下次编译变慢，但安全 |
| macOS npm | `~/Library/Caches/npm` | 包缓存，删了重新下载 |
| macOS pip | `~/Library/Caches/pip` | 同上 |
| macOS Homebrew | `~/Library/Caches/Homebrew` | 下载缓存，删了重新下载 |
| macOS CocoaPods | `~/Library/Caches/CocoaPods` | 同上 |
| Windows npm | `%LOCALAPPDATA%\npm-cache` | 同上 |
| Windows pip | `%LOCALAPPDATA%\pip\cache` | 同上 |
| Windows Visual Studio | `%LOCALAPPDATA%\Microsoft\VisualStudio\*\ComponentModelCache` | 可清，会重建 |
| Windows JetBrains 系 | `%LOCALAPPDATA%\JetBrains\*\caches` | 索引缓存，删了 IDE 会重建索引 |
| Windows Gradle | `%USERPROFILE%\.gradle\caches` | 依赖缓存，删了重新下载 |

> 🔴 不可动：`~/.gradle` 整体（含 wrapper 配置）、`~/.m2` 里的配置文件、`package-lock.json`/`node_modules`（删了项目要重新 install，除非用户明确要清）。

### 6. 影音 / 娱乐软件（🟡 谨慎）

| 平台 | 可清理路径 | 不可动 |
|---|---|---|
| macOS 腾讯视频 | `~/Library/Containers/com.tencent.liteav.trtc/.../Caches` | 已下载的剧集（在应用"下载"管理里删） |
| macOS 爱奇艺 | `~/Library/Containers/com.qiyi.video/.../Caches` | 已下载剧集 |
| Windows 腾讯视频 | `%APPDATA%\Tencent\QQLive\...\Cache` | 应用内"下载"目录 |
| Windows 网易云音乐 | `%LOCALAPPDATA%\Netease\CloudMusic\Cache` | 已下载歌曲（`%LOCALAPPDATA%\Netease\CloudMusic\...\Download`） |
| Windows Steam | 无（缓存极小） | `steamapps`（游戏本体）、`userdata`（存档） |
| macOS Steam | `~/Library/Application Support/Steam/.../htmlcache` | `steamapps`（游戏本体）、`userdata`（存档） |

> ⚠️ 影音软件"已下载"的内容属于**用户主动下载的资产**（剧集/歌曲/游戏），即使位于 Cache 附近也**不能清**；只清"播放产生的临时缓冲"。

### 7. 办公 / 效率软件（🟡 谨慎）

| 平台 | 可清理路径 | 不可动 |
|---|---|---|
| macOS Microsoft Office | `~/Library/Containers/com.microsoft.*/Data/Library/Caches` | Office 文档本体、`Preferences` |
| macOS WPS | `~/Library/Containers/com.kingsoft.*/Data/Library/Caches` | 云文档缓存目录（删了要重新下载文档） |
| Windows Office | `%LOCALAPPDATA%\Microsoft\Office\*.Cache` | 最近文档列表、配置 |
| Windows WPS | `%APPDATA%\Kingsoft\WPS Office\*\cache` | 云文档缓存 |
| macOS Adobe | `~/Library/Caches/Adobe`、`~/Library/Application Support/Adobe/.../Cache` | Photoshop 预设、Lightroom 目录（数据库！） |
| Windows Adobe | `%TEMP%\Adobe`、Photoshop 暂存盘临时文件 | Lightroom 目录（`.lrcat` 数据库，删了照片信息全丢） |

> ⚠️ **Lightroom 的 `.lrcat` 是数据库**（照片编辑记录），不属于缓存，删了无法找回——这是高频误删点。

### 8. 通讯 / 会议（🟡 谨慎）

| 平台 | 可清理路径 | 不可动 |
|---|---|---|
| macOS Zoom | `~/Library/Caches/us.zoom.xos` | 已保存的录制文件（`~/Documents/Zoom`） |
| macOS 腾讯会议 | `~/Library/Caches/com.tencent.meeting` | 会议录制、会议纪要 |
| Windows Zoom | `%APPDATA%\Zoom\...\cache` | 录制文件（`%USERPROFILE%\Documents\Zoom`） |
| Windows 腾讯会议 | `%APPDATA%\Tencent\WeMeet\...\cache` | 录制、纪要 |
| macOS Slack | `~/Library/Caches/com.tinyspeck.slackmacgap` | 工作区数据、已下载文件 |
| Windows Slack | `%APPDATA%\Slack\Cache` | 工作区数据 |

### 9. 图形 / 设计（🟡 谨慎）

| 平台 | 可清理路径 | 不可动 |
|---|---|---|
| macOS Figma | `~/Library/Caches/com.figma.*` | 团队/项目数据（在线，本地缓存删了重新同步） |
| Windows Figma | `%APPDATA%\Figma\Cache` | 同上 |
| macOS Sketch | `~/Library/Caches/com.bohemiancoding.sketch3` | 设计文档本体、`Preferences` |
| 通用 | GPU 着色器缓存（浏览器/游戏） | 无（自动重建） |

### 10. 其它常见（🟢/🟡）

| 平台 | 可清理路径 | 不可动 |
|---|---|---|
| macOS 系统 | `~/Library/Caches`（子目录内容） | `~/Library/Caches` 整个删除 |
| macOS 邮件 | `~/Library/Mail`（**别清**，含邮件本体） | — |
| macOS 照片 | 无（`~/Library/Photos` 是照片库本体） | 照片库整体 |
| Windows Windows 更新缓存 | 存储感知 → 临时文件 → "Windows 更新清理" | `C:\Windows\SoftwareDistribution\Download` 手动删 |
| Windows 传递优化 | 存储感知 → 临时文件 → "传递优化文件" | — |
| Windows 旧系统文件 | 存储感知 → 临时文件 → "以前的 Windows 安装"（⚠️ 删后无法回退旧系统） | — |
| Windows 预取 | `C:\Windows\Prefetch`（可清但收益极小，且需管理员） | — |

> **清单外的应用**：按第 0 节方法论判断——含 `Cache`/`Caches`/`Temp`/`tmp`/`Logs` 关键字才可能安全；否则归 🟡 或询问用户。**拿不准就不删。**

---

## 三、"这些千万别删"清单

### macOS

- `/System`、`/Library`（整体）、`/Applications` 内程序本体
- `~/Library/Application Support`（应用数据）、`~/Library/Preferences`（设置）、`~/Library/Keychains`（钥匙串/密码）
- Time Machine 本地快照（`tmutil listlocalsnapshots /`，想清需先关闭 Time Machine 或手动删快照）
- 用户文档（`~/Documents`、`~/Desktop`、`~/Pictures`、`~/Movies`）
- 系统睡眠镜像 `/private/var/vm/sleepimage`（勿手动删，系统会自动管理）

### Windows

- `C:\Windows`、`C:\Program Files`、`C:\Program Files (x86)`、`C:\Users\<用户名>\AppData`（整体）
- `WinSxS`、`pagefile.sys`、`hiberfil.sys`、系统还原点、`C:\Windows\System32`
- 用户文档、桌面、图片、视频、下载（未确认前）
- 软件安装目录（卸载走"设置 → 应用"）

---

## 四、指定文件夹清理流程

1. **先扫描**：列出该文件夹内容与各子项大小（macOS `du -sh`；Windows PowerShell 排序）。
2. **分类**：文档 / 图片视频 / 安装包 / 临时缓存 / 未知，逐项给大小与建议（保留/可删/需确认）。
3. **让用户勾选**：只删用户勾选的子项；**禁止整目录无差别删除**。
4. **执行后回执**：清理前后大小对比。

---

## 五、清理方法三选一（按用户意愿）

1. **一键脚本**（用户要省事）→ `references/script-templates.md`
2. **系统自带入口**（最安全，推荐先试）：
   - `[macOS]` 系统设置 → 通用 → 存储空间 → 优化存储/清废纸篓
   - `[Windows]` 设置 → 系统 → 存储 → 临时文件 → 勾选删除；`cleanmgr` 磁盘清理
3. **手动命令/路径**（用户想自己敲）→ 给完整可复制命令块

> 任何方案都遵守主提示词铁律：只清白名单路径、删除前二次确认、宁可少清不可多删。
