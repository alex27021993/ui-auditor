#!/usr/bin/env bash
# UI Auditor — установка скилов и слэш-команд для Claude Code.
# Запускать ИЗ КЛОНА репозитория: ./install.sh
# Линкует скилы из skills/<name> в ~/.claude/skills/<name> и команды из
# commands/<name>.md в ~/.claude/commands/<name>.md — поэтому `git pull` в этом
# клоне сразу обновляет и методику, и команды (симлинки ведут сюда).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE="${CLAUDE_HOME:-$HOME/.claude}"
VERSION="$(cat "$REPO/VERSION" 2>/dev/null || echo '?')"

echo "════════════════════════════════════════"
echo "  UI Auditor  v$VERSION"
echo "  установка / обновление скилов и команд"
echo "════════════════════════════════════════"

# --- Скилы ---
mkdir -p "$CLAUDE/skills"
for d in "$REPO"/skills/*/; do
  [ -f "$d/SKILL.md" ] || continue
  name="$(basename "$d")"
  ln -sfn "$d" "$CLAUDE/skills/$name"
  echo "✓ skill   $name → $CLAUDE/skills/$name"
done

# --- Слэш-команды (/audit, /audit-visual) ---
mkdir -p "$CLAUDE/commands"
for f in "$REPO"/commands/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  ln -sfn "$f" "$CLAUDE/commands/$name"
  echo "✓ command /${name%.md} → $CLAUDE/commands/$name"
done

echo
echo "Готово — UI Auditor v$VERSION установлен."
echo "Обновляться:  git -C \"$REPO\" pull   (симлинки подхватят новое сами; история — в CHANGELOG.md)"
echo "Запуск аудита в чате:  /audit https://example.com   (или /audit-visual …)"
echo "Дальше настрой браузер — см. раздел «Браузер» в README.md"
