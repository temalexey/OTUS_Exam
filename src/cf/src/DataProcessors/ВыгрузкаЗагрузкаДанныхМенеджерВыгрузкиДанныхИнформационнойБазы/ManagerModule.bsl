#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Выгружает данные информационной базы.
//
// Параметры:
//	Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - менеджер
//		контейнера, используемый в процессе выгрузи данных. Подробнее см. комментарий
//		к программному интерфейсу обработки ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.
//	Обработчики - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерОбработчиковВыгрузкиДанных - менеджер 
//		обработчиков выгрузки данных. 
//	Сериализатор - СериализаторXDTO - сериализатор XDTO с аннотацией типов. 
//
Процедура ВыгрузитьДанныеИнформационнойБазы(Контейнер, Обработчики, Сериализатор) Экспорт
	
	ПараметрыПроцессаВыгрузки = НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы(
		Контейнер, Обработчики, Сериализатор);
	УзлыРК = ПолучитьУзлыРезервногоКопирования(Контейнер, ПараметрыПроцессаВыгрузки.ИсключаемыеТипы);
	
	ЗаписатьВыгружаемыеОбъектыМетаданных(ПараметрыПроцессаВыгрузки);
	
	Если ПараметрыПроцессаВыгрузки.ИспользоватьМногопоточность Тогда
		
		Задания = ЗапуститьПотокиВыгрузкиДанных(ПараметрыПроцессаВыгрузки, УзлыРК);
		
		ВыгрузкаЗагрузкаДанныхСлужебный.ОжидатьВыгрузкуЗагрузкуДанныхВПотоках(
			Задания, ПараметрыПроцессаВыгрузки.Контейнер);
		
	Иначе
		
		ВыгрузитьОсновныеДанные(ПараметрыПроцессаВыгрузки, УзлыРК.ОсновнойУзел);
		
	КонецЕсли;
	
	Если УзлыРК.ДополнительныйУзел = Неопределено Тогда
		
		// Выгрузка в монопольном режиме
		ЗавершитьВыгрузку(ПараметрыПроцессаВыгрузки, УзлыРК.ОсновнойУзел);
				
	Иначе
		 
		// Выгрузка объектов измененных за время выгрузки
		// Если объектов много, то выгрузить без транзакции
		ВыгрузитьНакопленныеОсновныеДанные(ПараметрыПроцессаВыгрузки, УзлыРК.ДополнительныйУзел);
		
		ВыгрузкаВТранзакцииВыполнена = Ложь;
		
		Для НомерПопытки = 1 По 3 Цикл
			
			ВыгрузкаВТранзакцииВыполнена = ЗавершитьВыгрузкуВТранзакции(
				ПараметрыПроцессаВыгрузки, 
				УзлыРК.ДополнительныйУзел);
			
			Если ВыгрузкаВТранзакцииВыполнена Тогда
				Прервать;
			КонецЕсли;
			
			ОбщегоНазначенияБТС.Пауза(60);
			
		КонецЦикла;
		
		Если Не ВыгрузкаВТранзакцииВыполнена Тогда
			ВызватьИсключение НСтр("ru = 'Не удалось заблокировать область, резервная копия не сделана.'");
		КонецЕсли;
		
	КонецЕсли;
	
	ВыгрузитьОбщиеДанные(ПараметрыПроцессаВыгрузки);
	
	ПараметрыПроцессаВыгрузки.ПотокЗаписиПересоздаваемыхСсылок.Закрыть();
	ПараметрыПроцессаВыгрузки.ПотокЗаписиСопоставляемыхСсылок.Закрыть();
	
	Если ПараметрыПроцессаВыгрузки.Контейнер.ФиксироватьСостояние() Тогда
		Контейнер.ЗафиксироватьЗавершениеОбработкиОбъектовМетаданных();	
	КонецЕсли;
	
КонецПроцедуры

// Выгрузить данные информационной базы в потоке.
// 
// Параметры:
//  ПараметрыПотока - Структура - см. свойство Параметры в функции ЗапуститьПотокиВыгрузкиДанных
// 
Процедура ВыгрузитьДанныеИнформационнойБазыВПотоке(ПараметрыПотока) Экспорт
	
	Контейнер = Обработки.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера.Создать();
	Контейнер.ИнициализироватьВыгрузкуВПотоке(ПараметрыПотока.Контейнер);
	
	Обработчики = Обработки.ВыгрузкаЗагрузкаДанныхМенеджерОбработчиковВыгрузкиДанных.Создать();
	Обработчики.Инициализировать(Контейнер);
	
	Сериализатор = ВыгрузкаЗагрузкаДанныхСлужебный.СериализаторXDTOСАннотациейТипов();
	
	ПараметрыПроцессаВыгрузки = НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы(
		Контейнер, Обработчики, Сериализатор, ПараметрыПотока.ПотокЗаписиСопоставляемыхСсылок);
	
	ВыгрузитьОсновныеДанныеВПотоке(ПараметрыПроцессаВыгрузки, ПараметрыПотока.ОсновнойУзел);
	
	ПараметрыПроцессаВыгрузки.ПотокЗаписиПересоздаваемыхСсылок.Закрыть();
	ПараметрыПроцессаВыгрузки.ПотокЗаписиСопоставляемыхСсылок.Закрыть();
	
	ДанныеСообщения = Новый Структура();
	ДанныеСообщения.Вставить(
		"Состав",
		ОбщегоНазначения.ТаблицаЗначенийВМассив(ПараметрыПроцессаВыгрузки.Контейнер.Состав()));
	ДанныеСообщения.Вставить(
		"ИспользуемыеФайлы",
		Новый ФиксированныйМассив(ПараметрыПроцессаВыгрузки.Контейнер.ИспользуемыеФайлы()));
	ДанныеСообщения.Вставить(
		"Предупреждения",
		Новый ФиксированныйМассив(ПараметрыПроцессаВыгрузки.Контейнер.Предупреждения()));
	ДанныеСообщения.Вставить(
		"ДублиПредопределенных",
		ОбщегоНазначения.ЗначениеВСтрокуXML(ПараметрыПроцессаВыгрузки.Контейнер.ДублиПредопределенных()));
	
	ВыгрузкаЗагрузкаДанныхСлужебный.ОтправитьСообщениеВРодительскийПоток(
		ПараметрыПроцессаВыгрузки.Контейнер.ИдентификаторПроцесса(),
		"ЗавершениеВыгрузки",
		ДанныеСообщения);
	
КонецПроцедуры

// Возвращает признак возможности дифференциальной копии
// 
// Возвращаемое значение:
// 	Булево - Описание
Функция ВыгрузкаДифференциальнойКопииВозможна() Экспорт
	
	Узел = ПланыОбмена.МиграцияПриложений.НайтиПоКоду(КодОсновногоУзла());
	
	Возврат ЗначениеЗаполнено(Узел);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Новые параметры процесса выгрузки данных информационной базы.
// 
// Параметры:
//  Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - Контейнер
//  Обработчики - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерОбработчиковВыгрузкиДанных - Обработчики
//  Сериализатор - СериализаторXDTO - Сериализатор XDTO с аннотацией типов
//  ПараметрыИнициализацииСопоставленияСсылок - см. ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхПотокЗаписиСопоставляемыхСсылок.ПолучитьПараметрыИнициализацииВПотоке
// 
// Возвращаемое значение:
//  Структура - Новые параметры процесса выгрузки данных информационной базы:
// * Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера 
// * Обработчики - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерОбработчиковВыгрузкиДанных 
// * Сериализатор - СериализаторXDTO 
// * ПотокЗаписиПересоздаваемыхСсылок - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхПотокЗаписиПересоздаваемыхСсылок
// * ПотокЗаписиСопоставляемыхСсылок - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхПотокЗаписиСопоставляемыхСсылок
// * ВыгружаемыеТипы - Массив Из ОбъектМетаданных
// * ИсключаемыеТипы - Массив Из ОбъектМетаданных
// * ИспользоватьМногопоточность - Булево
Функция НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы(
	Контейнер, Обработчики, Сериализатор, ПараметрыИнициализацииСопоставленияСсылок = Неопределено)
	
	ПотокЗаписиПересоздаваемыхСсылок = Обработки.ВыгрузкаЗагрузкаДанныхПотокЗаписиПересоздаваемыхСсылок.Создать();
	ПотокЗаписиПересоздаваемыхСсылок.Инициализировать(Контейнер, Сериализатор);
	
	ПотокЗаписиСопоставляемыхСсылок = Обработки.ВыгрузкаЗагрузкаДанныхПотокЗаписиСопоставляемыхСсылок.Создать();
	ПотокЗаписиСопоставляемыхСсылок.Инициализировать(Контейнер, Сериализатор, ПараметрыИнициализацииСопоставленияСсылок);
	
	ПараметрыПроцессаВыгрузки = Новый Структура();
	ПараметрыПроцессаВыгрузки.Вставить("Контейнер", Контейнер);
	ПараметрыПроцессаВыгрузки.Вставить("Обработчики", Обработчики);
	ПараметрыПроцессаВыгрузки.Вставить("Сериализатор", Сериализатор);
	ПараметрыПроцессаВыгрузки.Вставить("ПотокЗаписиПересоздаваемыхСсылок", ПотокЗаписиПересоздаваемыхСсылок);
	ПараметрыПроцессаВыгрузки.Вставить("ПотокЗаписиСопоставляемыхСсылок", ПотокЗаписиСопоставляемыхСсылок);
	
	Если Контейнер.ЭтоДочернийПоток() Тогда
		
		ПараметрыПроцессаВыгрузки.Вставить("ВыгружаемыеТипы", Новый Массив());
		ПараметрыПроцессаВыгрузки.Вставить("ИсключаемыеТипы", Новый Массив());
		ПараметрыПроцессаВыгрузки.Вставить("ИспользоватьМногопоточность", Ложь);
		
	Иначе
		
		ПараметрыВыгрузки = Контейнер.ПараметрыВыгрузки();
		ИсключаемыеТипы = ВыгрузкаЗагрузкаДанныхСлужебныйСобытия.ПолучитьТипыИсключаемыеИзВыгрузкиЗагрузки();
		ИспользоватьМногопоточность = ВыгрузкаЗагрузкаДанныхСлужебный.ИспользоватьМногопоточность(ПараметрыВыгрузки);
		
		ПараметрыПроцессаВыгрузки.Вставить("ВыгружаемыеТипы", ПараметрыВыгрузки.ВыгружаемыеТипы);
		ПараметрыПроцессаВыгрузки.Вставить("ИсключаемыеТипы", ИсключаемыеТипы);
		ПараметрыПроцессаВыгрузки.Вставить("ИспользоватьМногопоточность", ИспользоватьМногопоточность);
		
	КонецЕсли;
	
	Возврат ПараметрыПроцессаВыгрузки;
	
КонецФункции

// Выгрузить основные данные.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  Узел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Узел плана обмена
Процедура ВыгрузитьОсновныеДанные(ПараметрыПроцессаВыгрузки, Узел)
	
	ВыборкаОбъектов = РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ВыборкаОбъектовКОбработке();
	
	Пока ВыборкаОбъектов.Следующий() Цикл
		РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ЗафиксироватьНачалоОбработкиОбъекта(ВыборкаОбъектов);
		ВыгрузитьДанныеОбъектаМетаданных(ВыборкаОбъектов, ПараметрыПроцессаВыгрузки, Узел);
	КонецЦикла;
	
КонецПроцедуры

// Выгрузить основные данные в потоке.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  Узел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Узел плана обмена
Процедура ВыгрузитьОсновныеДанныеВПотоке(ПараметрыПроцессаВыгрузки, Узел)
	
	Пока Истина Цикл
		
		РезультатПолучения = РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.ПолучитьОбъектКОбработке();
		
		Если Не РезультатПолучения.ЕстьОбъектыКОбработке Тогда
			Прервать;
		КонецЕсли;
		
		Если РезультатПолучения.Объект <> Неопределено Тогда
			ВыгрузитьДанныеОбъектаМетаданных(РезультатПолучения.Объект, ПараметрыПроцессаВыгрузки, Узел);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Выгрузить данные объекта иетаданных.
// 
// Параметры:
//  ВыборкаОбъектов - ВыборкаИзРезультатаЗапроса - Выборка объектов
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  Узел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Узел плана обмена
Процедура ВыгрузитьДанныеОбъектаМетаданных(ВыборкаОбъектов, ПараметрыПроцессаВыгрузки, Узел)
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ВыборкаОбъектов.ОбъектМетаданных);
	ВыгрузитьОбъектМетаданных(ПараметрыПроцессаВыгрузки, ОбъектМетаданных, Узел);
	
	РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.УдалитьЗапись(ВыборкаОбъектов);
	
КонецПроцедуры

// Выгрузить накопленные основные данные.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  ДополнительныйУзел - ПланОбменаСсылка.МиграцияПриложений - Узел плана обмена
//  ЭтоЗавершениеВыгрузки - Булево - Флаг завершения выгрузки
Процедура ВыгрузитьНакопленныеОсновныеДанные(ПараметрыПроцессаВыгрузки, ДополнительныйУзел, ЭтоЗавершениеВыгрузки = Ложь)
	
	ДанныеИзмененныхОбъектов = МиграцияПриложений.ПолучитьДанныеИзмененныхОбъектов(ДополнительныйУзел);
	МинимальноеКоличествоИзменений = ?(ЭтоЗавершениеВыгрузки, 0, 99);
	
	Если ДанныеИзмененныхОбъектов.КоличествоОбъектов <= МинимальноеКоличествоИзменений Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьИЗаписатьТаблицуВыгружаемыхОбъектов(
		ДанныеИзмененныхОбъектов.ТаблицаОбъектов,
		ПараметрыПроцессаВыгрузки.ИсключаемыеТипы);
	
	Если ПараметрыПроцессаВыгрузки.Контейнер.ФиксироватьСостояние() Тогда
		ПараметрыПроцессаВыгрузки.Контейнер.ДополнитьОбщееКоличествоОбъектов(
			ДанныеИзмененныхОбъектов.ТаблицаОбъектов.Итог("КоличествоОбъектов"));
	КонецЕсли;
	
	ВыгрузитьОсновныеДанные(ПараметрыПроцессаВыгрузки, ДополнительныйУзел);
	
	Если Не ЭтоЗавершениеВыгрузки Тогда
		ПланыОбмена.УдалитьРегистрациюИзменений(ДополнительныйУзел, 1);
	КонецЕсли;
	
КонецПроцедуры

// Запустить потоки загрузки данных.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  УзлыРК - см. ПолучитьУзлыРезервногоКопирования
// 
// Возвращаемое значение:
//  Массив из ФоновоеЗадание - Запущенные задания выгрузки данных
Функция ЗапуститьПотокиВыгрузкиДанных(ПараметрыПроцессаВыгрузки, УзлыРК)
	
	ПараметрыПотока = ВыгрузкаЗагрузкаДанныхСлужебный.НовыеПараметрыПотоковВыгрузкиЗагрузкиДанных();
	ПараметрыПотока.ЭтоВыгрузка = Истина;
	ПараметрыПотока.КоличествоПотоков = ПараметрыПроцессаВыгрузки.Контейнер.КоличествоПотоков();
	
	ПараметрыПотока.Параметры.Вставить(
		"Контейнер",
		ПараметрыПроцессаВыгрузки.Контейнер.ПолучитьПараметрыИнициализацииВПотоке());
	ПараметрыПотока.Параметры.Вставить(
		"ПотокЗаписиСопоставляемыхСсылок",
		ПараметрыПроцессаВыгрузки.ПотокЗаписиСопоставляемыхСсылок.ПолучитьПараметрыИнициализацииВПотоке());
	ПараметрыПотока.Параметры.Вставить("ОсновнойУзел", УзлыРК.ОсновнойУзел);
	
	Возврат ВыгрузкаЗагрузкаДанныхСлужебный.ЗапуститьПотокиВыгрузкиЗагрузкиДанных(ПараметрыПотока);
	
КонецФункции

// Записать выгружаемые объекты метаданных.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
Процедура ЗаписатьВыгружаемыеОбъектыМетаданных(ПараметрыПроцессаВыгрузки)
	
	ТаблицаОбъектов = Новый ТаблицаЗначений();
	ТаблицаОбъектов.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	ТаблицаОбъектов.Колонки.Добавить("КоличествоОбъектов", Новый ОписаниеТипов("Число"));
	
	Для Каждого ОбъектМетаданных Из ПараметрыПроцессаВыгрузки.ВыгружаемыеТипы Цикл
		
		Если ОбъектМетаданныхИсключенИзВыгрузки(ОбъектМетаданных, ПараметрыПроцессаВыгрузки.ИсключаемыеТипы) Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаТаблицы = ТаблицаОбъектов.Добавить();
		СтрокаТаблицы.ПолноеИмя = ОбъектМетаданных.ПолноеИмя();
		
		Если ПараметрыПроцессаВыгрузки.ИспользоватьМногопоточность Тогда
			СтрокаТаблицы.КоличествоОбъектов
				= ПараметрыПроцессаВыгрузки.Контейнер.ОбъектовКОбработкеПоОбъектуМетаданных(ОбъектМетаданных);
		КонецЕсли;
		
	КонецЦикла;
	
	ЗаписатьТаблицуВыгружаемыхОбъектов(ТаблицаОбъектов);
		
КонецПроцедуры

// Проверить и записать таблицу выгружаемых объектов.
// 
// Параметры:
//  ТаблицаОбъектов - ТаблицаЗначений - Таблица объектов:
// * ПолноеИмя - Строка - Полное имя объекта метаданных
// * КоличествоОбъектов - Число - Количество объектов
//  ИсключаемыеТипы - ФиксированныйМассив из ОбъектМетаданных - Исключаемые типы
Процедура ПроверитьИЗаписатьТаблицуВыгружаемыхОбъектов(ТаблицаОбъектов, ИсключаемыеТипы)
	
	ИндексСтроки = ТаблицаОбъектов.Количество() - 1;
	
	Пока ИндексСтроки >= 0 Цикл
		
		СтрокаТаблицы = ТаблицаОбъектов[ИндексСтроки];
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(СтрокаТаблицы.ПолноеИмя);
		
		Если ОбъектМетаданныхИсключенИзВыгрузки(ОбъектМетаданных, ИсключаемыеТипы) Тогда
			ТаблицаОбъектов.Удалить(ИндексСтроки);
		КонецЕсли;
		
		ИндексСтроки = ИндексСтроки - 1;
		
	КонецЦикла;
	
	ЗаписатьТаблицуВыгружаемыхОбъектов(ТаблицаОбъектов);
	
КонецПроцедуры

// Записать таблицу выгружаемых объектов.
// 
// Параметры:
//  ТаблицаОбъектов - ТаблицаЗначений - Таблица объектов:
// * ПолноеИмя - Строка - Полное имя объекта метаданных
// * КоличествоОбъектов - Число - Количество объектов
Процедура ЗаписатьТаблицуВыгружаемыхОбъектов(ТаблицаОбъектов)
	
	Если Не ЗначениеЗаполнено(ТаблицаОбъектов) Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаОбъектов.Сортировать("КоличествоОбъектов УБЫВ, ПолноеИмя");
	
	ПорядокОбработки = 0;
	НаборЗаписей = РегистрыСведений.ВыгрузкаЗагрузкаОбъектовМетаданных.СоздатьНаборЗаписей();
	
	Для Каждого СтрокаТаблицы Из ТаблицаОбъектов Цикл
		
		ПорядокОбработки = ПорядокОбработки + 1;
		
		ЗаписьНабора = НаборЗаписей.Добавить();
		ЗаписьНабора.ПорядокОбработки = ПорядокОбработки;
		ЗаписьНабора.ОбъектМетаданных = СтрокаТаблицы.ПолноеИмя;
		
	КонецЦикла;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры

// Получить узлы резервного копирования.
// 
// Параметры:
//  Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера - Контейнер
//  ИсключаемыеТипы - ФиксированныйМассив из ОбъектМетаданных - Исключаемые типы
// 
// Возвращаемое значение:
//  Структура - Получить узлы резервного копирования:
// * ОсновнойУзел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Основной узел
// * ДополнительныйУзел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Дополнительный узел
Функция ПолучитьУзлыРезервногоКопирования(Контейнер, ИсключаемыеТипы)
	
	// Выгрузка с помощью плана обмена:
	//   - в монопольном режиме выгружается за один этап
	//   - без монольного режима: сначала выгружаются все данные, потом из дополнительного узла.
	
	Если Контейнер.ЭтоРезервноеКопирование() И Не Контейнер.ВыгрузитьДифференциальнуюКопию() Тогда
		
		Узел = ПланыОбмена.МиграцияПриложений.НайтиПоКоду(КодОсновногоУзла());
		ИспользоватьДифференциальноеРезервноеКопирование
			= Константы.ИспользоватьДифференциальноеРезервноеКопирование.Получить();
		
		Если ЗначениеЗаполнено(Узел) Тогда
			
			НачатьТранзакцию();
			
			Попытка
				
				ЗаблокироватьВсеВыгружаемыеОбъекты(ИсключаемыеТипы, Контейнер);
				
				ПланыОбмена.УдалитьРегистрациюИзменений(Узел);
				
				Если Не ИспользоватьДифференциальноеРезервноеКопирование Тогда
					
					УзелОбъект = Узел.ПолучитьОбъект();
					УзелОбъект.ОбменДанными.Загрузка = Истина;
					УзелОбъект.Удалить();
					
				КонецЕсли;
				
				ЗафиксироватьТранзакцию();
				
			Исключение
				
				ОтменитьТранзакцию();
				ВызватьИсключение;
				
			КонецПопытки;
			
		ИначеЕсли ИспользоватьДифференциальноеРезервноеКопирование Тогда
			 
			УзелОбъект = ПланыОбмена.МиграцияПриложений.СоздатьУзел();
			УзелОбъект.Код = КодОсновногоУзла();
			УзелОбъект.Наименование = НСтр(
				"ru = 'Резервное копирование (основной узел)'",
				ОбщегоНазначения.КодОсновногоЯзыка());
			УзелОбъект.Записать();
			
		КонецЕсли;
		
	КонецЕсли;
	
	ДополнительныйУзел = Неопределено;
	
	Если Не МонопольныйРежим() Тогда
		
		// Перед выгрузкой нужно создать дополнительный узел, чтобы зарегистрировать все объекты, 
		// которые изменились за время выгрузки
		Блокировка = Новый БлокировкаДанных();
		ЭлементБлокировки = Блокировка.Добавить("ПланОбмена.МиграцияПриложений");
		ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
		ЭлементБлокировки.УстановитьЗначение("Код", КодДополнительногоУзла());
		
		НачатьТранзакцию();
		
		Попытка
			
			Блокировка.Заблокировать();
			
			ДополнительныйУзел = ПланыОбмена.МиграцияПриложений.НайтиПоКоду(КодДополнительногоУзла());
			
			Если ЗначениеЗаполнено(ДополнительныйУзел) Тогда
				
				// Значит остался от прошлого раза			
				ЗаблокироватьВсеВыгружаемыеОбъекты(ИсключаемыеТипы, Контейнер);
				ПланыОбмена.УдалитьРегистрациюИзменений(ДополнительныйУзел);
				
			Иначе
				
				УзелОбъект = ПланыОбмена.МиграцияПриложений.СоздатьУзел();
				УзелОбъект.Код = КодДополнительногоУзла();
				УзелОбъект.Наименование = НСтр(
					"ru = 'Резервное копирование (дополнительный узел)'",
					ОбщегоНазначения.КодОсновногоЯзыка());
				УзелОбъект.Записать();
				
				ДополнительныйУзел = УзелОбъект.Ссылка;
				
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			
			ОтменитьТранзакцию();
			ВызватьИсключение;
			
		КонецПопытки;
		
		Попытка
			ЗаблокироватьДанныеДляРедактирования(ДополнительныйУзел);
		Исключение
			ВызватьИсключение НСтр("ru = 'Не удалось запустить выгрузку данных, выгрузка уже выполняется другим заданием.
				|Дождитесь его завершения или принудительно завершите сеанс.'")
				+ Символы.ПС + ТехнологияСервиса.ПодробныйТекстОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		
	КонецЕсли;
	
	ОсновнойУзел = Неопределено; // Для полной копии узел не используется
	
	Если Контейнер.ВыгрузитьДифференциальнуюКопию() Тогда
		ОсновнойУзел = ПланыОбмена.МиграцияПриложений.НайтиПоКоду(КодОсновногоУзла());
	КонецЕсли;
	
	УзлыРК = Новый Структура();
	УзлыРК.Вставить("ОсновнойУзел", ОсновнойУзел);
	УзлыРК.Вставить("ДополнительныйУзел", ДополнительныйУзел);
	
	Возврат УзлыРК;

КонецФункции

// Объект метаданных исключен из выгрузки.
// 
// Параметры:
//  ОбъектМетаданных - ОбъектМетаданных - Объект метаданных
//  ИсключаемыеТипы - Массив Из ОбъектМетаданных - Исключаемые типы
// 
// Возвращаемое значение:
//  Булево - Объект метаданных исключен из выгрузки
Функция ОбъектМетаданныхИсключенИзВыгрузки(ОбъектМетаданных, ИсключаемыеТипы)
	
	Если ОбъектМетаданных = Метаданные.Справочники.Пользователи
		Или Метаданные.ПланыОбмена.Содержит(ОбъектМетаданных) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если ЭтоИсключаемыйТип(ИсключаемыеТипы, ОбъектМетаданных) Тогда
		Возврат Истина;
	КонецЕсли;
	
	// Если объект добавлен расширением и не входит в состав плана Миграция приложений, тогда
	// выгружать данные необходимо при финализации выгрузки, после установки монопольного режима
	Если Не МонопольныйРежим()
		И ОбъектМетаданных.РасширениеКонфигурации() <> Неопределено
		И Не Метаданные.ПланыОбмена.МиграцияПриложений.Состав.Содержит(ОбъектМетаданных) Тогда
		Возврат Истина;	
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Выгрузить общие данные.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
Процедура ВыгрузитьОбщиеДанные(ПараметрыПроцессаВыгрузки)
	
	ВыгружаемыеТипы = ПараметрыПроцессаВыгрузки.Контейнер.ПараметрыВыгрузки().ВыгружаемыеТипыОбщихДанных;
	
	Для Каждого ОбъектМетаданных Из ВыгружаемыеТипы Цикл
		
		Если ЭтоИсключаемыйТип(ПараметрыПроцессаВыгрузки.ИсключаемыеТипы, ОбъектМетаданных) Тогда
			Продолжить;
		КонецЕсли;
		
		ВыгрузитьОбъектМетаданных(ПараметрыПроцессаВыгрузки, ОбъектМетаданных);
		
	КонецЦикла;
	
КонецПроцедуры

// Выгрузить накопленные основные данные.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  ДополнительныйУзел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Узел плана обмена
Функция ЗавершитьВыгрузкуВТранзакции(ПараметрыПроцессаВыгрузки, ДополнительныйУзел)
	
	ОповеститьПользователейОЗавершенииВыгрузки();
	
	НачатьТранзакцию();
	
	Попытка
		
		Попытка
			
			ЗаблокироватьВсеВыгружаемыеОбъекты(
				ПараметрыПроцессаВыгрузки.ИсключаемыеТипы,
				ПараметрыПроцессаВыгрузки.Контейнер);
			
		Исключение
			
			ОтменитьТранзакцию();
			Возврат Ложь;
			
		КонецПопытки;
		
		ВыгрузитьНакопленныеОсновныеДанные(ПараметрыПроцессаВыгрузки, ДополнительныйУзел, Истина);
		ЗавершитьВыгрузку(ПараметрыПроцессаВыгрузки, ДополнительныйУзел);
			
		ДополнительныйУзел.ПолучитьОбъект().Удалить();
					
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Процедура ОповеститьПользователейОЗавершенииВыгрузки()
	
	Если Не ОбщегоНазначения.РазделениеВключено()
		Или Метаданные.ОбщиеМодули.Найти("ОповещениеПользователейБТС") = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ФоновоеЗадание = ПолучитьТекущийСеансИнформационнойБазы().ПолучитьФоновоеЗадание();
	
	Если ФоновоеЗадание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущийПользовательИнформационнойБазы = ПользователиИнформационнойБазы.ТекущийПользователь();
	ИдентификаторТекущегоПользователя = Неопределено;
	 
	Если ТекущийПользовательИнформационнойБазы <> Неопределено Тогда
		ИдентификаторТекущегоПользователя = ТекущийПользовательИнформационнойБазы.УникальныйИдентификатор;
	КонецЕсли;
	
	ЗначениеРазделителяСеанса = РаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
	ИменаИнтерактивныхПриложений = ОбщегоНазначенияБТС.ИменаИнтерактивныхПриложений();
	
	ОповещениеПользователя = Новый Структура();
	ОповещениеПользователя.Вставить("ВидОповещения", "ПредупреждениеОБлокировкеРаботы");
	ОповещениеПользователя.Вставить("ИдентификаторЗадания", Строка(ФоновоеЗадание.УникальныйИдентификатор));
	
	Оповещения = Новый Массив();
	
	Для Каждого Сеанс Из ПолучитьСеансыИнформационнойБазы() Цикл
		
		ПользовательСеанса = Сеанс.Пользователь;
		
		Если ПользовательСеанса = Неопределено 
			Или ПользовательСеанса.УникальныйИдентификатор = ИдентификаторТекущегоПользователя Тогда
			Продолжить;
		КонецЕсли;
		
		Если ИменаИнтерактивныхПриложений.Найти(Сеанс.ИмяПриложения) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
			
		Оповещение = Новый Структура();
		Оповещение.Вставить("ОбластьДанных", ЗначениеРазделителяСеанса);
		Оповещение.Вставить("ИмяПользователя", Сеанс.Пользователь.Имя);
		Оповещение.Вставить("НомерСеанса", Сеанс.НомерСеанса);
		Оповещение.Вставить("ОповещениеПользователя", ОповещениеПользователя);
		
		Оповещения.Добавить(Оповещение);

	КонецЦикла;
	
	Если ЗначениеЗаполнено(Оповещения) Тогда
		
		МодульОповещениеПользователейБТС = ОбщегоНазначения.ОбщийМодуль("ОповещениеПользователейБТС");
		МодульОповещениеПользователейБТС.ДоставитьОповещения(Оповещения);
		
		ОбщегоНазначенияБТС.Пауза(30);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗавершитьВыгрузку(ПараметрыПроцессаВыгрузки, Узел)
	
	ОбъектМетаданных_Пользователи = Метаданные.Справочники.Пользователи;
	ВыгружатьДанныеРасширений = ЗначениеЗаполнено(Узел);
	
	Для Каждого ОбъектМетаданных Из ПараметрыПроцессаВыгрузки.ВыгружаемыеТипы Цикл
		
		Если ЭтоИсключаемыйТип(ПараметрыПроцессаВыгрузки.ИсключаемыеТипы, ОбъектМетаданных) Тогда
			Продолжить;
		КонецЕсли;
		
		Если ОбщегоНазначенияБТС.ЭтоНаборЗаписейПоследовательности(ОбъектМетаданных) Тогда
			
			ВыгрузкаЗагрузкаДанныхГраницПоследовательностей.ПередВыгрузкойТипа(
				ПараметрыПроцессаВыгрузки.Контейнер,
				ПараметрыПроцессаВыгрузки.Сериализатор,
				ОбъектМетаданных,
				Ложь);
				
			Продолжить;
			
		КонецЕсли;
		
		ВыгружатьОбъектМетаданных = ОбъектМетаданных = ОбъектМетаданных_Пользователи
			Или Метаданные.ПланыОбмена.Содержит(ОбъектМетаданных);
			
		Если Не ВыгружатьОбъектМетаданных И ВыгружатьДанныеРасширений Тогда
			ВыгружатьОбъектМетаданных = ОбъектМетаданных.РасширениеКонфигурации() <> Неопределено
				И Не Метаданные.ПланыОбмена.МиграцияПриложений.Состав.Содержит(ОбъектМетаданных);
		КонецЕсли;
		
		Если ВыгружатьОбъектМетаданных Тогда
			ВыгрузитьОбъектМетаданных(ПараметрыПроцессаВыгрузки, ОбъектМетаданных);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция КодОсновногоУзла()
	
	Возврат "c191c628-b094-11ea-a48c-0242ac130016";
		
КонецФункции

Функция КодДополнительногоУзла()
	
	Возврат "974d5c6d-2d7e-4067-9614-dac005823e0e";
		
КонецФункции

Функция ЭтоИсключаемыйТип(ИсключаемыеТипы, ОбъектМетаданных)
	
	Если ИсключаемыеТипы.Найти(ОбъектМетаданных) = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Событие = НСтр(
		"ru = 'Выгрузка загрузка данных. Выгрузка объекта пропущена'",
		ОбщегоНазначения.КодОсновногоЯзыка());
	Комментарий = СтрШаблон(
		НСтр("ru = 'Выгрузка данных объекта метаданных %1 пропущена, т.к. он включен в
			 |список объектов метаданных, исключаемых из выгрузки и загрузки данных'"),
		ОбъектМетаданных.ПолноеИмя());
	
	ЗаписьЖурналаРегистрации(Событие, УровеньЖурналаРегистрации.Информация, ОбъектМетаданных, , Комментарий);
		
	Возврат Истина;
	
КонецФункции

// Выгрузить объект метаданных.
// 
// Параметры:
//  ПараметрыПроцессаВыгрузки - см. НовыеПараметрыПроцессаВыгрузкиДанныхИнформационнойБазы
//  ОбъектМетаданных - ОбъектМетаданных - Выгружаемый объект метаданных
//  Узел - ПланОбменаСсылка.МиграцияПриложений, Неопределено - Узел
Процедура ВыгрузитьОбъектМетаданных(ПараметрыПроцессаВыгрузки, ОбъектМетаданных, Узел = Неопределено)
			
	МенеджерВыгрузкиОбъекта = Создать();
	
	МенеджерВыгрузкиОбъекта.Инициализировать(
		ПараметрыПроцессаВыгрузки.Контейнер,
		ОбъектМетаданных,
		Узел,
		ПараметрыПроцессаВыгрузки.Обработчики,
		ПараметрыПроцессаВыгрузки.Сериализатор,
		ПараметрыПроцессаВыгрузки.ПотокЗаписиПересоздаваемыхСсылок,
		ПараметрыПроцессаВыгрузки.ПотокЗаписиСопоставляемыхСсылок);
	
	МенеджерВыгрузкиОбъекта.ВыгрузитьДанные();
	
	МенеджерВыгрузкиОбъекта.Закрыть();
	
КонецПроцедуры

Процедура ЗаблокироватьВсеВыгружаемыеОбъекты(ИсключаемыеТипы, Контейнер)
	
	Блокировка = Новый БлокировкаДанных();
	Для Каждого ОбъектМетаданных Из Контейнер.ПараметрыВыгрузки().ВыгружаемыеТипы Цикл
		Если ИсключаемыеТипы.Найти(ОбъектМетаданных) = Неопределено Тогда
			Если РаботаВМоделиСервиса.ЭтоПолноеИмяПерерасчета(ОбъектМетаданных.ПолноеИмя()) Тогда
				ПространствоБлокировкиЧастями = Новый Массив;
				ПространствоБлокировкиЧастями.Добавить("Перерасчет");
				ПространствоБлокировкиЧастями.Добавить(ОбъектМетаданных.Имя);
				ПространствоБлокировкиЧастями.Добавить("НаборЗаписей");
				Блокировка.Добавить(СтрСоединить(ПространствоБлокировкиЧастями, "."));
			Иначе
				Блокировка.Добавить(ОбъектМетаданных.ПолноеИмя());
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	//@skip-check lock-out-of-try
	Блокировка.Заблокировать();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
