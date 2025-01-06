///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ПрограммноеЗакрытие;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьЗначенияПараметров(Параметры);
	ТолькоПросмотр = Параметры.ТолькоПросмотр
					ИЛИ НЕ СервисКриптографииDSSСлужебный.ПроверитьПраво("ЭкземплярыСервераDSS", "Изменение");
	
	Заголовок = НСтр("ru = 'Расширенные настройки:'", СервисКриптографииDSSСлужебный.КодЯзыка()) + " " + Параметры.Заголовок;
	ВсеВерсии = СервисКриптографииDSSКлиентСервер.ПоддерживаемыеВерсии();
	Элементы.ВерсияАПИ.СписокВыбора.ЗагрузитьЗначения(ВсеВерсии);
	Элементы.Наименование.Доступность = НЕ ТолькоПросмотр;

	ПервичнаяАвторизация.ЗагрузитьЗначения(СервисКриптографииDSSСлужебный.ДоступныеСпособыПервичнойАвторизации());
	ВторичнаяАвторизация.ЗагрузитьЗначения(СервисКриптографииDSSСлужебный.ДоступныеСпособыВторичнойАвторизации());
	СервисКриптографииDSSСлужебный.ПолучитьПредставлениеСпособовАвторизации(ПервичнаяАвторизация);
	СервисКриптографииDSSСлужебный.ПолучитьПредставлениеСпособовАвторизации(ВторичнаяАвторизация);
	
	СпособыАвторизации = СервисКриптографииDSSКлиентСервер.ПолучитьПолеСтруктуры(Параметры, "СпособыАвторизации", Новый Массив);
	Для каждого СтрокаМассива Из СпособыАвторизации Цикл
		НашлиПервичную = ПервичнаяАвторизация.НайтиПоЗначению(СтрокаМассива);
		НашлиВторичную = ВторичнаяАвторизация.НайтиПоЗначению(СтрокаМассива);
		Если НашлиПервичную <> Неопределено Тогда
			НашлиПервичную.Пометка = Истина;
		КонецЕсли;	
		Если НашлиВторичную <> Неопределено Тогда
			НашлиВторичную.Пометка = Истина;
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СервисКриптографииDSSСлужебныйКлиент.ПриОткрытииФормы(ЭтотОбъект, ПрограммноеЗакрытие);
	ОбновитьСтатусОграничения("Первичная");
	ОбновитьСтатусОграничения("Вторичная");
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если СервисКриптографииDSSСлужебныйКлиент.ПередЗакрытиемФормы(
			ЭтотОбъект,
			Отказ,
			ПрограммноеЗакрытие,
			ЗавершениеРаботы) Тогда
		ЗакрытьФорму();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПервичнаяАвторизация

&НаКлиенте
Процедура ПервичнаяАвторизацияПриИзменении(Элемент)
	
	ОбновитьСтатусОграничения("Первичная");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыВторичнаяАвторизация

&НаКлиенте
Процедура ВторичнаяАвторизацияПриИзменении(Элемент)
	
	ОбновитьСтатусОграничения("Вторичная");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	Если Модифицированность Тогда
		Результат = Новый Структура(СписокРеквизитов());
		ЗаполнитьЗначенияСвойств(Результат, ЭтотОбъект);
		Результат.Вставить("СпособыАвторизации", ПолучитьВариантыАвторизации());
		РезультатВыбора = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию();
		РезультатВыбора.Вставить("Результат", Результат);
	Иначе
		РезультатВыбора = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь);
	КонецЕсли;
	
	ЗакрытьФорму(РезультатВыбора);
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	ЗакрытьФорму();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбновитьСтатусОграничения(ВидОграничения)
	
	Если ВидОграничения = "Первичная" Тогда
		ТекущийСписок = ПервичнаяАвторизация;
		ЭлементЗаголовка = Элементы.ДекорацияОписаниеПервичной;
	Иначе
		ТекущийСписок = ВторичнаяАвторизация;
		ЭлементЗаголовка = Элементы.ДекорацияОписаниеВторичной;
	КонецЕсли;
	
	ВсегоПометок = 0;
	Для Каждого СтрокаСписка Из ТекущийСписок Цикл
		ВсегоПометок = ВсегоПометок + ?(СтрокаСписка.Пометка, 1, 0);
	КонецЦикла;	
	
	КодЯзыка = СервисКриптографииDSSСлужебныйКлиент.КодЯзыка();
	Если ВсегоПометок = 0 Тогда
		ЭлементЗаголовка.Заголовок = НСтр("ru = 'По умолчанию доступны все способы авторизации.'", КодЯзыка);
	ИначеЕсли ВсегоПометок = ТекущийСписок.Количество() Тогда
		ЭлементЗаголовка.Заголовок = НСтр("ru = 'Доступны все способы авторизации.'", КодЯзыка);
	Иначе
		ЭлементЗаголовка.Заголовок = НСтр("ru = 'Способы авторизации ограничены списком.'", КодЯзыка);
	КонецЕсли;	
	
КонецПроцедуры	

&НаКлиенте
Функция ПолучитьВариантыАвторизации()
	
	Результат = Новый Массив;
	
	Для Каждого СтрокаСписка Из ПервичнаяАвторизация Цикл
		Если СтрокаСписка.Пометка Тогда
			Результат.Добавить(СтрокаСписка.Значение);
		КонецЕсли;	
	КонецЦикла;
	
	Для Каждого СтрокаСписка Из ВторичнаяАвторизация Цикл
		Если СтрокаСписка.Пометка Тогда
			Результат.Добавить(СтрокаСписка.Значение);
		КонецЕсли;	
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ЗакрытьФорму(ПараметрыЗакрытия = Неопределено)
	
	ПрограммноеЗакрытие = Истина;
	
	Если ПараметрыЗакрытия = Неопределено Тогда
		ПараметрыЗакрытия = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь);
	КонецЕсли;
	
	Закрыть(ПараметрыЗакрытия);
	
КонецПроцедуры	

&НаСервере
Функция СписокРеквизитов()
	
	Результат = "ВерсияАПИ, ШаблонПодтверждения, ТаймАут, Используется, Наименование";
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьЗначенияПараметров(ПараметрыФормы)
	
	ВсеПоля = Новый Структура(СписокРеквизитов());
	ЗаполнитьЗначенияСвойств(ВсеПоля, ПараметрыФормы);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ВсеПоля);
	
КонецПроцедуры

#КонецОбласти