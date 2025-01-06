///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Позволяет дополнить регистры с движениями документа дополнительными регистрами.
//
// Параметры:
//    Документ - ДокументСсылка - документ коллекцию движений которого необходимо дополнить.
//    РегистрыСДвижениями - Соответствие из КлючИЗначение:
//        * Ключ     - ОбъектМетаданных - регистр как объект метаданных.
//        * Значение - Строка           - имя поля регистратора.
//
Процедура ПриОпределенииРегистровСДвижениями(Документ, РегистрыСДвижениями) Экспорт
	
	// _Демо начало примера
	_ДемоСтандартныеПодсистемы.ПриОпределенииРегистровСДвижениями(Документ, РегистрыСДвижениями);
	// _Демо конец примера
	
КонецПроцедуры

// Позволяет рассчитать количество записей для дополнительных наборов, добавленных процедурой
// ПриОпределенииРегистровСДвижениями.
//
// Параметры:
//    Документ - ДокументСсылка - документ коллекцию движений которого необходимо дополнить.
//    РассчитанноеКоличество - Соответствие из КлючИЗначение:
//        * Ключ     - Строка - полное имя регистра (вместо точек используется символ подчеркивания).
//        * Значение - Число  - рассчитанное количество записей.
//
Процедура ПриРасчетеКоличестваЗаписей(Документ, РассчитанноеКоличество) Экспорт
	
	// _Демо начало примера
	_ДемоСтандартныеПодсистемы.ПриРасчетеКоличестваЗаписей(Документ, РассчитанноеКоличество);
	// _Демо конец примера
	
КонецПроцедуры

// Позволяет дополнить или переопределить коллекцию наборов данных для вывода движений документа.
//
// Параметры:
//    Документ - ДокументСсылка - документ, коллекцию движений которого необходимо дополнить.
//    НаборыДанных - Массив - сведения о наборах данных (тип элемента Структура).
//
Процедура ПриПодготовкеНабораДанных(Документ, НаборыДанных) Экспорт
	
	// _Демо начало примера
	_ДемоСтандартныеПодсистемы.ПриПодготовкеНабораДанных(Документ, НаборыДанных);
	// _Демо конец примера
	
КонецПроцедуры

#КонецОбласти
