// @strict-types

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Получить объект к обработке.
// 
// Параметры:
//  ПоПриоритетуОбработки - Булево - По приоритету обработки
// 
// Возвращаемое значение:
//  Структура - Получить объект к обработке:
// * ЕстьОбъектыКОбработке - Булево - Есть объекты к обработке
// * Объект - см. РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке
Функция ПолучитьОбъектКОбработке(ПоПриоритетуОбработки = Ложь) Экспорт
	
	Результат = Новый Структура();
	Результат.Вставить("ЕстьОбъектыКОбработке", Ложь);
	Результат.Вставить("Объект", Неопределено);
	
	Блокировка = Новый БлокировкаДанных();
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ВыгрузкаЗагрузкаОбъектовМетаданных");
	ЭлементБлокировки.УстановитьЗначение("ПорядокОбработки", 0);
	
	НачатьТранзакцию();
	
	Попытка
		
		Блокировка.Заблокировать();
		
		ВыборкаОбъектов = ВыборкаОбъектовКОбработке(Ложь, 1);
		
		Если ВыборкаОбъектов.Следующий() Тогда
			
			Результат.ЕстьОбъектыКОбработке = Истина;
			Результат.Объект = ВыборкаОбъектов;
			
			Если ПоПриоритетуОбработки Тогда
				
				ПриоритетЗагружаемого = ПриоритетЗагружаемогоОбъектаМетаданных();
				ПриоритетОбъекта = ПриоритетИзПорядкаОбработки(ВыборкаОбъектов.ПорядокОбработки);
				
				Если ПриоритетЗагружаемого <> ПриоритетОбъекта Тогда
					Результат.Объект = Неопределено;
				КонецЕсли;
				
			КонецЕсли;
			
			Если Результат.Объект <> Неопределено Тогда
				ЗафиксироватьНачалоОбработкиОбъекта(Результат.Объект);
			КонецЕсли;
		
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

// Выборка объектов к загрузке.
// 
// Параметры:
//  Обрабатывается - Булево - Признак выбора обрабатываемых \ не обрабатываемых ранее объектов.
//  КоличествоОбъектов - Число - Количество объектов в выборке
// 
// Возвращаемое значение:
//  ВыборкаИзРезультатаЗапроса - Выборка объектов к загрузке:
//  * ПорядокОбработки - Число - Номер объекта в порядке обработки
//  * ОбъектМетаданных - Строка - Полное имя объекта метаданных
Функция ВыборкаОбъектовКОбработке(Обрабатывается = Ложь, КоличествоОбъектов = 0) Экспорт
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("Обрабатывается", Обрабатывается);
	
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1000
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки КАК ПорядокОбработки,
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ОбъектМетаданных КАК ОбъектМетаданных
	|ИЗ
	|	РегистрСведений.ВыгрузкаЗагрузкаОбъектовМетаданных КАК ВыгрузкаЗагрузкаОбъектовМетаданных
	|ГДЕ
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.Обрабатывается = &Обрабатывается
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки";
	
	ТекстПервые = ?(ЗначениеЗаполнено(КоличествоОбъектов), "ПЕРВЫЕ " + Формат(КоличествоОбъектов, "ЧГ=0;"), "");
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "ПЕРВЫЕ 1000", ТекстПервые);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

// Есть обрабатываемые объекты метаданных.
// 
// Возвращаемое значение:
//  Булево - Есть обрабатываемые объекты метаданных
Функция ЕстьОбрабатываемыеОбъектыМетаданных() Экспорт
	
	Запрос = Новый Запрос();
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК Результат
	|ИЗ
	|	РегистрСведений.ВыгрузкаЗагрузкаОбъектовМетаданных КАК ВыгрузкаЗагрузкаОбъектовМетаданных
	|ГДЕ
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.Обрабатывается";
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

// Зафиксировать начало обработки объекта.
// 
// Параметры:
//  ВыборкаОбъектов - см. РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке
Процедура ЗафиксироватьНачалоОбработкиОбъекта(ВыборкаОбъектов) Экспорт
	
	ЗаписьРегистра = ПолучитьМенеджерЗаписи(ВыборкаОбъектов);
	ЗаписьРегистра.Обрабатывается = Истина;
	ЗаписьРегистра.Записать();
	
КонецПроцедуры

// Зафиксировать окончание обработки объекта.
// 
// Параметры:
//  ВыборкаОбъектов - см. РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке
Процедура ЗафиксироватьОкончаниеОбработкиОбъекта(ВыборкаОбъектов) Экспорт
	
	ЗаписьРегистра = ПолучитьМенеджерЗаписи(ВыборкаОбъектов);
	ЗаписьРегистра.Обрабатывается = Ложь;
	ЗаписьРегистра.Записать();
	
КонецПроцедуры

// Удалить запись.
// 
// Параметры:
//  ВыборкаОбъектов - см. РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке
Процедура УдалитьЗапись(ВыборкаОбъектов) Экспорт
	
	ЗаписьРегистра = СоздатьМенеджерЗаписи();
	ЗаписьРегистра.ПорядокОбработки = ВыборкаОбъектов.ПорядокОбработки;
	ЗаписьРегистра.Удалить();
	
КонецПроцедуры

// Приоритет загружаемого объекта метаданных.
// 
// Возвращаемое значение:
//  Неопределено, Число - Приоритет загружаемого объекта метаданных
Функция ПриоритетЗагружаемогоОбъектаМетаданных() Экспорт
	
	Запрос = Новый Запрос();
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки КАК ПорядокОбработки
	|ИЗ
	|	РегистрСведений.ВыгрузкаЗагрузкаОбъектовМетаданных КАК ВыгрузкаЗагрузкаОбъектовМетаданных
	|ГДЕ
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.Обрабатывается
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат ПриоритетИзПорядкаОбработки(Выборка.ПорядокОбработки);
	КонецЕсли;
	
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки КАК ПорядокОбработки
	|ИЗ
	|	РегистрСведений.ВыгрузкаЗагрузкаОбъектовМетаданных КАК ВыгрузкаЗагрузкаОбъектовМетаданных
	|ГДЕ
	|	НЕ ВыгрузкаЗагрузкаОбъектовМетаданных.Обрабатывается
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВыгрузкаЗагрузкаОбъектовМетаданных.ПорядокОбработки";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат ПриоритетИзПорядкаОбработки(Выборка.ПорядокОбработки);
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

// Приоритет из порядка обработки.
// 
// Параметры:
//  ПорядокОбработки - Число - Порядок обработки
// 
// Возвращаемое значение:
//  Число - Приоритет из порядка обработки
Функция ПриоритетИзПорядкаОбработки(ПорядокОбработки) Экспорт
	
	Возврат Цел(ПорядокОбработки / 10000);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Получить менеджер записи.
// 
// Параметры:
//  ВыборкаОбъектов - см. РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке
// 
// Возвращаемое значение:
//  РегистрСведенийМенеджерЗаписи.ВыгрузкаЗагрузкаОбъектовМетаданных - менеджер записи регистра
Функция ПолучитьМенеджерЗаписи(ВыборкаОбъектов)
	
	ЗаписьРегистра = СоздатьМенеджерЗаписи();
	ЗаписьРегистра.ПорядокОбработки = ВыборкаОбъектов.ПорядокОбработки;
	ЗаписьРегистра.Прочитать();
	
	Если Не ЗаписьРегистра.Выбран() Или ЗаписьРегистра.ОбъектМетаданных <> ВыборкаОбъектов.ОбъектМетаданных Тогда
		
		ТекстОшибки = СтрШаблон(
			НСтр("ru = 'Объект метаданных выборки ''%1'' не соответствует значению записи ''%2'''"),
			ВыборкаОбъектов.ОбъектМетаданных,
			?(ЗаписьРегистра.Выбран(), ЗаписьРегистра.ОбъектМетаданных, НСтр("ru = 'Запись не найдена'")));
		
		ВызватьИсключение ТекстОшибки;
		
	КонецЕсли;
	
	Возврат ЗаписьРегистра;
	
КонецФункции

#КонецОбласти

#КонецЕсли
