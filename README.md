#Описание
Этот проект представляет собой набор функций на PowerShell для работы с Telegram API. Скрипт позволяет получать обновления, отправлять сообщения, отправлять действия чата, редактировать сообщения и получать файлы из Telegram.

##Установка
Убедитесь, что у вас установлен PowerShell.
Скачайте или клонируйте этот репозиторий на ваш компьютер.
Использование

##Получение обновлений
Функция Get-TelegramUpdates позволяет получать обновления из Telegram.
`**powershell**`
$updates = Get-TelegramUpdates -BotToken "<Ваш_BotToken>"

##Отправка сообщения
Функция Send-Message отправляет сообщение в указанный чат.
`**powershell**`
Send-Message -BotToken "<Ваш_BotToken>" -ChatID "<Идентификатор_чата>" -Message "Ваше сообщение"

##Отправка действия чата
Функция Send-ChatAction отправляет действие чата, например, "печатает".
`**powershell**`
Send-ChatAction -BotToken "<Ваш_BotToken>" -ChatID "<Идентификатор_чата>"

##Отправка клавиатуры
Функция Send-KeyBoard отправляет клавиатуру с кнопками в Telegram.
`**powershell**`
$buttons = @("Кнопка 1", "Кнопка 2")
Send-KeyBoard -URL "https://api.telegram.org/bot<Ваш_BotToken>/sendKeyboard" -Buttons $buttons -ChatID "<Идентификатор_чата>" -Message "Выберите опцию."

##Редактирование сообщения
Функция Edit-TelegramMessageText редактирует существующее сообщение в Telegram.
`**powershell**`
Edit-TelegramMessageText -BotToken "<Ваш_BotToken>" -ChatID "<Идентификатор_чата>" -MessageID <Идентификатор_сообщения> -Message "Новый текст сообщения"

##Получение файла
Функция Get-TelegramFile позволяет получить файл по его идентификатору.
`**powershell**`
Get-TelegramFile -URL "https://api.telegram.org/bot<Ваш_BotToken>/getFile" -FileID "<Идентификатор_файла>" -ScriptPath "<Путь_к_скрипту>"

###Параметры
<Ваш_BotToken>: Токен вашего бота Telegram.
<Идентификатор_чата>: Уникальный идентификатор целевого чата или имя пользователя канала (в формате @channelusername).
<Идентификатор_сообщения>: Идентификатор сообщения, которое нужно редактировать.
<Идентификатор_файла>: Идентификатор файла, который нужно получить.
<Путь_к_скрипту>: Путь к директории, куда будет сохранен файл.

##Примечания
Убедитесь, что ваш бот имеет необходимые разрешения для выполнения указанных действий.
Рекомендуется использовать переменные окружения для хранения токена бота для повышения безопасности.

##Контакты
Если у вас есть вопросы или предложения, пожалуйста, свяжитесь с автором проекта.