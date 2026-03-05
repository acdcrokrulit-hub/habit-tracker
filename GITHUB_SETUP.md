# 📤 Инструкция по загрузке на GitHub

## Вариант 1: Через командную строку (рекомендуется)

1. Откройте терминал в папке проекта:
```bash
cd c:\Users\user\Desktop\mob.razrab\habit-tracker
```

2. Создайте новый репозиторий на GitHub:
   - Перейдите на https://github.com/new
   - Имя репозитория: `habit-tracker`
   - Не инициализируйте его (без README, .gitignore, license)
   - Нажмите "Create repository"

3. Выполните команды (замените `YOUR_USERNAME` на ваш ник GitHub):
```bash
git remote add origin https://github.com/YOUR_USERNAME/habit-tracker.git
git branch -M main
git push -u origin main
```

4. Если требуется аутентификация:
   - Используйте Personal Access Token вместо пароля
   - Создайте токен: https://github.com/settings/tokens
   - Права: `repo` (полный доступ)

## Вариант 2: Через GitHub Desktop

1. Скачайте GitHub Desktop: https://desktop.github.com/
2. Откройте программу и добавьте проект:
   - File → Add Local Repository
   - Выберите папку: `c:\Users\user\Desktop\mob.razrab\habit-tracker`
3. Нажмите "Publish repository"
4. Введите имя `habit-tracker` и нажмите Publish

## Вариант 3: Через VS Code

1. Откройте папку проекта в VS Code
2. Нажмите на иконку Source Control (Ctrl+Shift+G)
3. Нажмите "Publish to GitHub"
4. Следуйте инструкциям

## 🛠️ Если возникают ошибки

### Ошибка: Connection was reset
- Проверьте интернет-соединение
- Попробуйте использовать VPN
- Попробуйте позже

### Ошибка: Authentication failed
- Создайте Personal Access Token: https://github.com/settings/tokens
- Используйте токен вместо пароля при git push

### Ошибка: Repository not found
- Убедитесь, что репозиторий создан на GitHub
- Проверьте правильность URL

---

**Проект готов к загрузке! Все файлы созданы и закоммичены.**
