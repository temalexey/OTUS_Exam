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
	
	ЗаполнитьСведенияОбОрганизации(ЭтотОбъект, Параметры.СведенияОбОрганизации);
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		
		МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
		
		ВидКонтактнойИнформацииТелефон = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации(
			Перечисления["ТипыКонтактнойИнформации"].Телефон);
		
	КонецЕсли;
		
	Если Параметры.ТолькоПросмотр Тогда
		Элементы.ВсеЭлементы.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	СтандартныеПодсистемыСервер.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Не Модифицированность Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	СтандартнаяОбработка = Ложь;
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия <> "ИзменениеОрганизацииВЗаявленииНаВыпускСертификата" Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	ЗаполнитьСведенияОбОрганизации(ЭтотОбъект, Параметр);
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РеквизитПриИзменении(Элемент)
	
	Модифицированность = Истина;
	ЭтотОбъект[Элемент.Имя] = СокрЛП(ЭтотОбъект[Элемент.Имя]);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭтоИндивидуальныйПредпринимательПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ЭтоИндивидуальныйПредприниматель Тогда
		КПП = Неопределено;
		ЭтоИностраннаяОрганизация = Ложь;
	КонецЕсли;
	
	Элементы.ЭтоИностраннаяОрганизация.Видимость = Не ЭтоИндивидуальныйПредприниматель;
	Элементы.КПП.Видимость = Не ЭтоИндивидуальныйПредприниматель;
	
	ЭтоИностраннаяОрганизацияПриИзменении(Элементы.ЭтоИностраннаяОрганизация);
	
КонецПроцедуры

&НаКлиенте
Процедура ЭтоИностраннаяОрганизацияПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ЭтоИностраннаяОрганизация Тогда
		ОГРН = Неопределено;
	КонецЕсли;
	
	Элементы.ОГРН.Видимость = Не ЭтоИностраннаяОрганизация;
	
КонецПроцедуры


&НаКлиенте
Процедура ТелефонНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПредставлениеТелефонаНачалоВыбора(ЭтотОбъект, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		"Телефон", НСтр("ru = 'Телефон организации'"));
	
КонецПроцедуры

&НаКлиенте
Процедура ТелефонОчистка(Элемент, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	ПредставлениеТелефонаОчистка(ЭтотОбъект, Элемент, СтандартнаяОбработка, "Телефон");
	
КонецПроцедуры

&НаКлиенте
Процедура ТелефонОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	ПредставлениеТелефонаОбработкаВыбора(ЭтотОбъект, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, "Телефон");
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	СохранитьИзмененияИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСведенияОбОрганизации(Форма, СведенияОбОрганизации)
	
	ЗаполнитьЗначенияСвойств(Форма, СведенияОбОрганизации);
	Форма.СведенияОбОрганизации = СведенияОбОрганизации;
	
	Форма.Элементы.КПП.Видимость = Не Форма.ЭтоИндивидуальныйПредприниматель;
	Форма.Элементы.ЭтоИностраннаяОрганизация.Видимость = Не Форма.ЭтоИндивидуальныйПредприниматель;
	Форма.Элементы.ОГРН.Видимость = Не Форма.ЭтоИностраннаяОрганизация;
	Форма.Модифицированность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗадатьВопросПередЗакрытием()
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	ПоказатьВопрос(Новый ОписаниеОповещения("ЗакрытиеПослеОтветаНаВопрос", ЭтотОбъект),
		НСтр("ru = 'Данные были изменены. Сохранить изменения?'"), РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеПослеОтветаНаВопрос(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть(Неопределено);
	ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
		СохранитьИзмененияИЗакрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьИзмененияИЗакрыть()
	
	ОчиститьСообщения();
	
	Если Не ПроверитьСведенияОбОрганизации() Тогда
		Если Не Элементы.ВсеЭлементы.ТолькоПросмотр Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("СохранениеПослеОтветаНаВопрос", ЭтотОбъект),
				НСтр("ru = 'Есть ошибки. Все равно сохранить изменения?'"),
				РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	СохранениеПослеОтветаНаВопрос(КодВозвратаДиалога.Да, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранениеПослеОтветаНаВопрос(Ответ, Контекст) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(СведенияОбОрганизации, ЭтотОбъект);
	
	СведенияОбОрганизации.Телефон = ТелефонXML;
	СведенияОбОрганизации.ЮридическийАдрес = ЮридическийАдресXML;
	
	Модифицированность = Ложь;
	Закрыть(СведенияОбОрганизации);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаНачалоВыбора(Форма, Элемент, ДанныеВыбора, СтандартнаяОбработка, ИмяРеквизита, ЗаголовокФормы)
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеКонтактнойИнформациейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль(
		"УправлениеКонтактнойИнформациейКлиент");
	
	ПараметрыФормы = МодульУправлениеКонтактнойИнформациейКлиент.ПараметрыФормыКонтактнойИнформации(
		ВидКонтактнойИнформацииТелефон, ЭтотОбъект[ИмяРеквизита + "XML"], ЭтотОбъект[ИмяРеквизита]);
	
	ПараметрыФормы.Вставить("Заголовок", ЗаголовокФормы);
	
	МодульУправлениеКонтактнойИнформациейКлиент.ОткрытьФормуКонтактнойИнформации(ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаОчистка(Форма, Элемент, СтандартнаяОбработка, ИмяРеквизита)
	
	Форма[ИмяРеквизита + "XML"] = "";
	Форма[ИмяРеквизита] = "";
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, ИмяРеквизита)
	
	СтандартнаяОбработка = Ложь;
	Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
		// Данные не изменены.
		Возврат;
	КонецЕсли;
	
	Форма[ИмяРеквизита + "XML"] = ВыбранноеЗначение.КонтактнаяИнформация;
	Форма[ИмяРеквизита] = ВыбранноеЗначение.Представление;
	
КонецПроцедуры

&НаСервере
Функция ПроверитьСведенияОбОрганизации()
	
	ОбработкаМодуль = Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата;
	
	ПроверяемыеРеквизиты = Новый Массив;
	ОбработкаМодуль.ДобавитьРеквизитыДляПроверки(ЭтотОбъект,
		ПроверяемыеРеквизиты, ОбработкаМодуль.РеквизитыОрганизации(ЭтотОбъект));
	
	Возврат Не Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ПроверитьЗаполнениеРеквизитов(
		ЭтотОбъект, ПроверяемыеРеквизиты, ЭтоИндивидуальныйПредприниматель, Ложь, Ложь);
	
КонецФункции

#КонецОбласти