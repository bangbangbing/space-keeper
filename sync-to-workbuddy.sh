#!/bin/bash
# ============================================================
# sync-to-workbuddy.sh — space-keeper 专家一键同步脚本
#
# 作用：把 git 开发仓库同步到 WorkBuddy 专家运行目录，
#       并自动校验 + 注册，重启 WorkBuddy 后即可生效。
#
# 用法：
#   ./sync-to-workbuddy.sh          同步 + 校验 + 注册
#   ./sync-to-workbuddy.sh --push   同步 + 校验 + 注册 + 推送 GitHub
# ============================================================
set -euo pipefail

# ---------- 路径配置 ----------
SRC="$HOME/.workbuddy/plugins/marketplaces/experts/plugins/space-keeper-build"
DST="$HOME/.workbuddy/plugins/marketplaces/my-experts/plugins/space-keeper"
EXPERT_MANAGER="/Applications/WorkBuddy.app/Contents/Resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills/expert-manager"
GIT_PROXY="http://127.0.0.1:7897"   # 环境默认代理(52101)对 GitHub 返回 502，用本地 Clash 端口

echo "==> [1/4] 同步文件（rsync，排除 .git）"
if [ ! -d "$SRC" ]; then
  echo "❌ 源目录不存在: $SRC"; exit 1
fi
mkdir -p "$(dirname "$DST")"
rsync -a --delete --exclude '.git' "$SRC/" "$DST/"
echo "    已同步: $SRC -> $DST"

echo "==> [2/4] 校验专家包"
python3 "$EXPERT_MANAGER/scripts/validate_expert.py" "$DST"

echo "==> [3/4] 注册到专家中心（my-experts marketplace.json）"
python3 "$EXPERT_MANAGER/scripts/register_expert.py" "$DST"

echo "==> [4/4] 完成 ✅"
echo "    请重启 WorkBuddy，在 专家中心/我的专家 中搜索「空间管家」"

# ---------- 可选：推送 GitHub ----------
if [ "${1:-}" = "--push" ]; then
  echo "==> 附加：推送 GitHub（走代理 $GIT_PROXY）"
  cd "$SRC"
  # 有未提交改动时先自动提交
  if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "chore: sync space-keeper updates $(date +%Y-%m-%d)"
    echo "    已自动提交改动"
  fi
  git -c "http.proxy=$GIT_PROXY" -c "https.proxy=$GIT_PROXY" push origin main --tags
  echo "    已推送 origin main"
fi
