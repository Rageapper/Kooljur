# Инструкция по деплою проекта на GitHub

## Шаг 1: Инициализация Git репозитория (если еще не инициализирован)

```bash
cd project
git init
```

## Шаг 2: Добавление удаленного репозитория

```bash
git remote add origin https://github.com/Rageapper/Kooljur.git
```

Если репозиторий уже добавлен, обновите URL:
```bash
git remote set-url origin https://github.com/Rageapper/Kooljur.git
```

## Шаг 3: Проверка файлов перед коммитом

Убедитесь, что конфиденциальные файлы не будут закоммичены:

```bash
git status
```

Проверьте, что следующие файлы НЕ отображаются в списке для коммита:
- `android/local.properties`
- `ios/Flutter/flutter_export_environment.sh`
- `ios/Flutter/Generated.xcconfig`
- `lib/core/config/firebase_config_local.dart`
- `service-account-key.json`

## Шаг 4: Добавление файлов

```bash
git add .
```

## Шаг 5: Создание первого коммита

```bash
git commit -m "Initial commit: Kooljur Дневник - Flutter приложение для электронного дневника"
```

## Шаг 6: Отправка в GitHub

```bash
git branch -M main
git push -u origin main
```

Если репозиторий уже существует и содержит файлы:
```bash
git pull origin main --allow-unrelated-histories
# Разрешите конфликты, если они возникнут
git push -u origin main
```

## Проверка после деплоя

После успешного деплоя проверьте:
1. Откройте https://github.com/Rageapper/Kooljur
2. Убедитесь, что README.md отображается корректно
3. Проверьте, что конфиденциальные файлы отсутствуют в репозитории

## Важно!

⚠️ **Перед деплоем убедитесь:**
- Все конфиденциальные данные удалены из кода
- `.gitignore` настроен правильно
- README.md содержит актуальную информацию
- Пароль админ панели изменен (если используется в production)
