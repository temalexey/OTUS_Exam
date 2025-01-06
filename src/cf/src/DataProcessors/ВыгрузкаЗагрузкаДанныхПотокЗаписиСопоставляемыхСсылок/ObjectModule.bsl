#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем ТекущийКонтейнер; // ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера
Перем ТекущееИмяКолонкиСИсходнойСсылкой;
Перем ТекущиеСсылки;
Перем ТекущийСериализатор;
Перем ТекущийОбъектМетаданных;
Перем ПредыдущаяСсылка;
Перем ПредыдущийОбъектМетаданных;

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Инициализировать.
// 
// Параметры:
//  Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера
//  Сериализатор - СериализаторXDTO
//  ПараметрыИнициализации - см. ПолучитьПараметрыИнициализацииВПотоке
Процедура Инициализировать(Контейнер, Сериализатор, ПараметрыИнициализации = Неопределено) Экспорт
	
	ТекущийКонтейнер = Контейнер;
	ТекущийСериализатор = Сериализатор;
	
	ТекущееИмяКолонкиСИсходнойСсылкой = ?(ТекущийКонтейнер.ЭтоДочернийПоток(),
		ПараметрыИнициализации.ИмяКолонкиСИсходнойСсылкой,
		НовоеИмяКолонкиИсходныхСсылок());
	
КонецПроцедуры

Процедура СопоставитьСсылкуПриЗагрузке(Знач Ссылка, Знач ЕстественныйКлюч) Экспорт
	
	Если Ссылка.Метаданные() <> ПредыдущийОбъектМетаданных Тогда
		ПриСменеОбъектаМетаданных(Ссылка.Метаданные());
	КонецЕсли;
	
	Если Ссылка = ПредыдущаяСсылка Тогда
		
		СопоставляемаяСсылка = ТекущиеСсылки.Найти(Ссылка, ТекущееИмяКолонкиСИсходнойСсылкой);
		
	Иначе
		
		Если ТекущиеСсылки.Количество() > ЛимитСсылокВФайле() Тогда
			ЗаписатьСопоставляемыеСсылки();
		КонецЕсли;
		
		СопоставляемаяСсылка = ТекущиеСсылки.Добавить();
		
	КонецЕсли;
	
	СопоставляемаяСсылка[ТекущееИмяКолонкиСИсходнойСсылкой] = Ссылка;
	Для Каждого КлючИЗначение Из ЕстественныйКлюч Цикл
		
		Если ТекущиеСсылки.Колонки.Найти(КлючИЗначение.Ключ) = Неопределено Тогда
			
			МассивТипов = Новый Массив();
			МассивТипов.Добавить(ТипЗнч(КлючИЗначение.Значение));
			ОписаниеТипов = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыСтроки(1024));
			
			ТекущиеСсылки.Колонки.Добавить(КлючИЗначение.Ключ, ОписаниеТипов);
			
		КонецЕсли;
		
		СопоставляемаяСсылка[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
		
	КонецЦикла;
	
	ПредыдущаяСсылка = Ссылка;
	
КонецПроцедуры

Процедура Закрыть() Экспорт
	
	ЗаписатьСопоставляемыеСсылки();
	
	Если Не ТекущийКонтейнер.ЭтоДочернийПоток() Тогда
		ЗаписатьИмяКолонкиИсходныхСсылок();
	КонецЕсли;
	
КонецПроцедуры

// Получить параметры инициализации в потоке.
// 
// Возвращаемое значение:
//  ФиксированнаяСтруктура - Получить параметры инициализации в потоке:
// * ИмяКолонкиСИсходнойСсылкой - Строка 
Функция ПолучитьПараметрыИнициализацииВПотоке() Экспорт
	
	ПараметрыИнициализации = Новый Структура();
	ПараметрыИнициализации.Вставить("ИмяКолонкиСИсходнойСсылкой", ТекущееИмяКолонкиСИсходнойСсылкой);
	
	Возврат Новый ФиксированнаяСтруктура(ПараметрыИнициализации);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПриСменеОбъектаМетаданных(Знач НовыйОбъектМетаданных)
	
	Если ТекущийОбъектМетаданных <> Неопределено Тогда
		ЗаписатьСопоставляемыеСсылки();
	КонецЕсли;
	
	ПредыдущийОбъектМетаданных = ТекущийОбъектМетаданных;
	ТекущийОбъектМетаданных = НовыйОбъектМетаданных;
	
	ЗаполнитьКолонкиТаблицыИсходныхСсылок();
	
	ПредыдущаяСсылка = Неопределено;
	
КонецПроцедуры

Процедура ЗаполнитьКолонкиТаблицыИсходныхСсылок()
	
	ТекущиеСсылки = Новый ТаблицаЗначений();
	ТекущиеСсылки.Колонки.Добавить(ТекущееИмяКолонкиСИсходнойСсылкой, ОбщегоНазначенияБТСПовтИсп.ОписаниеСсылочныхТипов());
	
	ТипыОбщихДанных = ВыгрузкаЗагрузкаДанныхСлужебныйСобытия.ПолучитьТипыОбщихДанныхПоддерживающиеСопоставлениеСсылокПриЗагрузке();
	Если ТипыОбщихДанных.Найти(ТекущийОбъектМетаданных) <> Неопределено Тогда
		ПоляЕстественногоКлюча = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ТекущийОбъектМетаданных.ПолноеИмя()).ПоляЕстественногоКлюча();
		Для Каждого ПолеЕстественногоКлюча Из ПоляЕстественногоКлюча Цикл
			ОписаниеТиповПоля = ОписаниеТиповПоляОбъекта(ТекущийОбъектМетаданных, ПолеЕстественногоКлюча);
			ТолькоСсылочныеТипы = Истина;
			Для Каждого ВозможныйТип Из ОписаниеТиповПоля.Типы() Цикл
				Если ОбщегоНазначенияБТС.ЭтоПримитивныйТип(ВозможныйТип) ИЛИ ВозможныйТип = Тип("ХранилищеЗначения") Тогда
					ТолькоСсылочныеТипы = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если ТолькоСсылочныеТипы Тогда
				ОписаниеТиповПоля = ОбщегоНазначенияБТСПовтИсп.ОписаниеСсылочныхТипов();
			КонецЕсли;
			ТекущиеСсылки.Колонки.Добавить(ПолеЕстественногоКлюча, ОписаниеТиповПоля);
		КонецЦикла;
	КонецЕсли;
	
	ТекущиеСсылки.Индексы.Добавить(ТекущееИмяКолонкиСИсходнойСсылкой);
	
КонецПроцедуры

// Возвращает ОписаниеТипов для реквизита объекта метаданного.
//
// Параметры:
//	ОбъектМетаданных - ОбъектМетаданных - объект метаданных.
//	ИмяПоля - Строка - имя реквизита.
//
// Возвращаемое значение:
//	ОписаниеТипов - описание типов реквизита.
//
Функция ОписаниеТиповПоляОбъекта(ОбъектМетаданных, ИмяПоля)
	
	// Проверка для стандартных реквизитов
	Для Каждого СтандартныйРеквизит Из ОбъектМетаданных.СтандартныеРеквизиты Цикл 
		
		Если СтандартныйРеквизит.Имя = ИмяПоля Тогда 
			 Возврат СтандартныйРеквизит.Тип;
		КонецЕсли;
		
	КонецЦикла;
	
	// Проверка для реквизитов
	Для Каждого Реквизит Из ОбъектМетаданных.Реквизиты Цикл 
		
		Если Реквизит.Имя = ИмяПоля Тогда 
			 Возврат Реквизит.Тип;
		КонецЕсли;
		
	КонецЦикла;
	
	// Проверка для общих реквизитов
	КоличествоОбщихРеквизитов = Метаданные.ОбщиеРеквизиты.Количество();
	Для Итерация = 0 По КоличествоОбщихРеквизитов - 1 Цикл 
		
		ОбщийРеквизит = Метаданные.ОбщиеРеквизиты.Получить(Итерация);
		Если ОбщийРеквизит.Имя <> ИмяПоля Тогда 
			
			Продолжить;
			
		КонецЕсли;
		
		СоставОбщегоРеквизита = ОбщийРеквизит.Состав;
		НайденныйОбщийРеквизит = СоставОбщегоРеквизита.Найти(ОбъектМетаданных);
		Если НайденныйОбщийРеквизит <> Неопределено Тогда 
			
			Возврат ОбщийРеквизит.Тип;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ВызватьИсключение СтрШаблон(НСтр("ru='Не определен тип поля %1 объекта %2.'"), 
		ИмяПоля, ОбъектМетаданных.ПолноеИмя());
	
КонецФункции

Функция ЛимитСсылокВФайле()
	
	Возврат 17000;
	
КонецФункции

// Новое имя колонки исходных ссылок.
// 
// Возвращаемое значение:
//  Строка - Новое имя колонки исходных ссылок
Функция НовоеИмяКолонкиИсходныхСсылок()
	
	ИмяКолонки = Новый УникальныйИдентификатор();
	ИмяКолонки = Строка(ИмяКолонки);
	ИмяКолонки = "а" + СтрЗаменить(ИмяКолонки, "-", "");
	
	Возврат ИмяКолонки;
	
КонецФункции

Процедура ЗаписатьИмяКолонкиИсходныхСсылок()
	
	ИмяФайла = ТекущийКонтейнер.СоздатьПроизвольныйФайл("xml", ВыгрузкаЗагрузкаДанныхСлужебный.ТипДанныхДляИмениКолонкиТаблицыЗначений());
	ВыгрузкаЗагрузкаДанных.ЗаписатьОбъектВФайл(ТекущееИмяКолонкиСИсходнойСсылкой, ИмяФайла);
	
КонецПроцедуры

Процедура ЗаписатьСопоставляемыеСсылки()
	
	Если ТекущиеСсылки = Неопределено
		ИЛИ ТекущиеСсылки.Количество() = 0 Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ИмяФайла = ТекущийКонтейнер.СоздатьФайл(ВыгрузкаЗагрузкаДанныхСлужебный.ReferenceMapping(), ТекущийОбъектМетаданных.ПолноеИмя());
	ВыгрузкаЗагрузкаДанных.ЗаписатьОбъектВФайл(ТекущиеСсылки, ИмяФайла, ТекущийСериализатор);
	
	ТекущиеСсылки.Очистить();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
