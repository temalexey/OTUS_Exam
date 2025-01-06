///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
//

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	// Если нам не передали значение для заполнения владельца-партнера, то пытаемся 
	// установить его сами.
	ИскатьПартнера = ДанныеЗаполнения = Неопределено;
	Если Не ИскатьПартнера И ДанныеЗаполнения.Свойство("Владелец") Тогда
		АнализДанных = Новый Структура("Владелец");
		ЗаполнитьЗначенияСвойств(АнализДанных, ДанныеЗаполнения, "Владелец");
		ИскатьПартнера = Не ЗначениеЗаполнено(АнализДанных.Владелец);
	КонецЕсли;

	Если ИскатьПартнера Тогда
		Запрос = Новый Запрос("
							  |ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 2
							  |	Партнеры.Ссылка КАК Ссылка
							  |ИЗ
							  |	Справочник._ДемоПартнеры КАК Партнеры
							  |ГДЕ
							  |	НЕ Партнеры.ПометкаУдаления
							  |");
		Партнеры = Запрос.Выполнить().Выгрузить();
		// Можем устанавливать, только если доступен один из всех.
		Если Партнеры.Количество() = 1 Тогда
			Партнер = Партнеры[0]; // СправочникСсылка._ДемоПартнеры
			Владелец = Партнер.Ссылка;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли