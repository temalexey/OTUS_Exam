///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.ВариантыОтчетов

// Задать настройки формы отчета.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения
//         - Неопределено
//   КлючВарианта - Строка
//                - Неопределено
//   Настройки - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
	Настройки.ФормироватьСразу = Истина;
	Настройки.Печать.ПолеСверху = 5;
	Настройки.Печать.ПолеСлева = 5;
	Настройки.Печать.ПолеСнизу = 5;
	Настройки.Печать.ПолеСправа = 5;
	Настройки.События.ПередЗагрузкойНастроекВКомпоновщик = Истина;
	Настройки.События.ПриСозданииНаСервере = Истина;
	Настройки.События.ПриОпределенииПараметровВыбора = Истина;
	Настройки.События.ПриОпределенииОсновныхПолей = Истина;
КонецПроцедуры

// Вызывается в обработчике одноименного события формы отчета после выполнения кода формы.
// См. также: ФормаКлиентскогоПриложения.ПриСозданииНаСервере в синтакс-помощнике 
// и ОтчетыПереопределяемый.ПриСозданииНаСервере.
//
// Параметры:
//   Форма - см. ОбщаяФорма.ФормаОтчета.
//   Отказ - Булево - передается из параметров обработчика "как есть".
//   СтандартнаяОбработка - Булево - передается из параметров обработчика "как есть".
//
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	Форма.Элементы.ГруппаОтправить.Подсказка = НСтр("ru = '<Демо: Тест>'");
	Если Форма.Параметры.КлючВарианта = "ПоВерсиям" Тогда
		ОписаниеКоманды = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(Форма.Параметры, "ОписаниеКоманды"); // см. ПодключаемыеКоманды.ОписаниеКоманды
		Если ОписаниеКоманды <> Неопределено И ОписаниеКоманды.Идентификатор = "_ДемоОтчетПоВерсиям" Тогда
			Файл = ПараметрыФормы(Форма);
			Форма.ФормаПараметры.Отбор.Вставить("Папка", ВладельцыФайлов(Файл.Ссылка));
		КонецЕсли;
	КонецЕсли;
	
	Команда = Форма.Команды.Добавить("_ДемоКоманда");
	Команда.Действие  = "Подключаемый_Команда"; // Обработчик команды см. ОтчетыКлиентПереопределяемый.ОбработчикКоманды.
	Команда.Заголовок = НСтр("ru = 'Изменить табличный документ'");
	Команда.Картинка  = БиблиотекаКартинок.Изменить;
	
	ОтчетыСервер.ВывестиКоманду(Форма, Команда, "РаботаСТабличнымДокументом");
КонецПроцедуры

// Вызывается перед загрузкой новых настроек. Используется для изменения СКД отчета.
//
// Параметры:
//   Контекст - Произвольный
//   КлючСхемы - Строка
//   КлючВарианта - Строка
//                - Неопределено
//   НовыеНастройкиКД - НастройкиКомпоновкиДанных
//                    - Неопределено
//   НовыеПользовательскиеНастройкиКД - ПользовательскиеНастройкиКомпоновкиДанных
//                                    - Неопределено
//
Процедура ПередЗагрузкойНастроекВКомпоновщик(Контекст, КлючСхемы, КлючВарианта, НовыеНастройкиКД, НовыеПользовательскиеНастройкиКД) Экспорт
	УточнитьДатуИзменения(НовыеНастройкиКД);
	
	Если КлючСхемы = "1" Тогда
		Возврат;
	КонецЕсли;
	
	КлючСхемы = "1";
	
	// Подмена списка доступных значений на уровне схемы, чтобы СКД знала о представлениях этих значений.
	ВсеИзвестныеТипыФайлов = ТипыФайлов();
	ПолеНабораДанныхСхемыКД = СхемаКомпоновкиДанных.НаборыДанных.НаборДанных1.Поля.Найти("Тип");
	Если ТипЗнч(ПолеНабораДанныхСхемыКД) = Тип("ПолеНабораДанныхСхемыКомпоновкиДанных") Тогда
		ПолеНабораДанныхСхемыКД.УстановитьДоступныеЗначения(ВсеИзвестныеТипыФайлов);
	КонецЕсли;
	
	// А также для вложенной схемы.
	ВложеннаяСхема = СхемаКомпоновкиДанных.ВложенныеСхемыКомпоновкиДанных.Вложенный; // ВложеннаяСхемаКомпоновкиДанных 
	ПолеНабораДанныхСхемыКД = ВложеннаяСхема.Схема.НаборыДанных.НаборДанных1.Поля.Найти("Тип");
	Если ТипЗнч(ПолеНабораДанныхСхемыКД) = Тип("ПолеНабораДанныхСхемыКомпоновкиДанных") Тогда
		ПолеНабораДанныхСхемыКД.УстановитьДоступныеЗначения(ВсеИзвестныеТипыФайлов);
	КонецЕсли;
	ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКомпоновкиДанных, КлючСхемы);
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриОпределенииПараметровВыбора.
Процедура ПриОпределенииПараметровВыбора(Форма, СвойстваНастройки) Экспорт
	ИмяПоля = Строка(СвойстваНастройки.ПолеКД);
	Если ИмяПоля = "ПараметрыДанных.Размер" Тогда
		СвойстваНастройки.ЗначенияДляВыбора.Добавить(10000000, НСтр("ru = 'Больше 10 Мб'"));
	ИначеЕсли ИмяПоля = "Автор" И СвойстваНастройки.ОписаниеТипов.СодержитТип(Тип("СправочникСсылка.Пользователи")) Тогда
		СвойстваНастройки.ОграничиватьВыборУказаннымиЗначениями = Истина;
		СвойстваНастройки.ЗапросЗначенийВыбора.Текст =
		"ВЫБРАТЬ Ссылка ИЗ Справочник.Пользователи ГДЕ НЕ ПометкаУдаления И НЕ Недействителен И НЕ Служебный";
	ИначеЕсли ИмяПоля = "Тип" Тогда
		СвойстваНастройки.ЗначенияДляВыбора.Очистить();
		ВсеИзвестныеТипыФайлов = ТипыФайлов();
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ Расширение ИЗ Справочник.ВерсииФайлов";
		Таблица = Запрос.Выполнить().Выгрузить();
		Для Каждого СтрокаТаблицы Из Таблица Цикл
			Тип = НРег(СтрокаТаблицы.Расширение);
			Если СвойстваНастройки.ЗначенияДляВыбора.НайтиПоЗначению(Тип) <> Неопределено Тогда
				Продолжить;
			КонецЕсли;
			Элемент = ВсеИзвестныеТипыФайлов.НайтиПоЗначению(Тип);
			Если Элемент = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			СвойстваНастройки.ЗначенияДляВыбора.Добавить(Элемент.Значение, Элемент.Представление);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриОпределенииОсновныхПолей.
Процедура ПриОпределенииОсновныхПолей(Форма, ОсновныеПоля) Экспорт 
	
	ОсновныеПоля.Добавить("Ссылка");
	ОсновныеПоля.Добавить("ВладелецФайла");
	ОсновныеПоля.Добавить("Тип");
	ОсновныеПоля.Добавить("Автор");
	ОсновныеПоля.Добавить("ДатаСоздания");
	ОсновныеПоля.Добавить("ТекущаяВерсия");
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ВариантыОтчетов

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Параметры формы.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма
// 
// Возвращаемое значение:
//  Структура:
//   * Ссылка 
//
Функция ПараметрыФормы(Форма)
	Результат = Новый Структура;
	Результат.Вставить("Ссылка");
	ЗаполнитьЗначенияСвойств(Результат, Форма.ФормаПараметры.Отбор);
	Возврат Результат;
КонецФункции

// Возвращает список значений, в котором значение - расширение файлов в нижнем регистре.
//
Функция ТипыФайлов()
	Результат = Новый СписокЗначений;
	Результат.Добавить("txt",  НСтр("ru = 'Текстовый документ (.txt)'"));
	Результат.Добавить("xls",  НСтр("ru = 'Таблица Excel 97-2003 (.xls)'"));
	Результат.Добавить("xlsx", НСтр("ru = 'Таблица Excel 2007 (.xlsx)'"));
	Результат.Добавить("mxl",  НСтр("ru = 'Таблица 1С (.mxl)'"));
	Результат.Добавить("doc",  НСтр("ru = 'Документ Word 97-2003 (.doc)'"));
	Результат.Добавить("docx", НСтр("ru = 'Документ Word 2007 (.docx)'"));
	Результат.Добавить("pdf",  НСтр("ru = 'Документ Adobe (.pdf)'"));
	Результат.Добавить("htm",  НСтр("ru = 'Веб-страница (.htm)'"));
	Результат.Добавить("html", НСтр("ru = 'Веб-страница (.html)'"));
	Результат.Добавить("png",  НСтр("ru = 'Картинка (.png)'"));
	Возврат Результат;
КонецФункции

Функция ВладельцыФайлов(МассивФайлов)
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ ВладелецФайла ИЗ Справочник.Файлы ГДЕ Ссылка В (&МассивФайлов)");
	Запрос.УстановитьПараметр("МассивФайлов", МассивФайлов);
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("ВладелецФайла");
КонецФункции

Процедура УточнитьДатуИзменения(Настройки)
	
	Если ТипЗнч(Настройки) <> Тип("НастройкиКомпоновкиДанных") Тогда 
		Возврат;
	КонецЕсли;
	
	ПараметрыДанных = Настройки.ПараметрыДанных;
	Период = ПараметрыДанных.Элементы.Найти("Период");
	
	Если Период = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	СекундДоМестногоВремени = ПараметрыДанных.Элементы.Найти("СекундДоМестногоВремени");
	
	Если СекундДоМестногоВремени = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	ДатаУниверсальная = ТекущаяДатаСеанса();
	СекундДоМестногоВремени.Значение = МестноеВремя(ДатаУниверсальная, ЧасовойПоясСеанса()) - ДатаУниверсальная;
	СекундДоМестногоВремени.Использование = Период.Использование;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли