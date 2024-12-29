function Get-TelegramUpdates {
    <#
    .SYNOPSIS
    Получает обновления из Telegram

    .DESCRIPTION
    Эта функция получает обновления из Telegram и извлекает соответствующую информацию, такую ​​как идентификатор чата, текст, данные обратного вызова, фотографию, документ, местоположение и контакт.

    .PARAMETER URL
    URL-адрес Telegram API

    .OUTPUTS
    Хэш-таблица, содержащая извлеченную информацию

    .EXAMPLE
    Get-TelegramUpdates -BotToken $BotToken
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $BotToken
    )
    $URL = "https://api.telegram.org/bot$BotToken/getUpdates"
    $Json = Invoke-RestMethod -Uri $URL
    $Data = $Json.result | Select-Object -Last 1
    $Return = @{}
    # Нажатие на кнопку
    if ($null -ne $Data.callback_query) {
        $ChatID             = $Data.callback_query.from.id
        $FirstName          = $Data.callback_query.from.first_name
        $UserName           = $Data.callback_query.from.username
        $MessageID          = $Data.callback_query.message.message_id
        $Text               = $Data.callback_query.message.text
        $CallbackQueryData  = $Data.callback_query.data
        # From Callback Query
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("MessageID", $MessageID)
        $Return.Add("Text", $Text)
        $Return.Add("CallbackQueryData", $CallbackQueryData)
        $Return.Add("CallbackQuery", $true)
    }
    # Если получено местоположение
    elseif ($null -ne $Data.message.location) {
        $MessageID  = $Data.message.message_id
        $ChatID     = $Data.message.chat.id
        $FirstName  = $Data.message.chat.first_name
        $UserName   = $Data.message.chat.username
        $Latitude   = $Data.message.location.latitude
        $Longitude  = $Data.message.location.longitude
        # From Location
        $Return.Add("MessageID", $MessageID)
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("Latitude", $Latitude)
        $Return.Add("Longitude", $Longitude)
        $Return.Add("MessageLocation", $true)
    }
    # Если получено изображение
    elseif ($null -ne $Data.message.photo) {
        $MessageID  = $Data.message.message_id
        $ChatID     = $Data.message.chat.id
        $FirstName  = $Data.message.from.first_name
        $UserName   = $Data.message.chat.username
        $FileID     = ($Data.message.photo | Select-Object -Last 1).file_id
        # From Photo
        $Return.Add("MessageID", $MessageID)
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("FileID", $FileID)
        $Return.Add("MessagePhoto", $true)
    }
    # Если получен документ
    elseif ($null -ne $Data.message.document) {
        $MessageID  = $Data.message.message_id
        $ChatID     = $Data.message.chat.id
        $FirstName  = $Data.message.chat.first_name
        $UserName   = $Data.message.chat.username
        $FileName   = $Data.message.document.file_name
        $MimeType   = $Data.message.document.mime_type
        $FileID     = $Data.message.document.file_id
        # From Document
        $Return.Add("MessageID", $MessageID)
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("FileName", $FileName)
        $Return.Add("MimeType", $MimeType)
        $Return.Add("FileID", $FileID)
        $Return.Add("MessageDocument", $true)
    }
    # Если получен контакт
    elseif ($null -ne $Data.message.contact) {
        $MessageID          = $Data.message.message_id
        $ChatID             = $Data.message.chat.id
        $FirstName          = $Data.message.chat.first_name
        $UserName           = $Data.message.chat.username
        $PhoneNumber        = $Data.message.contact.phone_number
        $ContactFirstName   = $Data.message.contact.first_name
        $TelegramUserID     = $Data.message.contact.user_id
        # From Contact
        $Return.Add("MessageID", $MessageID)
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("PhoneNumber", $PhoneNumber)
        $Return.Add("ContactFirstName", $ContactFirstName)
        $Return.Add("TelegramUserID", $TelegramUserID)
        $Return.Add("MessageContact", $true)
    }
    # Обычное сообщение
    elseif ($null -ne $Data.message.text) {
        $MessageID  = $Data.message.message_id
        $ChatID     = $Data.message.chat.id
        $FirstName  = $Data.message.chat.first_name
        $UserName   = $Data.message.chat.username
        $Text       = $Data.message.text
        # From Text
        $Return.Add("MessageID", $MessageID)
        $Return.Add("ChatID", $ChatID)
        $Return.Add("FirstName", $FirstName)
        $Return.Add("UserName", $UserName)
        $Return.Add("Text", $Text)
        $Return.Add("MessageText", $true)
    }
    # Подтверждение
    Invoke-RestMethod "$($URL)?offset=$($($Data.update_id)+1)" -Method Get | Out-Null
    return $Return
} # function Get-TelegramUpdates

function Send-Message {
    <#
    .SYNOPSIS
    Отправляет сообщение в Telegram

    .DESCRIPTION
    Эта функция отправляет сообщение в Telegram, используя предоставленный идентификатор чата и текст.

    .EXAMPLE
    Send-Message -BotToken $BotToken -ChatID $ChatID -Message "Hello, world!"
    Отправляет сообщение в чат.

    .EXAMPLE
    Send-Message -BotToken $BotToken -ChatID $ChatID -MessageID $MessageID -Message "Hello, world!"
    Отправляет сообщение в чат ответом на сообщение.
    #>
    [CmdletBinding()]
    param (
        # BotToken
        [Parameter(Mandatory = $true)]
        [System.String]
        $BotToken,
        # Уникальный идентификатор целевого чата или имя пользователя целевого канала (в формате @channelusername)
        [Parameter(Mandatory = $true)]
        [System.String]
        $ChatID,
        # Текст отправляемого сообщения, 1-4096 символов после анализа сущностей.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,
        # Идентификатор сообщения, на которое будет дан ответ в текущем чате или в чатеchat_id, если он указан.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $MessageID
    )
    $URL = "https://api.telegram.org/bot$BotToken/sendMessage"
    $Return = @{
        text = $Message
        parse_mode = "Markdown"
        chat_id = $ChatID
        reply_to_message_id = $MessageID
    }
    $Json = $Return | ConvertTo-Json
    Invoke-RestMethod -Uri $URL -Method Post -ContentType 'application/json; charset=utf-8' -Body $Json
} # function Send-Message

function Send-ChatAction {
    <#
    .SYNOPSIS
    Sends a chat action to Telegram

    .DESCRIPTION
    Эта функция отправляет в Telegram действие чата, указывающее, что бот печатает.

    .EXAMPLE
    Send-ChatAction -BotToken $BotToken -ChatID $ChatID
    #>
    # BotToken
    [CmdletBinding()]
    param (
        # BotToken
        [Parameter(Mandatory = $true)]
        [System.String]
        $BotToken,
        # ChatID
        [Parameter(Mandatory = $true)]
        [System.String]
        $ChatID
    )
    $URL = "https://api.telegram.org/bot$BotToken/sendChatAction"
    $Body = @{
        chat_id = $ChatID
        action  = 'typing'
    }
    (Invoke-WebRequest -Uri $URL -Body $Body).Content | ConvertFrom-Json
} # function Send-ChatAction

function Send-KeyBoard($URL, $Buttons, $ChatID, $Message) {
    <#
    .SYNOPSIS
    Отправляет клавиатуру в Telegram

    .DESCRIPTION
    Эта функция отправляет клавиатуру в Telegram, используя предоставленные кнопки, идентификатор чата и текст.

    .PARAMETER URL
    URL-адрес Telegram API

    .PARAMETER buttons
    Массив кнопок для отображения на клавиатуре

    .PARAMETER chat_id
    Идентификатор чата, в который нужно отправить клавиатуру

    .PARAMETER text
    Текст, отображаемый с помощью клавиатуры

    .EXAMPLE
    Send-KeyBoard -URL "https://api.telegram.org/bot<token>/sendKeyboard" -Buttons @("Button 1", "Button 2") -chat_id 123456 -Message "Select an option."
    #>
    $Keyboard = @{}
    $Lines = 3
    # Тут необходимо использовать ArrayList, т.к внутри него мы будем хранить объекты - 
    # другие массивы
    $ButtonsLine = New-Object System.Collections.ArrayList
    for($Item=0; $Item -lt $Buttons.Count; $Item++) {
        # Добавляем кнопки в линию (line). Как только добавили 3 - добавляем Line в Keyboard
        $ButtonsLine.Add($Buttons[$Item]) | Out-Null
        # Проверяем счетчик - остаток от деления должен быть 0
        if( ($Item + 1)%$Lines -eq 0 ) {
            # Добавляем строку кнопок в keyboard
            $Keyboard["inline_keyboard"] += @(,@($ButtonsLine))
            $ButtonsLine.Clear()
        }
    }
    # Добавляем оставшиеся последние кнопки
    $Keyboard["inline_keyboard"] += @(,@($ButtonsLine))
    $HashTable = @{
        parse_mode = "Markdown"
        reply_markup = $Keyboard
        chat_id = $ChatID
        text = $Message
    }
    $Json = $HashTable | ConvertTo-Json -Depth 5
    Invoke-RestMethod $URL -Method Post -ContentType 'application/json; charset=utf-8' -Body $Json
} # function Send-KeyBoard

function Edit-TelegramMessageText {
    <#
    .SYNOPSIS
    Редактирует сообщение в Telegram

    .DESCRIPTION
    Эта функция редактирует сообщение в Telegram, используя предоставленный идентификатор чата, идентификатор сообщения и текст.

    .EXAMPLE
    Edit-TelegramMessageText -BotToken $BotToken -ChatID $ChatID -MessageID $MessageID -Message $Message
#>
    [CmdletBinding()]
    param (
        # BotToken
        [Parameter(Mandatory = $true)]
        [System.String]
        $BotToken, 
        # Требуется, если inline_message_id не указан. Уникальный идентификатор целевого чата или имя пользователя целевого канала (в формате @channelusername).
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $ChatID,
        # Требуется, если inline_message_id не указан. Идентификатор сообщения, которое нужно редактировать.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $MessageID, 
        # Требуется, если не указаны chat_id и message_id. Идентификатор встроенного сообщения.
        [Parameter(Mandatory = $false)]
        [System.String]
        $InlineMessageID,
        # Новый текст сообщения, 1-4096 символов после разбора сущностей.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,
        # Режим разбора сущностей в тексте сообщения. Дополнительные сведения см. в разделе «Параметры форматирования».
        [Parameter(Mandatory = $false)]
        [ValidateSet('HTML', 'MarkdownV2', 'Markdown')]
        [System.String]
        $ParseMode
        )
    $URL = "https://api.telegram.org/bot$($BotToken)/editMessageText"
    $Return = @{
        text = $Message
        parse_mode = "Markdown"
        chat_id = $ChatID
        message_id = $MessageID
    }
    $Json = $Return | ConvertTo-Json
    Invoke-RestMethod $URL -Method Post -ContentType 'application/json; charset=utf-8' -Body $Json
} # function Edit-TelegramMessageText

function Get-TelegramFile {
    [CmdletBinding()]
    param (
        # URL
        [Parameter(Mandatory = $true)]
        [string]
        $URL,
        # FileID
        [Parameter(Mandatory = $true)]
        [string]
        $FileID,
        # ScriptPath
        [Parameter(Mandatory = $true)]
        [string]
        $ScriptPath
    )
    {
        $GetPhotoPath = (Invoke-RestMethod -Uri "$($URL)?file_id=$($FileID)").result.file_path
        # Формируем URL для скачивания файла
        $FileDownloadUrl = "https://api.telegram.org/file/bot$BotToken/$GetPhotoPath"
        # Скачиваем файл
        Invoke-WebRequest -Uri $FileDownloadUrl -OutFile "$($ScriptPath)/Photo"
    }
} # function Get-TelegramFile