# Playbook (REMEDIATION): Microsoft Clarity + Brand Agents AI-чат (`/a/msba/`)

> ⚠️ **Это НЕ часть аудита.** UI Auditor (скилы Трека A/B) — read-only: он только
> диагностирует, действуя как пользователь, и НИЧЕГО не меняет на сайте. Этот файл —
> отдельная инструкция по **починке**, требующая доступа к серверу (SSH/WP-CLI/FTP) и
> деплоя кода. Применять её — ручное, осознанное действие администратора сайта, вне
> прогона аудита. Диагностику см. в зоне 17 функционального скила.

Стек: `multibrand-theme` + `vault-child` + плагин `microsoft-clarity` (трекинг Clarity +
AI-чат «Покупки с ИИ» / Brand Agents). Обе фичи часто молча ломаются.

## А. Тег Microsoft Clarity

**Диагностика (read-only):**
1. На главной в HTML есть `clarity.ms/tag/<ID>` (script в `<head>`).
2. В Network идут запросы на `*.clarity.ms/collect` со статусом 200/204.

**Признак поломки:** тега нет на странице.
**Причина:** опция `clarity_project_id` пустая — OAuth-привязка не записала ID (известный
баг плагина). Плагин выводит тег только при непустой опции.
**Фикс:** записать Project ID (с `clarity.microsoft.com` → Settings → Setup,
10-символьная строка) в опцию `clarity_project_id`. Без SSH/WP-CLI — залить mu-plugin с
`update_option('clarity_project_id','<ID>')` на `init` (он же защитит от затирания при
обновлении плагина).
**Сверка:** на странице не должно быть чужого `projectId` с другого сайта.

## Б. Brand Agents AI-чат (эндпоинт `/a/msba/`)

**Диагностика (read-only):**
1. Грузится загрузчик `frontendInjection.js` (домен `*.azurefd.net`); монтируется
   `<div id="ads-agent-host">` с shadow DOM и видимым лаунчером («Покупки с ИИ» /
   «Shop with AI», обычно снизу по центру).
2. Ключевая проверка — запрос конфига:
   ```
   curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" \
        "https://<домен>/a/msba/api/config/read?clientId=x"
   ```
   Ожидается: `200` (или `400 No clientId` при пустом clientId), БЕЗ редиректа.

**Признак поломки:** `301` → на тот же URL со слешем (или на «/»), пустой `#root`,
лаунчер не появляется.
**Причина:** ядровый WordPress `redirect_canonical` делает 301 на `/a/msba/...` до
обработчика плагина; при редиректе теряется `clientId` → конфиг не грузится.
**Фикс (в child-теме, `functions.php` — залить на сервер):**
```php
add_filter('redirect_canonical', function ($u) {
    $uri = $_SERVER['REQUEST_URI'] ?? '';
    return (strpos($uri, '/a/msba/') !== false) ? false : $u;
}, 0);
```
**Проверка после фикса:** тот же `curl` отдаёт 200/400 без 301; в браузере появляется
лаунчер; в Network `/a/msba/api/config/read?...` = 200.

## Важно про деплой/кеш на этом стеке
- **ftp.tools:** веб-корень обычно `/<домен>/www/`, НЕ `/` (заливка в `/` уходит в мусор).
- **OPcache** на origin → правки `.php` могут подхватиться с задержкой.
- **Cloudflare** кеширует CSS-бандл → хотфиксы CSS лить инлайном (`wp_add_inline_style`),
  а не правкой dist-файла. HTML CF не кеширует (`cf-cache-status: DYNAMIC`).
