# 空间分析报告模板（可视化 · 双版本 · 可导出 PDF）

> 本文件只在用户要做「空间分析 / 出报告 / 清理前看清单」时读取。

---

## 一、报告结构

- **存储总览**：各盘/卷总容量、已用、剩余 + 环形图（已用占比）
- **分类占用条**：临时文件 / 应用缓存 / 系统 / 文档 / 其他（实测或估算标注）
- **可清理清单**：逐项卡片（三色状态灯 🟢🟡🔴）+ 路径 + 占用 + 删除影响 + 建议回收
- **序号化清理步骤**：按"先 🟢 后 🟡、收益从高到低"排序
- **"这些千万别删"警示区**：按平台列出
- **双版本切换** + **打印/PDF 按钮**

---

## 二、评分标准（占用健康分，有依据才给分）

| 维度 | 权重 | 打分依据（示例） |
|---|---|---|
| 可用空间 | 40% | 系统盘剩余比例：≥30% 满分；20–30% 扣 20；10–20% 扣 45；<10% 扣 70 |
| 可清理占比 | 30% | 🟢+🟡 可清理项占总占用比例：<10% 满分；10–20% 扣 20；20–35% 扣 40；>35% 扣 60 |
| 清理风险 | 30% | 待清理项是否都是 🟢（无风险）：全 🟢 满分；含 🟡 扣 30；含 🔴 项误标扣 70 |

**总分 = 加权和**。等级：≥85 优秀 / 70–84 良好 / 60–69 亚健康 / <60 需处理。

**硬性规则**：
1. 无实测数据不给确定分数 → 标区间或走降级（第四节）。
2. 每项扣分必须写依据。
3. 状态灯只三色：🟢 正常 / 🟡 建议处理 / 🔴 必须处理。

---

## 三、完整 HTML 报告模板

保存为 `空间分析报告-YYYYMMDD.html`，UTF-8，单文件自包含（无外链、无 CDN、系统字体）。

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>空间分析报告</title>
<style>
  :root{
    --bg:#f5f7fa; --card:#fff; --text:#1f2430; --muted:#6b7280;
    --line:#e5e7eb; --green:#16a34a; --yellow:#d97706; --red:#dc2626; --blue:#2563eb;
  }
  *{box-sizing:border-box}
  body{margin:0;padding:24px;background:var(--bg);color:var(--text);
       font-family:"PingFang SC","Microsoft YaHei",-apple-system,"Segoe UI",sans-serif;line-height:1.6}
  .wrap{max-width:880px;margin:0 auto}
  .no-print{display:flex;gap:8px;justify-content:flex-end;margin-bottom:12px}
  button{cursor:pointer;border:1px solid var(--line);background:#fff;color:var(--text);
         padding:8px 14px;border-radius:8px;font-size:14px}
  button.active{background:var(--blue);color:#fff;border-color:var(--blue)}
  .card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:20px;margin-bottom:16px}
  h1{font-size:22px;margin:0 0 4px}
  h2{font-size:17px;margin:0 0 12px;padding-left:10px;border-left:4px solid var(--blue)}
  .meta{color:var(--muted);font-size:13px;margin-bottom:16px}
  .hero{display:flex;align-items:center;gap:28px;flex-wrap:wrap}
  .ring{position:relative;width:150px;height:150px;flex:none}
  .ring svg{transform:rotate(-90deg)}
  .ring .val{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center}
  .ring .num{font-size:34px;font-weight:700;line-height:1}
  .ring .lvl{font-size:13px;color:var(--muted);margin-top:4px}
  .summary{flex:1;min-width:240px}
  .summary .big{font-size:16px;font-weight:600;margin-bottom:6px}
  .cat{display:flex;align-items:center;gap:10px;margin-bottom:10px;font-size:14px}
  .cat .name{width:110px;flex:none;color:var(--muted)}
  .bar{flex:1;height:10px;background:#eef1f5;border-radius:5px;overflow:hidden}
  .bar i{display:block;height:100%;border-radius:5px}
  .cat .val{width:88px;text-align:right;font-variant-numeric:tabular-nums}
  .item{border:1px solid var(--line);border-radius:10px;padding:14px;margin-bottom:10px;background:#fff}
  .item .hd{display:flex;align-items:center;gap:10px;margin-bottom:8px;flex-wrap:wrap}
  .item .hd .t{font-weight:600;font-size:15px}
  .badge{font-size:12px;padding:2px 9px;border-radius:999px;color:#fff;flex:none}
  .b-green{background:var(--green)} .b-yellow{background:var(--yellow)} .b-red{background:var(--red)}
  .ver{font-size:14px;margin:6px 0}
  .ver .tag{display:inline-block;font-size:12px;color:var(--muted);border:1px solid var(--line);border-radius:4px;padding:0 6px;margin-right:6px}
  .howto{font-size:13px;color:#374151;background:#f8fafc;border-left:3px solid var(--blue);
         padding:8px 10px;border-radius:0 6px 6px 0;margin-top:8px}
  body.mode-plain .pro{display:none}
  body.mode-pro .plain{display:none}
  ol.actions{padding-left:20px;margin:0}
  ol.actions li{margin-bottom:8px}
  .warn{background:#fef2f2;border:1px solid #fecaca;color:#991b1b;border-radius:8px;padding:12px;font-size:13px}
  .foot{color:var(--muted);font-size:12px;text-align:center;padding:8px 0 24px}
  @media print{
    body{background:#fff;padding:0}
    .no-print{display:none}
    .card,.item{break-inside:avoid}
    @page{size:A4;margin:14mm}
  }
</style>
</head>
<body class="mode-plain">
<div class="wrap">

  <div class="no-print">
    <button id="btnPlain" class="active" onclick="setMode('plain')">大白话版</button>
    <button id="btnPro" onclick="setMode('pro')">专业版</button>
    <button onclick="window.print()">打印 / 另存为 PDF</button>
  </div>

  <div class="card">
    <h1>空间分析报告</h1>
    <div class="meta">
      设备：{{设备名}} ｜ 系统：{{macOS 15.x / Windows 11 23H2}} ｜
      扫描时间：{{时间}} ｜ 数据来源：{{扫描脚本实测 / 用户自查 / 估算}}
    </div>
    <div class="hero">
      <div class="ring">
        <svg width="150" height="150" viewBox="0 0 150 150">
          <circle cx="75" cy="75" r="62" fill="none" stroke="#eef1f5" stroke-width="14"/>
          <circle id="arc" cx="75" cy="75" r="62" fill="none" stroke="#2563eb" stroke-width="14"
                  stroke-linecap="round" stroke-dasharray="0 999"/>
        </svg>
        <div class="val"><div class="num" id="score">--</div><div class="lvl" id="level">--</div></div>
      </div>
      <div class="summary">
        <div class="big">{{一句话总评，例如：可清理约 XX GB，先清临时文件和浏览器缓存收益最大，应用缓存谨慎处理}}</div>
        <div style="color:#6b7280;font-size:14px">
          可清理：🟢 {{a}} 项 / {{A}} GB ｜ 🟡 {{b}} 项 / {{B}} GB ｜ 🔴 不动 {{c}} 项
        </div>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>分类占用</h2>
    <!-- 每条按实际数值替换 -->
    <div class="cat"><span class="name">临时文件</span>
      <span class="bar"><i style="width:{{百分比}}%;background:#16a34a"></i></span>
      <span class="val">{{xx GB}}</span></div>
    <div class="cat"><span class="name">应用缓存</span>
      <span class="bar"><i style="width:{{百分比}}%;background:#d97706"></i></span>
      <span class="val">{{xx GB}}</span></div>
    <div class="cat"><span class="name">系统</span>
      <span class="bar"><i style="width:{{百分比}}%;background:#2563eb"></i></span>
      <span class="val">{{xx GB}}</span></div>
    <div class="cat"><span class="name">文档 / 其他</span>
      <span class="bar"><i style="width:{{百分比}}%;background:#6b7280"></i></span>
      <span class="val">{{xx GB}}</span></div>
  </div>

  <div class="card">
    <h2>可清理清单</h2>

    <!-- ==== 一条分项，按此结构重复 ==== -->
    <div class="item">
      <div class="hd"><span class="badge b-green">可放心清理</span><span class="t">{{用户临时文件}}</span></div>
      <div class="ver plain"><span class="tag">大白话</span>{{临时文件是软件干活时留下的废料，删了不影响任何功能，约能回收 X GB。}}</div>
      <div class="ver pro"><span class="tag">专业版</span>{{路径 %TEMP% / ~/Library/Caches，实测占用 X GB。删除影响：无。建议：确认后由脚本或系统入口清理。}}</div>
    </div>
    <div class="item">
      <div class="hd"><span class="badge b-yellow">谨慎处理</span><span class="t">{{微信图片缓存}}</span></div>
      <div class="ver plain"><span class="tag">大白话</span>{{删了后之前看过的图片要重新加载，聊天记录不会丢。先备份聊天记录再清。}}</div>
      <div class="ver pro"><span class="tag">专业版</span>{{路径 …\WeChat\…\Cache，实测 X GB。删除影响：离线图片需重新下载。建议：先备份聊天记录（设置→聊天→备份），再清理。}}</div>
      <div class="howto">怎么做：{{具体入口或命令}}</div>
    </div>
    <div class="item">
      <div class="hd"><span class="badge b-red">不要动</span><span class="t">{{应用数据目录}}</span></div>
      <div class="ver plain"><span class="tag">大白话</span>{{这是软件的"家当"，删了软件会出问题，别动。}}</div>
      <div class="ver pro"><span class="tag">专业版</span>{{Application Support / Preferences 等，删除会导致应用配置丢失、需重新登录。建议：永不清理。}}</div>
    </div>
    <!-- ==== 重复结束 ==== -->

  </div>

  <div class="card">
    <h2>建议清理顺序（先 🟢 后 🟡，收益从高到低）</h2>
    <ol class="actions">
      <li>{{清用户临时文件：预计回收 X GB}}</li>
      <li>{{清浏览器缓存：预计回收 X GB}}</li>
      <li>{{清空废纸篓/回收站：预计回收 X GB}}</li>
      <li>{{（可选）微信图片缓存：需先备份，回收 X GB}}</li>
    </ol>
  </div>

  <div class="card">
    <h2>这些千万别删</h2>
    <div class="warn">
      {{按平台列出：macOS → /System、/Library、~/Library/Application Support、Preferences、Keychains、Time Machine 快照、用户文档；
      Windows → C:\Windows、Program Files、AppData 整体、WinSxS、pagefile.sys、hiberfil.sys、系统还原点。}}
      拿不准的路径，先发给我看一眼再删。
    </div>
  </div>

  <div class="foot">
    本报告由「电脑空间管家」生成 ｜ 生成时间 {{...}} ｜ 数据仅本机采集，报告可脱敏后再分享
  </div>
</div>

<script>
  var score = {{0-100 整数}};
  var C = 2 * Math.PI * 62;
  var arc = document.getElementById('arc');
  arc.setAttribute('stroke-dasharray', (C * score / 100).toFixed(1) + ' ' + C.toFixed(1));
  arc.setAttribute('stroke', score >= 85 ? '#16a34a' : score >= 70 ? '#2563eb' : score >= 60 ? '#d97706' : '#dc2626');
  document.getElementById('score').textContent = score;
  document.getElementById('level').textContent =
    score >= 85 ? '优秀' : score >= 70 ? '良好' : score >= 60 ? '亚健康' : '需处理';
  function setMode(m){
    document.body.className = 'mode-' + m;
    document.getElementById('btnPlain').className = m === 'plain' ? 'active' : '';
    document.getElementById('btnPro').className   = m === 'pro'   ? 'active' : '';
  }
</script>
</body>
</html>
```

### 填表要求

- `{{...}}` 全部替换成真实内容，**不留占位符**。
- 分数与颜色一致：≥85 绿 / 70–84 蓝 / 60–69 橙 / <60 红。
- 每项必须同时有大白话 + 专业版两段，内容不互相复制。
- "怎么做"里涉及删除的一律带 ⚠️ 后果说明。
- **可清理项等级必须与主提示词识别规则一致：拿不准的归 🟡/🔴，绝不标 🟢。**

---

## 四、无实测数据时的降级方案

用户不愿意跑扫描脚本时：**不给确定分数**，改出「自查清单」：

| 维度 | 你自己看一眼 | 什么情况算正常 |
|---|---|---|
| 系统盘剩余 | 此电脑/关于本机 → 看剩余 | ≥ 总容量 20% |
| 临时文件 | Windows: 设置→存储→临时文件；macOS: 关于本机→存储空间 | 能一键清空的项不超过几 GB |
| 应用缓存 | 看各应用缓存目录 | 拿不准的别动 |
| 回收站/废纸篓 | 打开看一眼 | 空或很小 |

同时主动问：要不要我生成一键扫描脚本，跑完把数据发我，我给你出带分数的完整报告。
