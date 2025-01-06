///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Обработчик клиентской назначаемой команды.
//
// Параметры:
//   ИдентификаторКоманды - Строка - имя команды, как оно задано в функции СведенияОВнешнейОбработке модуля объекта.
//   МассивДокументов - Массив - ссылки, для которых выполняется команда.
//
&НаКлиенте
Процедура Печать(ИдентификаторКоманды, МассивДокументов) Экспорт
	
	Если МассивДокументов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Состояние(НСтр("ru = 'Формирование печатных форм...'"));
	УправлениеПечатьюКлиент.ВыполнитьКомандуПечати("Обработка._ДемоПечатнаяФорма", "СписаниеТоваровOpenOfficeXML", МассивДокументов, ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если ЗначениеЗаполнено(Параметры.ОбъектыНазначения) Тогда
		Для Каждого Ссылка Из Параметры.ОбъектыНазначения Цикл
			ОбъектыНазначения.Добавить(Ссылка);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СформироватьПечатнуюФорму(Команда)
	
	Печать("СписаниеТоваровOpenOfficeXML", ОбъектыНазначения.ВыгрузитьЗначения());
	
КонецПроцедуры

#КонецОбласти
