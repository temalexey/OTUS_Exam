///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область СлужебныеПроцедурыИФункции

Процедура ВыполнитьДействие(Параметры, АдресРезультата) Экспорт
	
	ОписаниеЗамера = ОценкаПроизводительности.НачатьЗамерДлительнойОперации("ДемоЗамерДлительнойОперации");
	ОписаниеЗамераВариант2 = ОценкаПроизводительности.НачатьЗамерДлительнойОперации("ДемоЗамерДлительнойОперацииВариант2");
	КоличествоКонтрагентов = Параметры.КоличествоКонтрагентов;
	КоличествоБанковскихСчетовКонтрагента = Параметры.КоличествоБанковскихСчетовКонтрагента;
	УдалитьСозданные = Параметры.УдалитьСозданные;
	
	НаименованиеКонтрагента = НСтр("ru = 'Контрагент %1'");
	НаименованиеСчета = НСтр("ru = 'Банковский счет контрагента %1'");
	МассивОбъектов = Новый Массив;
	
	НачатьТранзакцию();
	Попытка
		Для СчетчикКонтрагента = 1 По КоличествоКонтрагентов Цикл
			КонтрагентОбъект = Справочники._ДемоКонтрагенты.СоздатьЭлемент();
			
			КонтрагентОбъект.Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НаименованиеКонтрагента, Формат(СчетчикКонтрагента, "ЧГ="));
			КонтрагентОбъект.Записать();
			ОценкаПроизводительности.ЗафиксироватьЗамерДлительнойОперации(ОписаниеЗамера, 1, "ЗаписьКонтрагента");
			МассивОбъектов.Добавить(КонтрагентОбъект.Ссылка);
			Для СчетчикСчета = 1 По КоличествоБанковскихСчетовКонтрагента Цикл			
				СчетОбъект = Справочники._ДемоБанковскиеСчета.СоздатьЭлемент();
				СчетОбъект.Владелец = КонтрагентОбъект.Ссылка;
				СчетОбъект.Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НаименованиеСчета, Формат(СчетчикКонтрагента, "ЧГ="));
				СчетОбъект.Записать();                       
				ОценкаПроизводительности.ЗафиксироватьЗамерДлительнойОперации(ОписаниеЗамера, 1, "ЗаписьБанковскогоСчета");
			КонецЦикла;
		КонецЦикла;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
	КонецПопытки;
		
	Если УдалитьСозданные Тогда
		ТаблицаКонтрагентов = Новый ТаблицаЗначений;
		ТаблицаКонтрагентов.Колонки.Добавить("Контрагент", Новый ОписаниеТипов("СправочникСсылка._ДемоКонтрагенты"));
		ТаблицаКонтрагентов.ЗагрузитьКолонку(МассивОбъектов, "Контрагент");
		НачатьТранзакцию();
		Попытка
			Блокировка = Новый БлокировкаДанных;
			ЭлементБлокировки = Блокировка.Добавить("Справочник._ДемоКонтрагенты");
			ЭлементБлокировки.ИсточникДанных = ТаблицаКонтрагентов;
			ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Ссылка", "Контрагент");
			Блокировка.Заблокировать();
			Для Каждого Элемент Из МассивОбъектов Цикл
				ЭлементОбъект = Элемент.ПолучитьОбъект();
				ЭлементОбъект.Удалить();
			КонецЦикла;	
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
		КонецПопытки;
	КонецЕсли;
	ОценкаПроизводительности.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамера, МассивОбъектов.Количество(), "УдалениеКонтрагентов");
	ВсегоДействий = КоличествоКонтрагентов * (2 + КоличествоБанковскихСчетовКонтрагента);
	ОценкаПроизводительности.ЗакончитьЗамерДлительнойОперации(ОписаниеЗамераВариант2, ВсегоДействий);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
