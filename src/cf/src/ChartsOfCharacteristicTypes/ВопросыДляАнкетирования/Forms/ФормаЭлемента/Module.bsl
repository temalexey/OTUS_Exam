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

	УстановитьУсловноеОформление();
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(Объект, ЭтотОбъект);
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(ВариантыОтветов,"Владелец", Объект.Ссылка, ВидСравненияКомпоновкиДанных.Равно, ,Истина);
	
	УстановитьТипОтвета();
	
	Если ТипОтвета = Перечисления.ТипыОтветовНаВопрос.Строка Тогда
		ДлинаСтроки = Объект.Длина;
	КонецЕсли;
	
	Если Объект.Ссылка.Пустая() Тогда
		Объект.ВидПереключателя = Перечисления.ВидыПереключателяВАнкетах.Переключатель;
		Объект.ВидФлажка = Перечисления.ВидыФлажкаВАнкетах.ПолеВвода;
	КонецЕсли;
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПараметрыРазмещения = ПодключаемыеКоманды.ПараметрыРазмещения();
	ПараметрыРазмещения.Источники = Новый ОписаниеТипов("ПланВидовХарактеристикСсылка.ВопросыДляАнкетирования");
	ПараметрыРазмещения.КоманднаяПанель = Элементы.ФормаКоманднаяПанель;
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект, ПараметрыРазмещения);
	
	ПараметрыРазмещения = ПодключаемыеКоманды.ПараметрыРазмещения();
	ПараметрыРазмещения.Источники = Новый ОписаниеТипов("СправочникСсылка.ВариантыОтветовАнкет");
	ПараметрыРазмещения.КоманднаяПанель = Элементы.ТаблицаВариантыОтветовКоманднаяПанель;
	ПараметрыРазмещения.ПрефиксГрупп = "ВариантыОтветовАнкет";
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект, ПараметрыРазмещения);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	НаименованиеДоРедактирования = Объект.Наименование;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Объект.Ссылка.Пустая() Тогда
		ПриИзмененииТипаОтвета();
	КонецЕсли;
	УправлениеВидимостью();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Число") Тогда
		
		Если Объект.МинимальноеЗначение > Объект.МаксимальноеЗначение Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю(
				НСтр("ru = 'Минимально допустимое значение не может быть больше чем максимальное.'"),,
				"Объект.МинимальноеЗначение");
			Отказ = Истина;
		КонецЕсли;
		
		Если Объект.ИспользоватьМинимальноеЗначение И Объект.ИспользоватьМаксимальноеЗначение Тогда
			Если Объект.МинимальноеЗначение = Объект.МаксимальноеЗначение Тогда
				ОбщегоНазначенияКлиент.СообщитьПользователю(
					НСтр("ru = 'Минимально допустимое значение не может быть равно максимальному.'"),,
					"Объект.МинимальноеЗначение");
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
		
		Если Объект.ПоказыватьПолосуРегулирования Тогда
			Если Объект.ШагПолосыРегулирования > Объект.МаксимальноеЗначение - Объект.МинимальноеЗначение Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю(
				НСтр("ru = 'Шаг полосы не может быть больше разницы максимального и минимального значений.'"),,
				"Объект.ШагПолосыРегулирования");
			Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Строка") Тогда	
		
		Объект.Длина = ДлинаСтроки;
		Если ДлинаСтроки = 0 Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Не заполнено значение длины строки.'"),,"ДлинаСтроки");
			Отказ = Истина;
		КонецЕсли;
		
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Текст") Тогда
		
		Объект.Длина = 1024;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ДоступностьТаблицыВариантыОтветов(ЭтотОбъект);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(ВариантыОтветов,
	                                                                        "Владелец",
	                                                                        Объект.Ссылка,
	                                                                        ВидСравненияКомпоновкиДанных.Равно,
	                                                                        ,
	                                                                        Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПодключаемыеКоманды") Тогда
		МодульПодключаемыеКомандыКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ПодключаемыеКомандыКлиент");
		МодульПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, Объект, ПараметрыЗаписи);
	КонецЕсли;
	
	УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ТипОтветаПриИзменении(Элемент)
	
	ПриИзмененииТипаОтвета();
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаВариантыОтветовПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	ОткрытьФормуЭлементаСправочникаВопросыОтветовАнкет(Элемент,Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ТребуетсяКомментарийПриИзменении(Элемент)
	
	ДоступностьНеобходимостьПояснениеКомментария();
	
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	
	Если Объект.Формулировка = НаименованиеДоРедактирования Тогда
	
		Объект.Формулировка = Объект.Наименование;
	
	КонецЕсли;
	
	НаименованиеДоРедактирования = Объект.Наименование;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаВариантыОтветовПередНачаломИзменения(Элемент, Отказ)
	
	Отказ = Истина;
	ОткрытьФормуЭлементаСправочникаВопросыОтветовАнкет(Элемент,Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаВариантыОтветовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ОткрытьФормуЭлементаСправочникаВопросыОтветовАнкет(Элемент,Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ДлинаПриИзменении(Элемент)
	
	УстановитьТочностьВЗависимостиОтДлиныЧисла();
	
	ОтключитьОтметкуНезаполненного();
	
КонецПроцедуры

&НаКлиенте
Процедура ТочностьПриИзменении(Элемент)
	
	УстановитьТочностьВЗависимостиОтДлиныЧисла();
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("РедактированиеФормулировкиПриЗакрытии", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияМногострочногоТекста(ОповещениеОЗакрытии, Элемент.ТекстРедактирования, НСтр("ru = 'Формулировка'"));
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьМинимальноеЗначениеПриИзменении(Элемент) 
	
	Элементы.МинимальноеЗначение.Доступность = Объект.ИспользоватьМинимальноеЗначение;
	
	УстановитьДоступностьНастройкиПолосыРегулирования();
	
КонецПроцедуры 

&НаКлиенте
Процедура ИспользоватьМаксимальноеЗначениеПриИзменении(Элемент)
	
	Элементы.МаксимальноеЗначение.Доступность = Объект.ИспользоватьМаксимальноеЗначение;
	
	УстановитьДоступностьНастройкиПолосыРегулирования();
	УстановитьШагПолосыРегулированияПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура МинимальноеЗначениеПриИзменении(Элемент)
	
	УстановитьШагПолосыРегулированияПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура МаксимальноеЗначениеПриИзменении(Элемент)
	
	УстановитьШагПолосыРегулированияПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьПолосуРегулированияПриИзменении(Элемент)
	
	Элементы.ШагПолосыРегулирования.Доступность = Объект.ПоказыватьПолосуРегулирования;
	
КонецПроцедуры

&НаКлиенте
Процедура ШагПриращенияПолосыРегулированияПриИзменении(Элемент)
	
	УстановитьШагПолосыРегулированияПоУмолчанию();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыводитьПодсказкуУЧисловыхВопросовПриИзменении(Элемент)
	
	УстановитьДоступностьДиапазонаПодсказок();

	Если Объект.ВыводитьПодсказкуУЧисловыхВопросов И Объект.ДиапазонПодсказокЧисловогоВопроса.Количество() = 0 Тогда
		НоваяСтрока = Объект.ДиапазонПодсказокЧисловогоВопроса.Добавить();
		НоваяСтрока.ЗначениеДо = ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса();
	КонецЕсли;
	
	УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса();
	
КонецПроцедуры

&НаКлиенте
Процедура ДиапазонПодсказокПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	ДиапазонПодсказокПрежнееЗначение = Элемент.ТекущиеДанные.ЗначениеДо;
	
	Если Элемент.ТекущийЭлемент = Элементы.ДиапазонПодсказокЗначениеДо Тогда
		Элемент.ТекущиеДанные.ОтключитьУсловноеОформление = Истина
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДиапазонПодсказокПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТекущиеДанные.ОтключитьУсловноеОформление = Ложь;
	
	Если ОтменаРедактирования Тогда
		Если ВернутьЗначениеДиапазону Тогда
			ТекущиеДанные.ЗначениеДо = ДиапазонПодсказокПрежнееЗначение;
			ВернутьЗначениеДиапазону = Ложь;
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	Если Не НоваяСтрока И ДиапазонПодсказокПрежнееЗначение = ТекущиеДанные.ЗначениеДо Тогда
		Возврат;
	КонецЕсли;
		
	ТаблицаДиапазонов = Объект.ДиапазонПодсказокЧисловогоВопроса;
	
	Если Не НоваяСтрока И ДиапазонПодсказокПрежнееЗначение = ТекущиеДанные.ЗначениеДо Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьЗаполнениеДиапазонаПодсказок(ТаблицаДиапазонов, Отказ);
	
	Если Не Отказ Тогда
		УстановитьПозициюДиапазонаПодсказок(ТаблицаДиапазонов, ТекущиеДанные, ТекущиеДанные.ЗначениеДо);
		УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса();
	Иначе
		ВернутьЗначениеДиапазону = Истина;
		
		ОчиститьСообщения();
		Если НоваяСтрока Тогда
			ИмяПоляФормы = СтрШаблон("Объект.ДиапазонПодсказокЧисловогоВопроса[%1]",
				ТаблицаДиапазонов.Индекс(ТекущиеДанные));
		Иначе
			ИмяПоляФормы = СтрШаблон("Объект.ДиапазонПодсказокЧисловогоВопроса[%1].ЗначениеДо",
				ТаблицаДиапазонов.Индекс(ТекущиеДанные));
		КонецЕсли;
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Такое значение уже присутствует в диапазоне подсказок.'"),, ИмяПоляФормы);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДиапазонПодсказокПередУдалением(Элемент, Отказ)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущиеДанные.ЗначениеДо = ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса() Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДиапазонПодсказокПослеУдаления(Элемент)
	УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

// СтандартныеПодсистемы.ПодключаемыеКоманды
// 
// Параметры:
//   Команда - КомандаФормы
// 
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	Если СтрНачинаетсяС(Команда.Имя, "ВариантыОтветовАнкет") Тогда
		ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Элементы.ТаблицаВариантыОтветов);
	Иначе
		ПодключаемыеКомандыКлиент.НачатьВыполнениеКоманды(ЭтотОбъект, Команда, Объект);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПродолжитьВыполнениеКомандыНаСервере(ПараметрыВыполнения, ДополнительныеПараметры) Экспорт
	ВыполнитьКомандуНаСервере(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ВыполнитьКомандуНаСервере(ПараметрыВыполнения)
	Если СтрНачинаетсяС(ПараметрыВыполнения.ИмяКомандыВФорме, "ВариантыОтветовАнкет") Тогда
		ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Элементы.ТаблицаВариантыОтветов);
	Иначе
		ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, ПараметрыВыполнения, Объект);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Элементы.ТаблицаВариантыОтветов);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.Длина.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.Длина");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;

	ГруппаОтбора1 = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаОтбора1.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ТипОтвета");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Перечисления.ТипыОтветовНаВопрос.Строка;

	ОтборЭлемента = ГруппаОтбора1.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ТипОтвета");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Перечисления.ТипыОтветовНаВопрос.Число;

	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

	//

	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ТипОтвета.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ТипОтвета");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Перечисления.ТипыОтветовНаВопрос.ЗначениеИнформационнойБазы;

	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);

	// Текст диапазона подсказки.

	ЭлементУсловногоОформления = УсловноеОформление.Элементы.Добавить();
	
	СвойствоЭлементОформления = ЭлементУсловногоОформления.Оформление.Элементы.Найти("Текст");
	СвойствоЭлементОформления.Значение = Новый ПолеКомпоновкиДанных("Объект.ДиапазонПодсказокЧисловогоВопроса.ЗначениеПредставление");
	СвойствоЭлементОформления.Использование = Истина;
	
	ЭлементОтбораДанных = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ДиапазонПодсказокЧисловогоВопроса.ЗначениеПредставление");
	ЭлементОтбораДанных.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
	ЭлементОтбораДанных.Использование = Истина;
	
	ЭлементОтбораДанных = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ДиапазонПодсказокЧисловогоВопроса.ОтключитьУсловноеОформление");
	ЭлементОтбораДанных.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбораДанных.ПравоеЗначение = Ложь ;
	ЭлементОтбораДанных.Использование = Истина;
	
	ОформляемоеПоле = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("ДиапазонПодсказокЗначениеДо");
	ОформляемоеПоле.Использование = Истина;
	
	// Доступность верхнего диапазона подсказок.
	
	ЭлементУсловногоОформления = УсловноеОформление.Элементы.Добавить();
	
	СвойствоЭлементОформления = ЭлементУсловногоОформления.Оформление.Элементы.Найти("ТолькоПросмотр");
	СвойствоЭлементОформления.Значение = Истина;
	СвойствоЭлементОформления.Использование = Истина;
	
	ЭлементОтбораДанных = ЭлементУсловногоОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ЭлементОтбораДанных.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ДиапазонПодсказокЧисловогоВопроса.ЗначениеДо");
	ЭлементОтбораДанных.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ЭлементОтбораДанных.ПравоеЗначение = ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса();
	ЭлементОтбораДанных.Использование = Истина;
	
	ОформляемоеПоле = ЭлементУсловногоОформления.Поля.Элементы.Добавить();
	ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("ДиапазонПодсказокЗначениеДо");
	ОформляемоеПоле.Использование = Истина;

КонецПроцедуры

&НаКлиенте
Процедура УправлениеВидимостью()
	
	ВозможенКомментарий = НЕ (Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.НесколькоВариантовИз") 
	                        ИЛИ Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Текст"));
	Элементы.ТребуетсяКомментарий.Доступность  = ВозможенКомментарий;
	Элементы.Комментарий.Доступность           = ВозможенКомментарий;
	Если НЕ ВозможенКомментарий Тогда
		Объект.ТребуетсяКомментарий = Ложь;
		Объект.ПояснениеКомментария = "";
	КонецЕсли;
	ДоступностьНеобходимостьПояснениеКомментария();
	
	Если Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Строка") Тогда 
		Элементы.ЗависимыеПараметры.ТекущаяСтраница = Элементы.СтраницаСтрока;
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Число") Тогда
		Элементы.ЗависимыеПараметры.ТекущаяСтраница = Элементы.СтраницаЧисло;
		Элементы.МинимальноеЗначение.Доступность = Объект.ИспользоватьМинимальноеЗначение;
		Элементы.МаксимальноеЗначение.Доступность = Объект.ИспользоватьМаксимальноеЗначение;
		
		УстановитьДоступностьНастройкиПолосыРегулирования();
		УстановитьДоступностьДиапазонаПодсказок();
		УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса();
		
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.ЗначениеИнформационнойБазы") Тогда
		Элементы.ЗависимыеПараметры.ТекущаяСтраница = Элементы.Пустая;
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.ОдинВариантИз") 
	      ИЛИ Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.НесколькоВариантовИз") Тогда
		Элементы.ЗависимыеПараметры.ТекущаяСтраница = Элементы.ВариантыОтветов; 
		ДоступностьТаблицыВариантыОтветов(ЭтотОбъект);
	Иначе
		Элементы.ЗависимыеПараметры.ТекущаяСтраница = Элементы.Пустая;
	КонецЕсли;
	
	Если Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.ОдинВариантИз") Тогда
		Элементы.ГруппаВидПереключателя.ТекущаяСтраница = Элементы.ГруппаВидПереключателяОтображать;
	ИначеЕсли Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Булево") Тогда
		Элементы.ГруппаВидПереключателя.ТекущаяСтраница = Элементы.ГруппаВидОтображенияБулевоОтображать;
	Иначе
		Элементы.ГруппаВидПереключателя.ТекущаяСтраница = Элементы.ГруппаВидПереключателяНеОтображать;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииТипаОтвета()

	Если ТипЗнч(ТипОтвета) = Тип("ПеречислениеСсылка.ТипыОтветовНаВопрос") Тогда
		
		Объект.ТипОтвета = ТипОтвета;
		
	ИначеЕсли ТипЗнч(ТипОтвета) = Тип("ОписаниеТипов") Тогда
		
		Объект.ТипОтвета   = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.ЗначениеИнформационнойБазы");
		Объект.ТипЗначения = ТипОтвета;
		
	КонецЕсли;
	
	УправлениеВидимостью();
	
	Если Объект.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.Число") Тогда
		УстановитьТочностьВЗависимостиОтДлиныЧисла();
	КонецЕсли;

КонецПроцедуры 

&НаКлиенте
Процедура ДоступностьНеобходимостьПояснениеКомментария()
	
	Элементы.ПояснениеКомментария.АвтоОтметкаНезаполненного = Объект.ТребуетсяКомментарий;
	Элементы.ПояснениеКомментария.ТолькоПросмотр            = НЕ Объект.ТребуетсяКомментарий;
	
	ОтключитьОтметкуНезаполненного();
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ДоступностьТаблицыВариантыОтветов(Форма)
	
	Если Форма.Объект.Ссылка.Пустая() Тогда
		Форма.Элементы.ТаблицаВариантыОтветов.ТолькоПросмотр  = Истина;
		Форма.ИнформацияВариантыОтветов                       = НСтр("ru = 'Для редактирования вариантов ответов запишите вопрос для анкетирования'");
	Иначе
		Форма.Элементы.ТаблицаВариантыОтветов.ТолькоПросмотр = Ложь;
		Форма.ИнформацияВариантыОтветов                      = НСтр("ru = 'Варианты ответов на вопрос:'");
	КонецЕсли; 
	
	Если Форма.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.ОдинВариантИз") Тогда
		Форма.Элементы.ТребуетОткрытогоОтвета.Видимость = Ложь;
	ИначеЕсли Форма.ТипОтвета = ПредопределенноеЗначение("Перечисление.ТипыОтветовНаВопрос.НесколькоВариантовИз") Тогда
		Форма.Элементы.ТребуетОткрытогоОтвета.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуЭлементаСправочникаВопросыОтветовАнкет(Элемент,РежимДобавления)
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Владелец",Объект.Ссылка);
	СтруктураПараметров.Вставить("ТипОтвета",Объект.ТипОтвета);
	
	Если Не РежимДобавления Тогда
		ТекущиеДанные = Элементы.ТаблицаВариантыОтветов.ТекущиеДанные;
		Если ТекущиеДанные = Неопределено Тогда
			Возврат;
		КонецЕсли;
		СтруктураПараметров.Вставить("Ключ",ТекущиеДанные.Ссылка);
		СтруктураПараметров.Вставить("Наименование",ТекущиеДанные.Наименование);
	КонецЕсли;
		
	ОткрытьФорму("Справочник.ВариантыОтветовАнкет.ФормаОбъекта", СтруктураПараметров,Элемент);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьТипОтвета()
	
	Для каждого ЗначениеПеречисления Из Метаданные.Перечисления.ТипыОтветовНаВопрос.ЗначенияПеречисления Цикл
		
		Если Перечисления.ТипыОтветовНаВопрос[ЗначениеПеречисления.Имя] = Перечисления.ТипыОтветовНаВопрос.ЗначениеИнформационнойБазы Тогда 
			
			Для каждого ДоступныйТип Из РеквизитФормыВЗначение("Объект").Метаданные().Тип.Типы() Цикл
				
				Если ДоступныйТип = Тип("Строка") ИЛИ ДоступныйТип = Тип("Булево") ИЛИ ДоступныйТип = Тип("Число") ИЛИ ДоступныйТип = Тип("Дата") ИЛИ ДоступныйТип = Тип("СправочникСсылка.ВариантыОтветовАнкет") Тогда
					Продолжить;
				КонецЕсли;
				
				МассивТипов = Новый Массив;
				МассивТипов.Добавить(ДоступныйТип);
				Элементы.ТипОтвета.СписокВыбора.Добавить(Новый ОписаниеТипов(МассивТипов));
				
			КонецЦикла;
			
		Иначе
			Элементы.ТипОтвета.СписокВыбора.Добавить(Перечисления.ТипыОтветовНаВопрос[ЗначениеПеречисления.Имя]);
		КонецЕсли;
		
	КонецЦикла;
	
	Если Объект.ТипОтвета = Перечисления.ТипыОтветовНаВопрос.ЗначениеИнформационнойБазы Тогда
		
		ТипОтвета = Объект.ТипЗначения;
		
	ИначеЕсли Объект.ТипОтвета = Перечисления.ТипыОтветовНаВопрос.ПустаяСсылка() Тогда
		
		ТипОтвета = Элементы.ТипОтвета.СписокВыбора[0].Значение;
		
	Иначе
		
		ТипОтвета = Объект.ТипОтвета;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьТочностьВЗависимостиОтДлиныЧисла()

	Если Объект.Длина > 15 Тогда
		Объект.Длина = 15;
	КонецЕсли;
	
	Если Объект.Длина = 0 Тогда
		Объект.Точность = 0;
	ИначеЕсли Объект.Длина <= Объект.Точность Тогда
		Объект.Точность = Объект.Длина - 1;
	КонецЕсли;
	
	Если Объект.Точность > 3 Тогда
		Объект.Точность = 3;
	КонецЕсли;
	
	Если (Объект.Длина - Объект.Точность) > 12 Тогда
		Объект.Длина = Объект.Точность + 12;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РедактированиеФормулировкиПриЗакрытии(ТекстВозврата, ДополнительныеПараметры) Экспорт
	
	Если Объект.Формулировка <> ТекстВозврата Тогда
		Объект.Формулировка = ТекстВозврата;
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьНастройкиПолосыРегулирования()
	
	Элементы.ПоказыватьПолосуРегулирования.Доступность = Объект.ИспользоватьМинимальноеЗначение
		И Объект.ИспользоватьМаксимальноеЗначение;
	Элементы.ШагПолосыРегулирования.Доступность = Объект.ПоказыватьПолосуРегулирования;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьШагПолосыРегулированияПоУмолчанию()
	
	Если Не Объект.ПоказыватьПолосуРегулирования Тогда
		Возврат;
	КонецЕсли;
	
	// Если шаг полосы не кратен разницы максимального и минимальных значений, то устанавливаем шаг = 1
	ДлинаПолосы = (Объект.МаксимальноеЗначение - Объект.МинимальноеЗначение) / Объект.ШагПолосыРегулирования;
	Если ДлинаПолосы <> Цел(ДлинаПолосы) Тогда
		Объект.ШагПолосыРегулирования = 1;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьДиапазонаПодсказок()
	
	Элементы.ДиапазонПодсказок.Доступность = Объект.ВыводитьПодсказкуУЧисловыхВопросов;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса()
	Возврат 9999999999999.99;
КонецФункции

&НаКлиенте
Процедура УстановитьПредставлениеДиапазонаПодсказокЧисловогоВопроса()
	
	ТаблицаДиапазонов = Объект.ДиапазонПодсказокЧисловогоВопроса;
	
	Для Каждого ТекущаяСтрока Из ТаблицаДиапазонов Цикл
		ТекущийИндекс = Объект.ДиапазонПодсказокЧисловогоВопроса.Индекс(ТекущаяСтрока);
		Если ТекущаяСтрока.ЗначениеДо = ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса() Тогда
			Если ТекущийИндекс = 0 Тогда
				ТекущаяСтрока.ЗначениеПредставление = НСтр("ru = 'любое значение'");
				Продолжить;
			КонецЕсли;
			ПредыдущаяСтрока = ТаблицаДиапазонов[ТекущийИндекс - 1];
			Если ПредыдущаяСтрока.ЗначениеДо = ЗначениеПорогаДиапазонаПодсказокЧисловогоВопроса() Тогда
				ТекущаяСтрока.ЗначениеПредставление = ПредыдущаяСтрока.ЗначениеПредставление;
			Иначе
				ТекущаяСтрока.ЗначениеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'более %1'"), Строка(ПредыдущаяСтрока.ЗначениеДо));
			КонецЕсли;
		Иначе
			Если ТекущийИндекс = 0 Тогда
				ТекущаяСтрока.ЗначениеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = '%1 и менее'"), Строка(ТекущаяСтрока.ЗначениеДо));
					Продолжить;
			КонецЕсли;
			ПредыдущаяСтрока = ТаблицаДиапазонов[ТекущийИндекс - 1];
			Если ПредыдущаяСтрока.ЗначениеДо = ТекущаяСтрока.ЗначениеДо Тогда
				ТекущаяСтрока.ЗначениеПредставление = ПредыдущаяСтрока.ЗначениеПредставление;
			Иначе
				ТекущаяСтрока.ЗначениеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'от %1 до %2'"), 
					Строка(ПредыдущаяСтрока.ЗначениеДо), 
					Строка(ТекущаяСтрока.ЗначениеДо));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьЗаполнениеДиапазонаПодсказок(ТаблицаДиапазонов, Отказ)
	
	МассивЗначений = Новый Массив;
	
	Для Каждого ТекущаяСтрока Из ТаблицаДиапазонов Цикл
		Если МассивЗначений.Найти(ТекущаяСтрока.ЗначениеДо) <> Неопределено Тогда
			Отказ = Истина;
			Возврат;
		КонецЕсли;
		МассивЗначений.Добавить(ТекущаяСтрока.ЗначениеДо);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьПозициюДиапазонаПодсказок(ТаблицаДиапазонов, ТекущиеДанные, ЗначениеЭлемента)
	
	КоличествоЭлементов = ТаблицаДиапазонов.Количество();
	
	Если КоличествоЭлементов <= 1 Тогда
		Возврат;
	КонецЕсли;
	
	ТекущаяПозиция = ТаблицаДиапазонов.Индекс(ТекущиеДанные);
	
	МестоПозицииНайдено = Ложь;
	Для Каждого ЭлементКоллекции Из ТаблицаДиапазонов Цикл
		
		ТекущийИндекс = ТаблицаДиапазонов.Индекс(ЭлементКоллекции);
		ЭтоПоследнийЭлемент = ?(КоличествоЭлементов = ТекущийИндекс + 1, Истина, Ложь);
		
		Если Не ЭтоПоследнийЭлемент Тогда
			НоваяПозиция = ТекущийИндекс;
		КонецЕсли;
		
		НайденЭлементСБольшимЗначением = ?(ЭлементКоллекции.ЗначениеДо > ЗначениеЭлемента, Истина, Ложь);
		
		Если НайденЭлементСБольшимЗначением Тогда
			МестоПозицииНайдено = Истина;
		КонецЕсли;
		
		Если МестоПозицииНайдено Тогда
			Если НоваяПозиция > ТекущаяПозиция Тогда
				НоваяПозиция = НоваяПозиция - 1;
			КонецЕсли;
			Прервать;
		КонецЕсли
		
	КонецЦикла;
	
	Сдвиг = НоваяПозиция - ТекущаяПозиция;
	ТаблицаДиапазонов.Сдвинуть(ТекущаяПозиция, Сдвиг);
	
КонецПроцедуры

#КонецОбласти
