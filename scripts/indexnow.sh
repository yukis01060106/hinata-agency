#!/usr/bin/env bash
# Bing などの検索エンジンに「ページを更新したので見に来て」と知らせる（IndexNow）。
# 使い方：npm run indexnow（本番に公開したあとに実行）
# 鍵は public/<鍵>.txt に置いてあり、本番の https://hinata-agency.co.jp/<鍵>.txt で確認される。
set -euo pipefail
cd "$(dirname "$0")/.."

site="https://hinata-agency.co.jp"
key_file=$(ls public/*.txt | grep -E '/[0-9a-f]{32}\.txt$' | head -1)
key=$(basename "$key_file" .txt)

# サイトマップに載っているページをすべて送る
urls=$(curl -s "$site/sitemap.xml" | grep -o '<loc>[^<]*</loc>' | sed -e 's#<loc>##' -e 's#</loc>##')
json=$(printf '%s\n' $urls | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')

curl -s -o /dev/null -w "IndexNow: %{http_code}（200/202 なら受け付け）\n" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "{\"host\":\"hinata-agency.co.jp\",\"key\":\"$key\",\"keyLocation\":\"$site/$key.txt\",\"urlList\":$json}" \
  https://api.indexnow.org/indexnow
