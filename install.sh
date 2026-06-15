#!/usr/bin/env bash
# UI Auditor — установка скилов для Claude Code.
# Запускать ИЗ КЛОНА репозитория: ./install.sh
# Линкует каждый скил из skills/<name> в ~/.claude/skills/<name>,
# поэтому `git pull` в этом клоне сразу обновляет скилы (симлинк ведёт сюда).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}/skills"
mkdir -p "$DEST"

for d in "$REPO"/skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  ln -sfn "$d" "$DEST/$name"
  echo "✓ $name → $DEST/$name"
done

echo
echo "Готово. Обновляться: git -C \"$REPO\" pull   (симлинки подхватят новое сами)"
echo "Дальше настрой браузер — см. раздел «Браузер» в README.md"
