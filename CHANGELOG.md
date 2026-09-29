# 更新日志

本项目的版本履历遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式。

## [1.0.0] - 2026-09-28

### 新增
- 首个可上线版本：macOS + Windows 双平台「电脑空间管家」技能包
- 核心能力一：空间分析与可视化报告（临时文件/应用缓存/回收站/大文件定位，HTML 报告含双版本切换与 PDF 导出）
- 核心能力二：经用户确认后的清理（一键脚本 / 系统自带入口 / 手动命令三条路径）
- 「应用缓存识别铁律」：只清 Cache/Temp/Logs 类可再生日录，绝不碰应用数据/配置/聊天记录；宁可少清不可多删
- `references/cleanup-playbook.md`：应用缓存白名单（10 大类，macOS/Windows 双平台）+ 通用识别方法论
- `references/script-templates.md`：一键扫描/清理脚本模板（.sh / .bat）
- `references/report-templates.md`：可视化空间分析报告模板 + 评分标准 + 降级方案
- 头像、示例对话、README、MIT License

### 安全设计
- 所有清理必须经用户确认；脚本删除路径硬编码白名单；禁止通配符扫盘
- 聊天软件缓存清理前强制提醒备份聊天记录
- 不编造数据：占用大小一律以实测为准
