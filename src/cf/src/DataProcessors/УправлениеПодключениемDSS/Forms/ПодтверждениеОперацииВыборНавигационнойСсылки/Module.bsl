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
	
	Элементы.СписокФайлов.РежимВыбора = Параметры.РежимВыбора;
	
	Если Параметры.СписокДокументов <> Неопределено Тогда
		Для каждого СтрокаМассива Из Параметры.СписокДокументов Цикл
			НоваяСтрока = СписокФайлов.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаМассива);
			НоваяСтрока.НаименованиеФайла = СервисКриптографииDSSПодтверждениеСервер.ПредставлениеДокумента(СтрокаМассива);
		КонецЦикла;	
	
		Заголовок = "Документы (" + XMLСтрока(СписокФайлов.Количество()) + ")";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СервисКриптографииDSSСлужебныйКлиент.ПриОткрытииФормы(ЭтотОбъект, ПрограммноеЗакрытие);
	
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
#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СписокФайловВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ТекущаяСтрока = Элементы.СписокФайлов.ТекущиеДанные;
	
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	Если Элементы.СписокФайлов.РежимВыбора Тогда
		ОтветПользователя = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Истина);
		ОтветПользователя.Вставить("Результат", ТекущаяСтрока.НавигационнаяСсылка);
		ЗакрытьФорму(ОтветПользователя);
	Иначе
		СервисКриптографииDSSКлиент.ПерейтиПоСсылке(ТекущаяСтрока.НавигационнаяСсылка);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗакрытьФорму(ПараметрыЗакрытия = Неопределено)
	
	ПрограммноеЗакрытие = Истина;
	
	Если ПараметрыЗакрытия = Неопределено Тогда
		ПараметрыЗакрытия = СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь, "ОтказПользователя");
	КонецЕсли;	
	
	Закрыть(ПараметрыЗакрытия);
	
КонецПроцедуры	

#КонецОбласти
