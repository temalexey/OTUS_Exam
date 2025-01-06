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
	Если Не УправлениеИтогамиИАгрегатамиСлужебный.НадоСдвинутьГраницуИтогов() Тогда
		Отказ = Истина; // Период уже был установлен в сеансе другого пользователя.
		Возврат;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДлительнаяОперация = ДлительнаяОперацияЗапускСервер(УникальныйИдентификатор);
	
	НастройкиОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	НастройкиОжидания.ВыводитьОкноОжидания = Ложь;
	
	Обработчик = Новый ОписаниеОповещения("ДлительнаяОперацияЗавершениеКлиент", ЭтотОбъект);
	
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, Обработчик, НастройкиОжидания);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ДлительнаяОперацияЗапускСервер(УникальныйИдентификатор)
	ИмяМетода = "Обработки.СдвигГраницыИтогов.ВыполнитьКоманду";
	
	НастройкиЗапуска = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	НастройкиЗапуска.НаименованиеФоновогоЗадания = НСтр("ru = 'Итоги и агрегаты: Ускорение проведения документов и формирования отчетов'");
	НастройкиЗапуска.ОжидатьЗавершение = 0;
	
	Возврат ДлительныеОперации.ВыполнитьВФоне(ИмяМетода, Неопределено, НастройкиЗапуска);
КонецФункции

// Параметры:
//  Результат - см. ДлительныеОперацииКлиент.НовыйРезультатДлительнойОперации
//  ДополнительныеПараметры - Неопределено
//
&НаКлиенте
Процедура ДлительнаяОперацияЗавершениеКлиент(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		ДлительнаяОперацияПослеВыводаРезультата(Ложь);
		Возврат;
	КонецЕсли;
	Если Результат.Статус = "Выполнено" Тогда
		ПоказатьОповещениеПользователя(НСтр("ru = 'Оптимизация успешно завершена'"),,, БиблиотекаКартинок.Успешно32);
		ДлительнаяОперацияПослеВыводаРезультата(Истина);
	Иначе
		СтандартныеПодсистемыКлиент.ВывестиИнформациюОбОшибке(
			Результат.ИнформацияОбОшибке);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДлительнаяОперацияПослеВыводаРезультата(Результат)
	Если ОписаниеОповещенияОЗакрытии <> Неопределено Тогда
		ВыполнитьОбработкуОповещения(ОписаниеОповещенияОЗакрытии, Результат); // Обход особенности вызова из ПриОткрытии.
	КонецЕсли;
	Если Открыта() Тогда
		Закрыть(Результат);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти