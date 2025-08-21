## Преобразование таблицы в нормализованный вид

Существущая таблица

|user_id|name|email|status|device|token|issued|espires|role|permission_resource|permission_action|
|-------|----|-----|------|------|-----|------|-------|----|-------------------|-----------------|
|1|Sergey Petrov|Spetr@example.com|active|HP ProDesk|abc_123|2025.02.15 08:00|2025.02.15 10:00|admin|setting|edit|
|1|Sergey Petrov|Spetr@example.com|active|HP ProBook|xyz_321|2025.02.15 11:00|2025.02.15 13:00|admin|setting|edit|
|2|Alexey Smirnov|Asmir@example.com|blocked|B760 Pro RS|qaz_111|2025.02.15 07:45|2025.02.15 09:45|user|view|read|
|3|Evgeniy Karpov|Ekarp@example.com|active|MackBook Pro|wsa_221|2025.02.15 10:00|2025.02.15 12:00|user|view|read|

### Выполнение нормализации до 3NF

1. Функциональные зависимости
- user_id → name, email, status (атрибуты пользователя зависят только от пользователя, а не от сессии)
- token → user_id, device, issued, expires (каждый токен однозначно определяет сессию)
- role_name задаёт набор прав (resource/action) — это отдельный справочник roles, а права — справочник permissions с таблицей связи role_permissions
- Права/роли не зависят от конкретной сессии и пользователя в конкретный момент — это отдельная область данных

2. Нормализация
- 1NF: значения уже атомарные (строки, даты, текст).
- 2NF: убираем частичные зависимости — отделяем данные пользователя и роли/права от сессий (токен — ключ сессии).
- 3NF: убираем транзитивные зависимости — роли и права выносим в собственные таблицы и связываем между собой; избавляемся от дублирования device_name, выделив devices.

3. Итоговая схема

Пользователи
```
CREATE TABLE users (
  user_id        BIGINT PRIMARY KEY,
  name           TEXT        NOT NULL,
  email          TEXT        NOT NULL UNIQUE,
  status         TEXT        NOT NULL CHECK (status IN ('active','blocked','inactive'))
);
```
Устройства
```
CREATE TABLE devices (
  device_id      BIGSERIAL PRIMARY KEY,
  name           TEXT NOT NULL,
  UNIQUE (name)
);
```
Сессии
```
CREATE TABLE sessions (
  session_id     BIGSERIAL PRIMARY KEY,
  user_id        BIGINT      NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  device_id      BIGINT      REFERENCES devices(device_id),
  token          TEXT        NOT NULL UNIQUE,
  issued      TIMESTAMPTZ NOT NULL,
  expires     TIMESTAMPTZ NOT NULL
);
```
Роли
```
CREATE TABLE roles (
  role_id        BIGSERIAL PRIMARY KEY,
  name           TEXT NOT NULL UNIQUE
);
```
Права
```
CREATE TABLE permissions (
  permission_id  BIGSERIAL PRIMARY KEY,
  resource       TEXT NOT NULL,
  action         TEXT NOT NULL,
  UNIQUE (resource, action)
);
```
Права по ролям
```
CREATE TABLE role_permissions (
  role_id        BIGINT NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
  permission_id  BIGINT NOT NULL REFERENCES permissions(permission_id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);
```
Пользовательские роли
```
CREATE TABLE user_roles (
  user_id        BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  role_id        BIGINT NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, role_id)
);
```
4. Выполненные исправления нормализацией
- Устранение избыточности: имя, email, статус пользователя не дублируются в каждой сессии; права не повторяются в строках сессий
- Отсутствие противоречий: изменили email/статус/набор прав — не нужно править десятки строк, данные консистентны по ссылкам
- Обновляемость: проще блокировать пользователя, отзывать роли/права, удалять/закрывать конкретные сессии (по token), не рискуя повредить другие данные
- Чёткие границы ответственности: аутентификация (sessions), справочники (users, devices), авторизация (roles, permissions, role_permissions, user_roles)
- Готовность к масштабированию: легко добавлять новые роли/права, несколько ролей на пользователя, аналитику по устройствам