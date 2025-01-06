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

// СтандартныеПодсистемы.Печать

// Переопределяет настройки печати для объекта.
//
// Параметры:
//  Настройки - см. УправлениеПечатью.НастройкиПечатиОбъекта.
//
Процедура ПриОпределенииНастроекПечати(Настройки) Экспорт
	
	Настройки.ПриДобавленииКомандПечати = Истина;
	
КонецПроцедуры

// Заполняет список команд печати.
// 
// Параметры:
//  КомандыПечати - см. УправлениеПечатью.СоздатьКоллекциюКомандПечати
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "НакладнаяНаПеремещение";
	КомандаПечати.Представление = НСтр("ru = 'Накладная на перемещение'");
	КомандаПечати.ПроверкаПроведенияПередПечатью = Истина;
	
КонецПроцедуры

// Формирует печатные формы.
//
// Параметры:
//  МассивОбъектов - см. УправлениеПечатьюПереопределяемый.ПриПечати.МассивОбъектов
//  ПараметрыПечати - см. УправлениеПечатьюПереопределяемый.ПриПечати.ПараметрыПечати
//  КоллекцияПечатныхФорм - см. УправлениеПечатьюПереопределяемый.ПриПечати.КоллекцияПечатныхФорм
//  ОбъектыПечати - см. УправлениеПечатьюПереопределяемый.ПриПечати.ОбъектыПечати
//  ПараметрыВывода - см. УправлениеПечатьюПереопределяемый.ПриПечати.ПараметрыВывода
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт

	// Печать накладной на перемещение.
	НужноПечататьМакет = УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "НакладнаяНаПеремещение");
	Если НужноПечататьМакет Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
			КоллекцияПечатныхФорм,
			"НакладнаяНаПеремещение",
			НСтр("ru = 'Накладная на перемещение'"),
			ПечатнаяФормаПеремещениеТоваров(МассивОбъектов, ОбъектыПечати),
			,
			"Документ._ДемоПеремещениеТоваров.ПФ_MXL_НакладнаяНаПеремещение");
	КонецЕсли;
		
КонецПроцедуры

// Конец СтандартныеПодсистемы.Печать

// СтандартныеПодсистемы.УправлениеДоступом

// Параметры:
//   Ограничение - см. УправлениеДоступомПереопределяемый.ПриЗаполненииОграниченияДоступа.Ограничение.
//
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"РазрешитьЧтение
	|ГДЕ
	|	ЗначениеРазрешено(Организация)
	|	И (     ЗначениеРазрешено(МестоХраненияИсточник)
	|	    ИЛИ ЗначениеРазрешено(МестоХраненияПриемник))
	|;
	|РазрешитьИзменениеЕслиРазрешеноЧтение
	|ГДЕ
	|	ЗначениеРазрешено(МестоХраненияИсточник)
	|	И ЗначениеРазрешено(МестоХраненияПриемник)
	|	И ЗначениеРазрешено(Ответственный)";
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПечатнаяФормаПеремещениеТоваров(МассивОбъектов, ОбъектыПечати)
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	_ДемоПеремещениеТоваров.Ссылка,
	|	_ДемоПеремещениеТоваров.Номер,
	|	_ДемоПеремещениеТоваров.Дата,
	|	_ДемоПеремещениеТоваров.МестоХраненияИсточник,
	|	_ДемоПеремещениеТоваров.МестоХраненияПриемник,
	|	_ДемоПеремещениеТоваров.Организация,
	|	_ДемоПеремещениеТоваров.Ответственный,
	|	_ДемоПеремещениеТоваров.Товары.(
	|		НомерСтроки,
	|		Номенклатура,
	|		Количество
	|	)
	|ИЗ
	|	Документ._ДемоПеремещениеТоваров КАК _ДемоПеремещениеТоваров
	|ГДЕ
	|	_ДемоПеремещениеТоваров.Ссылка В (&СписокДокументов)";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("СписокДокументов", МассивОбъектов);
	
	Шапка = Запрос.Выполнить().Выбрать();
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "НакладнаяНаПеремещение";
	
	Макет = УправлениеПечатью.МакетПечатнойФормы("Документ._ДемоПеремещениеТоваров.ПФ_MXL_НакладнаяНаПеремещение");
	
	Пока Шапка.Следующий() Цикл
		Если ТабличныйДокумент.ВысотаТаблицы > 0 Тогда
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		ДанныеПечати = Новый Структура;
		
		ТекстЗаголовка = СформироватьЗаголовокДокумента(Шапка, НСтр("ru = 'Демо: Перемещение товаров'"));
		ДанныеПечати.Вставить("ТекстЗаголовка", ТекстЗаголовка);
		ДанныеПечати.Вставить("ОрганизацияПредставление", Шапка.Организация);
		ДанныеПечати.Вставить("ОтправительПредставление", Шапка.МестоХраненияИсточник);
		ДанныеПечати.Вставить("ПолучательПредставление", Шапка.МестоХраненияПриемник);
		
		ТаблицаТовары = Шапка.Товары.Выгрузить();
		
		МассивОбластейМакета = Новый Массив;
		МассивОбластейМакета.Добавить("Заголовок");
		МассивОбластейМакета.Добавить("ШапкаТаблицы");
		МассивОбластейМакета.Добавить("Строка");
		МассивОбластейМакета.Добавить("Подвал");
		МассивОбластейМакета.Добавить("Подписи");
		
		Для Каждого ИмяОбласти Из МассивОбластейМакета Цикл
			ОбластьМакета = Макет.ПолучитьОбласть(ИмяОбласти);
			Если ИмяОбласти <> "Строка" Тогда
				ЗаполнитьЗначенияСвойств(ОбластьМакета.Параметры, ДанныеПечати);
				ТабличныйДокумент.Вывести(ОбластьМакета);
			Иначе
				Для Каждого СтрокаТаблицы Из ТаблицаТовары Цикл
					ОбластьМакета.Параметры.Заполнить(СтрокаТаблицы);
					ТабличныйДокумент.Вывести(ОбластьМакета);
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;

		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, НомерСтрокиНачало, ОбъектыПечати, Шапка.Ссылка);
	
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
	
КонецФункции

// Возвращает заголовок документа для печатной формы.
//
// Параметры:
//  Шапка - любая структура с полями:
//           Номер         - Строка, Число - номер документа;
//           Дата          - Дата - дата документа;
//           Представление - Строка - (необязательный) платформенное представление ссылки на документ.
//                                    Если параметр НазваниеДокумента не задан, то название документа будет вычисляться
//                                    из этого параметра.
//  НазваниеДокумента - Строка - название документа (например, "Счет на оплату").
//
// Возвращаемое значение:
//  Строка - заголовок документа.
//
Функция СформироватьЗаголовокДокумента(Шапка, Знач НазваниеДокумента = "")
	
	ДанныеДокумента = Новый Структура("Номер,Дата,Представление");
	ЗаполнитьЗначенияСвойств(ДанныеДокумента, Шапка);
	
	// Если название документа не передано, получим название по представлению документа.
	Если ПустаяСтрока(НазваниеДокумента) И ЗначениеЗаполнено(ДанныеДокумента.Представление) Тогда
		ПоложениеНомера = СтрНайти(ДанныеДокумента.Представление, ДанныеДокумента.Номер);
		Если ПоложениеНомера > 0 Тогда
			НазваниеДокумента = СокрЛП(Лев(ДанныеДокумента.Представление, ПоложениеНомера - 1));
		КонецЕсли;
	КонецЕсли;

	НомерНаПечать = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ДанныеДокумента.Номер);
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 № %2 от %3'"),
		НазваниеДокумента, НомерНаПечать, Формат(ДанныеДокумента.Дата, "ДЛФ=DD"));
	
КонецФункции

#КонецОбласти

#КонецЕсли
