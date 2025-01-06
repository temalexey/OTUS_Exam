///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ПеревестиТекст(Текст, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат Текст;
	КонецЕсли;
	
	Возврат ПеревестиТексты(ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Текст), ЯзыкПеревода, ИсходныйЯзык)[Текст];
	
КонецФункции

Функция ПеревестиТексты(Тексты, ЯзыкПеревода = Неопределено, ИсходныйЯзык = Неопределено) Экспорт
	
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр("ПеревестиТексты", "Тексты", Тексты, Тип("Массив"));
	
	Если Не ЗначениеЗаполнено(ЯзыкПеревода) Тогда
		ЯзыкПеревода = ОбщегоНазначения.КодОсновногоЯзыка();
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	НастройкиАвторизации = НастройкиАвторизации();
	УстановитьПривилегированныйРежим(Ложь);
	
	ИмяХоста = "translate.api.cloud.yandex.net";
	
	HTTPЗапрос = Новый HTTPЗапрос("/translate/v2/translate");
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	HTTPЗапрос.Заголовки.Вставить("Authorization", "Bearer" + " " + IAMТокен());
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("folder_id", НастройкиАвторизации.ИдентификаторКаталога);
	ПараметрыЗапроса.Вставить("texts", Тексты);
	ПараметрыЗапроса.Вставить("targetLanguageCode", ЯзыкПеревода);
	
	Если ЗначениеЗаполнено(ИсходныйЯзык) Тогда
		ПараметрыЗапроса.Вставить("sourceLanguageCode", ИсходныйЯзык);
	КонецЕсли;
	
	HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.ЗначениеВJSON(ПараметрыЗапроса));
	РезультатЗапроса = ВыполнитьЗапрос(HTTPЗапрос, ИмяХоста);
	
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		ВызватьИсключение ТекстОшибки(НСтр("ru = 'Не удалось выполнить перевод текста.'"));
	КонецЕсли;
	
	ОтветСервера = ОбщегоНазначения.JSONВЗначение(РезультатЗапроса.ОтветСервера);
	
	Результат = Новый Соответствие;
	Для Индекс = 0 По Тексты.ВГраница() Цикл
		Перевод = ОтветСервера["translations"][Индекс];
		Результат.Вставить(Тексты[Индекс], Перевод["text"]);
		Если Не ЗначениеЗаполнено(ИсходныйЯзык) Тогда
			ИсходныйЯзык = Перевод["detectedLanguageCode"];
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция МаксимальныйРазмерПорции() Экспорт
	
	Возврат 10000;
	
КонецФункции

Функция IAMТокен()
	
	ПараметрыТокена = Новый Структура("IAMТокен,СрокДействия");
	
	УстановитьПривилегированныйРежим(Истина);
	ЗаполнитьЗначенияСвойств(ПараметрыТокена, НастройкиАвторизации());
	УстановитьПривилегированныйРежим(Ложь);
	
	Если Не ЗначениеЗаполнено(ПараметрыТокена.IAMТокен) 
		Или Не ЗначениеЗаполнено(ПараметрыТокена.СрокДействия)
		Или ПараметрыТокена.СрокДействия <= УниверсальноеВремя(ТекущаяДата()) Тогда // АПК:143
		ПараметрыТокена = НовыйIAMТокен();
		УстановитьПривилегированныйРежим(Истина);
		Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.СервисПереводаТекста");
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ПараметрыТокена.IAMТокен, "IAMТокен");
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(Владелец, ПараметрыТокена.СрокДействия, "СрокДействия");
		УстановитьПривилегированныйРежим(Ложь);
	КонецЕсли;
	
	Возврат ПараметрыТокена.IAMТокен;
	
КонецФункции

Функция НовыйIAMТокен()
	
	ИмяХоста = "iam.api.cloud.yandex.net";
	
	HTTPЗапрос = Новый HTTPЗапрос("/iam/v1/tokens");
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	
	ПараметрыЗапроса = Новый Структура;
	
	УстановитьПривилегированныйРежим(Истина);
	ПараметрыЗапроса.Вставить("yandexPassportOauthToken", НастройкиАвторизации().OAuthТокен);
	УстановитьПривилегированныйРежим(Ложь);
	
	HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.ЗначениеВJSON(ПараметрыЗапроса));
	
	РезультатЗапроса = ВыполнитьЗапрос(HTTPЗапрос, ИмяХоста);
	
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		ВызватьИсключение ТекстОшибки(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
			"ru = 'Не удалось авторизоваться в сервисе %1.'"), "Yandex.Cloud"));
	КонецЕсли;
	
	НастройкаАвторизации = ОбщегоНазначения.JSONВЗначение(РезультатЗапроса.ОтветСервера, "expiresAt");
	IAMТокен = НастройкаАвторизации["iamToken"];
	СрокДействия = НастройкаАвторизации["expiresAt"];
	
	Результат = Новый Структура;
	Результат.Вставить("IAMТокен", IAMТокен);
	Результат.Вставить("СрокДействия", УниверсальноеВремя(СрокДействия));
	
	Возврат Результат;
	
КонецФункции

Функция ДоступныеЯзыки() Экспорт
	
	ИмяХоста = "translate.api.cloud.yandex.net";
	
	HTTPЗапрос = Новый HTTPЗапрос("/translate/v2/languages");
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	HTTPЗапрос.Заголовки.Вставить("Authorization", "Bearer" + " " + IAMТокен());
	
	
	ПараметрыЗапроса = Новый Структура;
	
	УстановитьПривилегированныйРежим(Истина);
	ПараметрыЗапроса.Вставить("folder_id", НастройкиАвторизации().ИдентификаторКаталога);
	УстановитьПривилегированныйРежим(Ложь);
	
	HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.ЗначениеВJSON(ПараметрыЗапроса));
	
	РезультатЗапроса = ВыполнитьЗапрос(HTTPЗапрос, ИмяХоста);
	
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		ВызватьИсключение ТекстОшибки(НСтр("ru = 'Не удалось получить список доступных языков.'"));
	КонецЕсли;
	
	Результат = Новый Массив;
	ДоступныеЯзыки = ОбщегоНазначения.JSONВЗначение(РезультатЗапроса.ОтветСервера);
	Для Каждого Язык Из ДоступныеЯзыки["languages"] Цикл
		КодЯзыка = Язык["code"];
		Если ЗначениеЗаполнено(КодЯзыка) Тогда
			Результат.Добавить(КодЯзыка);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ВыполнитьЗапрос(Знач HTTPЗапрос, Знач ИмяХоста)
	
	Прокси = ПолучениеФайловИзИнтернета.ПолучитьПрокси("https");
	ЗащищенноеСоединение = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	
	Попытка
		Соединение = Новый HTTPСоединение(ИмяХоста, , , , Прокси, 60, ЗащищенноеСоединение);
		HTTPОтвет = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		ЗаписатьОшибкуВЖурналРегистрации(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось установить соединение с сервером %1 по причине:
			|%2'"), ИмяХоста, ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
		ВызватьИсключение;
	КонецПопытки;
	
	Результат = Новый Структура;
	Результат.Вставить("ЗапросВыполнен", Ложь);
	Результат.Вставить("ОтветСервера", "");
	
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Запрос ""%1"" не выполнен. Код состояния: %2.'"),
			HTTPЗапрос.АдресРесурса,
			HTTPОтвет.КодСостояния) + Символы.ПС + HTTPОтвет.ПолучитьТелоКакСтроку();
		ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки);
	КонецЕсли;
		
	Если HTTPОтвет.КодСостояния = 401 
		Или HTTPОтвет.КодСостояния = 403 Тогда
		ИнформацияОбОшибке = ОбщегоНазначения.JSONВЗначение(HTTPОтвет.ПолучитьТелоКакСтроку());
		ВызватьИсключение ИнформацияОбОшибке["message"];
	КонецЕсли;
	
	Результат.ЗапросВыполнен = HTTPОтвет.КодСостояния = 200;
	Результат.ОтветСервера = HTTPОтвет.ПолучитьТелоКакСтроку();
	
	Возврат Результат;
	
КонецФункции

Функция НастройкиАвторизации() Экспорт
	
	ИменаПараметров = "OAuthТокен,ИдентификаторКаталога,IAMТокен,СрокДействия";
	Результат = Новый Структура(ИменаПараметров);
	
	Владелец = ОбщегоНазначения.ИдентификаторОбъектаМетаданных("Константа.СервисПереводаТекста");
	Настройки = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(Владелец, ИменаПараметров);
	Если ЗначениеЗаполнено(Настройки) Тогда
		ЗаполнитьЗначенияСвойств(Результат, Настройки);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//  Настройки - см. ПереводТекстаНаДругиеЯзыки.НастройкиСервисаПереводаТекста
//
Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
	Настройки.ИнструкцияПоПодключению = СтроковыеФункции.ФорматированнаяСтрока(НСтр(
		"ru = 'Как настроить:
		|1. Подключите сервис <a href = ""%1"">Yandex.Cloud</a> и активируйте <a href = ""%2"">платежный аккаунт</a>.
		|2. Перейдите на страницу <a href = ""%3"">Яндекс OAuth</a> и скопируйте строку из букв и цифр в поле <b>OAuth-токен</b>.
		|3. Перейдите в <a href = ""%4"">консоль управления Yandex Cloud</a>, в списке <b>Ваши ресурсы</b> справа от каталога <b>default</b> скопируйте строку из букв и цифр и вставьте в поле <b>Идентификатор каталога</b>.'"),
		"https://cloud.yandex.com/", "https://console.cloud.yandex.com/billing",
		"https://oauth.yandex.com/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb",
		"https://console.cloud.yandex.com/");
	
	Параметр = Настройки.ПараметрыАвторизации.Добавить();
	Параметр.Имя = "OAuthТокен";
	Параметр.Представление = НСтр("ru = 'OAuth-токен'");
	Параметр.ОтображениеПодсказки = ОтображениеПодсказки.ОтображатьСверху;
	
	Параметр = Настройки.ПараметрыАвторизации.Добавить();
	Параметр.Имя = "ИдентификаторКаталога";
	Параметр.Представление = НСтр("ru = 'Идентификатор каталога'");
	Параметр.ОтображениеПодсказки = ОтображениеПодсказки.ОтображатьСверху;
	
КонецПроцедуры

Функция НастройкаВыполнена() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	НастройкиАвторизации = НастройкиАвторизации();
	
	Возврат ЗначениеЗаполнено(НастройкиАвторизации.OAuthТокен)
		И ЗначениеЗаполнено(НастройкиАвторизации.ИдентификаторКаталога);
	
КонецФункции

Процедура ЗаписатьОшибкуВЖурналРегистрации(Комментарий)
	
	ЗаписьЖурналаРегистрации(НСтр("ru = 'Перевод текста'", ОбщегоНазначения.КодОсновногоЯзыка()),
		УровеньЖурналаРегистрации.Ошибка, , Перечисления.СервисыПереводаТекста.ЯндексПереводчик, Комментарий);
	
КонецПроцедуры

Функция ТекстОшибки(ТекстОшибки)
	
	Если Пользователи.ЭтоПолноправныйПользователь() Тогда
		Возврат ТекстОшибки + Символы.ПС + НСтр("ru = 'Подробности см. в журнале регистрации.'");
	КонецЕсли;
	
	Возврат ТекстОшибки + Символы.ПС + НСтр("ru = 'Обратитесь к администратору.'");
	
КонецФункции

// Возвращает список разрешений для использования сервиса перевода.
//
// Возвращаемое значение:
//  Массив
//
Функция Разрешения() Экспорт
	
	Протокол = "HTTPS";
	Адрес = "translate.api.cloud.yandex.net";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Сервис перевода текста Яндекс.Переводчик'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешение = МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание);
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(Разрешение);
	
	Возврат Разрешения;
	
КонецФункции

#КонецОбласти
