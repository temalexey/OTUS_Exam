///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если НЕ ИспользуетсяСОбъектамиАдресации И НЕ ИспользуетсяБезОбъектовАдресации Тогда
		ОбщегоНазначения.СообщитьПользователю(
			НСтр("ru = 'Не указаны допустимые способы назначения исполнителей на роль: совместно с объектами адресации, без них или обоими способами.'"),
		 	ЭтотОбъект, "ИспользуетсяБезОбъектовАдресации",,Отказ);
		Возврат;
	КонецЕсли;
	
	Если НЕ ИспользуетсяСОбъектамиАдресации Тогда
		Возврат;
	КонецЕсли;
	
	ЗаданыТипыОсновногоОбъектаАдресации = ТипыОсновногоОбъектаАдресации <> Неопределено И НЕ ТипыОсновногоОбъектаАдресации.Пустая();
	Если НЕ ЗаданыТипыОсновногоОбъектаАдресации Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Не указаны типы основного объекта адресации.'"),
		 	ЭтотОбъект, "ТипыОсновногоОбъектаАдресации",,Отказ);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	Если ТипыОсновногоОбъектаАдресации <> Неопределено И ТипыОсновногоОбъектаАдресации.Пустая() Тогда
		ТипыОсновногоОбъектаАдресации = Неопределено;
	КонецЕсли;
	
	Если ТипыДополнительногоОбъектаАдресации <> Неопределено И ТипыДополнительногоОбъектаАдресации.Пустая() Тогда
		ТипыДополнительногоОбъектаАдресации = Неопределено;
	КонецЕсли;
	
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей") Тогда
		Если Назначение.Найти(Справочники.Пользователи.ПустаяСсылка(), "ТипПользователей") = Неопределено Тогда
			// При отключенных внешних пользователях, роль всегда должна быть назначена пользователям.
			Назначение.Добавить().ТипПользователей = Справочники.Пользователи.ПустаяСсылка();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПриЧтенииПредставленийНаСервере() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Мультиязычность") Тогда
		МодульМультиязычностьСервер = ОбщегоНазначения.ОбщийМодуль("МультиязычностьСервер");
		МодульМультиязычностьСервер.ПриЧтенииПредставленийНаСервере(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли