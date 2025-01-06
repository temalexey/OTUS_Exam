///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Команды работы с бизнес-процессами.

// Отмечает указанные бизнес-процессы как остановленные.
//
// Параметры:
//  ПараметрКоманды  - Массив из ОпределяемыйТип.БизнесПроцесс
//                   - ОпределяемыйТип.БизнесПроцесс
//
Процедура Остановить(Знач ПараметрКоманды) Экспорт
	
	ТекстВопроса = "";
	ЧислоЗадач = 0;
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		Если ПараметрКоманды.Количество() = 0 Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс.'"));
			Возврат;
		КонецЕсли;
		
		Если ПараметрКоманды.Количество() = 1 И ТипЗнч(ПараметрКоманды[0]) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс.'"));
			Возврат;
		КонецЕсли;
		
		ЧислоЗадач = БизнесПроцессыИЗадачиВызовСервера.КоличествоНевыполненныхЗадачБизнесПроцессов(ПараметрКоманды);
		Если ПараметрКоманды.Количество() = 1 Тогда
			Если ЧислоЗадач > 0 Тогда
				ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Будет выполнена остановка бизнес-процесса ""%1"" и всех его невыполненных задач (%2). Продолжить?'"), 
					Строка(ПараметрКоманды[0]), ЧислоЗадач);
			Иначе
				ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Будет выполнена остановка бизнес-процесса ""%1"". Продолжить?'"), 
					Строка(ПараметрКоманды[0]));
			КонецЕсли;
		Иначе
			ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Будет выполнена остановка бизнес-процессов (%1) и всех их невыполненных задач (%2). Продолжить?'"), 
				ПараметрКоманды.Количество(), ЧислоЗадач);
		КонецЕсли;
		
	Иначе
		
		Если ТипЗнч(ПараметрКоманды) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс'"));
			Возврат;
		КонецЕсли;
		
		ЧислоЗадач = БизнесПроцессыИЗадачиВызовСервера.КоличествоНевыполненныхЗадачБизнесПроцесса(ПараметрКоманды);
		Если ЧислоЗадач > 0 Тогда
			ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Будет выполнена остановка бизнес-процесса ""%1"" и всех его невыполненных задач (%2). Продолжить?'"), 
				Строка(ПараметрКоманды), ЧислоЗадач);
		Иначе
			ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Будет выполнена остановка бизнес-процесса ""%1"". Продолжить?'"), 
				Строка(ПараметрКоманды));
		КонецЕсли;
		
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ОстановитьЗавершение", ЭтотОбъект, ПараметрКоманды);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет, НСтр("ru = 'Остановка бизнес-процесса'"));
	
КонецПроцедуры

// Отмечает указанный бизнес-процесс как остановленный.
//  Предназначена для вызова из формы бизнес-процесса.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//        - РасширениеУправляемойФормыДляОбъектов - форма бизнес-процесса, где:
//   * Объект - ОпределяемыйТип.БизнесПроцессОбъект - бизнес-процесс. 
//
Процедура ОстановитьБизнесПроцессИзФормыОбъекта(Форма) Экспорт
	Форма.Объект.Состояние = ПредопределенноеЗначение("Перечисление.СостоянияБизнесПроцессов.Остановлен");
	ОчиститьСообщения();
	Форма.Записать();
	ПоказатьОповещениеПользователя(
		НСтр("ru = 'Бизнес-процесс остановлен'"),
		ПолучитьНавигационнуюСсылку(Форма.Объект.Ссылка),
		Строка(Форма.Объект.Ссылка),
		БиблиотекаКартинок.ДиалогИнформация);
	ОповеститьОбИзменении(Форма.Объект.Ссылка);
	
КонецПроцедуры

// Отмечает указанные бизнес-процессы как активные.
//
// Параметры:
//  ПараметрКоманды - Массив из ОпределяемыйТип.БизнесПроцесс
//                  - СтрокаГруппировкиДинамическогоСписка
//                  - ОпределяемыйТип.БизнесПроцесс - бизнес процесс.
//
Процедура СделатьАктивным(Знач ПараметрКоманды) Экспорт
	
	ТекстВопроса = "";
	ЧислоЗадач = 0;
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		Если ПараметрКоманды.Количество() = 0 Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс.'"));
			Возврат;
		КонецЕсли;
		
		Если ПараметрКоманды.Количество() = 1 И ТипЗнч(ПараметрКоманды[0]) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс.'"));
			Возврат;
		КонецЕсли;
		
		ЧислоЗадач = БизнесПроцессыИЗадачиВызовСервера.КоличествоНевыполненныхЗадачБизнесПроцессов(ПараметрКоманды);
		Если ПараметрКоманды.Количество() = 1 Тогда
			ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Бизнес-процесс ""%1"" и все его задачи (%2) будут сделаны активными. Продолжить?'"),
				Строка(ПараметрКоманды[0]), ЧислоЗадач);
		Иначе		
			ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Бизнес-процессы (%1) и их задачи (%2) будут сделаны активными. Продолжить?'"),
				ПараметрКоманды.Количество(), ЧислоЗадач);
		КонецЕсли;
		
	Иначе
		
		Если ТипЗнч(ПараметрКоманды) = Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не выбран ни один бизнес-процесс.'"));
			Возврат;
		КонецЕсли;
		
		ЧислоЗадач = БизнесПроцессыИЗадачиВызовСервера.КоличествоНевыполненныхЗадачБизнесПроцесса(ПараметрКоманды);
		ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Бизнес-процесс ""%1"" и все его задачи (%2) будут сделаны активными. Продолжить?'"),
			Строка(ПараметрКоманды), ЧислоЗадач);
			
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("СделатьАктивнымЗавершение", ЭтотОбъект, ПараметрКоманды);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет, НСтр("ru = 'Остановка бизнес-процесса'"));
	
КонецПроцедуры

// Отмечает указанный бизнес-процесс как активный.
// Предназначена для вызова из формы бизнес-процесса.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//        - РасширениеУправляемойФормыДляОбъектов - форма бизнес-процесса, где:
//   * Объект - ОпределяемыйТип.БизнесПроцессОбъект - бизнес-процесс.
//
Процедура ПродолжитьБизнесПроцессИзФормыОбъекта(Форма) Экспорт
	
	Форма.Объект.Состояние = ПредопределенноеЗначение("Перечисление.СостоянияБизнесПроцессов.Активен");
	ОчиститьСообщения();
	Форма.Записать();
	ПоказатьОповещениеПользователя(
		НСтр("ru = 'Бизнес-процесс сделан активным'"),
		ПолучитьНавигационнуюСсылку(Форма.Объект.Ссылка),
		Строка(Форма.Объект.Ссылка),
		БиблиотекаКартинок.ДиалогИнформация);
	ОповеститьОбИзменении(Форма.Объект.Ссылка);
	
КонецПроцедуры

// Отмечает указанные задачи как принятые к исполнению.
//
// Параметры:
//  МассивЗадач - Массив из ЗадачаСсылка.ЗадачаИсполнителя
//
Процедура ПринятьЗадачиКИсполнению(Знач МассивЗадач) Экспорт
	
	БизнесПроцессыИЗадачиВызовСервера.ПринятьЗадачиКИсполнению(МассивЗадач);
	Если МассивЗадач.Количество() = 0 Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	
	ТипЗначенияЗадачи = Неопределено;
	Для каждого Задача Из МассивЗадач Цикл
		Если ТипЗнч(Задача) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда 
			ТипЗначенияЗадачи = ТипЗнч(Задача);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если ТипЗначенияЗадачи <> Неопределено Тогда
		ОповеститьОбИзменении(ТипЗначенияЗадачи);
	КонецЕсли;
	
КонецПроцедуры

// Отмечает указанную задачу как принятую к исполнению.
//
// Параметры:
//  Форма               - ФормаКлиентскогоПриложения
//                      - РасширениеУправляемойФормыДляОбъектов - форма задачи, где:
//   * Объект - ЗадачаОбъект - задача.
//  ТекущийПользователь - СправочникСсылка.ВнешниеПользователи
//                      - СправочникСсылка.Пользователи - ссылка на текущего
//                                                        пользователя приложения.
//
Процедура ПринятьЗадачуКИсполнению(Форма, ТекущийПользователь) Экспорт
	
	Форма.Объект.ПринятаКИсполнению = Истина;
	
	// ДатаПринятияКИсполнению устанавливается пустой - она будет проинициализирована 
	// текущей датой сеанса перед записью самой  задачи.
	Форма.Объект.ДатаПринятияКИсполнению = Дата('00010101');
	Если НЕ ЗначениеЗаполнено(Форма.Объект.Исполнитель) Тогда
		Форма.Объект.Исполнитель = ТекущийПользователь;
	КонецЕсли;
	
	ОчиститьСообщения();
	Форма.Записать();
	ОбновитьДоступностьКомандПринятияКИсполнению(Форма);
	ОповеститьОбИзменении(Форма.Объект.Ссылка);
	
КонецПроцедуры

// Отмечает указанные задачи как не принятые к исполнению.
//
// Параметры:
//  МассивЗадач - Массив из ЗадачаСсылка.ЗадачаИсполнителя
//
Процедура ОтменитьПринятиеЗадачКИсполнению(Знач МассивЗадач) Экспорт
	
	БизнесПроцессыИЗадачиВызовСервера.ОтменитьПринятиеЗадачКИсполнению(МассивЗадач);
	
	Если МассивЗадач.Количество() = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	
	ТипЗначенияЗадачи = Неопределено;
	Для каждого Задача Из МассивЗадач Цикл
		Если ТипЗнч(Задача) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда 
			ТипЗначенияЗадачи = ТипЗнч(Задача);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ТипЗначенияЗадачи <> Неопределено Тогда
		ОповеститьОбИзменении(ТипЗначенияЗадачи);
	КонецЕсли;
	
КонецПроцедуры

// Отмечает указанную задачу как не принятую к исполнению.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//        - РасширениеУправляемойФормыДляОбъектов - форма задачи, где:
//   * Объект - ЗадачаОбъект - задача.
//
Процедура ОтменитьПринятиеЗадачиКИсполнению(Форма) Экспорт
	
	Форма.Объект.ПринятаКИсполнению      = Ложь;
	Форма.Объект.ДатаПринятияКИсполнению = "00010101000000";
	Если Не Форма.Объект.РольИсполнителя.Пустая() Тогда
		Форма.Объект.Исполнитель = Неопределено;
	КонецЕсли;
	
	ОчиститьСообщения();
	Форма.Записать();
	ОбновитьДоступностьКомандПринятияКИсполнению(Форма);
	ОповеститьОбИзменении(Форма.Объект.Ссылка);
	
КонецПроцедуры

// Устанавливает доступность команд принятия к исполнению.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма задачи, где:
//   * Элементы - ВсеЭлементыФормы - элементы формы. Содержит:
//     ** ФормаПринятьКИсполнению - ПолеВвода - кнопка команды на форме.
//     ** ФормаОтменитьПринятиеКИсполнению - ПолеВвода - кнопка команды на форме. 
//
Процедура ОбновитьДоступностьКомандПринятияКИсполнению(Форма) Экспорт
	
	Если Форма.Объект.ПринятаКИсполнению = Истина Тогда
		Форма.Элементы.ФормаПринятьКИсполнению.Доступность = Ложь;
		
		Если Форма.Объект.Выполнена Тогда
			Форма.Элементы.ФормаОтменитьПринятиеКИсполнению.Доступность = Ложь;
		Иначе
			Форма.Элементы.ФормаОтменитьПринятиеКИсполнению.Доступность = Истина;
		КонецЕсли;
		
	Иначе	
		Форма.Элементы.ФормаПринятьКИсполнению.Доступность = Истина;
		Форма.Элементы.ФормаОтменитьПринятиеКИсполнению.Доступность = Ложь;
	КонецЕсли;
		
КонецПроцедуры

// Открывает форму для настройки отложенного старта бизнес процесса.
//
// Параметры:
//  БизнесПроцесс  - ОпределяемыйТип.БизнесПроцесс
//  СрокИсполнения - Дата
//
Процедура НастроитьОтложенныйСтарт(БизнесПроцесс, СрокИсполнения) Экспорт
	
	Если БизнесПроцесс.Пустая() Тогда
		ТекстПредупреждения = 
			НСтр("ru = 'Невозможно настроить отложенный старт для незаписанного процесса.'");
		ПоказатьПредупреждение(, ТекстПредупреждения);
		Возврат;
	КонецЕсли;
		
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("БизнесПроцесс", БизнесПроцесс);
	ПараметрыФормы.Вставить("СрокИсполнения", СрокИсполнения);
	
	ОткрытьФорму(
		"РегистрСведений.ПроцессыДляЗапуска.Форма.НастройкаОтложенногоСтартаПроцесса",
		ПараметрыФормы,,,,,,
		РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Дополнительные процедуры и функции.

// Стандартный обработчик оповещения для форм выполнения задач.
//  Для вызова из обработчика события формы ОбработкаОповещения.
//
// Параметры:
//  Форма      - ФормаКлиентскогоПриложения - форма выполнения задачи, где:
//   * Объект - ЗадачаОбъект  - задача объекта.
//  ИмяСобытия - Строка       - имя события.
//  Параметр   - Произвольный - параметр события.
//  Источник   - Произвольный - источник события.
//
Процедура ФормаЗадачиОбработкаОповещения(Форма, ИмяСобытия, Параметр, Источник) Экспорт
	
	Если ИмяСобытия = "Запись_ЗадачаИсполнителя" 
		И НЕ Форма.Модифицированность 
		И (Источник = Форма.Объект.Ссылка ИЛИ (ТипЗнч(Источник) = Тип("Массив") 
		И Источник.Найти(Форма.Объект.Ссылка) <> Неопределено)) Тогда
		Если Параметр.Свойство("Перенаправлена") Тогда
			Форма.Закрыть();
		Иначе
			Форма.Прочитать();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Стандартный обработчик ПередНачаломДобавления для списков задач.
//  Для вызова из обработчика события таблицы формы ПередНачаломДобавления.
//
// Параметры:
//  Форма        - ФормаКлиентскогоПриложения - форма задачи.
//  Элемент      - ТаблицаФормы - элементы таблицы формы.
//  Отказ        - Булево - признак отказа от добавления объекта. Если в теле процедуры-обработчика установить данному
//                          параметру значение Истина, то добавление объекта выполнено не будет.
//  Копирование  - Булево - определяет режим копирования. Если установлено Истина, то происходит копирование строки. 
//  Родитель     - Неопределено
//               - СправочникСсылка
//               - ПланСчетовСсылка - ссылка на элемент, который будет использован при
//                                    добавлении в качестве родителя.
//  Группа       - Булево - признак добавления группы. Истина - будет добавлена группа. 
//
Процедура СписокЗадачПередНачаломДобавления(Форма, Элемент, Отказ, Копирование, Родитель, Группа) Экспорт
	
	Если Копирование Тогда
		Задача = Элемент.ТекущаяСтрока;
		Если НЕ ЗначениеЗаполнено(Задача) Тогда
			Возврат;
		КонецЕсли;
		ПараметрыФормы = Новый Структура("Основание", Задача);
	КонецЕсли;
	СоздатьЗадание(Форма, ПараметрыФормы);
	Отказ = Истина;
	
КонецПроцедуры

// Записать и закрыть форму выполнения задачи.
//
// Параметры:
//  Форма  - ФормаКлиентскогоПриложения - форма выполнения задачи, где:
//   * Объект - ЗадачаОбъект - задача бизнес-процесса.
//  ВыполнитьЗадачу  - Булево - задача записывается в режиме выполнения.
//  ПараметрыОповещения - Структура - дополнительные параметры оповещения.
//
// Возвращаемое значение:
//   Булево   - Истина, если запись прошла успешно.
//
Функция ЗаписатьИЗакрытьВыполнить(Форма, ВыполнитьЗадачу = Ложь, ПараметрыОповещения = Неопределено) Экспорт
	
	ОчиститьСообщения();
	
	НовыйОбъект = Форма.Объект.Ссылка.Пустая();
	ТекстОповещения = "";
	Если ПараметрыОповещения = Неопределено Тогда
		ПараметрыОповещения = Новый Структура;
	КонецЕсли;
	Если НЕ Форма.НачальныйПризнакВыполнения И ВыполнитьЗадачу Тогда
		Если НЕ Форма.Записать(Новый Структура("ВыполнитьЗадачу", Истина)) Тогда
			Возврат Ложь;
		КонецЕсли;
		ТекстОповещения = НСтр("ru = 'Задача выполнена'");
	Иначе
		Если НЕ Форма.Записать() Тогда
			Возврат Ложь;
		КонецЕсли;
		ТекстОповещения = ?(НовыйОбъект, НСтр("ru = 'Задача создана'"), НСтр("ru = 'Задача изменена'"));
	КонецЕсли;
	
	Оповестить("Запись_ЗадачаИсполнителя", ПараметрыОповещения, Форма.Объект.Ссылка);
	ПоказатьОповещениеПользователя(ТекстОповещения,
		ПолучитьНавигационнуюСсылку(Форма.Объект.Ссылка),
		Строка(Форма.Объект.Ссылка),
		БиблиотекаКартинок.ДиалогИнформация);
	Форма.Закрыть();
	Возврат Истина;
	
КонецФункции

// Открыть форму для ввода нового задания.
//
// Параметры:
//  ФормаВладелец  - ФормаКлиентскогоПриложения - форма, которая должна быть владельцем для открываемой.
//  ПараметрыФормы - Структура - параметры открываемой формы.
//
Процедура СоздатьЗадание(Знач ФормаВладелец = Неопределено, Знач ПараметрыФормы = Неопределено) Экспорт
	
	ОткрытьФорму("БизнесПроцесс.Задание.ФормаОбъекта", ПараметрыФормы, ФормаВладелец);
	
КонецПроцедуры	

// Открыть форму для перенаправления одной или нескольких задач другому исполнителю.
//
// Параметры:
//  ПеренаправляемыеЗадачи - Массив из ЗадачаСсылка.ЗадачаИсполнителя
//  ФормаВладелец - ФормаКлиентскогоПриложения - форма, которая должна быть владельцем для открываемой
//                                               формы перенаправления задач.
//
Процедура ПеренаправитьЗадачи(ПеренаправляемыеЗадачи, ФормаВладелец) Экспорт
	
	Если ПеренаправляемыеЗадачи = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Не выбраны задачи.'"));
		Возврат;
	КонецЕсли;
		
	ЗадачиМогутБытьПеренаправлены = БизнесПроцессыИЗадачиВызовСервера.ПеренаправитьЗадачи(
		ПеренаправляемыеЗадачи, Неопределено, Истина);
	Если НЕ ЗадачиМогутБытьПеренаправлены И ПеренаправляемыеЗадачи.Количество() = 1 Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Невозможно перенаправить уже выполненную задачу или направленную другому исполнителю.'"));
		Возврат;
	КонецЕсли;
		
	Оповещение = Новый ОписаниеОповещения("ПеренаправитьЗадачиЗавершение", ЭтотОбъект, ПеренаправляемыеЗадачи);
	ОткрытьФорму("Задача.ЗадачаИсполнителя.Форма.ПеренаправитьЗадачи",
		Новый Структура("Задача,КоличествоЗадач,ЗаголовокФормы", 
		ПеренаправляемыеЗадачи[0], ПеренаправляемыеЗадачи.Количество(), 
		?(ПеренаправляемыеЗадачи.Количество() > 1, НСтр("ru = 'Перенаправить задачи'"), 
			НСтр("ru = 'Перенаправить задачу'"))), 
		ФормаВладелец,,,,Оповещение);
		
КонецПроцедуры

// Открыть форму с дополнительной информацией о задаче.
//
// Параметры:
//  ЗадачаСсылка - ЗадачаСсылка.ЗадачаИсполнителя
// 
Процедура ОткрытьДопИнформациюОЗадаче(Знач ЗадачаСсылка) Экспорт
	
	ОткрытьФорму("Задача.ЗадачаИсполнителя.Форма.Дополнительно", 
		Новый Структура("Ключ", ЗадачаСсылка));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ОткрытьСписокРолейИИсполнителейЗадач() Экспорт
	
	ОткрытьФорму("РегистрСведений.ИсполнителиЗадач.Форма.РолиИИсполнителиЗадач");
	
КонецПроцедуры

// Открывает форму выбора роли исполнителя.
// 
// Параметры:
//  ПараметрыФормы - см. ПараметрыФормыВыбораРолиИсполнителя
//  Владелец - Неопределено
//           - ФормаКлиентскогоПриложения - форма из которой открывается форма выбора роли исполнителя.
//
Процедура ОткрытьФормуВыбораРолиИсполнителя(ПараметрыФормы, Владелец) Экспорт

	ОткрытьФорму("ОбщаяФорма.ВыборРолиИсполнителя", ПараметрыФормы, Владелец);

КонецПроцедуры

// Параметры открытия формы выбора роли исполнителя.
// 
// Параметры:
//  РольИсполнителя - СправочникСсылка.РолиИсполнителей - роль для ролевой адресации задачи участникам бизнес-процессов. 
//  ОсновнойОбъектАдресации - Произвольный - основной объект адресации для направления задачи.
//  ДополнительныйОбъектАдресации - Произвольный - дополнительный объект адресации для направления задачи
// 
// Возвращаемое значение:
//  Структура:
//   * РольИсполнителя  - СправочникСсылка.РолиИсполнителей - роль для ролевой адресации задачи участникам бизнес-процессов.
//   * ОсновнойОбъектАдресации - Произвольный - основной объект адресации для направления задачи
//   * ДополнительныйОбъектАдресации - Произвольный - дополнительный объект адресации для направления задачи
//   * ВыборОбъектаАдресации - Булево - Если Истина, то в списке будет выбран основной объект адресации.
// 
Функция ПараметрыФормыВыбораРолиИсполнителя(РольИсполнителя, ОсновнойОбъектАдресации = Неопределено, 
		ДополнительныйОбъектАдресации = Неопределено) Экспорт

	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("РольИсполнителя",               РольИсполнителя);
	ПараметрыФормы.Вставить("ОсновнойОбъектАдресации",       ОсновнойОбъектАдресации);
	ПараметрыФормы.Вставить("ДополнительныйОбъектАдресации", ДополнительныйОбъектАдресации);
	ПараметрыФормы.Вставить("ВыборОбъектаАдресации",         Ложь);
	
	Возврат ПараметрыФормы;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОткрытьБизнесПроцесс(Список) Экспорт
	Если ТипЗнч(Список.ТекущаяСтрока) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	Если Список.ТекущиеДанные.БизнесПроцесс = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'У выбранной задачи не указан бизнес-процесс.'"));
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(, Список.ТекущиеДанные.БизнесПроцесс);
КонецПроцедуры

Процедура ОткрытьПредметЗадачи(Список) Экспорт
	Если ТипЗнч(Список.ТекущаяСтрока) <> Тип("ЗадачаСсылка.ЗадачаИсполнителя") Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	Если Список.ТекущиеДанные.Предмет = Неопределено Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'У выбранной задачи не указан предмет.'"));
		Возврат;
	КонецЕсли;
	ПоказатьЗначение(, Список.ТекущиеДанные.Предмет);
КонецПроцедуры

// Стандартный обработчик ПометкаУдаления для списков бизнес-процессов.
// Для вызова из обработчика события списка ПометкаУдаления.
//
// Параметры:
//   Список  - ТаблицаФормы - элемент управления (таблица формы) со списком бизнес-процессов.
//
Процедура СписокБизнесПроцессовПометкаУдаления(Список) Экспорт
	
	ВыделенныеСтроки = Список.ВыделенныеСтроки;
	Если ВыделенныеСтроки = Неопределено ИЛИ ВыделенныеСтроки.Количество() <= 0 Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Команда не может быть выполнена для указанного объекта.'"));
		Возврат;
	КонецЕсли;
	Оповещение = Новый ОписаниеОповещения("СписокБизнесПроцессовПометкаУдаленияЗавершение", ЭтотОбъект, Список);
	ПоказатьВопрос(Оповещение, НСтр("ru = 'Изменить пометку удаления?'"), РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

// Открывает форму выбора исполнителя.
//
// Параметры:
//   ЭлементИсполнитель - ПолеФормы - элемент формы, в которой выполняется выбора исполнителя, 
//      который будет указан как владелец формы выбора исполнителя.
//   РеквизитИсполнитель - СправочникСсылка.Пользователи - выбранное ранее значение исполнителя.
//      Используется для установки текущей строки в форме выбора исполнителя.
//   ТолькоПростыеРоли - Булево - если Истина, то указывает что для выбора нужно 
//      использовать только роли без объектов адресации.
//   БезВнешнихРолей - Булево - если Истина, то указывает, что для выбора надо
//      использовать только роли, у которых не установлен признак ВнешняяРоль.
//
Процедура ВыбратьИсполнителя(ЭлементИсполнитель, РеквизитИсполнитель, ТолькоПростыеРоли = Ложь, БезВнешнихРолей = Ложь) Экспорт 
	
	СтандартнаяОбработка = Истина;
	БизнесПроцессыИЗадачиКлиентПереопределяемый.ПриВыбореИсполнителя(ЭлементИсполнитель, РеквизитИсполнитель, 
		ТолькоПростыеРоли, БезВнешнихРолей, СтандартнаяОбработка);
	Если Не СтандартнаяОбработка Тогда
		Возврат;
	КонецЕсли;
			
	ПараметрыФормы = Новый Структура("Исполнитель, ТолькоПростыеРоли, БезВнешнихРолей", 
		РеквизитИсполнитель, ТолькоПростыеРоли, БезВнешнихРолей);
	ОткрытьФорму("ОбщаяФорма.ВыборИсполнителяБизнесПроцесса", ПараметрыФормы, ЭлементИсполнитель);
	
КонецПроцедуры	

Процедура ОстановитьЗавершение(Знач Результат, Знач ПараметрКоманды) Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		БизнесПроцессыИЗадачиВызовСервера.ОстановитьБизнесПроцессы(ПараметрКоманды);
		
	Иначе
		
		БизнесПроцессыИЗадачиВызовСервера.ОстановитьБизнесПроцесс(ПараметрКоманды);
		
	КонецЕсли;
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		Если ПараметрКоманды.Количество() <> 0 Тогда
			
			Для Каждого Параметр Из ПараметрКоманды Цикл
				
				Если ТипЗнч(Параметр) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
					ОповеститьОбИзменении(ТипЗнч(Параметр));
					Прервать;
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	Иначе
		ОповеститьОбИзменении(ПараметрКоманды);
	КонецЕсли;

КонецПроцедуры

Процедура СписокБизнесПроцессовПометкаУдаленияЗавершение(Результат, Список) Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ВыделенныеСтроки = Список.ВыделенныеСтроки;
	БизнесПроцессСсылка = БизнесПроцессыИЗадачиВызовСервера.ПометитьНаУдалениеБизнесПроцессы(ВыделенныеСтроки);
	Список.Обновить();
	ПоказатьОповещениеПользователя(НСтр("ru = 'Пометка удаления изменена.'"), 
		?(БизнесПроцессСсылка <> Неопределено, ПолучитьНавигационнуюСсылку(БизнесПроцессСсылка), ""),
		?(БизнесПроцессСсылка <> Неопределено, Строка(БизнесПроцессСсылка), ""));
	
КонецПроцедуры

Процедура СделатьАктивнымЗавершение(Знач Результат, Знач ПараметрКоманды) Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
		
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		БизнесПроцессыИЗадачиВызовСервера.СделатьАктивнымБизнесПроцессы(ПараметрКоманды);
		
	Иначе
		
		БизнесПроцессыИЗадачиВызовСервера.СделатьАктивнымБизнесПроцесс(ПараметрКоманды);
		
	КонецЕсли;
	
	Если ТипЗнч(ПараметрКоманды) = Тип("Массив") Тогда
		
		Если ПараметрКоманды.Количество() <> 0 Тогда
			
			Для Каждого Параметр Из ПараметрКоманды Цикл
				
				Если ТипЗнч(Параметр) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
					ОповеститьОбИзменении(ТипЗнч(Параметр));
					Прервать;
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	Иначе
		ОповеститьОбИзменении(ПараметрКоманды);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПеренаправитьЗадачиЗавершение(Знач Результат, Знач МассивЗадач) Экспорт
	
	Если ТипЗнч(Результат) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	МассивПеренаправленныхЗадач = Неопределено;
	ЗадачиПеренаправлены = БизнесПроцессыИЗадачиВызовСервера.ПеренаправитьЗадачи(
		МассивЗадач, Результат, Ложь, МассивПеренаправленныхЗадач);
		
	Оповестить("Запись_ЗадачаИсполнителя", Новый Структура("Перенаправлена", ЗадачиПеренаправлены), МассивЗадач);
	
КонецПроцедуры

#КонецОбласти