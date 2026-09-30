# RouteFlow for OpenWrt — releases

Готовые пакеты RouteFlow для OpenWrt и установщик в одну команду.

RouteFlow — выборочная маршрутизация для OpenWrt: сайты из ваших правил идут через VPN или прокси (VLESS, Shadowsocks, AmneziaWG, WireGuard, OpenVPN), остальное — напрямую. Автоматическое переключение и возврат, обход DPI через zapret2 (в том числе «обход, а где не помогает — VPN»), откат изменений и современный веб-интерфейс LuCI на русском и английском.

## Установка

По SSH на роутере под root:

```sh
wget -qO- https://raw.githubusercontent.com/ConverPRO/routeflow-releases/main/install.sh | sh
```

Конкретная версия:

```sh
wget -qO- https://raw.githubusercontent.com/ConverPRO/routeflow-releases/main/install.sh | ROUTEFLOW_TAG=v1.0.0-rc9 sh
```

`ROUTEFLOW_CHANNEL=stable` ставит только стабильные релизы, `rc` — самый свежий, включая релиз-кандидаты. По умолчанию (`auto`) ставится стабильный релиз, а если стабильных ещё нет — самый свежий.

Если sing-box ещё не установлен, ставится компактный `sing-box-tiny` (`ROUTEFLOW_SINGBOX=full` — полная сборка). Если на роутере есть Podkop, установщик спросит, оставить его работать (по умолчанию), удалить или отменить установку.

После установки RouteFlow **выключен** и трафик не трогает. Включается он через мастер настройки: **LuCI → RouteFlow**. До первого переключения держите открытой SSH-сессию.

## Требования

- OpenWrt **24.10** (opkg). OpenWrt 25+ с `apk` пока не поддерживается.
- Около 20–35 МБ свободного места на overlay: RouteFlow ~300 КБ, основное — `sing-box-tiny` (~30 МБ в распакованном виде на x86_64).
- Архитектура может быть любой: пакеты RouteFlow — `all`. `sing-box` и модули ядра ставятся из фидов вашей прошивки через `opkg update`, бинарник `nfqws2` для zapret2 выбирается по `DISTRIB_ARCH`: arm64, arm, mips, mipsel, mips64, x86, x86_64, riscv64, ppc.

## Что проверяется при установке

1. `release.json` подписан ключом RouteFlow (`usign`), публичный ключ встроен в `install.sh`.
2. В подписанном манифесте записаны SHA-256 для `install.sh` релиза и для `SHA256SUMS`.
3. `SHA256SUMS` проверяет каждый `.ipk` и скрипт проверки конфликтов.
4. Если на роутере стоят конфликтующие решения (passwall, openclash, homeproxy), установка останавливается. Podkop не мешает установке: RouteFlow не запустится рядом с ним без явного перехода.

Обновления из LuCI и `routeflowctl update-apply` проходят ту же цепочку проверок.

## Публичный ключ

```
untrusted comment: RouteFlow release signing key
RWSedSS5dcQhoekrOiS4aykFkJHUh9oVg4pYqbRYBb8XsGPCY3A8DXX6
```
