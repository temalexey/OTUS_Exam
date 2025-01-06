///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Движения.ОтветыНаВопросыАнкет.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ТаблицаСостав.Вопрос,
	|	ТаблицаСостав.ЭлементарныйВопрос,
	|	ТаблицаСостав.НомерЯчейки,
	|	ТаблицаСостав.Ответ,
	|	ТаблицаСостав.ОткрытыйОтвет,
	|	ТаблицаСостав.НомерСтроки,
	|	ТаблицаСостав.БезОтвета КАК БезОтвета
	|ПОМЕСТИТЬ Состав
	|ИЗ
	|	&ТаблицаСостав КАК ТаблицаСостав
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Состав.Вопрос,
	|	Состав.ЭлементарныйВопрос,
	|	Состав.НомерЯчейки,
	|	ВЫБОР
	|		КОГДА НЕ Состав.БезОтвета
	|			ТОГДА Состав.Ответ
	|	КОНЕЦ КАК Ответ,
	|	Состав.ОткрытыйОтвет,
	|	ИСТИНА КАК Активность,
	|	&Ссылка КАК Регистратор,
	|	&Ссылка КАК Анкета,
	|	Состав.НомерСтроки КАК НомерСтроки,
	|	Состав.БезОтвета КАК БезОтвета
	|ИЗ
	|	Состав КАК Состав";
	
	Запрос.УстановитьПараметр("ТаблицаСостав",Состав);
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	
	Движения.ОтветыНаВопросыАнкет.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если ДанныеЗаполнения <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект,ДанныеЗаполнения);
	КонецЕсли;
	
	Если РежимАнкетирования = Перечисления.РежимыАнкетирования.Интервью Тогда
		Интервьюер = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если РежимАнкетирования = Перечисления.РежимыАнкетирования.Интервью Тогда
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("Опрос"));
	Иначе
		ПроверяемыеРеквизиты.Удалить(ПроверяемыеРеквизиты.Найти("ШаблонАнкеты"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли