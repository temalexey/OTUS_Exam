#Область ОбработчикиСобытийФормы  

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
			
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Объект.Ответственный = Пользователи.ТекущийПользователь();
	КонецЕсли; 
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
		
КонецПроцедуры  

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды 
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Объект.НачалоАренды = Объект.Дата;
		Объект.ОкончаниеАренды = Объект.Дата;
		
		РассчитатьСрокИСтоимость();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ПодключаемыеКомандыКлиент.ПослеЗаписи(ЭтотОбъект, ЭтотОбъект, ПараметрыЗаписи);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НачалоАрендыПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(Объект.ОкончаниеАренды) И Объект.НачалоАренды > Объект.ОкончаниеАренды Тогда
		Объект.НачалоАренды = Объект.ОкончаниеАренды;
	КонецЕсли; 
	
	РассчитатьСрокИСтоимость();
	
КонецПроцедуры

&НаКлиенте
Процедура ОкончаниеАрендыПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(Объект.НачалоАренды) И Объект.ОкончаниеАренды < Объект.НачалоАренды Тогда
		Объект.ОкончаниеАренды = Объект.НачалоАренды;
	КонецЕсли;
	
	РассчитатьСрокИСтоимость();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСостав

&НаКлиенте
Процедура СоставПриИзменении(Элемент)
	
	РассчитатьСрокИСтоимость();
	
КонецПроцедуры

&НаКлиенте
Процедура СоставИнструментПриИзменении(Элемент)
	
	ТекущаяСтрока = Элементы.Состав.ТекущиеДанные;
	Расценки = отусАрендаИнструментаВызовСервера.ПолучитьЦеныИнструмента(ТекущаяСтрока.Инструмент, Объект.Дата);
	
	Если НЕ ТекущаяСтрока.Количество Тогда
		ТекущаяСтрока.Количество = 1;
	КонецЕсли;
	
	ТекущаяСтрока.Депозит = Расценки.Депозит;
	ТекущаяСтрока.ДепозитВсего = Расценки.Депозит * ТекущаяСтрока.Количество;
	
	ТекущаяСтрока.Аренда = Расценки.Аренда;
	ТекущаяСтрока.АрендаВсего = Расценки.Аренда * ТекущаяСтрока.Количество * Объект.КоличествоСутокАренды;
	
	РассчитатьСрокИСтоимость();
			
КонецПроцедуры  

&НаКлиенте
Процедура СоставКоличествоПриИзменении(Элемент)
	
	ТекущаяСтрока = Элементы.Состав.ТекущиеДанные;
		
	Если НЕ ТекущаяСтрока.Количество Тогда
		ТекущаяСтрока.Количество = 1;
	КонецЕсли;
	
	ТекущаяСтрока.ДепозитВсего = ТекущаяСтрока.Депозит * ТекущаяСтрока.Количество;
	ТекущаяСтрока.АрендаВсего = ТекущаяСтрока.Аренда * ТекущаяСтрока.Количество * Объект.КоличествоСутокАренды;
	
	РассчитатьСрокИСтоимость();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

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

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура РассчитатьСрокИСтоимость() 
					
	Объект.КоличествоСутокАренды = (Объект.ОкончаниеАренды - Объект.НачалоАренды + 86400) / 86400;
	
	Для Каждого ТекущаяСтрока Из Объект.Состав Цикл
		ТекущаяСтрока.ДепозитВсего = ТекущаяСтрока.Депозит * ТекущаяСтрока.Количество;
		ТекущаяСтрока.АрендаВсего = ТекущаяСтрока.Аренда * ТекущаяСтрока.Количество * Объект.КоличествоСутокАренды;	
	КонецЦикла;
	
	Объект.СуммаДокумента = Объект.Состав.Итог("ДепозитВсего") + Объект.Состав.Итог("АрендаВсего");
		
КонецПроцедуры	

#КонецОбласти

