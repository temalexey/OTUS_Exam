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
	
	Настройки.События.ПередЗагрузкойНастроекВКомпоновщик = Истина;
	Настройки.События.ПослеЗагрузкиНастроекВКомпоновщик = Истина;
	
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
	
	Если КлючСхемы <> "1" Тогда
		КлючСхемы = "1";
		
		Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения")
		   И НовыеНастройкиКД <> Неопределено
		   И Контекст.Параметры.Свойство("ПараметрКоманды")
		   И ЗначениеЗаполнено(Контекст.Параметры.ПараметрКоманды)
		   И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
			
			МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
			ПараметрыДляОтчетов = МодульУправлениеДоступомСлужебный.ПараметрыДляОтчетов();
			
			Значения = Контекст.Параметры.ПараметрКоманды;
			Если ТипЗнч(Значения[0]) = ПараметрыДляОтчетов.ТипСправочникСсылкаГруппыДоступа Тогда
				ИмяПараметра = "ГруппаДоступа";
			ИначеЕсли ТипЗнч(Значения[0]) = ПараметрыДляОтчетов.ТипСправочникСсылкаПрофилиГруппДоступа Тогда
				ИмяПараметра = "Профиль";
			КонецЕсли;
			
			СписокЗначений = Новый СписокЗначений;
			СписокЗначений.ЗагрузитьЗначения(Значения);
			ПользователиСлужебный.УстановитьОтборДляПараметра(ИмяПараметра,
				СписокЗначений, НовыеНастройкиКД, НовыеПользовательскиеНастройкиКД);
		КонецЕсли;
	КонецЕсли;
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
	ПоТипамГруппИЗначений = МодульУправлениеДоступомСлужебный.СвойстваВсехВидовДоступа().ПоТипамГруппИЗначений;
	
	Типы = Новый Массив;
	Типы.Добавить(Тип("СправочникСсылка.Пользователи"));
	Типы.Добавить(Тип("СправочникСсылка.ГруппыПользователей"));
	Типы.Добавить(Тип("СправочникСсылка.ВнешниеПользователи"));
	Типы.Добавить(Тип("СправочникСсылка.ГруппыВнешнихПользователей"));
	
	Для Каждого КлючИЗначение Из ПоТипамГруппИЗначений Цикл
		СвойстваВидаДоступа = КлючИЗначение.Значение; // см. УправлениеДоступомСлужебный.СвойстваВидаДоступа
		Если СвойстваВидаДоступа.Имя = "Пользователи"
		 Или СвойстваВидаДоступа.Имя = "ВнешниеПользователи" Тогда
			Продолжить;
		КонецЕсли;
		Типы.Добавить(КлючИЗначение.Ключ);
	КонецЦикла;
	
	СхемаКомпоновкиДанных.Параметры.ЗначениеДоступа.ТипЗначения = Новый ОписаниеТипов(Типы);
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда
		МодульОтчетыСервер = ОбщегоНазначения.ОбщийМодуль("ОтчетыСервер");
		МодульОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКомпоновкиДанных, КлючСхемы);
	КонецЕсли;
	
КонецПроцедуры

//  Параметры:
//    ДополнительныеПараметры - Структура
//
Процедура ПослеЗагрузкиНастроекВКомпоновщик(ДополнительныеПараметры) Экспорт
	
	Параметр = Новый ПараметрКомпоновкиДанных("ВидДоступа");
	ДоступныйПараметр = КомпоновщикНастроек.Настройки.ПараметрыДанных.ДоступныеПараметры.НайтиПараметр(Параметр);
	Если ДоступныйПараметр = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеДоступомСлужебныйПовтИсп = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебныйПовтИсп");
	ПредставлениеВидовДоступа = МодульУправлениеДоступомСлужебныйПовтИсп.ПредставлениеВидовДоступа();
	
	МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
	ПоТипамЗначений = МодульУправлениеДоступомСлужебный.СвойстваВсехВидовДоступа().ПоТипамЗначений;
	
	ВидыДоступа = Новый СписокЗначений;
	Для Каждого КлючИЗначение Из ПредставлениеВидовДоступа Цикл
		СвойстваВидаДоступа = ПоТипамЗначений.Получить(КлючИЗначение.Ключ); // см. УправлениеДоступомСлужебный.СвойстваВидаДоступа
		ВидыДоступа.Добавить(СвойстваВидаДоступа.Имя, КлючИЗначение.Значение);
	КонецЦикла;
	
	ДоступныйПараметр.ДоступныеЗначения = ВидыДоступа;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДокументРезультат.Очистить();
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		ВыполнитьПроверкуПравДоступа("АдминистрированиеДанных", Метаданные);
	Иначе
		ВыполнитьПроверкуПравДоступа("Администрирование", Метаданные);
	КонецЕсли;
	УстановитьПривилегированныйРежим(Истина);
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("Изменения", ИзмененияЗначений(Настройки));
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, Настройки, ДанныеРасшифровки);
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных, ДанныеРасшифровки, Истина);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПроцессорВывода.НачатьВывод();
	ЭлементРезультата = ПроцессорКомпоновки.Следующий();
	Пока ЭлементРезультата <> Неопределено Цикл
		ПроцессорВывода.ВывестиЭлемент(ЭлементРезультата);
		ЭлементРезультата = ПроцессорКомпоновки.Следующий();
	КонецЦикла;
	ПроцессорВывода.ЗакончитьВывод();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ИзмененияЗначений(Настройки)
	
	ИмяКолонкиСоединение = КонтрольРаботыПользователейСлужебный.ИмяКолонкиСоединение();
	
	Отбор = Новый Структура;
	
	СтатусыТранзакции = Новый Массив;
	СтатусыТранзакции.Добавить(СтатусТранзакцииЗаписиЖурналаРегистрации.Зафиксирована);
	СтатусыТранзакции.Добавить(СтатусТранзакцииЗаписиЖурналаРегистрации.НетТранзакции);
	Отбор.Вставить("СтатусТранзакции", СтатусыТранзакции);
	
	Период = ЗначениеПараметра(Настройки, "Период", Новый СтандартныйПериод);
	Если ЗначениеЗаполнено(Период.ДатаНачала) Тогда
		Отбор.Вставить("StartDate", Период.ДатаНачала);
	КонецЕсли;
	Если ЗначениеЗаполнено(Период.ДатаОкончания) Тогда
		Отбор.Вставить("EndDate", Период.ДатаОкончания);
	КонецЕсли;
	
	МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
	ПараметрыДляОтчетов = МодульУправлениеДоступомСлужебный.ПараметрыДляОтчетов();
	Отбор.Вставить("Событие",
		МодульУправлениеДоступомСлужебный.ИмяСобытияИзменениеРазрешенныхЗначенийДляЖурналаРегистрации());
	
	Автор = ЗначениеПараметра(Настройки, "Автор", Null);
	Если Автор <> Null Тогда
		Отбор.Вставить("Пользователь", Строка(Автор));
	КонецЕсли;
	
	ТипБулево     = Новый ОписаниеТипов("Булево");
	ТипДата       = Новый ОписаниеТипов("Дата");
	ТипЧисло      = Новый ОписаниеТипов("Число");
	ТипСтрока     = Новый ОписаниеТипов("Строка");
	ТипСтрока1    = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(1));
	ТипСтрока20   = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(20));
	ТипСтрока36   = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(36));
	ТипСтрока100  = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(100));
	ТипСтрока1000 = Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(1000));
	
	ТипПрофиль         = Новый ОписаниеТипов(ТипСтрока100, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(
		ПараметрыДляОтчетов.ТипСправочникСсылкаПрофилиГруппДоступа));
	ТипГруппаДоступа   = Новый ОписаниеТипов(ТипСтрока100, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(
		ПараметрыДляОтчетов.ТипСправочникСсылкаГруппыДоступа));
	ТипЗначениеДоступа = Новый ОписаниеТипов(ТипСтрока100,  ПараметрыДляОтчетов.ТипыЗначенийДоступа);
	ТипИсточник        = Новый ОписаниеТипов(ТипСтрока1000, ПараметрыДляОтчетов.ТипыЗначенийДоступа);
	ТипИсточник        = Новый ОписаниеТипов(ТипИсточник, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(
		ПараметрыДляОтчетов.ТипСправочникСсылкаПрофилиГруппДоступа));
	ТипИсточник        = Новый ОписаниеТипов(ТипИсточник, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(
		ПараметрыДляОтчетов.ТипСправочникСсылкаГруппыДоступа));
	
	Изменения = Новый ТаблицаЗначений;
	Колонки = Изменения.Колонки;
	Колонки.Добавить("Профиль",                          ТипПрофиль);
	Колонки.Добавить("ПредставлениеПрофиля",             ТипСтрока1000);
	Колонки.Добавить("ПометкаУдаленияПрофиля",           ТипБулево);
	Колонки.Добавить("ГруппаДоступа",                    ТипГруппаДоступа);
	Колонки.Добавить("ПредставлениеГруппыДоступа",       ТипСтрока1000);
	Колонки.Добавить("ПометкаУдаленияГруппыДоступа",     ТипБулево);
	Колонки.Добавить("НомерСобытия",                     ТипЧисло);
	Колонки.Добавить("Дата",                             ТипДата);
	Колонки.Добавить("Автор",                            ТипСтрока100);
	Колонки.Добавить("ИдентификаторАвтора",              ТипСтрока36);
	Колонки.Добавить("Приложение",                       ТипСтрока20);
	Колонки.Добавить("Компьютер",                        ТипСтрока);
	Колонки.Добавить("Сеанс",                            ТипЧисло);
	Колонки.Добавить(ИмяКолонкиСоединение,               ТипЧисло);
	Колонки.Добавить("Источник",                         ТипИсточник);
	Колонки.Добавить("ПредставлениеИсточника",           ТипСтрока1000);
	Колонки.Добавить("ВидДоступа",                       ТипЗначениеДоступа);
	Колонки.Добавить("ИмяВидаДоступа",                   ТипСтрока1000);
	Колонки.Добавить("ПредставлениеВидаДоступа",         ТипСтрока1000);
	Колонки.Добавить("ВидДоступаИспользуется",           ТипБулево);
	Колонки.Добавить("Предустановленный",                ТипБулево);
	Колонки.Добавить("ВсеРазрешены",                     ТипБулево);
	Колонки.Добавить("ВидИзмененияВидаДоступа",          ТипСтрока1);
	Колонки.Добавить("ЗначениеИлиГруппа",                ТипЗначениеДоступа);
	Колонки.Добавить("ПредставлениеЗначенияИлиГруппы",   ТипСтрока1000);
	Колонки.Добавить("ЭтоГруппаЗначений",                ТипБулево);
	Колонки.Добавить("ВключаяНижестоящие",               ТипБулево);
	Колонки.Добавить("ЗначениеДоступа",                  ТипЗначениеДоступа);
	Колонки.Добавить("ПредставлениеЗначенияДоступа",     ТипСтрока1000);
	Колонки.Добавить("ВидИзмененияЗначенияДоступа",      ТипСтрока1);
	Колонки.Добавить("БылоПрофиль",                      ТипПрофиль);
	Колонки.Добавить("БылоПредставлениеПрофиля",         ТипСтрока1000);
	Колонки.Добавить("БылоПометкаУдаленияПрофиля",       ТипБулево);
	Колонки.Добавить("БылоПометкаУдаленияГруппыДоступа", ТипБулево);
	Колонки.Добавить("БылоПредустановленный",            ТипБулево);
	Колонки.Добавить("БылоВсеРазрешены",                 ТипБулево);
	Колонки.Добавить("БылоВключаяНижестоящие",           ТипБулево);
	
	КолонкиЖурнала = "Событие,Дата,Пользователь,ИмяПользователя,
	|ИмяПриложения,Компьютер,Сеанс,Данные," + ИмяКолонкиСоединение;
	
	УстановитьПривилегированныйРежим(Истина);
	События = Новый ТаблицаЗначений;
	ВыгрузитьЖурналРегистрации(События, Отбор, КолонкиЖурнала);
	
	НомерСобытия = 0;
	ОтборДанных = Новый Структура;
	ОтборДанных.Вставить("Профили", ИдентификаторыЗначений(
		ЗначениеПараметра(Настройки, "Профиль", Неопределено)));
	ОтборДанных.Вставить("ГруппыДоступа", ИдентификаторыЗначений(
		ЗначениеПараметра(Настройки, "ГруппаДоступа", Неопределено)));
	ОтборДанных.Вставить("ВидыДоступа", ИдентификаторыЗначений(СсылкиИзИменВидовДоступа(
		ЗначениеПараметра(Настройки, "ВидДоступа", Неопределено)), Истина));
	ОтборДанных.Вставить("ЗначенияДоступа", ИдентификаторыЗначений(
		ЗначениеПараметра(Настройки, "ЗначениеДоступа", Неопределено), Истина));
	
	Для Каждого Событие Из События Цикл
		Данные = РасширенныеДанныеИзмененияЗначений(Событие.Данные, ОтборДанных);
		Если Данные = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		НомерСобытия = НомерСобытия + 1;
		
		СвойстваСобытия = Новый Структура;
		СвойстваСобытия.Вставить("НомерСобытия",        НомерСобытия);
		СвойстваСобытия.Вставить("Дата",                Событие.Дата);
		СвойстваСобытия.Вставить("Автор",               Событие.ИмяПользователя);
		СвойстваСобытия.Вставить("ИдентификаторАвтора", Событие.Пользователь);
		СвойстваСобытия.Вставить("Приложение",          Событие.ИмяПриложения);
		СвойстваСобытия.Вставить("Компьютер",           Событие.Компьютер);
		СвойстваСобытия.Вставить("Сеанс",               Событие.Сеанс);
		СвойстваСобытия.Вставить(ИмяКолонкиСоединение,  Событие.Соединение);
		
		Если ТипЗнч(Данные.Источник) = Тип("ТаблицаЗначений") Тогда
			СвойстваСобытия.Вставить("Источник", Данные.НавигационнаяСсылкаИсточника);
			ЭтоИзменениеИспользованияВидовДоступа = ЗначениеЗаполнено(Данные.Источник);
			СвойстваСобытия.Вставить("ПредставлениеИсточника", ?(ЭтоИзменениеИспользованияВидовДоступа,
				НСтр("ru = '<Изменение использования видов доступа>'"),
				НСтр("ru = '<Изменение составов групп пользователей>'")));
		Иначе
			ЭтоИзменениеИспользованияВидовДоступа = Ложь;
			СвойстваСобытия.Вставить("Источник", ДесериализованнаяСсылка(Данные.Источник));
			СвойстваСобытия.Вставить("ПредставлениеИсточника", Данные.ПредставлениеИсточника);
		КонецЕсли;
		
		Кэши = Новый Соответствие;
		Данные.ИзменениеВидовДоступа.Колонки.Добавить("Обработано", Новый ОписаниеТипов("Булево"));
		
		ДобавитьИзменениеЗначений(Изменения, СвойстваСобытия, Данные, Кэши);
		
		ИзменениеЗначенийДоступа = Данные.ИзменениеЗначенийДоступа.Скопировать(Новый Массив);
		Для Каждого ОписаниеИзменения Из Данные.ИзменениеВидовДоступа Цикл
			Если ОписаниеИзменения.Обработано Тогда
				Продолжить;
			КонецЕсли;
			СтарыеЗначения = ОписаниеИзменения.СтарыеЗначенияСвойств;
			Если ОписаниеИзменения.ВидИзменения = "Изменено"
			   И Не ЗначениеЗаполнено(СтарыеЗначения)
			   И Не ЭтоИзменениеИспользованияВидовДоступа Тогда
				Продолжить;
			КонецЕсли;
			НоваяСтрока = ИзменениеЗначенийДоступа.Добавить();
			НоваяСтрока.ГруппаДоступаИлиПрофиль = ОписаниеИзменения.ГруппаДоступаИлиПрофиль;
			НоваяСтрока.ВидДоступа = ОписаниеИзменения.ВидДоступа;
			НоваяСтрока.ЗначениеДоступа = "*";
			НоваяСтрока.ВидИзменения = "Изменено";
		КонецЦикла;
	
		Если ЗначениеЗаполнено(ИзменениеЗначенийДоступа) Тогда
			Данные.ИзменениеЗначенийДоступа = ИзменениеЗначенийДоступа;
			ДобавитьИзменениеЗначений(Изменения, СвойстваСобытия, Данные, Кэши);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Изменения;
	
КонецФункции

Функция ЗначениеПараметра(Настройки, ИмяПараметра, ЗначениеПоУмолчанию)
	
	Поле = Настройки.ПараметрыДанных.Элементы.Найти(ИмяПараметра);
	
	Если Поле <> Неопределено И Поле.Использование Тогда
		Возврат Поле.Значение;
	КонецЕсли;
	
	Возврат ЗначениеПоУмолчанию;
	
КонецФункции

Функция СсылкиИзИменВидовДоступа(ВыбранныеЗначения)
	
	Если ВыбранныеЗначения = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(ВыбранныеЗначения) = Тип("СписокЗначений") Тогда
		Значения = ВыбранныеЗначения.ВыгрузитьЗначения();
	Иначе
		Значения = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ВыбранныеЗначения);
	КонецЕсли;
	
	МодульУправлениеДоступомСлужебный = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебный");
	ПоИменам = МодульУправлениеДоступомСлужебный.СвойстваВсехВидовДоступа().ПоИменам;
	
	Результат = Новый СписокЗначений;
	Для Каждого Значение Из Значения Цикл
		СвойстваВидаДоступа = ПоИменам.Получить(Значение); // см. УправлениеДоступомСлужебный.СвойстваВидаДоступа
		Если СвойстваВидаДоступа = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Результат.Добавить(СвойстваВидаДоступа.Ссылка);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ИдентификаторыЗначений(ВыбранныеЗначения, УчестьПустыеСсылки = Ложь)
	
	Если ВыбранныеЗначения = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(ВыбранныеЗначения) = Тип("СписокЗначений") Тогда
		Значения = ВыбранныеЗначения.ВыгрузитьЗначения();
	Иначе
		Значения = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ВыбранныеЗначения);
	КонецЕсли;
	
	Результат = Новый Соответствие;
	
	Для Каждого Значение Из Значения Цикл
		Если Не ЗначениеЗаполнено(Значение) И Не УчестьПустыеСсылки Тогда
			Продолжить;
		КонецЕсли;
		Результат.Вставить(ПользователиСлужебный.СериализованнаяСсылка(Значение), Истина);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//  ДанныеСобытия - Строка
//
// Возвращаемое значение:
//  Структура
//
Функция РасширенныеДанныеИзмененияЗначений(ДанныеСобытия, ОтборДанных)
	
	Если Не ЗначениеЗаполнено(ДанныеСобытия) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Данные = ОбщегоНазначения.ЗначениеИзСтрокиXML(ДанныеСобытия);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Если ТипЗнч(Данные) <> Тип("Структура") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Хранение = Новый Структура;
	Хранение.Вставить("ВерсияСтруктурыДанных");
	Хранение.Вставить("Источник");
	Хранение.Вставить("НавигационнаяСсылкаИсточника");
	Хранение.Вставить("ПредставлениеИсточника");
	Хранение.Вставить("ИзменениеВидовДоступа");
	Хранение.Вставить("ПредставлениеВидовДоступа");
	Хранение.Вставить("ИзменениеЗначенийДоступа");
	Хранение.Вставить("ИзменениеГруппЗначенийДоступа");
	Хранение.Вставить("ПредставлениеГруппДоступа");
	Хранение.Вставить("ПредставлениеЗначенийДоступа");
	ЗаполнитьЗначенияСвойств(Хранение, Данные);
	Если Хранение.ВерсияСтруктурыДанных <> 1 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(Хранение.Источник) = Тип("Массив") Тогда
		Если Не ЗначениеЗаполнено(Хранение.Источник) Тогда
			Источник = Новый ТаблицаЗначений;
		Иначе
			Свойства = Новый Структура;
			Свойства.Вставить("ВидДоступа", "");
			Свойства.Вставить("Используется", Ложь);
			Свойства.Вставить("ВидИзменения", "");
			Источник = ХранимаяТаблица(Хранение.Источник, Свойства);
			Если Не ЗначениеЗаполнено(Источник) Тогда
				Возврат Неопределено;
			КонецЕсли;
		КонецЕсли;
	Иначе
		Источник = Хранение.Источник;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("ГруппаДоступаИлиПрофиль", "");
	Свойства.Вставить("ВидДоступа", "");
	Свойства.Вставить("ВсеРазрешены", Ложь);
	Свойства.Вставить("Предустановленный", Ложь);
	Свойства.Вставить("СтарыеЗначенияСвойств", Новый Структура);
	Свойства.Вставить("ВидИзменения", "");
	
	ИзменениеВидовДоступа = ХранимаяТаблица(Хранение.ИзменениеВидовДоступа, Свойства);
	Если Не ЗначениеЗаполнено(ИзменениеВидовДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("ВидДоступа", "");
	Свойства.Вставить("Используется", Ложь);
	Свойства.Вставить("Имя", "");
	Свойства.Вставить("Представление", "");
	
	ПредставлениеВидовДоступа = ХранимаяТаблица(Хранение.ПредставлениеВидовДоступа, Свойства);
	Если Не ЗначениеЗаполнено(ПредставлениеВидовДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("ГруппаДоступаИлиПрофиль", "");
	Свойства.Вставить("ВидДоступа", "");
	Свойства.Вставить("ЗначениеДоступа", "");
	Свойства.Вставить("ЭтоГруппаЗначений", Ложь);
	Свойства.Вставить("ВключаяНижестоящие", Ложь);
	Свойства.Вставить("СтарыеЗначенияСвойств", Новый Структура);
	Свойства.Вставить("ВидИзменения", "");
	
	ИзменениеЗначенийДоступа = ХранимаяТаблица(Хранение.ИзменениеЗначенийДоступа, Свойства);
	Если ИзменениеЗначенийДоступа = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("ГруппаЗначений", "");
	Свойства.Вставить("ЗначениеДоступа", "");
	Свойства.Вставить("ВидИзменения", "");
	
	ИзменениеГруппЗначенийДоступа = ХранимаяТаблица(Хранение.ИзменениеГруппЗначенийДоступа, Свойства);
	Если ИзменениеГруппЗначенийДоступа = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("ГруппаДоступа", "");
	Свойства.Вставить("Представление", "");
	Свойства.Вставить("ПометкаУдаления", Ложь);
	Свойства.Вставить("Профиль", "");
	Свойства.Вставить("ПредставлениеПрофиля", "");
	Свойства.Вставить("ПометкаУдаленияПрофиля", Ложь);
	Свойства.Вставить("СтарыеЗначенияСвойств", Новый Структура);
	
	ПредставлениеГруппДоступа = ХранимаяТаблица(Хранение.ПредставлениеГруппДоступа, Свойства);
	Если Не ЗначениеЗаполнено(ПредставлениеГруппДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Свойства = Новый Структура;
	Свойства.Вставить("Значение", "");
	Свойства.Вставить("Представление", "");
	Свойства.Вставить("НавигационнаяСсылка", "");
	
	ПредставлениеЗначенийДоступа = ХранимаяТаблица(Хранение.ПредставлениеЗначенийДоступа, Свойства);
	Если ПредставлениеЗначенийДоступа = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ИзменениеВидовДоступа.Индексы.Добавить("ГруппаДоступаИлиПрофиль, ВидДоступа");
	ИзменениеГруппЗначенийДоступа.Индексы.Добавить("ГруппаЗначений");
	ПредставлениеГруппДоступа.Индексы.Добавить("ГруппаДоступа");
	ПредставлениеГруппДоступа.Индексы.Добавить("Профиль");
	ПредставлениеЗначенийДоступа.Индексы.Добавить("Значение");
	
	Отбор = Новый Структура("ВидИзменения", "");
	НайденныеСтроки = ИзменениеЗначенийДоступа.НайтиСтроки(Отбор);
	НеизмененныеЗначения = ИзменениеЗначенийДоступа.Скопировать(НайденныеСтроки);
	НеизмененныеЗначения.Колонки.Добавить("ЗначениеГруппы");
	Отбор = Новый Структура("ГруппаЗначений");
	Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
		Отбор.ГруппаЗначений = НайденнаяСтрока.ЗначениеДоступа;
		ЗначенияГруппы = ИзменениеГруппЗначенийДоступа.НайтиСтроки(Отбор);
		Для Каждого ЗначениеГруппы Из ЗначенияГруппы Цикл
			НоваяСтрока = НеизмененныеЗначения.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, НайденнаяСтрока);
			НоваяСтрока.ЗначениеГруппы = ЗначениеГруппы.ЗначениеДоступа;
		КонецЦикла;
		ИзменениеЗначенийДоступа.Удалить(НайденнаяСтрока);
	КонецЦикла;
	НеизмененныеЗначения.Индексы.Добавить("ГруппаДоступаИлиПрофиль,ВидДоступа,ЗначениеДоступа");
	НеизмененныеЗначения.Индексы.Добавить("ГруппаДоступаИлиПрофиль,ВидДоступа,ЗначениеГруппы");
	
	Результат = Новый Структура;
	Результат.Вставить("Источник",                      Источник);
	Результат.Вставить("НавигационнаяСсылкаИсточника",  Хранение.НавигационнаяСсылкаИсточника);
	Результат.Вставить("ПредставлениеИсточника",        Хранение.ПредставлениеИсточника);
	Результат.Вставить("ИзменениеВидовДоступа",         ИзменениеВидовДоступа);
	Результат.Вставить("ПредставлениеВидовДоступа",     ПредставлениеВидовДоступа);
	Результат.Вставить("ИзменениеЗначенийДоступа",      ИзменениеЗначенийДоступа);
	Результат.Вставить("ИзменениеГруппЗначенийДоступа", ИзменениеГруппЗначенийДоступа);
	Результат.Вставить("ПредставлениеГруппДоступа",     ПредставлениеГруппДоступа);
	Результат.Вставить("ПредставлениеЗначенийДоступа",  ПредставлениеЗначенийДоступа);
	Результат.Вставить("НеизмененныеЗначения",          НеизмененныеЗначения);
	
	Если ОтборДанных.Профили = Неопределено
	   И ОтборДанных.ГруппыДоступа = Неопределено
	   И ОтборДанных.ВидыДоступа = Неопределено
	   И ОтборДанных.ЗначенияДоступа = Неопределено Тогда
		
		Возврат Результат;
	КонецЕсли;
	
	Индекс = ПредставлениеГруппДоступа.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Строка = ПредставлениеГруппДоступа.Получить(Индекс);
		Если ОтборДанных.Профили <> Неопределено
		   И ОтборДанных.Профили.Получить(Строка.Профиль) = Неопределено
		 Или ОтборДанных.ГруппыДоступа <> Неопределено
		   И ОтборДанных.ГруппыДоступа.Получить(Строка.ГруппаДоступа) = Неопределено Тогда
			ПредставлениеГруппДоступа.Удалить(Индекс);
		КонецЕсли;
	КонецЦикла;
	
	Если Не ЗначениеЗаполнено(ПредставлениеГруппДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Индекс = ИзменениеВидовДоступа.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Строка = ИзменениеВидовДоступа.Получить(Индекс);
		Если ОтборДанных.ВидыДоступа <> Неопределено
		   И ОтборДанных.ВидыДоступа.Получить(Строка.ВидДоступа) = Неопределено Тогда
			ИзменениеВидовДоступа.Удалить(Индекс);
		КонецЕсли;
	КонецЦикла;
	
	Если Не ЗначениеЗаполнено(ИзменениеВидовДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ОтборДанных.ЗначенияДоступа = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Индекс = ИзменениеГруппЗначенийДоступа.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Строка = ИзменениеГруппЗначенийДоступа.Получить(Индекс);
		Если ОтборДанных.ЗначенияДоступа.Получить(Строка.ГруппаЗначений) <> Неопределено
		 Или ОтборДанных.ЗначенияДоступа.Получить(Строка.ЗначениеДоступа) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ИзменениеГруппЗначенийДоступа.Удалить(Индекс);
	КонецЦикла;
	
	Индекс = ИзменениеЗначенийДоступа.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Строка = ИзменениеЗначенийДоступа.Получить(Индекс);
		Если Строка.ВидИзменения = ""
		 Или ОтборДанных.ЗначенияДоступа.Получить(Строка.ЗначениеДоступа) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		Отбор = Новый Структура("ГруппаЗначений", Строка.ЗначениеДоступа);
		НайденныеСтроки = ИзменениеГруппЗначенийДоступа.НайтиСтроки(Отбор);
		Если ЗначениеЗаполнено(НайденныеСтроки) Тогда
			Продолжить;
		КонецЕсли;
		ИзменениеЗначенийДоступа.Удалить(Индекс);
	КонецЦикла;
	
	Если Не ЗначениеЗаполнено(ИзменениеЗначенийДоступа) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ХранимаяТаблица(Строки, Свойства)
	
	Если ТипЗнч(Строки) <> Тип("Массив") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = Новый ТаблицаЗначений;
	Для Каждого КлючИЗначение Из Свойства Цикл
		Типы = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ТипЗнч(КлючИЗначение.Значение));
		Результат.Колонки.Добавить(КлючИЗначение.Ключ, Новый ОписаниеТипов(Типы));
	КонецЦикла;
	
	Для Каждого Строка Из Строки Цикл
		Если ТипЗнч(Строка) <> Тип("Структура") Тогда
			Возврат Неопределено;
		КонецЕсли;
		НоваяСтрока = Результат.Добавить();
		Для Каждого КлючИЗначение Из Свойства Цикл
			Если Не Строка.Свойство(КлючИЗначение.Ключ)
			 Или ТипЗнч(Строка[КлючИЗначение.Ключ]) <> ТипЗнч(КлючИЗначение.Значение) Тогда
				Возврат Неопределено;
			КонецЕсли;
			НоваяСтрока[КлючИЗначение.Ключ] = Строка[КлючИЗначение.Ключ];
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ДобавитьИзменениеЗначений(Изменения, СвойстваСобытия, Данные, Кэши)
	
	Для Каждого ОписаниеИзменения Из Данные.ИзменениеЗначенийДоступа Цикл
		НайденнаяСтрока = Данные.ПредставлениеГруппДоступа.Найти(
			ОписаниеИзменения.ГруппаДоступаИлиПрофиль, "ГруппаДоступа");
		Если НайденнаяСтрока = Неопределено Тогда
			ЭтоГруппаДоступа = Ложь;
			Отбор = Новый Структура("Профиль", ОписаниеИзменения.ГруппаДоступаИлиПрофиль);
			СвойстваГруппДоступа = Данные.ПредставлениеГруппДоступа.НайтиСтроки(Отбор);
		Иначе
			СвойстваГруппДоступа = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(НайденнаяСтрока);
			ЭтоГруппаДоступа = Истина;
		КонецЕсли;
		Если Не ЗначениеЗаполнено(СвойстваГруппДоступа) Тогда
			Продолжить;
		КонецЕсли;
		СвойстваВидаДоступа = СвойстваТекущегоВидаДоступа(ОписаниеИзменения,
			ЭтоГруппаДоступа, Данные, Кэши);
		Если СвойстваВидаДоступа = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		СвойстваЗначения = СвойстваТекущегоЗначения(ОписаниеИзменения.ЗначениеДоступа, Данные, Кэши);
		СвойстваСтроки = Новый Структура;
		СвойстваСтроки.Вставить("Профиль",                          ДесериализованнаяСсылка(СвойстваГруппДоступа[0].Профиль));
		СвойстваСтроки.Вставить("ПредставлениеПрофиля",             СвойстваГруппДоступа[0].ПредставлениеПрофиля);
		СвойстваСтроки.Вставить("ПометкаУдаленияПрофиля",           СвойстваГруппДоступа[0].ПометкаУдаленияПрофиля);
		СвойстваСтроки.Вставить("ЗначениеИлиГруппа",                СвойстваЗначения.ЗначениеДоступа);
		СвойстваСтроки.Вставить("ПредставлениеЗначенияИлиГруппы",   СвойстваЗначения.ПредставлениеЗначенияДоступа);
		СвойстваСтроки.Вставить("ЭтоГруппаЗначений",                ОписаниеИзменения.ЭтоГруппаЗначений);
		СвойстваСтроки.Вставить("ВключаяНижестоящие",               ОписаниеИзменения.ВключаяНижестоящие);
		СтарыеЗначения = СвойстваГруппДоступа[0].СтарыеЗначенияСвойств;
		СвойстваСтроки.Вставить("БылоПрофиль", ?(СтарыеЗначения.Свойство("Профиль"),
			ДесериализованнаяСсылка(СтарыеЗначения.Профиль), СвойстваСтроки.Профиль));
		СвойстваСтроки.Вставить("БылоПредставлениеПрофиля", ?(СтарыеЗначения.Свойство("ПредставлениеПрофиля"),
			СтарыеЗначения.ПредставлениеПрофиля, СвойстваСтроки.ПредставлениеПрофиля));
		СвойстваСтроки.Вставить("БылоПометкаУдаленияПрофиля", ?(СтарыеЗначения.Свойство("ПометкаУдаленияПрофиля"),
			СтарыеЗначения.ПометкаУдаленияПрофиля, СвойстваСтроки.ПометкаУдаленияПрофиля));
		СтарыеЗначения = ОписаниеИзменения.СтарыеЗначенияСвойств;
		СвойстваСтроки.Вставить("БылоВключаяНижестоящие", ?(СтарыеЗначения.Свойство("ВключаяНижестоящие"),
			СтарыеЗначения.ВключаяНижестоящие, СвойстваСтроки.ВключаяНижестоящие));
		Если ТипЗнч(Данные.Источник) = Тип("ТаблицаЗначений")
		 Или СвойстваВидаДоступа.ВидИзмененияВидаДоступа <> "*" Тогда
			Варианты = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве("");
		Иначе
			Варианты = Новый Массив;
			Варианты.Добавить("-");
			Варианты.Добавить("+");
		КонецЕсли;
		Для Каждого СвойстваГруппыДоступа Из СвойстваГруппДоступа Цикл
			СвойстваСтроки.Вставить("ГруппаДоступа",                    ДесериализованнаяСсылка(СвойстваГруппыДоступа.ГруппаДоступа));
			СвойстваСтроки.Вставить("ПредставлениеГруппыДоступа",       СвойстваГруппыДоступа.Представление);
			СвойстваСтроки.Вставить("ПометкаУдаленияГруппыДоступа",     СвойстваГруппыДоступа.ПометкаУдаления);
			СтарыеЗначения = СвойстваГруппыДоступа.СтарыеЗначенияСвойств;
			СвойстваСтроки.Вставить("БылоПометкаУдаленияГруппыДоступа", ?(СтарыеЗначения.Свойство("ПометкаУдаления"),
				СтарыеЗначения.ПометкаУдаления, СвойстваСтроки.ПометкаУдаленияГруппыДоступа));
			Для Каждого Вариант Из Варианты Цикл
				Если Вариант <> "" Тогда
					Если ОписаниеИзменения.ВидИзменения = "Добавлено" И Вариант = "-"
					 Или ОписаниеИзменения.ВидИзменения = "Удалено"   И Вариант = "+" Тогда
						Продолжить;
					КонецЕсли;
					СвойстваВидаДоступа.ВидИзмененияВидаДоступа = Вариант;
				КонецЕсли;
				ВсеРазрешены = ?(СвойстваВидаДоступа.ВидИзмененияВидаДоступа = "+",
					СвойстваВидаДоступа.ВсеРазрешены, СвойстваВидаДоступа.БылоВсеРазрешены);
				ВключаяНижестоящие = ?(Вариант = "+", СвойстваСтроки.ВключаяНижестоящие,
					?(Вариант = "-", СвойстваСтроки.БылоВключаяНижестоящие,
						СвойстваСтроки.ВключаяНижестоящие Или СвойстваСтроки.БылоВключаяНижестоящие));
				СвойстваВидаДоступа.ПредставлениеВидаДоступа =
					СвойстваВидаДоступа.ПредставлениеВидаДоступаБезУточнения
					+ " (" + ?(ВсеРазрешены, НСтр("ru = 'Запрещенные'"), НСтр("ru = 'Разрешенные'")) + ")";
				ЗначенияГруппы = Неопределено;
				ВидИзмененияЗначенияДоступа = ?(ОписаниеИзменения.ВидИзменения = "Добавлено", "+",
					?(ОписаниеИзменения.ВидИзменения = "Удалено", "-", Вариант));
				Если ОписаниеИзменения.ЭтоГруппаЗначений Или ВключаяНижестоящие Тогда
					Отбор = Новый Структура("ГруппаЗначений", ОписаниеИзменения.ЗначениеДоступа);
					ЗначенияГруппы = Данные.ИзменениеГруппЗначенийДоступа.НайтиСтроки(Отбор);
					Для Каждого ЗначениеГруппы Из ЗначенияГруппы Цикл
						Если ЗначениеВСоставеНеизмененных(ЗначениеГруппы, ОписаниеИзменения, Данные) Тогда
							Продолжить;
						КонецЕсли;
						ЭтоЗначениеГруппы = ЗначениеГруппы.ЗначениеДоступа <> ОписаниеИзменения.ЗначениеДоступа;
						Если Не ЭтоЗначениеГруппы И ВидИзмененияЗначенияДоступа = "" Тогда
							Продолжить;
						КонецЕсли;
						НоваяСтрока = Изменения.Добавить();
						ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваСобытия);
						ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваСтроки);
						ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваВидаДоступа);
						ЗаполнитьЗначенияСвойств(НоваяСтрока,
							СвойстваТекущегоЗначения(ЗначениеГруппы.ЗначениеДоступа, Данные, Кэши));
						НоваяСтрока.ВидИзмененияЗначенияДоступа = ?(Вариант <> "", ВидИзмененияЗначенияДоступа,
							?(ЗначениеГруппы.ВидИзменения = "Добавлено", "+",
								?(ЗначениеГруппы.ВидИзменения = "Удалено", "-",
									?(ЭтоЗначениеГруппы И СвойстваСтроки.ВключаяНижестоящие И Не СвойстваСтроки.БылоВключаяНижестоящие, "+",
										?(ЭтоЗначениеГруппы И Не СвойстваСтроки.ВключаяНижестоящие И СвойстваСтроки.БылоВключаяНижестоящие, "-",
											ВидИзмененияЗначенияДоступа)))));
					КонецЦикла;
				КонецЕсли;
				Если Не ЗначениеЗаполнено(ЗначенияГруппы)
				   И Не ЗначениеВСоставеНеизмененных(ОписаниеИзменения, ОписаниеИзменения, Данные) Тогда
					НоваяСтрока = Изменения.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваСобытия);
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваСтроки);
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваВидаДоступа);
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваЗначения);
					НоваяСтрока.ВидИзмененияЗначенияДоступа = ВидИзмененияЗначенияДоступа;
					Если СвойстваЗначения.ЗначениеДоступа = "*" Тогда
						ПредставлениеЗначения = "<" + ?(ВсеРазрешены,
							НСтр("ru = 'Все разрешены'"), НСтр("ru = 'Все запрещены'")) + ">";
						НоваяСтрока.ПредставлениеЗначенияИлиГруппы = ПредставлениеЗначения;
						НоваяСтрока.ПредставлениеЗначенияДоступа   = ПредставлениеЗначения;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Функция ДесериализованнаяСсылка(СериализованнаяСсылка)
	
	Если СериализованнаяСсылка = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Результат = ЗначениеИзСтрокиВнутр(СериализованнаяСсылка);
	Исключение
		Результат = Неопределено;
	КонецПопытки;
	
	Если Результат = Неопределено Тогда
		Возврат СериализованнаяСсылка;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция СвойстваТекущегоВидаДоступа(ОписаниеИзменения, ЭтоГруппаДоступа, Данные, Кэши)
	
	Отбор = Новый Структура("ГруппаДоступаИлиПрофиль, ВидДоступа",
		ОписаниеИзменения.ГруппаДоступаИлиПрофиль, ОписаниеИзменения.ВидДоступа);
	НайденныеСтроки = Данные.ИзменениеВидовДоступа.НайтиСтроки(Отбор);
	
	Если Не ЗначениеЗаполнено(НайденныеСтроки) Тогда
		Возврат Неопределено;
	КонецЕсли;
	ИзменениеВидаДоступа = НайденныеСтроки[0];
	
	СтарыеЗначенияСвойств = ИзменениеВидаДоступа.СтарыеЗначенияСвойств;
	БылоПредустановленный = ?(СтарыеЗначенияСвойств.Свойство("Предустановленный"),
			СтарыеЗначенияСвойств.Предустановленный, ИзменениеВидаДоступа.Предустановленный);
	
	Если ЭтоГруппаДоступа
	   И ИзменениеВидаДоступа.Предустановленный <> Ложь
	   И Не (БылоПредустановленный = Ложь
	         И ОписаниеИзменения.ВидИзменения <> "Добавлено")
	 Или Не ЭтоГруппаДоступа
	   И ИзменениеВидаДоступа.Предустановленный <> Истина
	   И Не (БылоПредустановленный = Истина
	         И ОписаниеИзменения.ВидИзменения <> "Добавлено") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Кэш = Кэши.Получить("СвойстваВидовДоступа");
	Если Кэш = Неопределено Тогда
		Кэш = Новый Соответствие;
		Кэши.Вставить("СвойстваВидовДоступа", Кэш);
	КонецЕсли;
	
	Свойства = Кэш.Получить(ОписаниеИзменения.ВидДоступа);
	Если Свойства = Неопределено Тогда
		НайденнаяСтрока = Данные.ПредставлениеВидовДоступа.Найти(ОписаниеИзменения.ВидДоступа, "ВидДоступа");
		Свойства = Новый Структура;
		Свойства.Вставить("ВидДоступа", ДесериализованнаяСсылка(ОписаниеИзменения.ВидДоступа));
		Свойства.Вставить("ИмяВидаДоступа", "");
		Свойства.Вставить("ВидДоступаИспользуется", Ложь);
		Свойства.Вставить("ПредставлениеВидаДоступа", "");
		Свойства.Вставить("ПредставлениеВидаДоступаБезУточнения", "");
		Если НайденнаяСтрока <> Неопределено Тогда
			Свойства.ИмяВидаДоступа                       = НайденнаяСтрока.Имя;
			Свойства.ВидДоступаИспользуется               = НайденнаяСтрока.Используется;
			Свойства.ПредставлениеВидаДоступаБезУточнения = НайденнаяСтрока.Представление;
		КонецЕсли;
		МодульУправлениеДоступомСлужебныйПовтИсп = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступомСлужебныйПовтИсп");
		ПредставлениеВидовДоступа = МодульУправлениеДоступомСлужебныйПовтИсп.ПредставлениеВидовДоступа();
		Представление = ПредставлениеВидовДоступа.Получить(ТипЗнч(Свойства.ВидДоступа));
		Если Представление <> Неопределено Тогда
			Свойства.ПредставлениеВидаДоступаБезУточнения = Представление;
		КонецЕсли;
		Кэш.Вставить(ОписаниеИзменения.ВидДоступа, Свойства);
	КонецЕсли;
	
	Свойства.Вставить("ВсеРазрешены",      ИзменениеВидаДоступа.ВсеРазрешены);
	Свойства.Вставить("Предустановленный", ИзменениеВидаДоступа.Предустановленный);
	
	Свойства.Вставить("БылоВсеРазрешены", ?(СтарыеЗначенияСвойств.Свойство("ВсеРазрешены"),
			СтарыеЗначенияСвойств.ВсеРазрешены, Свойства.ВсеРазрешены));
	
	Свойства.Вставить("БылоПредустановленный", БылоПредустановленный);
	
	Если ТипЗнч(Данные.Источник) = Тип("ТаблицаЗначений") Тогда
		ВидИзмененияВидаДоступа = "*";
		
	ИначеЕсли ИзменениеВидаДоступа.ВидИзменения = "Добавлено"
	      Или Не ЭтоГруппаДоступа
	        И Свойства.Предустановленный
	        И Не Свойства.БылоПредустановленный Тогда
		
		ВидИзмененияВидаДоступа = "+";
		
	ИначеЕсли ИзменениеВидаДоступа.ВидИзменения = "Удалено"
	      Или Не ЭтоГруппаДоступа
	        И Не Свойства.Предустановленный
	        И Свойства.БылоПредустановленный Тогда
		
		ВидИзмененияВидаДоступа = "-";
		
	ИначеЕсли Свойства.ВсеРазрешены <> Свойства.БылоВсеРазрешены Тогда
		ВидИзмененияВидаДоступа = "*";
	КонецЕсли;
	
	Свойства.Вставить("ВидИзмененияВидаДоступа", ВидИзмененияВидаДоступа);
	ИзменениеВидаДоступа.Обработано = Истина;
	
	Возврат Свойства;
	
КонецФункции

Функция СвойстваТекущегоЗначения(Значение, Данные, Кэши)
	
	Кэш = Кэши.Получить("СвойстваЗначенийИГруппЗначений");
	Если Кэш = Неопределено Тогда
		Кэш = Новый Соответствие;
		Кэши.Вставить("СвойстваЗначенийИГруппЗначений", Кэш);
	КонецЕсли;
	
	Свойства = Кэш.Получить(Значение);
	Если Свойства = Неопределено Тогда
		НайденнаяСтрока = Данные.ПредставлениеЗначенийДоступа.Найти(Значение, "Значение");
		Свойства = Новый Структура;
		Свойства.Вставить("ЗначениеДоступа", ?(Значение = "*", "*", ДесериализованнаяСсылка(Значение)));
		Свойства.Вставить("ПредставлениеЗначенияДоступа", "");
		Если НайденнаяСтрока <> Неопределено Тогда
			Свойства.ПредставлениеЗначенияДоступа = НайденнаяСтрока.Представление;
		КонецЕсли;
		Кэш.Вставить(Значение, Свойства);
	КонецЕсли;
	
	Возврат Свойства;
	
КонецФункции

Функция ЗначениеВСоставеНеизмененных(ЗначениеСИзменением, ОписаниеИзменения, Данные)
	
	Значение = ЗначениеСИзменением.ЗначениеДоступа;
	
	Отбор = Новый Структура("ГруппаДоступаИлиПрофиль,ВидДоступа,ЗначениеДоступа",
		ОписаниеИзменения.ГруппаДоступаИлиПрофиль, ОписаниеИзменения.ВидДоступа, Значение);
	
	Если ЗначениеЗаполнено(Данные.НеизмененныеЗначения.НайтиСтроки(Отбор)) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Отбор = Новый Структура("ГруппаДоступаИлиПрофиль,ВидДоступа,ЗначениеГруппы",
		ОписаниеИзменения.ГруппаДоступаИлиПрофиль, ОписаниеИзменения.ВидДоступа, Значение);
	
	Если ЗначениеЗаполнено(Данные.НеизмененныеЗначения.НайтиСтроки(Отбор)) Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли