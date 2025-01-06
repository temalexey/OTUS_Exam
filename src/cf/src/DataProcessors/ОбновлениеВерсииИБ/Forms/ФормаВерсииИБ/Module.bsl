///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НаборЗаписейВерсии = РегистрыСведений.ВерсииПодсистем.СоздатьНаборЗаписей();
	НаборЗаписейВерсии.Прочитать();
	ЗначениеВРеквизитФормы(НаборЗаписейВерсии, "Версии");
	
	Если ОбщегоНазначения.РазделениеВключено()
		И ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
		Элементы.КомандыСписка.Видимость = Ложь;
		
		РегистрВерсииПодсистемОбластейДанных = "ВерсииПодсистемОбластейДанных";
		НаборЗаписейВерсииОбластей = РегистрыСведений[РегистрВерсииПодсистемОбластейДанных].СоздатьНаборЗаписей();
		НаборЗаписейВерсииОбластей.Прочитать();
		ЗначениеВРеквизитФормы(НаборЗаписейВерсииОбластей, "ВерсииОбластей");
		
		МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
		СеансЗапущенБезРазделителей = МодульРаботаВМоделиСервиса.СеансЗапущенБезРазделителей();
		
		Если НЕ СеансЗапущенБезРазделителей Тогда
			Элементы.Версии.ТолькоПросмотр = Истина;
		КонецЕсли;
	Иначе
		Элементы.ВерсииПодсистем.ОтображениеСтраниц = ОтображениеСтраницФормы.Нет;
		Элементы.Версии.ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиЭлементаФормы.Нет;
	КонецЕсли;
	
	ТекстПодсказки = НСтр("ru = 'Важно. Ошибка будет воспроизводиться до перезапуска обновления.
		|Имитация ошибки заполнения свойства %1.
		|См. процедуру %2 документа %3.'");
	ТекстПодсказки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстПодсказки, "ПараметрыВыборки",
		"ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию", "_ДемоЗаказПокупателя");
	Элементы.ИмитироватьНекорректныеПараметрыВыборки.Подсказка = ТекстПодсказки;
	
	ИмитироватьОшибкуПриОбновлении = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ИмитироватьОшибкуПриОбновлении", Ложь);
	МонопольноеОбновление = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ВыполнятьМонопольноеОбновление", Ложь);
	ИмитироватьОшибкуПриОтложенномОбновлении = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ИмитироватьОшибкуПриОтложенномОбновлении", Ложь);
	ИмитироватьОшибкуПриОтложенномПараллельномОбновлении = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ИмитироватьОшибкуПриОтложенномПараллельномОбновлении", Ложь);
	ИмитироватьПроблемуСОбработчикомИДанными = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ИмитироватьПроблемыСДаннымиИОбработчиком", Ложь);
	ПаузаПриВыполненииОбработчика = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ПаузаПриВыполненииОбработчика", 0);
	ИмитироватьНекорректныеПараметрыВыборки = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОбновлениеИБ", "ИмитироватьОшибкуВПараметрахВыборки", Ложь);
	
	ПутьКФормам = РеквизитФормыВЗначение("Объект").Метаданные().ПолноеИмя() + ".Форма";
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если СтрНайти(ПараметрЗапуска, "ЗапуститьОбновлениеИнформационнойБазы") > 0 Тогда
		ЗапуститьОбновлениеИнформационнойБазы = Истина;
		Элементы.ЗапуститьОбновлениеИнформационнойБазы.ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ВыбратьИЗакрыть", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыВерсии

&НаКлиенте
Процедура ВерсииПриИзменении(Элемент)
	
	ВерсииОбщихДанныхИзменены = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыВерсииОбластей

&НаКлиенте
Процедура ВерсииОбластейПриИзменении(Элемент)
	
	ВерсииОбластейДанныхИзменены = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьВсе(Команда)
	
	ЗаписатьВсеНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезапуститьПрограмму(Команда)
	
	Оповещение = Новый ОписаниеОповещения("ПерезапуститьПрограммуЗавершение", ЭтотОбъект);
	ПоказатьВопрос(Оповещение, НСтр("ru = 'Перезапустить приложение?'"), РежимДиалогаВопрос.ОКОтмена);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьИЗакрыть(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	ЗаписатьВсеНаСервере();
	Закрыть();
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьВсеНаСервере()
	
	Если НЕ Модифицированность Тогда
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ВыполнятьМонопольноеОбновление", МонопольноеОбновление);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ИмитироватьОшибкуПриОбновлении", ИмитироватьОшибкуПриОбновлении);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ИмитироватьОшибкуПриОтложенномОбновлении", ИмитироватьОшибкуПриОтложенномОбновлении);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ИмитироватьОшибкуПриОтложенномПараллельномОбновлении", ИмитироватьОшибкуПриОтложенномПараллельномОбновлении);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ИмитироватьПроблемыСДаннымиИОбработчиком", ИмитироватьПроблемуСОбработчикомИДанными);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ПаузаПриВыполненииОбработчика", ПаузаПриВыполненииОбработчика);
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
			"ИмитироватьОшибкуВПараметрахВыборки", ИмитироватьНекорректныеПараметрыВыборки);
		Возврат;
	КонецЕсли;
	
	Отбор = Новый Структура("ИмяПодсистемы", Метаданные.Имя);
	
	ВерсияКонфигурации = Неопределено;
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		
		Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса.БазоваяФункциональность") Тогда
			МодульРаботаВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль("РаботаВМоделиСервиса");
			СеансЗапущенБезРазделителей = МодульРаботаВМоделиСервиса.СеансЗапущенБезРазделителей();
		Иначе
			СеансЗапущенБезРазделителей = Истина;
		КонецЕсли;
		
		Если СеансЗапущенБезРазделителей
		   И ВерсииОбщихДанныхИзменены Тогда
			
			ВерсияКонфигурации = Версии.НайтиСтроки(Отбор);
			РеквизитФормыВЗначение("Версии").Записать();
		КонецЕсли;
		
		Если ВерсииОбластейДанныхИзменены Тогда
			ВерсияКонфигурации = ВерсииОбластей.НайтиСтроки(Отбор);
			РеквизитФормыВЗначение("ВерсииОбластей").Записать();
		КонецЕсли;
	Иначе
		Если ВерсииОбщихДанныхИзменены Тогда
			ВерсияКонфигурации = Версии.НайтиСтроки(Отбор);
			РеквизитФормыВЗначение("Версии").Записать();
		КонецЕсли;
	КонецЕсли;
	
	Если ВерсияКонфигурации <> Неопределено
		И ВерсияКонфигурации.Количество() <> 0 Тогда
		Версия = ВерсияКонфигурации[0].Версия;
		Отбор = Новый Структура;
		Отбор.Вставить("КлючОбъекта", "ОбновлениеИБ");
		Отбор.Вставить("КлючНастроек", "ПоследняяВерсияОтображенияИзмененийСистемы");
		
		Выборка = ХранилищеОбщихНастроек.Выбрать(Отбор);
		
		Пока Выборка.Следующий() Цикл
			ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
				"ПоследняяВерсияОтображенияИзмененийСистемы", Версия, , Выборка.Пользователь);
		КонецЦикла;
		
	КонецЕсли;
	
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ВыполнятьМонопольноеОбновление", МонопольноеОбновление);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ИмитироватьОшибкуПриОбновлении", ИмитироватьОшибкуПриОбновлении);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ИмитироватьОшибкуПриОтложенномОбновлении", ИмитироватьОшибкуПриОтложенномОбновлении);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ИмитироватьОшибкуПриОтложенномПараллельномОбновлении", ИмитироватьОшибкуПриОтложенномПараллельномОбновлении);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ИмитироватьПроблемыСДаннымиИОбработчиком", ИмитироватьПроблемуСОбработчикомИДанными);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ПаузаПриВыполненииОбработчика", ПаузаПриВыполненииОбработчика);
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбновлениеИБ",
		"ИмитироватьОшибкуВПараметрахВыборки", ИмитироватьНекорректныеПараметрыВыборки);
	
	Если ВерсииОбщихДанныхИзменены Тогда
		СведенияОбОбновлении = ОбновлениеИнформационнойБазыСлужебный.СведенияОбОбновленииИнформационнойБазы();
		СведенияОбОбновлении.ЛегальнаяВерсия = "";
		ОбновлениеИнформационнойБазыСлужебный.ЗаписатьСведенияОбОбновленииИнформационнойБазы(СведенияОбОбновлении);
	КонецЕсли;
	
	Модифицированность           = Ложь;
	ВерсииОбщихДанныхИзменены    = Ложь;
	ВерсииОбластейДанныхИзменены = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезапуститьПрограммуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> КодВозвратаДиалога.ОК Тогда
		Возврат;
	КонецЕсли;
	
	НовыйПараметрЗапуска = СтрЗаменить(ПараметрЗапуска, """", """""");
	
	Если НЕ ЗапуститьОбновлениеИнформационнойБазы
	 ИЛИ СтрНайти(ПараметрЗапуска, "ЗапуститьОбновлениеИнформационнойБазы") > 0 Тогда
		
		ДополнительныеПараметрыКоманднойСтроки = "/C """ + НовыйПараметрЗапуска + """";
	Иначе
		ДополнительныеПараметрыКоманднойСтроки = "/C """ + НовыйПараметрЗапуска
			+ ?(Прав(ПараметрЗапуска, 1) = ";", "", ";") + "ЗапуститьОбновлениеИнформационнойБазы""";
	КонецЕсли;
	
	ЗавершитьРаботуСистемы(Истина, Истина, ДополнительныеПараметрыКоманднойСтроки);
	
КонецПроцедуры

#КонецОбласти
