///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КонтекстВыбора;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	УстановитьУсловноеОформление();

	УстановитьПривилегированныйРежим(Истина);
	АвторСтрокой = Строка(Объект.Автор);
	УстановитьПривилегированныйРежим(Ложь);
	
	// Для нового объекта выполняем код инициализации формы в ПриСозданииНаСервере.
	// Для существующего - в ПриЧтенииНаСервере.
	Если Объект.Ссылка.Пустая() Тогда
		ИнициализироватьФорму();
	КонецЕсли;
	
	// СтандартныеПодсистемы.ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	ИнициализироватьФорму();
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)

	Если ВРег(ИсточникВыбора.ИмяФормы) = ВРег("ОбщаяФорма.ВыборРолиИсполнителя") Тогда

		Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
			Если КонтекстВыбора = "РольНажатие" Тогда
				УстановитьРоль(ВыбранноеЗначение);
			ИначеЕсли КонтекстВыбора = "РольПроверяющегоНажатие" Тогда
				УстановитьРольПроверяющего(ВыбранноеЗначение);
			КонецЕсли;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ТипИсполнителяПриИзменении(Элемент)
	УстановитьРоль(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)

	Если ТипЗнч(ТипИсполнителя) = Тип("СправочникСсылка.Пользователи") Тогда
		Объект.Исполнитель = ИсполнительПоНазначению;
		Объект.РольИсполнителя = Неопределено;
	ИначеЕсли ТипЗнч(ТипИсполнителя) <> Тип("СправочникСсылка.РолиИсполнителей") Тогда
		Объект.Исполнитель = ВнешнийПользовательПоОбъектуАвторизации(ИсполнительПоНазначению);
		Объект.РольИсполнителя = Неопределено;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)

	Если ТипЗнч(ТипИсполнителя) <> Тип("СправочникСсылка.Пользователи") Тогда
		УстановитьИсполнителяПоДаннымФормы();
	КонецЕсли;
	
	// Проверяем заполнение во всех случаях при записи, а не только при старте.
	Если НачальныйПризнакСтарта И ТекущийОбъект.Стартован 
		Или (Не НачальныйПризнакСтарта И Не ТекущийОбъект.Стартован) Тогда

		Если Не ТекущийОбъект.ПроверитьЗаполнение() Тогда
			Отказ = Истина;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	УправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)

	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
		МодульПодключаемыеКомандыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПодключаемыеКомандыКлиент");
		МодульПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ГлавнаяЗадачаНажатие(Элемент, СтандартнаяОбработка)

	ПоказатьЗначение(, Объект.ГлавнаяЗадача);
	СтандартнаяОбработка = Ложь;

КонецПроцедуры

&НаКлиенте
Процедура РольНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;

	КонтекстВыбора = "РольНажатие";

	ПараметрыФормы = БизнесПроцессыИЗадачиКлиент.ПараметрыФормыВыбораРолиИсполнителя(Объект.РольИсполнителя,
		Объект.ОсновнойОбъектАдресации, Объект.ДополнительныйОбъектАдресации);
	
	БизнесПроцессыИЗадачиКлиент.ОткрытьФормуВыбораРолиИсполнителя(ПараметрыФормы, ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ПредметНажатие(Элемент, СтандартнаяОбработка)

	ПоказатьЗначение(, Объект.Предмет);
	СтандартнаяОбработка = Ложь;

КонецПроцедуры

&НаКлиенте
Процедура РольПроверяющегоНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;

	КонтекстВыбора = "РольПроверяющегоНажатие";

	ПараметрыФормы = БизнесПроцессыИЗадачиКлиент.ПараметрыФормыВыбораРолиИсполнителя(Объект.РольПроверяющего,
		Объект.ОсновнойОбъектАдресации, Объект.ДополнительныйОбъектАдресации);
	
	БизнесПроцессыИЗадачиКлиент.ОткрытьФормуВыбораРолиИсполнителя(ПараметрыФормы, ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ПроверяющийПриИзменении(Элемент)

	Если Объект.ПроверитьВыполнение И ЗначениеЗаполнено(ПроверяющийПоНазначению) Тогда
		Если ТипЗнч(ТипПроверяющего) = Тип("СправочникСсылка.РолиИсполнителей") Тогда
			Объект.РольПроверяющего = ПроверяющийПоНазначению;
			Объект.Проверяющий = Неопределено;
		Иначе
			Объект.Проверяющий = ПроверяющийПоНазначению;
			Объект.РольПроверяющего = Неопределено;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПроверитьВыполнениеПриИзменении(Элемент)
	УстановитьСостояниеЭлементов();
КонецПроцедуры

&НаКлиенте
Процедура ПроверяющийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	Если ТипЗнч(ТипПроверяющего) = Тип("СправочникСсылка.РолиИсполнителей") Тогда
		Если Не ПользователиКлиент.ЭтоСеансВнешнегоПользователя() Тогда
			СтандартнаяОбработка = Ложь;
			КонтекстВыбора = "РольПроверяющегоНажатие";
			
			ПараметрыФормы = БизнесПроцессыИЗадачиКлиент.ПараметрыФормыВыбораРолиИсполнителя(Объект.РольПроверяющего,
				Объект.ОсновнойОбъектАдресации, Объект.ДополнительныйОбъектАдресации);
	
			БизнесПроцессыИЗадачиКлиент.ОткрытьФормуВыбораРолиИсполнителя(ПараметрыФормы, ЭтотОбъект);
			
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИсполнительОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ИсполнительНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	Если ТипЗнч(ТипИсполнителя) = Тип("СправочникСсылка.РолиИсполнителей") Тогда
		Если Не ПользователиКлиент.ЭтоСеансВнешнегоПользователя() Тогда
			СтандартнаяОбработка = Ложь;
			КонтекстВыбора = "РольНажатие";
			
			ПараметрыФормы = БизнесПроцессыИЗадачиКлиент.ПараметрыФормыВыбораРолиИсполнителя(Объект.РольИсполнителя,
				Объект.ОсновнойОбъектАдресации, Объект.ДополнительныйОбъектАдресации);
	
			БизнесПроцессыИЗадачиКлиент.ОткрытьФормуВыбораРолиИсполнителя(ПараметрыФормы, ЭтотОбъект);
			
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИсполнительПриИзменении(Элемент)

	Если ПользователиКлиент.ЭтоСеансВнешнегоПользователя() Тогда
		Объект.РольИсполнителя = ИсполнительПоНазначению;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)

	ОчиститьСообщения();
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;

	Записать();
	Закрыть();

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Исполнитель.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТипАдресации");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = 0;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.Исполнитель");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Роль.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТипАдресации");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = 1;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.РольИсполнителя");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Проверяющий.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПроверяющийТипАдресации");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = 0;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.Проверяющий");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РольПроверяющего.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПроверяющийТипАдресации");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = 1;

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.РольПроверяющего");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

КонецПроцедуры

&НаСервере
Процедура ИнициализироватьФорму()

	ИспользоватьДатуИВремяВСрокахЗадач = ПолучитьФункциональнуюОпцию("ИспользоватьДатуИВремяВСрокахЗадач");
	Элементы.Дата.Формат = ?(ИспользоватьДатуИВремяВСрокахЗадач, "ДЛФ=DT", "ДЛФ=D");

	Элементы.ГруппаСостояние.Видимость = Объект.Завершен Или Объект.Стартован;
	Если Объект.Завершен Тогда
		ДатаЗавершенияСтрокой = ?(ИспользоватьДатуИВремяВСрокахЗадач, Формат(Объект.ДатаЗавершения, "ДЛФ=DT"), Формат(
			Объект.ДатаЗавершения, "ДЛФ=D"));
		Элементы.ДекорацияТекст.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
			"ru = 'Задание выполнено %1.'"), ДатаЗавершенияСтрокой);

		Для Каждого Элемент Из Элементы Цикл
			Если ТипЗнч(Элемент) <> Тип("ПолеФормы") И ТипЗнч(Элемент) <> Тип("ГруппаФормы") Тогда
				Продолжить;
			КонецЕсли;
			Элемент.ТолькоПросмотр = Истина;
		КонецЦикла;
	Иначе
		ТекстСостояния = ?(ПолучитьФункциональнуюОпцию("ИзменятьЗаданияЗаднимЧислом"), НСтр("ru = 'Изменения формулировки, важности, автора, а также перенос сроков исполнения и проверки задания 
																							|вступят в силу немедленно для ранее выданной задачи.'"),
			НСтр("ru = 'Изменения формулировки, важности, автора, а также перенос сроков исполнения и проверки задания 
				 |не будут отражены в ранее выданной задаче.'"));
		Элементы.ДекорацияТекст.Заголовок = ТекстСостояния;

	КонецЕсли;

	Элементы.ФормаСтартИЗакрыть.Видимость = Не Объект.Стартован;
	Элементы.ФормаСтартИЗакрыть.КнопкаПоУмолчанию = Не Объект.Стартован;
	Элементы.ФормаСтарт.Видимость = Не Объект.Стартован;
	Элементы.ФормаЗаписатьИЗакрыть.Видимость = Объект.Стартован;
	Элементы.ФормаЗаписатьИЗакрыть.КнопкаПоУмолчанию = Объект.Стартован;

	Элементы.Предмет.Гиперссылка = Объект.Предмет <> Неопределено И Не Объект.Предмет.Пустая();
	ПредметСтрокой = ОбщегоНазначения.ПредметСтрокой(Объект.Предмет);
	НачальныйПризнакСтарта = Объект.Стартован;
	УстановитьСостояниеЭлементов();

	Если Объект.ГлавнаяЗадача = Неопределено Или Объект.ГлавнаяЗадача.Пустая() Тогда
		Элементы.ГлавнаяЗадача.Гиперссылка = Ложь;
		ГлавнаяЗадачаСтрокой = НСтр("ru = 'не задана'");
	Иначе
		ГлавнаяЗадачаСтрокой = Строка(Объект.ГлавнаяЗадача);
	КонецЕсли;

	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьПодчиненныеБизнесПроцессы") Тогда
		Элементы.ГлавнаяЗадача.Видимость = Ложь;
	КонецЕсли;

	Элементы.ТипИсполнителя.СписокВыбора.Очистить();
	Элементы.ТипПроверяющего.СписокВыбора.Очистить();
	Элементы.ТипИсполнителя.СписокВыбора.Добавить(Справочники.РолиИсполнителей.ПустаяСсылка(), 
		НСтр("ru = 'Роль исполнителя'"));
	Элементы.ТипПроверяющего.СписокВыбора.Добавить(Справочники.РолиИсполнителей.ПустаяСсылка(), 
		НСтр("ru = 'Роль исполнителя'"));

	Если Пользователи.ЭтоСеансВнешнегоПользователя() Тогда
		ОпределитьОтображениеФормыДляВнешнегоПользователя();
	Иначе
		ОпределитьОтображениеФормыДляПользователя();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОпределитьОтображениеФормыДляПользователя()

	Элементы.ТипИсполнителя.СписокВыбора.Добавить(Справочники.Пользователи.ПустаяСсылка(), НСтр("ru = 'Пользователь'"));
	Элементы.ТипПроверяющего.СписокВыбора.Добавить(Справочники.Пользователи.ПустаяСсылка(), НСтр("ru = 'Пользователь'"));

	Если ПравоДоступа("Чтение", Метаданные.Справочники.ВнешниеПользователи) Тогда
		Для Каждого ТипВнешнегоИсполнителя Из Метаданные.ОпределяемыеТипы.ВнешнийПользователь.Тип.Типы() Цикл
			Если Не ОбщегоНазначения.ЭтоСсылка(ТипВнешнегоИсполнителя) Тогда
				Продолжить;
			КонецЕсли;
			МетаданныеОбъекта = Метаданные.НайтиПоТипу(ТипВнешнегоИсполнителя);
			Представление = ОбщегоНазначения.ПредставлениеОбъекта(МетаданныеОбъекта);
			Значение = Справочники[МетаданныеОбъекта.Имя].ПустаяСсылка();
			Элементы.ТипИсполнителя.СписокВыбора.Добавить(Значение, Представление);
		КонецЦикла;
	КонецЕсли;

	Если ЗначениеЗаполнено(Объект.Предмет) Тогда
		МетаданныеОбъекта = Объект.Предмет.Метаданные();
		Если МетаданныеОбъекта.Реквизиты.Найти("Ответственный") <> Неопределено Тогда
			ОтветственныйЗаПредмет = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Предмет, "Ответственный");  
			Если ОбщегоНазначения.ЭтоСсылка(ТипЗнч(ОтветственныйЗаПредмет)) Тогда
				ТипПроверяющего = Элементы.ТипИсполнителя.СписокВыбора.НайтиПоЗначению(
					Справочники[ОтветственныйЗаПредмет.Метаданные().Имя].ПустаяСсылка()).Значение;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Если ЗначениеЗаполнено(Объект.Исполнитель) Тогда
		Если ТипЗнч(Объект.Исполнитель) = Тип("СправочникСсылка.ВнешниеПользователи") Тогда
			ИсполнительПоНазначению = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Исполнитель, "ОбъектАвторизации");	
			ТипИсполнителя = Элементы.ТипИсполнителя.СписокВыбора.НайтиПоЗначению(
				Справочники[ИсполнительПоНазначению.Метаданные().Имя].ПустаяСсылка()).Значение;
		ИначеЕсли ТипЗнч(Объект.Исполнитель) = Тип("СправочникСсылка.Пользователи") Тогда
			ТипИсполнителя = Элементы.ТипИсполнителя.СписокВыбора.НайтиПоЗначению(
				Справочники.Пользователи.ПустаяСсылка()).Значение;
			ИсполнительПоНазначению = Объект.Исполнитель;
		КонецЕсли;
	Иначе
		ТипИсполнителя = Элементы.ТипИсполнителя.СписокВыбора.НайтиПоЗначению(
			Справочники.РолиИсполнителей.ПустаяСсылка()).Значение;
		ИсполнительПоНазначению = Объект.РольИсполнителя;
	КонецЕсли;

	Если ЗначениеЗаполнено(Объект.Проверяющий) Тогда
		ТипПроверяющего = Элементы.ТипПроверяющего.СписокВыбора.НайтиПоЗначению(
			Справочники.Пользователи.ПустаяСсылка()).Значение;
		ПроверяющийПоНазначению = Объект.Проверяющий;
	Иначе
		ТипПроверяющего = Элементы.ТипПроверяющего.СписокВыбора.НайтиПоЗначению(
			Справочники.РолиИсполнителей.ПустаяСсылка()).Значение;
		ПроверяющийПоНазначению = Объект.РольПроверяющего;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОпределитьОтображениеФормыДляВнешнегоПользователя()

	Если Объект.Ссылка.Пустая() Тогда
		ТипИсполнителя = Справочники.РолиИсполнителей.ПустаяСсылка();
		ОбъектАвторизации = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ВнешниеПользователи.ТекущийВнешнийПользователь(), "ОбъектАвторизации");
		ОбъектАвторизацииПустаяСсылка = Справочники[ОбъектАвторизации.Метаданные().Имя].ПустаяСсылка();
		Объект.Исполнитель = Справочники.РолиИсполнителей.ПустаяСсылка();

		ТаблицаРолей = ТаблицаРолей(ОбъектАвторизацииПустаяСсылка);

		Элементы.Исполнитель.СвязьПоТипу = Новый СвязьПоТипу;
		ИсполнительПоНазначению = Справочники.РолиИсполнителей.ПустаяСсылка();

		Если ТаблицаРолей.Количество() = 1 Тогда
			ИсполнительПоНазначению = ТаблицаРолей.Получить(0).Ссылка;
			Объект.РольИсполнителя = ИсполнительПоНазначению;
		КонецЕсли;
	Иначе
		Если ЗначениеЗаполнено(Объект.РольИсполнителя) Тогда
			ТипИсполнителя = Объект.РольИсполнителя;
			ИсполнительПоНазначению = Объект.РольИсполнителя;
		Иначе
			ИсполнительСтрокой = Строка(Объект.Исполнитель);
			Элементы.ИсполнительСтрокой.Видимость = Истина;
			Элементы.Исполнитель.Видимость = Ложь;
			Элементы.Исполнитель.ТолькоПросмотр = Истина;
		КонецЕсли;
	КонецЕсли;

	Элементы.Автор.Видимость = Ложь;
	Элементы.АвторСтрокой.Видимость = Истина;
	Элементы.ГруппаПроверитьИсполнение.Видимость = Ложь;
	Элементы.ТипИсполнителя.Видимость = Ложь;
	Элементы.Исполнитель.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Авто;

КонецПроцедуры

// Для внутреннего использования.
//
// Параметры:
//   ТипПользователей - СправочникСсылка - тип пользователей.
// 
// Возвращаемое значение:
//   ТаблицаЗначений - коллекция ролей для заданного типа пользователей:
//     * Ссылка - СправочникСсылка.РолиИсполнителей - ссылка на роль.
//
&НаСервереБезКонтекста
Функция ТаблицаРолей(ТипПользователей)

	Запрос = Новый Запрос("ВЫБРАТЬ РАЗРЕШЕННЫЕ
						  |	РолиИсполнителейНазначение.Ссылка КАК Ссылка
						  |ИЗ
						  |	Справочник.РолиИсполнителей.Назначение КАК РолиИсполнителейНазначение
						  |ГДЕ
						  |	РолиИсполнителейНазначение.ТипПользователей = &ТипПользователей");
	Запрос.УстановитьПараметр("ТипПользователей", ТипПользователей);

	Возврат Запрос.Выполнить().Выгрузить();

КонецФункции

&НаСервере
Процедура УстановитьСостояниеЭлементов()
	РольСтрокой = РольСтрокой(Объект.ОсновнойОбъектАдресации, Объект.ДополнительныйОбъектАдресации);
	Элементы.Роль.Видимость = ?(ЗначениеЗаполнено(РольСтрокой), Истина, Ложь);

	РольПроверяющегоСтрокой = РольСтрокой(Объект.ОсновнойОбъектАдресацииПроверяющий,
		Объект.ДополнительныйОбъектАдресацииПроверяющий);
	Элементы.РольПроверяющего.Видимость = ?(ЗначениеЗаполнено(РольПроверяющегоСтрокой), Истина, Ложь);

	Элементы.ГруппаПроверка.Доступность = Объект.ПроверитьВыполнение;

КонецПроцедуры

&НаСервере
Функция РольСтрокой(ОсновнойОбъектАдресации, ДополнительныйОбъектАдресации)
	Результат = "";
	Если ОсновнойОбъектАдресации <> Неопределено Тогда
		Результат = НСтр("ru = 'Объект адресации'") + ": " + Строка(ОсновнойОбъектАдресации);
		Если ДополнительныйОбъектАдресации <> Неопределено Тогда
			Результат = Результат + " ," + Строка(ДополнительныйОбъектАдресации);
		КонецЕсли;
	КонецЕсли;
	Возврат Результат;
КонецФункции

&НаСервере
Процедура УстановитьИсполнителяПоДаннымФормы()

	Если ЗначениеЗаполнено(ИсполнительПоНазначению) Тогда
		Если ТипЗнч(ТипИсполнителя) = Тип("СправочникСсылка.РолиИсполнителей") Тогда
			Если Пользователи.ЭтоСеансВнешнегоПользователя() Тогда
				Объект.Исполнитель = Справочники.Пользователи.ПустаяСсылка();
				Объект.РольИсполнителя = ИсполнительПоНазначению;
			КонецЕсли;
			УстановитьСостояниеЭлементов();
		Иначе
			Объект.Исполнитель = ВнешнийПользовательПоОбъектуАвторизации(ИсполнительПоНазначению);
			Объект.РольИсполнителя = Неопределено;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ВнешнийПользовательПоОбъектуАвторизации(ИсполнительПоНазначению)

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВнешниеПользователи.Ссылка
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи
	|ГДЕ
	|	ВнешниеПользователи.ОбъектАвторизации = &ИсполнительПоНазначению";

	Запрос.УстановитьПараметр("ИсполнительПоНазначению", ИсполнительПоНазначению);

	РезультатЗапроса = Запрос.Выполнить();

	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();

	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЕсли;

	Возврат Справочники.ВнешниеПользователи.ПустаяСсылка();

КонецФункции

&НаСервере
Процедура УстановитьРольПроверяющего(Знач СведенияОРоли)
	Объект.Проверяющий = Справочники.Пользователи.ПустаяСсылка();
	Объект.РольПроверяющего = СведенияОРоли.РольИсполнителя;
	ПроверяющийПоНазначению = СведенияОРоли.РольИсполнителя;
	Объект.ОсновнойОбъектАдресацииПроверяющий = СведенияОРоли.ОсновнойОбъектАдресации;
	Объект.ДополнительныйОбъектАдресацииПроверяющий = СведенияОРоли.ДополнительныйОбъектАдресации;
	УстановитьСостояниеЭлементов();
КонецПроцедуры

&НаСервере
Процедура УстановитьРоль(Знач СведенияОРоли)
	Объект.Исполнитель = Справочники.Пользователи.ПустаяСсылка();

	Если ЗначениеЗаполнено(СведенияОРоли) Тогда
		Объект.РольИсполнителя = СведенияОРоли.РольИсполнителя;
		ИсполнительПоНазначению = СведенияОРоли.РольИсполнителя;
		Объект.ОсновнойОбъектАдресации = СведенияОРоли.ОсновнойОбъектАдресации;
		Объект.ДополнительныйОбъектАдресации = СведенияОРоли.ДополнительныйОбъектАдресации;
	Иначе
		Объект.РольИсполнителя = Неопределено;
		ИсполнительПоНазначению = Неопределено;
		Объект.ОсновнойОбъектАдресации = Неопределено;
		Объект.ДополнительныйОбъектАдресации = Неопределено;
	КонецЕсли;
	УстановитьСостояниеЭлементов();
	УстановитьИсполнителяПоДаннымФормы();
КонецПроцедуры

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти