# space-keeper v1.0.0 Release Notes

> **电脑空间管家** —— macOS + Windows 双平台「先看清、再清理」的空间管理技能包

## 🎉 本版本亮点

1. **双平台覆盖**：macOS 与 Windows 10/11 全支持，路径与命令按平台自动适配。
2. **可视化空间分析报告**：占用环形图 + 分类占用条 + 三色状态灯 + 「大白话/专业版」双版本切换 + 一键打印/PDF 导出。
3. **应用缓存识别铁律**：内置 10 大类应用缓存白名单（微信/QQ/钉钉/浏览器/网盘/开发工具/影音/办公/会议/设计）+ 通用识别方法论——**只清 Cache/Temp/Logs 可再生日录，绝不碰应用数据/配置/聊天记录**。
4. **确认后清理**：默认只扫描、只报告；清理必须用户确认，支持一键脚本（.sh/.bat）、系统自带入口、手动命令三条路径。
5. **安全设计**：脚本删除路径硬编码白名单、禁止通配符扫盘、聊天缓存清理前强制提醒备份、不编造数据。

## 📦 包含文件

```
space-keeper/
├── .codebuddy-plugin/plugin.json
├── agents/space-keeper.md          # 主提示词（八段式）
├── references/
│   ├── cleanup-playbook.md         # 应用缓存白名单(10大类) + 识别方法论 + 处置骨架
│   ├── script-templates.md         # 一键扫描/清理脚本模板（macOS/Windows）
│   └── report-templates.md         # 可视化报告模板 + 评分标准 + 降级方案
├── examples/sample-dialogues.md
├── avatars/expert.png
├── CHANGELOG.md
└── README.md
```

## ✅ 已验证

- 在 macOS 真机完成两轮实际清理：回收约 13.4 GB（用户缓存 20GB → 7.7GB）
- 白名单删除 25/26 项成功，唯一失败项重试后成功（Chrome 运行锁文件）
- 聊天记录、应用数据、配置全程未触碰

## 📥 安装

```bash
mkdir -p ~/.workbuddy/plugins/marketplaces/my-experts/plugins/
cp -R space-keeper ~/.workbuddy/plugins/marketplaces/my-experts/plugins/
python3 scripts/register_expert.py <expert-dir>
```

## 🙏 致谢

- 设计参考：`xtgxiso-windows-pc-care` 专家包（八段式提示词 + 按需读取参考资料 + 报告双版本范式）
- 感谢所有早期使用者反馈

## ⚠️ 注意事项

- 技能包为**纯提示词专家**，不联网、不执行用户未确认的脚本
- 清理动作均由用户确认后执行；拿不准的缓存一律不删（宁可少清，不可多删）
- 贡献请遵循 README 中的贡献指南
