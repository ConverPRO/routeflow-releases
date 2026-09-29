# RouteFlow for OpenWrt — releases

Готовые пакеты RouteFlow для OpenWrt и установщик в одну команду.

RouteFlow управляет трафиком на роутере: sing-box, nftables, dnsmasq, резервирование VPN/прокси, автоматический переход на прямой WAN, откат изменений и веб-интерфейс LuCI. Опционально работает с zapret2/nfqws2.

## Установка

По SSH на роутере под root:

```sh
wget -qO- https://raw.githubusercontent.com/ConverPRO/routeflow-releases/main/install.sh | sh
```

Конкретная версия:

```sh
wget -qO- https://raw.githubusercontent.com/ConverPRO/routeflow-releases/main/install.sh | ROUTEFLOW_TAG=v1.0.0-rc5 sh
```

`ROUTEFLOW_CHANNEL=stable` ставит только стабильные релизы, `rc` — самый свежий, включая релиз-кандидаты. По умолчанию (`auto`) ставится стабильный релиз, а если стабильных ещё нет — самый свежий.

После установки RouteFlow **выключен** и трафик не трогает. Включается он через мастер настройки: **LuCI → RouteFlow**. До первого переключения держите открытой SSH-сессию.

## Требования

- OpenWrt **24.10** (opkg). OpenWrt 25+ с `apk` пока не поддерживается.
- Около 2 МБ свободного места плюс место под зависимости. Больше всего занимает `sing-box`.
- Архитектура может быть любой: пакеты RouteFlow — `all`. `sing-box` и модули ядра ставятся из фидов вашей прошивки через `opkg update`, бинарник `nfqws2` для zapret2 выбирается по `DISTRIB_ARCH`: arm64, arm, mips, mipsel, mips64, x86, x86_64, riscv64, ppc.

## Что проверяется при установке

1. `release.json` подписан ключом RouteFlow (`usign`), публичный ключ встроен в `install.sh`.
2. В подписанном манифесте записаны SHA-256 для `install.sh` релиза и для `SHA256SUMS`.
3. `SHA256SUMS` проверяет каждый `.ipk` и скрипт проверки конфликтов.
4. Если на роутере стоят конфликтующие решения (passwall, openclash, homeproxy), установка останавливается.

Обновления из LuCI и `routeflowctl update-apply` проходят ту же цепочку проверок.

## Публичный ключ

```
untrusted comment: RouteFlow release signing key
RWSedSS5dcQhoekrOiS4aykFkJHUh9oVg4pYqbRYBb8XsGPCY3A8DXX6
```
