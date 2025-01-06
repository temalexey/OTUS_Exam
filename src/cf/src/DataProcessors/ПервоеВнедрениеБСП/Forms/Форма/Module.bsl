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
	
	ЗначениеОбъект = РеквизитФормыВЗначение("Объект");
	Подсистемы.Загрузить(ЗначениеОбъект.ЗависимостиПодсистем());
	
	ЗаполнитьИерархиюПодсистем();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИерархияПодсистемПометкаПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ИерархияПодсистем.ТекущиеДанные;
	ИмяПодсистемы = ТекущиеДанные.Имя;
	
	Если ТекущиеДанные.Пометка Тогда
		
		ТекущиеДанные.ВыбранаПользователем = Истина;
		
		ОбработанныеПодсистемы = Новый Массив;
		ОбработанныеПодсистемы.Добавить(ИмяПодсистемы);
		ИзменитьПометкуРекурсивно(ТекущиеДанные, ТекущиеДанные.Пометка, ОбработанныеПодсистемы);
		
		МассивЗависимостей = Новый Массив;
		Для Каждого ИмяПодсистемы Из ОбработанныеПодсистемы Цикл
			ДобавитьЗависимостиРекурсивно(МассивЗависимостей, ИмяПодсистемы);
		КонецЦикла;
		
		Для Каждого Подсистема Из ИерархияПодсистем.ПолучитьЭлементы() Цикл
			
			Если МассивЗависимостей.Найти(Подсистема.Имя) <> Неопределено Тогда
				Подсистема.Пометка = Истина;
			КонецЕсли;
			
			Для Каждого ПодчиненнаяПодсистема Из Подсистема.ПолучитьЭлементы() Цикл
				
				Если МассивЗависимостей.Найти(ПодчиненнаяПодсистема.Имя) <> Неопределено Тогда
					ПодчиненнаяПодсистема.Пометка = Истина;
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЦикла;
		Возврат;
		
	КонецЕсли;
		
	МассивЗависимыхПодсистем = Новый Массив;
	ЗаполнитьЗависимыеПодсистемыРекурсивно(ИерархияПодсистем, ИмяПодсистемы, МассивЗависимыхПодсистем);
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИмяПодсистемы", ИмяПодсистемы);
	ДополнительныеПараметры.Вставить("ЗависимыеПодсистемы", МассивЗависимыхПодсистем);
	
	Если МассивЗависимыхПодсистем.Количество() = 0 Тогда
		СнятьПометкуЗависимыхПодсистемЗавершение(КодВозвратаДиалога.Да, ДополнительныеПараметры);
		Возврат;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("СнятьПометкуЗависимыхПодсистемЗавершение", ЭтотОбъект, 
		ДополнительныеПараметры);
	СинонимыПодсистем = СинонимыПодсистем(МассивЗависимыхПодсистем);
	ТекстВопроса = СтрЗаменить(
		НСтр("ru='Пометка будет также снята у зависимых подсистем:
			|%1
			|
			|Продолжить?'"),
		"%1",
		СтрСоединить(СинонимыПодсистем, Символы.ПС));
	
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ИерархияПодсистемПриАктивизацииСтроки(Элемент)
	
	Если Элементы.ИерархияПодсистем.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ИмяПодсистемы = Элементы.ИерархияПодсистем.ТекущиеДанные.Имя;
	Если ПустаяСтрока(ИмяПодсистемы) Тогда
		Возврат;
	КонецЕсли;
	
	ПодсистемыПоИмени = Подсистемы.НайтиСтроки(Новый Структура("Имя", ИмяПодсистемы));
	Если ПодсистемыПоИмени.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Подсистема = ПодсистемыПоИмени[0];
	ОписаниеПодсистемы = Подсистема.Описание;
	
	СинонимыПодсистем = Новый Массив;
	Для Каждого Зависимость Из Подсистема.ЗависитОтПодсистем Цикл
		СинонимыПодсистем.Добавить(Подсистемы.НайтиСтроки(Новый Структура("Имя", СокрЛП(Зависимость)))[0].Синоним);
	КонецЦикла;
	ЗависитОтПодсистем = СтрСоединить(СинонимыПодсистем, Символы.ПС);
	
	СинонимыПодсистем.Очистить();
	Для Каждого Зависимость Из Подсистема.УсловноЗависитОтПодсистем Цикл
		СинонимыПодсистем.Добавить(Подсистемы.НайтиСтроки(Новый Структура("Имя", СокрЛП(Зависимость)))[0].Синоним);
	КонецЦикла;
	УсловноЗависитОтПодсистем = СтрСоединить(СинонимыПодсистем, Символы.ПС);
	
	МассивЗависимыхПодсистем = Новый Массив;
	ЗаполнитьЗависимыеПодсистемыРекурсивно(ИерархияПодсистем, ИмяПодсистемы, МассивЗависимыхПодсистем, Ложь);
	СинонимыПодсистем = СинонимыПодсистем(МассивЗависимыхПодсистем);
	ЗависимыеПодсистемы = СтрСоединить(СинонимыПодсистем, Символы.ПС);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УдалитьКодНеиспользуемыхПодсистем(Команда)
	
	Сообщения = Новый Массив;

	ЭтоФайловаяБаза = (СтрНайти(ВРег(СтрокаСоединенияИнформационнойБазы()), "FILE=") = 1);
	Если Не ЭтоФайловаяБаза Тогда
		Сообщения.Добавить(НСтр("ru = 'Удаление кода неиспользуемых подсистем возможно только в файловой базе.'"));
	КонецЕсли;
	
	Если ОткрытКонфигуратор() Тогда
		Сообщения.Добавить(НСтр("ru = 'Для удаления фрагментов кода неиспользуемых подсистем закройте конфигуратор.'"));
	КонецЕсли;

	Если Сообщения.Количество() > 0 Тогда
		ПоказатьПредупреждение(, СтрСоединить(Сообщения, Символы.ПС));
		Возврат;
	КонецЕсли;

	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеПодтвержденияУдаленияФрагментовКода", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Будет выполнено удаление фрагментов кода неиспользуемых подсистем. Продолжить?'"), 
		РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодсистемыСнятьПометки(Команда)
	
	ИзменитьПометкуРекурсивно(ИерархияПодсистем, Ложь)
	
КонецПроцедуры

&НаКлиенте
Процедура ПодсистемыОтметитьВсе(Команда)
	
	ИзменитьПометкуРекурсивно(ИерархияПодсистем, Истина)
	
КонецПроцедуры

&НаКлиенте
Процедура ВывестиСписокПодсистем(Команда)
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ДобавитьПодсистемыРекурсивно(ТекстовыйДокумент, ИерархияПодсистем);
	ТекстовыйДокумент.Показать(НСтр("ru = 'Выбранные подсистемы'"));
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьНастройкиВФайл(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("СохранитьНастройкиВФайлПродолжение", ЭтотОбъект);
	НачатьПодключениеРасширенияРаботыСФайлами(ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура СохранитьНастройкиВФайлПродолжение(Подключено, ДополнительныеПараметры) Экспорт
	
	Если Подключено Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПослеВыбораФайлаВДиалогеСохранения", ЭтотОбъект);
		
		ДиалогСохранения = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
		ДиалогСохранения.МножественныйВыбор = Ложь;
		ДиалогСохранения.Фильтр = НСтр("ru = 'Файл настроек сравнения'") + "(*.xml)|*.xml";
		ДиалогСохранения.ПолноеИмяФайла = "ФайлНастроекСравнения";
		ДиалогСохранения.Показать(ОписаниеОповещения);
		
	Иначе
		ПолучитьФайл(СформироватьФайлНастроек(), "ФайлНастроекСравнения.xml", Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеВыбораФайлаВДиалогеСохранения(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	НастройкиСравнения = СформироватьФайлНастроек();
	
	ПолноеИмяФайла = Результат[0];
	ПолучаемыеФайлы = Новый Массив;
	ПолучаемыеФайлы.Добавить(Новый ОписаниеПередаваемогоФайла(ПолноеИмяФайла, НастройкиСравнения));
	
	НачатьПолучениеФайлов(Новый ОписаниеОповещения, ПолучаемыеФайлы, ПолноеИмяФайла, Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПодтвержденияУдаленияФрагментовКода(РезультатВопроса, ДополнительныеПараметры) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		ОчиститьСообщения();
		Состояние(НСтр("ru = 'Выполняется удаление фрагментов кода из модулей конфигурации'"));
		Результат = ВырезатьФрагментыПодсистем();
		НачатьУдалениеФайлов(Новый ОписаниеОповещения("ПослеУдаленияФрагментовКода", ЭтотОбъект, 
			Новый Структура("Результат", Результат)), КаталогВыгрузкиМодулей);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеУдаленияФрагментовКода(ДополнительныеПараметры) Экспорт
	
	Результат = ДополнительныеПараметры.Результат;
	
	Если Не ПустаяСтрока(Результат.Ошибки) Тогда
		Документ = Новый ТекстовыйДокумент();
		Документ.УстановитьТекст(Результат.Ошибки);
		Документ.Показать(НСтр("ru = 'Пропущенные модули'"));
	КонецЕсли;
	ПоказатьПредупреждение(, СтрЗаменить(НСтр("ru = 'Было проведено замен: %1'"), "%1", Результат.ЧислоЗамен));

КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	//
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ИерархияПодсистем.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ИерархияПодсистем.Обязательная");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	Элемент.Оформление.УстановитьЗначениеПараметра("Шрифт", Новый Шрифт(,, Истина)); //@skip-check new-font - обработка предназначена для запуска на пустой конфигурации, в которой нет стилей.
	
КонецПроцедуры

&НаСервере
Функция ВырезатьФрагментыПодсистем()
	
	ИмяАдминистратораИБ = ПользователиИнформационнойБазы.ТекущийПользователь().Имя;
	
	СтрокаСоединения = СтрокаСоединенияИнформационнойБазы();
	ФайловаяБаза = СтрНайти(СтрокаСоединения, "File=");
	ПервыйСимволПути = ФайловаяБаза + 6;
	СтрокаСоединения = Сред(СтрокаСоединения, ПервыйСимволПути);
	ПоследнийСимволПути = СтрНайти(СтрокаСоединения, ";");
	СтрокаСоединения = Лев(СтрокаСоединения, ПоследнийСимволПути - 2);
	КаталогИБ = СтрокаСоединения;
	
	КаталогВыгрузкиМодулей = ПолучитьИмяВременногоФайла("ВыгрузкаМодулей");
	СоздатьКаталог(КаталогВыгрузкиМодулей);
	
	УдалитьФайлы(КаталогВыгрузкиМодулей, "*");
	ВыгрузитьМодулиКонфигурации();
	
	ЧислоЗамен = 0;
	Ошибки = "";
	ПодсистемыДляУдаления = СписокПодсистемДляУдаления();
	Если ПодсистемыДляУдаления.Количество() > 0 Тогда
		
		МассивФайлов = НайтиФайлы(КаталогВыгрузкиМодулей, "*.txt");
		ТекстФайла = Новый ТекстовыйДокумент;
		
		Для Каждого Файл Из МассивФайлов Цикл
			
			ТекстСообщения = НСтр("ru = 'Выполняется удаление фрагментов кода в модуле [ИмяФайлаМодуля]'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "[ИмяФайлаМодуля]", Файл.Имя);
			ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Информация,,, ТекстСообщения);
			
			ТекстФайла.Прочитать(Файл.ПолноеИмя);
			СтрокаТекста = ТекстФайла.ПолучитьТекст();
			Для Каждого ИмяПодсистемы Из ПодсистемыДляУдаления Цикл
				ВырезатьФрагментыПодсистемыВТексте(Файл.Имя, ИмяПодсистемы, СтрокаТекста, ЧислоЗамен, Ошибки);
			КонецЦикла;
			ТекстФайла.УстановитьТекст(СтрокаТекста);
			ТекстФайла.Записать(Файл.ПолноеИмя);
		КонецЦикла;
		
	КонецЕсли;
	
	Если ЧислоЗамен > 0 Тогда
		ЗагрузитьМодулиВКонфигурацию();
	КонецЕсли;
	
	Возврат Новый Структура("ЧислоЗамен,Ошибки", ЧислоЗамен, Ошибки);
	
КонецФункции

&НаСервере
Процедура ВырезатьФрагментыПодсистемыВТексте(ИмяФайлаМодуля, ИмяПодсистемы, СтрокаТекста, ЧислоЗамен, Ошибки)
	
	НачалоФрагмента = НайтиНачалоФрагмента(СтрокаТекста, ИмяПодсистемы);
	Пока НачалоФрагмента > 0 Цикл
		
		ПозицияКонцаФрагмента = НайтиКонецФрагмента(СтрокаТекста, ИмяПодсистемы);
		Если ПозицияКонцаФрагмента = 0 Тогда
			ТекстСообщения = НСтр("ru = '%1: для открывающей скобки %2 не обнаружена закрывающая скобка.'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%2", "// " + ИмяПодсистемы);
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%1", ИмяФайлаМодуля);
			ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,,, ТекстСообщения);
			Ошибки = Ошибки + Символы.ПС + ТекстСообщения;
			Возврат;
		КонецЕсли; 				
		
		Если ПозицияКонцаФрагмента < НачалоФрагмента Тогда
			ТекстСообщения = НСтр("ru = '%1: для открывающей скобки %2 закрывающая скобка расположена выше по тексту.'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%2", "// " + ИмяПодсистемы);
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%1", ИмяФайлаМодуля);
			ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,,, ТекстСообщения);
			Ошибки = Ошибки + Символы.ПС + ТекстСообщения;
			Возврат;
		КонецЕсли; 	

		ДлинаНачалаФрагмента = СтрДлина("// " + ИмяПодсистемы);
		ПромежуточнаяСтрока = Сред(СтрокаТекста, НачалоФрагмента + ДлинаНачалаФрагмента + 1, ПозицияКонцаФрагмента - (НачалоФрагмента + ДлинаНачалаФрагмента) + 1);
		Если НайтиНачалоФрагмента(ПромежуточнаяСтрока, ИмяПодсистемы) > 0 Тогда 
			ТекстСообщения = НСтр("ru = '%1: внутри открывающейся скобки %2 есть еще одна открывающаяся скобка, до закрывающейся.'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%2", "// " + ИмяПодсистемы);
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%1", ИмяФайлаМодуля);
			ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(), УровеньЖурналаРегистрации.Предупреждение,,, ТекстСообщения);
			Ошибки = Ошибки + Символы.ПС + ТекстСообщения;
			Возврат;
		КонецЕсли;	
		
		ПозицияПоследнегоСимвола = ПозицияКонцаФрагмента + СтрДлина("// Конец " + ИмяПодсистемы);
		ВырезатьФрагмент(СтрокаТекста, НачалоФрагмента - 1, ПозицияПоследнегоСимвола);
		ЧислоЗамен = ЧислоЗамен + 1;
		
		НачалоФрагмента = НайтиНачалоФрагмента(СтрокаТекста, ИмяПодсистемы);
		
	КонецЦикла;
	
КонецПроцедуры	

&НаСервере
Функция НайтиНачалоФрагмента(Знач СтрокаТекста, Знач ИмяПодсистемы)
	
	СтрокаТекста 	= НРег(СтрокаТекста);
	ИмяПодсистемы 	= НРег(ИмяПодсистемы);
	
	ПервыйВариант = "// " + ИмяПодсистемы;
	ВторойВариант = "//" + ИмяПодсистемы;
	
	Если СтрНайти(СтрокаТекста, ПервыйВариант) = 0 И СтрНайти(СтрокаТекста, ВторойВариант) = 0 Тогда
		Возврат 0;
	КонецЕсли;
	
	Для Итерация = 1 По СтрДлина(СтрокаТекста) Цикл
		Если Сред(СтрокаТекста, Итерация, СтрДлина(ПервыйВариант)) = (ПервыйВариант) Тогда 
			Если Не ПустаяСтрока(Сред(СтрокаТекста, Итерация + СтрДлина(ПервыйВариант), 1)) Тогда 
				Продолжить;
			КонецЕсли;
			Возврат Итерация;
		КонецЕсли;
		
		Если Сред(СтрокаТекста, Итерация, СтрДлина(ВторойВариант)) = (ВторойВариант) Тогда 
			Если Не ПустаяСтрока(Сред(СтрокаТекста, Итерация + СтрДлина(ВторойВариант), 1)) Тогда 
				Продолжить;
			КонецЕсли;	
			Возврат Итерация;
		КонецЕсли;
	КонецЦикла;	
	
	Возврат 0;
	
КонецФункции

&НаСервере
Функция НайтиКонецФрагмента(Знач СтрокаТекста, Знач ИмяПодсистемы)
	
	СтрокаТекста 	= НРег(СтрокаТекста);
	ИмяПодсистемы 	= НРег(ИмяПодсистемы);
	
	ПервыйВариант = "// конец " + ИмяПодсистемы;
	ВторойВариант = "//конец " + ИмяПодсистемы;
	
	Если СтрНайти(СтрокаТекста, ПервыйВариант) = 0 И СтрНайти(СтрокаТекста, ВторойВариант) = 0 Тогда
		Возврат 0;
	КонецЕсли;
	
	Для Итерация = 1 По СтрДлина(СтрокаТекста) Цикл
		
		Если Сред(СтрокаТекста, Итерация, СтрДлина(ПервыйВариант)) = (ПервыйВариант) Тогда 
			Если Не ПустаяСтрока(Сред(СтрокаТекста, Итерация + СтрДлина(ПервыйВариант), 1)) Тогда 
				Продолжить;
			КонецЕсли;
			Возврат Итерация;
		КонецЕсли;
		
		Если Сред(СтрокаТекста, Итерация, СтрДлина(ВторойВариант)) = (ВторойВариант) Тогда 
			Если Не ПустаяСтрока(Сред(СтрокаТекста, Итерация + СтрДлина(ВторойВариант), 1)) Тогда 
				Продолжить;
			КонецЕсли;
			Возврат Итерация;
		КонецЕсли;
	КонецЦикла;
	
	Возврат 0;
	
КонецФункции

&НаСервере
Процедура ВырезатьФрагмент(СтрокаТекста, Начало, Конец)
	СтрокаТекста = СокрП(Лев(СтрокаТекста, Начало)) + Сред(СтрокаТекста, Конец);
КонецПроцедуры	

&НаСервере
Процедура ЗагрузитьМодулиВКонфигурацию()
		
	СтрокаЗапускаПлатформы = КаталогПрограммы() + "1cv8.exe";
	
	КаталогКонфигурации = КаталогИБ;
	Пользователь = ИмяАдминистратораИБ;
	Пароль = "";
	КоманднаяСтрока = СтрокаЗапускаПлатформы + " DESIGNER /F"""
		+ КаталогКонфигурации + """ /N"""
		+ Пользователь + """ /P""" + Пароль
		+ """ /LoadConfigFiles """ + КаталогВыгрузкиМодулей
		+ """ -Module";
				  
	ЗапуститьПриложение(КоманднаяСтрока,,Истина);
	
КонецПроцедуры

&НаСервере
Процедура ВыгрузитьМодулиКонфигурации()

	СтрокаЗапускаПлатформы = КаталогПрограммы() + "1cv8.exe";
	КаталогКонфигурации = КаталогИБ;
	Пользователь = ИмяАдминистратораИБ;
	Пароль = "";
	КоманднаяСтрока = СтрокаЗапускаПлатформы + " DESIGNER /F"""
		+ КаталогКонфигурации + """ /N"""
		+ Пользователь + """ /P""" + Пароль
		+ """ /DumpConfigFiles """ + КаталогВыгрузкиМодулей
		+ """ -Module";
				  
	ЗапуститьПриложение(КоманднаяСтрока,,Истина);

КонецПроцедуры

&НаСервере
Функция СписокПодсистемДляУдаления()
	
	СписокПодсистем = Подсистемы.Выгрузить(, "Имя").ВыгрузитьКолонку("Имя");
	СписокИспользуемыхПодсистем = СписокИспользуемыхПодсистем();
	
	ПодсистемыДляУдаления = Новый Массив;
	Для Каждого ИмяПодсистемы Из СписокПодсистем Цикл
		Если СписокИспользуемыхПодсистем.Найти(ИмяПодсистемы) = Неопределено Тогда 
			ПодсистемыДляУдаления.Добавить("СтандартныеПодсистемы." + ИмяПодсистемы);
		КонецЕсли;
	КонецЦикла;
		
	Возврат ПодсистемыДляУдаления;
	
КонецФункции

&НаСервере
Функция СписокИспользуемыхПодсистем()
	
	Результат = Новый Массив;
	СтандартныеПодсистемы = Метаданные.Подсистемы.Найти("СтандартныеПодсистемы");
	Если СтандартныеПодсистемы = Неопределено Тогда
		ТекстИсключения = НСтр("ru = 'Ошибка внедрения БСП. Группа подсистем ""[ИмяПодсистемы]"" не найдена в метаданных конфигурации базы данных.'");
		ТекстИсключения = СтрЗаменить(ТекстИсключения, "[ИмяПодсистемы]", "СтандартныеПодсистемы");
		ВызватьИсключение ТекстИсключения;
	Иначе
		СписокПодсистем = СтандартныеПодсистемы.Подсистемы;
		ПолучитьПодсистемы(Результат, СписокПодсистем, "")
	КонецЕсли;
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ПолучитьПодсистемы(СписокПодсистем, ВложенныеПодсистемы, ПутьКПодсистеме)
	
	Если ВложенныеПодсистемы.Количество() > 0 Тогда
		Для Каждого Подсистема Из ВложенныеПодсистемы Цикл
			РезервныйПуть = ПутьКПодсистеме;
			ПутьКПодсистеме = ПутьКПодсистеме + "." + Строка(Подсистема.Имя);
			ПолучитьПодсистемы(СписокПодсистем, Подсистема.Подсистемы, ПутьКПодсистеме);
			СписокПодсистем.Добавить(Сред(ПутьКПодсистеме, 2));
			ПутьКПодсистеме = РезервныйПуть;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СобытиеЖурналаРегистрации()
	
	Возврат НСтр("ru = 'Помощник внедрения БСП'", КодОсновногоЯзыка());
	
КонецФункции

&НаСервере
Функция ОткрытКонфигуратор()
	
	Для Каждого Сеанс Из ПолучитьСеансыИнформационнойБазы() Цикл
		Если ВРег(Сеанс.ИмяПриложения) = ВРег("Designer") Тогда // Конфигуратор
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;
	
КонецФункции

&НаСервере
Функция СформироватьФайлНастроек()
	
	ФайлШаблона = ПолучитьИмяВременногоФайла("xml");
	ЗаписьТекста = Новый ЗаписьТекста(ФайлШаблона);
	ЗаписьТекста.Записать(РеквизитФормыВЗначение("Объект").ПолучитьМакет("ШаблонНастроек").ПолучитьТекст());
	ЗаписьТекста.Закрыть();
	
	ДокументDOM = ДокументDOM(ФайлШаблона);
	УдалитьФайлы(ФайлШаблона);
	
	// Раздел Objects.
	УзелОбъекты = ДокументDOM.ПолучитьЭлементыПоИмени("Objects")[0];
	
	УстановитьФлажкиПодсистемРекурсивно(ИерархияПодсистем, ДокументDOM, УзелОбъекты, "");
	
	ИмяФайлаНастроек = ПолучитьИмяВременногоФайла("xml");
	ЗаписатьДокументDOMВФайл(ДокументDOM, ИмяФайлаНастроек);
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяФайлаНастроек);
	Адрес = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
	УдалитьФайлы(ИмяФайлаНастроек);
	Возврат Адрес;
	
КонецФункции

&НаСервере
Функция ДокументDOM(ПутьКФайлу)
	
	ЧтениеXML = Новый ЧтениеXML;
	ПостроительDOM = Новый ПостроительDOM;
	ЧтениеXML.ОткрытьФайл(ПутьКФайлу);
	ДокументDOM = ПостроительDOM.Прочитать(ЧтениеXML);
	ЧтениеXML.Закрыть();
	
	Возврат ДокументDOM;
	
КонецФункции

&НаСервере
Процедура ДобавитьОписаниеПодсистемы(ИмяПодсистемы, ДокументDOM, УзелОбъекты, ИнтерфейснаяПодсистема = Ложь)
	
	УзелОбъект = ДокументDOM.СоздатьЭлемент("Object");
	УзелОбъект.УстановитьАтрибут("fullNameInSecondConfiguration", ИмяПодсистемы);
	
	УзелПравило = ДокументDOM.СоздатьЭлемент("MergeRule");
	УзелПравило.ТекстовоеСодержимое = "GetFromSecondConfiguration";
	УзелОбъект.ДобавитьДочерний(УзелПравило);
	
	Если Не ИнтерфейснаяПодсистема Тогда
		УзелПодсистема = ДокументDOM.СоздатьЭлемент("Subsystem");
		УзелПодсистема.УстановитьАтрибут("configuration", "Second");
		УзелПодсистема.УстановитьАтрибут("includeObjectsFromSubordinateSubsystems", "true");
		
		УзелПравило = ДокументDOM.СоздатьЭлемент("MergeRule");
		УзелПравило.ТекстовоеСодержимое = "GetFromSecondConfiguration";
		УзелПодсистема.ДобавитьДочерний(УзелПравило);
		УзелОбъект.ДобавитьДочерний(УзелПодсистема);
	КонецЕсли;
	
	УзелОбъекты.ДобавитьДочерний(УзелОбъект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьДокументDOMВФайл(ДокументDOM, ПутьКФайлу)
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ПутьКФайлу);
	
	ЗаписьDOM = Новый ЗаписьDOM;
	ЗаписьDOM.Записать(ДокументDOM, ЗаписьXML);
	
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьПометкуРекурсивно(УровеньИерархии, ЗначениеПометки, ОбработанныеПодсистемы = Неопределено)
	
	Для Каждого СтрокаИерархии Из УровеньИерархии.ПолучитьЭлементы() Цикл
		
		Если СтрокаИерархии.Обязательная Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаИерархии.Пометка = ЗначениеПометки;
		СтрокаИерархии.ВыбранаПользователем = ЗначениеПометки;
		
		Если ОбработанныеПодсистемы <> Неопределено Тогда
			ОбработанныеПодсистемы.Добавить(СтрокаИерархии.Имя);
		КонецЕсли;
		
		ИзменитьПометкуРекурсивно(СтрокаИерархии, ЗначениеПометки, ОбработанныеПодсистемы);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьПодсистемыРекурсивно(ТекстовыйДокумент, УровеньИерархии)
	
	Для Каждого Подсистема Из УровеньИерархии.ПолучитьЭлементы() Цикл
		
		Если Не Подсистема.Пометка Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстовыйДокумент.ДобавитьСтроку(Подсистема.Имя);
		ДобавитьПодсистемыРекурсивно(ТекстовыйДокумент, Подсистема);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьЗависимостиРекурсивно(Зависимости, ИмяПодсистемы)
	
	Если ПустаяСтрока(ИмяПодсистемы) Тогда
		Возврат;
	КонецЕсли;
	
	ИнформацияОПодсистемах = Подсистемы.НайтиСтроки(Новый Структура("Имя", ИмяПодсистемы));
	Если ИнформацияОПодсистемах.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Подсистема = ИнформацияОПодсистемах[0];
	Для Каждого ЗависимостьОтПодсистемы Из Подсистема.ЗависитОтПодсистем Цикл
		
		Если Зависимости.Найти(ЗависимостьОтПодсистемы) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Зависимости.Добавить(ЗависимостьОтПодсистемы);
		ДобавитьЗависимостиРекурсивно(Зависимости, ЗависимостьОтПодсистемы);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФлажкиПодсистемРекурсивно(УровеньИерархии, ДокументDOM, УзелОбъекты, ИмяФайлаЗахвата)
	
	Для Каждого Подсистема Из УровеньИерархии.ПолучитьЭлементы() Цикл
		
		Если Подсистема.Пометка Тогда
			
			ИмяПодсистемы = Подсистема.Имя;
			Если СтрНайти(ИмяПодсистемы, ".") > 0 Тогда
				ИмяПодсистемы = СтрЗаменить(ИмяПодсистемы, ".", ".Подсистема.");
			КонецЕсли;
			
			ШаблонИмени = "Подсистема.СтандартныеПодсистемы.Подсистема.%1";
			ПолноеИмя = СтрЗаменить(ШаблонИмени, "%1", ИмяПодсистемы);
			
			ДобавитьОписаниеПодсистемы(ПолноеИмя, ДокументDOM, УзелОбъекты);
			Если ИмяПодсистемы = "НастройкиПрограммы" Тогда
				ПолноеИмя = "Подсистема.Администрирование";
				ДобавитьОписаниеПодсистемы(ПолноеИмя, ДокументDOM, УзелОбъекты, Истина);
			ИначеЕсли ИмяПодсистемы = "ПодключаемыеКоманды" Тогда
				ПолноеИмя = "Подсистема.ПодключаемыеОтчетыИОбработки";
				ДобавитьОписаниеПодсистемы(ПолноеИмя, ДокументDOM, УзелОбъекты, Истина);
			КонецЕсли;
			
		КонецЕсли;
		
		УстановитьФлажкиПодсистемРекурсивно(Подсистема, ДокументDOM, УзелОбъекты, ИмяФайлаЗахвата);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьИерархиюПодсистем()
	
	ДеревоЗначений = РеквизитФормыВЗначение("ИерархияПодсистем", Тип("ДеревоЗначений"));
	ДеревоЗначений.Строки.Очистить();
	СозданныеСтрокиДерева = Новый Соответствие;

	Для Каждого СтрокаТаблицы Из Подсистемы Цикл
		Если СозданныеСтрокиДерева[СтрокаТаблицы.Имя] <> Неопределено Тогда
			Продолжить;
		КонецЕсли; 
		Если Не ПустаяСтрока(СтрокаТаблицы.Родитель) Тогда
			СтрокаГруппировки = ДеревоЗначений.Строки.Найти(СтрокаТаблицы.Родитель, "Имя", Истина);
			Если СтрокаГруппировки = Неопределено Тогда
				СтрокаРодителя = Подсистемы.НайтиСтроки(Новый Структура("Имя", СтрокаТаблицы.Родитель))[0];
				СтрокаГруппировки = ДеревоЗначений.Строки.Добавить(); // Возможен только второй уровень иерархии
				ЗаполнитьЗначенияСвойств(СтрокаГруппировки, СтрокаРодителя);
				СозданныеСтрокиДерева[СтрокаРодителя.Имя] = Истина; 
			КонецЕсли;
			СтрокаДерева = СтрокаГруппировки.Строки.Добавить(); 
		Иначе
			СтрокаДерева = ДеревоЗначений.Строки.Добавить(); 
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(СтрокаДерева, СтрокаТаблицы);
		СозданныеСтрокиДерева[СтрокаТаблицы.Имя] = Истина; 
	КонецЦикла;

	ДеревоЗначений.Строки.Сортировать("Синоним", Истина);
	ЗначениеВРеквизитФормы(ДеревоЗначений, "ИерархияПодсистем");

КонецПроцедуры

&НаСервере
Функция КодОсновногоЯзыка()
	
	Если Метаданные.Константы.Найти("ОсновнойЯзык") <> Неопределено
		И ЗначениеЗаполнено(Константы["ОсновнойЯзык"].Получить()) Тогда
		Возврат Константы["ОсновнойЯзык"].Получить();
	КонецЕсли;
	
	Возврат Метаданные.ОсновнойЯзык.КодЯзыка;
	
КонецФункции

&НаКлиенте
Функция СинонимыПодсистем(Подсистемы)
	
	СинонимыПодсистем = Новый Массив;
	
	Для Каждого ЗависимаяПодсистема Из Подсистемы Цикл
		СинонимыПодсистем.Добавить(ЗависимаяПодсистема.Синоним);
	КонецЦикла;
	
	Возврат СинонимыПодсистем;
	
КонецФункции

&НаКлиенте
Функция ИменаПодсистем(Подсистемы)
	
	ИменаПодсистем = Новый Массив;
	
	Для Каждого ЗависимаяПодсистема Из Подсистемы Цикл
		ИменаПодсистем.Добавить(ЗависимаяПодсистема.Имя);
	КонецЦикла;
	
	Возврат ИменаПодсистем;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьЗависимыеПодсистемыРекурсивно(УровеньИерархии, ИмяПодсистемы, ЗависимыеПодсистемы, ТолькоСПометкой = Истина)
	
	Для Каждого Подсистема Из УровеньИерархии.ПолучитьЭлементы() Цикл
		
		Если (НЕ ТолькоСПометкой) ИЛИ Подсистема.Пометка Тогда
			
			Зависимости = Подсистемы.НайтиСтроки(Новый Структура("Имя", Подсистема.Имя))[0].ЗависитОтПодсистем;
			Если (Зависимости.Найти(ИмяПодсистемы) <> Неопределено) И (ЗависимыеПодсистемы.Найти(Подсистема) = Неопределено) Тогда
				ЗависимыеПодсистемы.Добавить(Подсистема);
				ЗаполнитьЗависимыеПодсистемыРекурсивно(ИерархияПодсистем, Подсистема.Имя, ЗависимыеПодсистемы, ТолькоСПометкой);
			КонецЕсли;
			
		КонецЕсли;
		
		ЗаполнитьЗависимыеПодсистемыРекурсивно(Подсистема, ИмяПодсистемы, ЗависимыеПодсистемы, ТолькоСПометкой);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьЗависитОтПодсистемРекурсивно(КоллекцияПодсистем, Зависимости, ЗависитОтПодсистем)
	
	Для Каждого Подсистема Из КоллекцияПодсистем Цикл
		
		Если Подсистема.ВыбранаПользователем Тогда
			Продолжить;
		КонецЕсли;
		
		Если (Зависимости.Найти(Подсистема.Имя) = Неопределено) ИЛИ (НЕ Подсистема.Пометка) Тогда
			ЗаполнитьЗависитОтПодсистемРекурсивно(Подсистема.ПолучитьЭлементы(), Зависимости, ЗависитОтПодсистем);
			Продолжить;
		КонецЕсли;
		
		ЗависимостиПодсистемы = Подсистемы.НайтиСтроки(Новый Структура("Имя", Подсистема.Имя))[0].ЗависитОтПодсистем;
		НетВыбранныхСвязанныхПодсистем = Истина;
		Если (ЗависимостиПодсистемы.Количество() > 0) Тогда
			НетВыбранныхСвязанныхПодсистем = НЕ ЕстьПомеченныеСвязанныеПодсистемы(ИерархияПодсистем.ПолучитьЭлементы(),
				ЗависимостиПодсистемы, Зависимости, Истина);
		КонецЕсли;
		
		МассивЗависимыхПодсистем = Новый Массив;
		ЗаполнитьЗависимыеПодсистемыРекурсивно(ИерархияПодсистем, Подсистема.Имя, МассивЗависимыхПодсистем, Ложь);
		ИменаЗависимыхПодсистем = ИменаПодсистем(МассивЗависимыхПодсистем);
		
		НетПомеченныхЗависимыхПодсистем = Истина;
		Если ИменаЗависимыхПодсистем.Количество() > 0 Тогда
			НетПомеченныхЗависимыхПодсистем = НЕ ЕстьПомеченныеСвязанныеПодсистемы(ИерархияПодсистем.ПолучитьЭлементы(),
				ИменаЗависимыхПодсистем, Зависимости);
		КонецЕсли;
		
		Если НетВыбранныхСвязанныхПодсистем
			И НетПомеченныхЗависимыхПодсистем
			И (НЕ Подсистема.Обязательная)
			И (ЗависитОтПодсистем.Найти(Подсистема) = Неопределено) Тогда
			ЗависитОтПодсистем.Добавить(Подсистема);
		КонецЕсли;
		
		ЗаполнитьЗависитОтПодсистемРекурсивно(Подсистема.ПолучитьЭлементы(), ЗависимостиПодсистемы, ЗависитОтПодсистем);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ЕстьПомеченныеСвязанныеПодсистемы(КоллекцияПодсистем, СвязанныеПодсистемы, Зависимости, ВыбранаПользователем = Ложь)
	
	Для Каждого ПодчиненнаяПодсистема Из КоллекцияПодсистем Цикл
		
		Если СвязанныеПодсистемы.Найти(ПодчиненнаяПодсистема.Имя) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если Зависимости.Найти(ПодчиненнаяПодсистема.Имя) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ПодсистемаОтмечена = ?(ВыбранаПользователем, ПодчиненнаяПодсистема.Пометка И ПодчиненнаяПодсистема.ВыбранаПользователем,
			ПодчиненнаяПодсистема.Пометка);
		
		Если ПодсистемаОтмечена Тогда
			Возврат Истина;
		КонецЕсли;
		
		Если ЕстьПомеченныеСвязанныеПодсистемы(ПодчиненнаяПодсистема.ПолучитьЭлементы(),
				СвязанныеПодсистемы, Зависимости, ВыбранаПользователем) Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

&НаКлиенте
Процедура СнятьПометкуЗависимыхПодсистемЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	ТекущиеДанные = Элементы.ИерархияПодсистем.ТекущиеДанные;
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		ТекущиеДанные.Пометка = Истина;
		Возврат;
	КонецЕсли;
	
	ОбрабатываемыеПодсистемы = Новый Массив;
	ОбрабатываемыеПодсистемы.Добавить(ТекущиеДанные.Имя);
	
	ТекущиеДанные.ВыбранаПользователем = Ложь;
	
	ИзменитьПометкуРекурсивно(ТекущиеДанные, ТекущиеДанные.Пометка, ОбрабатываемыеПодсистемы);
	
	ИмяПодсистемы = ДополнительныеПараметры.ИмяПодсистемы;
	Для Каждого ЭлементМассива Из ДополнительныеПараметры.ЗависимыеПодсистемы Цикл
		ОбрабатываемыеПодсистемы.Добавить(ЭлементМассива.Имя);
		ЭлементМассива.Пометка = Ложь;
		ЭлементМассива.ВыбранаПользователем = Ложь;
	КонецЦикла;
	
	ЗависимостиПодсистем = Новый Массив;
	Для Каждого ИмяПодсистемы Из ОбрабатываемыеПодсистемы Цикл
		ДобавитьЗависимостиРекурсивно(ЗависимостиПодсистем, ИмяПодсистемы);
	КонецЦикла;
	
	МассивЗависитОтПодсистем = Новый Массив;
	ЗаполнитьЗависитОтПодсистемРекурсивно(ИерархияПодсистем.ПолучитьЭлементы(), ЗависимостиПодсистем, МассивЗависитОтПодсистем);
	Если МассивЗависитОтПодсистем.Количество() > 0 Тогда
		
		СинонимыПодсистем = СинонимыПодсистем(МассивЗависитОтПодсистем);
		
		ПараметрыОповещения = Новый Структура;
		ПараметрыОповещения.Вставить("ЗависитОтПодсистем", МассивЗависитОтПодсистем);
		ПараметрыОповещения.Вставить("СинонимыПодсистем", СинонимыПодсистем);
		
		СохраненныйОтвет = СохраненныйОтветПользователя();
		Если СохраненныйОтвет = Неопределено Тогда
			
			ТекстВопроса = СтрЗаменить(
				НСтр("ru='При выборе данной подсистемы были автоматически отмечены для внедрения:
					|%1
					|
					|Снять пометку?'"),
				"%1",
				СтрСоединить(СинонимыПодсистем, Символы.ПС));
			
			ОписаниеОповещения = Новый ОписаниеОповещения("СнятьПометкуЗависитОтПодсистемЗавершение", ЭтотОбъект, ПараметрыОповещения);
			
			ПараметрыОткрытия = Новый Структура;
			ПараметрыОткрытия.Вставить("Заголовок", КлиентскоеПриложение.ПолучитьЗаголовок());
			ПараметрыОткрытия.Вставить("ТекстСообщения", ТекстВопроса);
			
			МассивИмениФормы = СтрРазделить(ИмяФормы, ".");
			МассивИмениФормы.Удалить(МассивИмениФормы.ВГраница());
			ИмяФормыВопроса = СтрСоединить(МассивИмениФормы, ".") + ".Вопрос";
			ОткрытьФорму(ИмяФормыВопроса, ПараметрыОткрытия,,,,, ОписаниеОповещения);
			
			Возврат;
		КонецЕсли;
			
		ПараметрыОтвета = Новый Структура;
		ПараметрыОтвета.Вставить("Значение", ?(СохраненныйОтвет = Истина, КодВозвратаДиалога.Да, КодВозвратаДиалога.Нет));
		ПараметрыОтвета.Вставить("БольшеНеЗадаватьЭтотВопрос", Ложь);
		
		СнятьПометкуЗависитОтПодсистемЗавершение(ПараметрыОтвета, ПараметрыОповещения);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьПометкуЗависитОтПодсистемЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Ответ.БольшеНеЗадаватьЭтотВопрос Тогда
		ОтветПользователя = (Ответ.Значение = КодВозвратаДиалога.Да);
		СохранитьОтветПользователяНаСервере(ОтветПользователя);
	КонецЕсли;
	
	Если Ответ.Значение <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ЭлементМассива Из ДополнительныеПараметры.ЗависитОтПодсистем Цикл
		ЭлементМассива.Пометка = Ложь;
	КонецЦикла;
	
	ТекстСостояния = СтрЗаменить(
		НСтр("ru='Снята пометка с подсистем:
			|%1'"),
		"%1",
		СтрСоединить(ДополнительныеПараметры.СинонимыПодсистем, Символы.ПС));
	
	Состояние(ТекстСостояния);
	
КонецПроцедуры

&НаСервере
Процедура СохранитьОтветПользователяНаСервере(ОтветПользователя)
	
	ХранилищеОбщихНастроек.Сохранить("ОбщиеНастройкиПользователя",
		"ВопросОСнятииПометокСАвтоматическиОтмеченныхПодсистем",
		ОтветПользователя);
	
КонецПроцедуры

&НаСервере
Функция СохраненныйОтветПользователя()
	
	СохраненныйОтвет = ХранилищеОбщихНастроек.Загрузить("ОбщиеНастройкиПользователя",
		"ВопросОСнятииПометокСАвтоматическиОтмеченныхПодсистем");
	
	Возврат СохраненныйОтвет;
	
КонецФункции

#КонецОбласти
