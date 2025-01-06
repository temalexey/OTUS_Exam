///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Функция НастройкиПоУмолчанию() Экспорт
	Результат = Новый Структура;
	
	Результат.Вставить("ПроверятьЗаполнение", Ложь);
	
	Результат.Вставить("ПростыеДублиИспользование", Истина);
	Результат.Вставить("ПростыеДублиКоличество", 10);
	Результат.Вставить("ПростыеДублиПрефикс", НСтр("ru = 'Тест поиска дублей %1'"));
	
	Результат.Вставить("РегистрыСведенийИспользование", Истина);
	Результат.Вставить("РегистрыСведенийКоличество", 1);
	Результат.Вставить("РегистрыСведенийПрефикс", НСтр("ru = 'Дубли в регистрах сведений %1'"));
	
	Результат.Вставить("РегистрыНакопленияИспользование", Истина);
	Результат.Вставить("РегистрыНакопленияКоличество", 1);
	Результат.Вставить("РегистрыНакопленияПрефикс", НСтр("ru = 'Дубли в регистрах накопления %1'"));
	
	Возврат Результат;
КонецФункции

Функция Сгенерировать(КоллекцияНастроек) Экспорт
	Настройки = НастройкиПоУмолчанию();
	Если КоллекцияНастроек <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(Настройки, КоллекцияНастроек);
	КонецЕсли;
	
	Результат = Результат();
	СозданныеОбъекты = Результат.СозданныеОбъекты;
	
	ФлажокДоНачала = Константы.ИспользоватьДатыЗапретаИзменения.Получить();
	Константы.ИспользоватьДатыЗапретаИзменения.Установить(Ложь);
	ОбновитьПовторноИспользуемыеЗначения();
	
	НачатьТранзакцию();
	Попытка
		
		Если Настройки.ПростыеДублиИспользование Тогда
			СоздатьПростыеДубли(Настройки, Результат);
		КонецЕсли;
		
		Если Настройки.РегистрыСведенийИспользование Тогда
			СоздатьЗаписиВРегистреСведенийКурсыВалют(Настройки, Результат);
			СоздатьЗаписиВРегистреСведенийЗаведующиеМестамиХранения(Настройки, Результат);
			СоздатьЗаписиВРегистреСведенийРаботникиОрганизаций(Настройки, Результат);
		КонецЕсли;
		
		Если Настройки.РегистрыНакопленияИспользование Тогда
			СоздатьДублиИспользующиесяВРегистрахНакопления(Настройки, Результат);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		
		Константы.ИспользоватьДатыЗапретаИзменения.Установить(ФлажокДоНачала);
		ОбновитьПовторноИспользуемыеЗначения();
		
		ВызватьИсключение;
		
	КонецПопытки;
	
	Константы.ИспользоватьДатыЗапретаИзменения.Установить(ФлажокДоНачала);
	ОбновитьПовторноИспользуемыеЗначения();
	
	// Установка пометок удаления в случайном порядке.
	ПомечаемыеНаУдаление = СозданныеОбъекты.НайтиСтроки(Новый Структура("Пометка", Истина));
	
	ОсталосьПометить = ПомечаемыеНаУдаление.Количество();
	ГСЧ = Новый ГенераторСлучайныхЧисел;
	Пока ОсталосьПометить > 0 Цикл
		ОсталосьПометить = ОсталосьПометить - 1;
		Индекс = ГСЧ.СлучайноеЧисло(0, ОсталосьПометить);
		ПомечаемыеНаУдаление[Индекс].Ссылка.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);
		ПомечаемыеНаУдаление.Удалить(Индекс);
	КонецЦикла;
	
	// Установка пометок удаления в случайном порядке.
	СнимаемыеСПометки = СозданныеОбъекты.НайтиСтроки(Новый Структура("Пометка, Ссылочный", Ложь, Истина));
	
	ОсталосьСнять = СнимаемыеСПометки.Количество();
	Пока ОсталосьСнять > 0 Цикл
		ОсталосьСнять = ОсталосьСнять - 1;
		Индекс = ГСЧ.СлучайноеЧисло(0, ОсталосьСнять);
		СнимаемыеСПометки[Индекс].Ссылка.ПолучитьОбъект().УстановитьПометкуУдаления(Ложь);
		СнимаемыеСПометки.Удалить(Индекс);
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращаемое значение:
//  Структура:
//   * ТипыДублей - Массив
//   * СозданныеОбъекты - ТаблицаЗначений
//
Функция Результат()
	СозданныеОбъекты = Новый ТаблицаЗначений;
	СозданныеОбъекты.Колонки.Добавить("Сценарий", Новый ОписаниеТипов("Строка"));
	СозданныеОбъекты.Колонки.Добавить("Тип", Новый ОписаниеТипов("Тип"));
	СозданныеОбъекты.Колонки.Добавить("Ссылка");
	СозданныеОбъекты.Колонки.Добавить("Пометка", Новый ОписаниеТипов("Булево"));
	СозданныеОбъекты.Колонки.Добавить("Вид", Новый ОписаниеТипов("Строка"));
	СозданныеОбъекты.Колонки.Добавить("Ссылочный", Новый ОписаниеТипов("Булево"));
	СозданныеОбъекты.Колонки.Добавить("ЭтоДубль", Новый ОписаниеТипов("Булево"));
	СозданныеОбъекты.Колонки.Добавить("Оригинал");
	
	Результат = Новый Структура;
	Результат.Вставить("СозданныеОбъекты", СозданныеОбъекты);
	Результат.Вставить("ТипыДублей", Новый Массив);
	
	Возврат Результат;
КонецФункции

// АПК:1328-выкл разделяемая блокировка на читаемые данные не требуется для данных тестов

Процедура СоздатьПростыеДубли(Настройки, Результат)
	Сценарий = "ПростыеДубли";
	
	СправочникМенеджер = Справочники._ДемоНоменклатура;
	ШаблонНаименования = Настройки.ПростыеДублиПрефикс;
	
	ШаблонНаименованияДляЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, "%");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	_ДемоНоменклатура.Ссылка,
	|	_ДемоНоменклатура.Наименование,
	|	_ДемоНоменклатура.Артикул
	|ИЗ
	|	Справочник._ДемоНоменклатура КАК _ДемоНоменклатура
	|ГДЕ
	|	_ДемоНоменклатура.Наименование ПОДОБНО &ШаблонНаименования СПЕЦСИМВОЛ ""~""";
	Запрос.УстановитьПараметр("ШаблонНаименования", ОбщегоНазначения.СформироватьСтрокуДляПоискаВЗапросе(ШаблонНаименованияДляЗапроса));
	
	УжеСозданныеОбъекты = Запрос.Выполнить().Выгрузить();
	
	Для НомерЭлемента = 1 По Настройки.ПростыеДублиКоличество Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ШаблонНаименования,
			Формат(НомерЭлемента, "ЧГ="));
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Артикул", Наименование, "Оригинал"));
		Если Найденные.Количество() = 0 Тогда
			ОригиналОбъект = СправочникМенеджер.СоздатьЭлемент();
			ОригиналОбъект.Наименование = Наименование;
			ОригиналОбъект.Артикул = "Оригинал";
			ОригиналОбъект.Записать();
			СсылкаОригинала = ОригиналОбъект.Ссылка;
		Иначе
			СсылкаОригинала = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, СсылкаОригинала, Ложь);
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Артикул", Наименование, "Дубль"));
		Если Найденные.Количество() = 0 Тогда
			ДубльОбъект = СправочникМенеджер.СоздатьЭлемент();
			ДубльОбъект.Наименование = Наименование;
			ДубльОбъект.Артикул = "Дубль";
			ДубльОбъект.Записать();
			СсылкаДубля = ДубльОбъект.Ссылка;
		Иначе
			СсылкаДубля = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, СсылкаДубля, Ложь);
	КонецЦикла;
	
КонецПроцедуры

Процедура СоздатьЗаписиВРегистреСведенийКурсыВалют(Настройки, Результат)
	
	// На базе регистра КурсыВалют тестируется исключение поиска в ведущих измерениях.
	Сценарий = "ВедущиеИзмеренияВРегистрахСведений";
	
	ШаблонНаименования = НСтр("ru = 'Валюта %1'");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Валюты.Ссылка,
	|	Валюты.Наименование,
	|	Валюты.Код
	|ИЗ
	|	Справочник.Валюты КАК Валюты
	|ГДЕ
	|	Валюты.Наименование ПОДОБНО &ШаблонНаименования СПЕЦСИМВОЛ ""~""";
	ШаблонНаименованияДляЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, "%");
	Запрос.УстановитьПараметр("ШаблонНаименования", ОбщегоНазначения.СформироватьСтрокуДляПоискаВЗапросе(ШаблонНаименованияДляЗапроса));
	УжеСозданныеОбъекты = Запрос.Выполнить().Выгрузить(); 
	
	Для НомерЭлемента = 1 По Настройки.РегистрыСведенийКоличество Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(НомерЭлемента, "ЧГ="));
		
		Код = "О" + Строка(НомерЭлемента);
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Код", Наименование, Код));
		Если Найденные.Количество() = 0 Тогда
			ОригиналОбъект = Справочники.Валюты.СоздатьЭлемент();
			ОригиналОбъект.Код = Код;
			ОригиналОбъект.Наименование = Наименование;
			ОригиналОбъект.НаименованиеПолное = Наименование;
			ОригиналОбъект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
			ЗаписатьОбъект(Настройки, ОригиналОбъект);
			Оригинал = ОригиналОбъект.Ссылка;
		Иначе
			Оригинал = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Оригинал, Истина);
		
		Код = "Д" + Строка(НомерЭлемента);
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Код", Наименование, Код));
		Если Найденные.Количество() = 0 Тогда
			ДубльОбъект = Справочники.Валюты.СоздатьЭлемент();
			ДубльОбъект.Код = Код;
			ДубльОбъект.Наименование = Наименование;
			ДубльОбъект.НаименованиеПолное = Наименование;
			ДубльОбъект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод;
			ЗаписатьОбъект(Настройки, ДубльОбъект);
			Дубль = ДубльОбъект.Ссылка;
		Иначе
			Дубль = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Дубль, Истина, Оригинал);
		
		Набор1 = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		Набор1.Отбор.Валюта.Установить(Оригинал);
		
		Запись1 = Набор1.Добавить();
		Запись1.Период = Дата(2001, 01, 01);
		Запись1.Валюта = Оригинал;
		Запись1.Курс   = 10;
		
		Набор2 = РегистрыСведений.КурсыВалют.СоздатьНаборЗаписей();
		Набор2.Отбор.Валюта.Установить(Дубль);
		
		Запись2 = Набор2.Добавить();
		Запись2.Период = Дата(2001, 01, 01);
		Запись2.Валюта = Дубль;
		Запись2.Курс   = 20;
		
		Запись2 = Набор2.Добавить();
		Запись2.Период = Дата(2014, 01, 01);
		Запись2.Валюта = Дубль;
		Запись2.Курс   = 80;
		
		Набор1.Записать(Истина);
		Набор2.Записать(Истина);
	КонецЦикла;
	
КонецПроцедуры

Процедура СоздатьЗаписиВРегистреСведенийРаботникиОрганизаций(Настройки, Результат)
	// На базе регистра _ДемоРаботникиОрганизаций тестируется исключение поиска ссылок.
	Сценарий = "ЗаменаСсылокВРегистрахСведений";
	
	ШаблонНаименованияОрганизации = НСтр("ru = 'Организация %1 (тест дублей)'");
	
	// Измерения в виде директив.
	ВариантыЗаписей = Новый Массив;
	ВариантыЗаписей.Добавить(Новый Структура("СоздаватьОригинал, СоздаватьДубль", Истина, Ложь));
	ВариантыЗаписей.Добавить(Новый Структура("СоздаватьОригинал, СоздаватьДубль", Ложь, Истина));
	ВариантыЗаписей.Добавить(Новый Структура("СоздаватьОригинал, СоздаватьДубль", Истина, Истина));
	
	// Для ресурса ПодразделениеОрганизации требуется 2 уникальные ссылки.
	СсылкиПодразделений = Новый Массив;
	ШаблонНаименования = НСтр("ru = 'Ресурс %1 (тест дублей)'");
	Для НомерЭлемента = 1 По 5 Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(НомерЭлемента, "ЧГ="));
		Подразделение = Справочники._ДемоПодразделения.НайтиПоНаименованию(Наименование);
		Если Не ЗначениеЗаполнено(Подразделение) Тогда
			СправочникОбъект = Справочники._ДемоПодразделения.СоздатьЭлемент();
			СправочникОбъект.Наименование = Наименование;
			ЗаписатьОбъект(Настройки, СправочникОбъект);
			Подразделение = СправочникОбъект.Ссылка;
		КонецЕсли;
		СсылкиПодразделений.Добавить(Подразделение);
		Зарегистрировать(Результат, Сценарий, Подразделение, Истина);
	КонецЦикла;
	
	// Ресурсы можно более конкретно - в виде ссылок.
	ВариантыПоПодразделениям = Новый Массив;
	ВариантыПоПодразделениям.Добавить(Новый Структура("Оригинал, Дубль", Неопределено, СсылкиПодразделений[0]));
	ВариантыПоПодразделениям.Добавить(Новый Структура("Оригинал, Дубль", СсылкиПодразделений[1], Неопределено));
	ВариантыПоПодразделениям.Добавить(Новый Структура("Оригинал, Дубль", СсылкиПодразделений[2], СсылкиПодразделений[2]));
	ВариантыПоПодразделениям.Добавить(Новый Структура("Оригинал, Дубль", СсылкиПодразделений[3], СсылкиПодразделений[4]));
	
	ВариантыПоСтавкам = Новый Массив;
	ВариантыПоСтавкам.Добавить(Новый Структура("Оригинал, Дубль", 0, 1));
	ВариантыПоСтавкам.Добавить(Новый Структура("Оригинал, Дубль", 2, 0));
	ВариантыПоСтавкам.Добавить(Новый Структура("Оригинал, Дубль", 3, 3));
	ВариантыПоСтавкам.Добавить(Новый Структура("Оригинал, Дубль", 4, 5));
	
	ВариантыПоНомерам = Новый Массив;
	ВариантыПоНомерам.Добавить(Новый Структура("Оригинал, Дубль", "", "А"));
	ВариантыПоНомерам.Добавить(Новый Структура("Оригинал, Дубль", "Б", ""));
	ВариантыПоНомерам.Добавить(Новый Структура("Оригинал, Дубль", "В", "В"));
	ВариантыПоНомерам.Добавить(Новый Структура("Оригинал, Дубль", "Г", "Д"));
	
	ШаблонНаименования = Настройки.РегистрыСведенийПрефикс;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	_ДемоФизическиеЛица.Ссылка,
	|	_ДемоФизическиеЛица.Наименование,
	|	_ДемоФизическиеЛица.КемВыданДокумент
	|ИЗ
	|	Справочник._ДемоФизическиеЛица КАК _ДемоФизическиеЛица
	|ГДЕ
	|	_ДемоФизическиеЛица.Наименование ПОДОБНО &ШаблонНаименования СПЕЦСИМВОЛ ""~""";
	ШаблонНаименованияДляЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, "%");
	Запрос.УстановитьПараметр("ШаблонНаименования", ОбщегоНазначения.СформироватьСтрокуДляПоискаВЗапросе(ШаблонНаименованияДляЗапроса));
	УжеСозданныеОбъекты = Запрос.Выполнить().Выгрузить();
	
	Для НомерЭлемента = 1 По Настройки.РегистрыСведенийКоличество Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(НомерЭлемента, "ЧГ="));
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, КемВыданДокумент", Наименование, "Оригинал"));
		Если Найденные.Количество() = 0 Тогда
			СправочникОбъект = Справочники._ДемоФизическиеЛица.СоздатьЭлемент();
			СправочникОбъект.Наименование = Наименование;
			СправочникОбъект.КемВыданДокумент = "Оригинал";
			ЗаписатьОбъект(Настройки, СправочникОбъект);
			Оригинал = СправочникОбъект.Ссылка;
		Иначе
			Оригинал = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Оригинал, Истина);
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, КемВыданДокумент", Наименование, "Дубль"));
		Если Найденные.Количество() = 0 Тогда
			СправочникОбъект = Справочники._ДемоФизическиеЛица.СоздатьЭлемент();
			СправочникОбъект.Наименование = Наименование;
			СправочникОбъект.КемВыданДокумент = "Дубль";
			ЗаписатьОбъект(Настройки, СправочникОбъект, , Ложь);
			Дубль = СправочникОбъект.Ссылка;
		Иначе
			Дубль = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Дубль, Истина, Оригинал);
		
		Набор1 = РегистрыСведений._ДемоРаботникиОрганизаций.СоздатьНаборЗаписей();
		Набор1.Отбор.ФизическоеЛицо.Установить(Оригинал);
		Набор2 = РегистрыСведений._ДемоРаботникиОрганизаций.СоздатьНаборЗаписей();
		Набор2.Отбор.ФизическоеЛицо.Установить(Дубль);
		
		Период = НачалоГода(ТекущаяДатаСеанса());
		
		//   - 3 вида пересечения по измерениям:
		//       - есть запись по дублю, но нет записи по оригиналу
		//       - есть запись по оригиналу, но нет записи по дублю
		//       - есть обе записи.
		НомерВарианта = 0;
		Для Каждого НастройкаЗаписи Из ВариантыЗаписей Цикл
			Для Каждого НастройкаПодразделения Из ВариантыПоПодразделениям Цикл
				Для Каждого НастройкаСтавки Из ВариантыПоСтавкам Цикл
					Для Каждого НастройкаНомера Из ВариантыПоНомерам Цикл
						НомерВарианта = НомерВарианта + 1;
						
						// Ссылка для измерения Организация.
						Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименованияОрганизации, Формат(НомерЭлемента*НомерВарианта, "ЧГ="));
						Организация = Справочники._ДемоОрганизации.НайтиПоНаименованию(Наименование);
						Если Не ЗначениеЗаполнено(Организация) Тогда
							СправочникОбъект = Справочники._ДемоОрганизации.СоздатьЭлемент();
							СправочникОбъект.Наименование            = Наименование;
							СправочникОбъект.НаименованиеСокращенное = Наименование;
							Адрес = СправочникОбъект.КонтактнаяИнформация.Добавить();
							Адрес.Тип = Перечисления.ТипыКонтактнойИнформации.Адрес;
							Адрес.Вид = УправлениеКонтактнойИнформацией.ВидКонтактнойИнформацииПоИмени("_ДемоЮридическийАдресОрганизации");
							Адрес.ЗначенияПолей = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияПоПредставлению(НСтр("ru='г.Москва, Дмитровское шоссе, д.9'"), Адрес.Вид);
							Адрес.Представление = НСтр("ru='Тестовый Адрес'");
							ЗаписатьОбъект(Настройки, СправочникОбъект);
							Организация = СправочникОбъект.Ссылка;
						КонецЕсли;
						Зарегистрировать(Результат, Сценарий, Организация, Истина);
						
						Если НастройкаЗаписи.СоздаватьОригинал Тогда
							Запись1 = Набор1.Добавить();
							Запись1.Период         = Период;
							Запись1.Активность     = Истина;
							Запись1.Организация    = Организация;
							Запись1.ФизическоеЛицо = Оригинал;
							Запись1.ПодразделениеОрганизации = НастройкаПодразделения.Оригинал;
							Запись1.ЗанимаемыхСтавок         = НастройкаСтавки.Оригинал;
							Запись1.ТабельныйНомер           = НастройкаНомера.Оригинал;
						КонецЕсли;
						
						Если НастройкаЗаписи.СоздаватьДубль Тогда
							Запись2 = Набор2.Добавить();
							Запись2.Период         = Период;
							Запись2.Активность     = Истина;
							Запись2.Организация    = Организация;
							Запись2.ФизическоеЛицо = Дубль;
							Запись2.ПодразделениеОрганизации = НастройкаПодразделения.Дубль;
							Запись2.ЗанимаемыхСтавок         = НастройкаСтавки.Дубль;
							Запись2.ТабельныйНомер           = НастройкаНомера.Дубль;
						КонецЕсли;
						
					КонецЦикла;
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
		
		Набор1.Записать(Истина);
		Набор2.Записать(Истина);
	КонецЦикла;
	
КонецПроцедуры

Процедура СоздатьЗаписиВРегистреСведенийЗаведующиеМестамиХранения(Настройки, Результат)
	// На базе регистра _ДемоЗаведующиеМестамиХранения тестируется дата запрета (29.02.2012).
	Сценарий = "ЗаменаСсылокВРегистрахСведений";
	
	// Для измерения МестоХранения требуется 1 ссылка.
	Суффикс = " (" + НСтр("ru = 'Тест поиска и удаления дублей № 3'") + ")";
	Наименование = НСтр("ru = 'Склад'") + Суффикс;
	Склад = Справочники._ДемоМестаХранения.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(Склад) Тогда
		СправочникОбъект = Справочники._ДемоМестаХранения.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Склад = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Склад, Истина);
	
	ШаблонНаименования = Настройки.РегистрыСведенийПрефикс;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка,
	|	Пользователи.Наименование,
	|	Пользователи.Комментарий
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Наименование ПОДОБНО &ШаблонНаименования СПЕЦСИМВОЛ ""~""";
	ШаблонНаименованияДляЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, "%");
	Запрос.УстановитьПараметр("ШаблонНаименования", ОбщегоНазначения.СформироватьСтрокуДляПоискаВЗапросе(ШаблонНаименованияДляЗапроса));
	УжеСозданныеОбъекты = Запрос.Выполнить().Выгрузить();
	
	Для НомерЭлемента = 1 По Настройки.РегистрыСведенийКоличество Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(НомерЭлемента, "ЧГ="));
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Комментарий", Наименование, "Оригинал"));
		Если Найденные.Количество() = 0 Тогда
			ОригиналОбъект = Справочники.Пользователи.СоздатьЭлемент();
			ОригиналОбъект.Наименование = Наименование;
			ОригиналОбъект.Комментарий = "Оригинал";
			ЗаписатьОбъект(Настройки, ОригиналОбъект);
			Оригинал = ОригиналОбъект.Ссылка;
		Иначе
			Оригинал = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Оригинал, Истина);
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Комментарий", Наименование, "Дубль"));
		Если Найденные.Количество() = 0 Тогда
			ДубльОбъект = Справочники.Пользователи.СоздатьЭлемент();
			ДубльОбъект.Наименование = Наименование;
			ДубльОбъект.Комментарий = "Дубль";
			ДубльОбъект.Записать();
			Дубль = ДубльОбъект.Ссылка;
		Иначе
			Дубль = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Дубль, Истина, Оригинал);
		
		Набор = РегистрыСведений._ДемоЗаведующиеМестамиХранения.СоздатьНаборЗаписей();
		Набор.Отбор.МестоХранения.Установить(Склад);
		
		Запись = Набор.Добавить();
		Запись.Период        = Дата(2001, 01, 01);
		Запись.Пользователь  = Оригинал;
		Запись.МестоХранения = Склад;
		
		Запись = Набор.Добавить();
		Запись.Период        = Дата(2004, 02, 01);
		Запись.Пользователь  = Дубль;
		Запись.МестоХранения = Склад;
		
		Запись = Набор.Добавить();
		Запись.Период        = Дата(2006, 02, 01);
		Запись.Пользователь  = Оригинал;
		Запись.МестоХранения = Склад;
		
		Набор.Записать(Истина);
	КонецЦикла;
КонецПроцедуры

Процедура СоздатьДублиИспользующиесяВРегистрахНакопления(Настройки, Результат)
	// РЕГИСТР НАКОПЛЕНИЯ.
	Сценарий = "ЗаменаСсылокВРегистрахНакопления";
	
	// На базе регистра _ДемоОстаткиТоваровВМестахХранения тестируется следующие варианты:
	//   2 вида измерений:
	//     * Регистратор (ДокументСсылка._ДемоПоступлениеТоваров).
	//     * Организация (СправочникСсылка._ДемоОрганизации).
	//     По измерениям тестируется 3 вида пересечения данных:
	//       - есть запись по дублю, но нет записи по оригиналу
	//       - есть запись по оригиналу, но нет записи по дублю
	//       - есть обе записи.
	//     Однако, поскольку Организация указывается в шапке документа _ДемоПоступлениеТоваров,
	//     то измерение Организация не может отличаться для одного регистратора.
	//     Поэтому измерение Организация не тестируем (генерируем 1 организацию).
	//   1 вид ресурсов:
	//     * Количество (Число, 15, 3).
	//     По ресурсам тестируется 4 вида их заполнения:
	//       - Заполнено и не совпадает.
	//       - Не заполнено в дубле.
	//       - Не заполнено в оригинале.
	//     Не смогли протестировать варианты "не заполнено", т.к. нельзя проводить документы с нулевым количеством номенклатуры.
	// 3^1*4^1 = 12 вариантов.
	//   Под каждый вариант нужно создать 12 документов _ДемоПоступлениеТоваров.
	
	// Ссылка для измерения Организация.
	ШаблонНаименования = НСтр("ru = 'Организация %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	Организация = Справочники._ДемоОрганизации.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(Организация) Тогда
		СправочникОбъект = Справочники._ДемоОрганизации.СоздатьЭлемент();
		СправочникОбъект.Наименование            = Наименование;
		СправочникОбъект.НаименованиеСокращенное = Наименование;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Организация = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Организация, Истина);
	
	// Для измерения МестоХранения требуется 1 ссылка.
	ШаблонНаименования = НСтр("ru = 'Склад %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	МестоХранения = Справочники._ДемоМестаХранения.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(МестоХранения) Тогда
		СправочникОбъект = Справочники._ДемоМестаХранения.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		МестоХранения = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, МестоХранения, Истина);
	
	// Для документа _ДемоПоступлениеТоваров требуется 1 партнер.
	ШаблонНаименования = НСтр("ru = 'Партнер %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	Партнер = Справочники._ДемоПартнеры.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(Партнер) Тогда
		СправочникОбъект = Справочники._ДемоПартнеры.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		СправочникОбъект.ВидПартнера = Перечисления._ДемоЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Партнер = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Партнер, Истина);
	
	// Для документа _ДемоПоступлениеТоваров требуется 1 контрагент.
	ШаблонНаименования = НСтр("ru = 'Контрагент %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	Контрагент = Справочники._ДемоКонтрагенты.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(Контрагент) Тогда
		СправочникОбъект = Справочники._ДемоКонтрагенты.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		СправочникОбъект.ВидКонтрагента = Перечисления._ДемоЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Контрагент = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Контрагент, Истина);
	
	// Для договора требуется 1 валюта.
	Валюта = Справочники.Валюты.НайтиПоНаименованию("RUB");
	Если Не ЗначениеЗаполнено(Валюта) Тогда
		СправочникОбъект = Справочники.Валюты.СоздатьЭлемент();
		СправочникОбъект.Наименование = "RUB";
		СправочникОбъект.НаименованиеПолное = НСтр("ru = 'Российский рубль'");
		СправочникОбъект.Записать();
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Валюта = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Валюта, Ложь);
	
	// Для документа _ДемоПоступлениеТоваров требуется 1 договор.
	ШаблонНаименования = НСтр("ru = 'Договор %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	Договор = Справочники._ДемоДоговорыКонтрагентов.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(Договор) Тогда
		СправочникОбъект = Справочники._ДемоДоговорыКонтрагентов.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		СправочникОбъект.Организация = Организация;
		СправочникОбъект.Владелец = Контрагент;
		СправочникОбъект.Партнер = Партнер;
		СправочникОбъект.ВалютаРасчетов = Валюта;
		СправочникОбъект.Записать();
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		Договор = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, Договор, Истина);
	
	// Для справочника _ДемоНоменклатура требуется 1 вид.
	ШаблонНаименования = НСтр("ru = 'Вид номенклатуры %1 (тест дублей)'");
	Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(1, "ЧГ="));
	ВидНоменклатуры = Справочники._ДемоВидыНоменклатуры.НайтиПоНаименованию(Наименование);
	Если Не ЗначениеЗаполнено(ВидНоменклатуры) Тогда
		СправочникОбъект = Справочники._ДемоВидыНоменклатуры.СоздатьЭлемент();
		СправочникОбъект.Наименование = Наименование;
		ЗаписатьОбъект(Настройки, СправочникОбъект);
		ВидНоменклатуры = СправочникОбъект.Ссылка;
	КонецЕсли;
	Зарегистрировать(Результат, Сценарий, ВидНоменклатуры, Истина);
	
	ШаблонНаименования = Настройки.РегистрыНакопленияПрефикс;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	_ДемоНоменклатура.Ссылка,
	|	_ДемоНоменклатура.Наименование,
	|	_ДемоНоменклатура.Артикул
	|ИЗ
	|	Справочник._ДемоНоменклатура КАК _ДемоНоменклатура
	|ГДЕ
	|	_ДемоНоменклатура.Наименование ПОДОБНО &ШаблонНаименования СПЕЦСИМВОЛ ""~""";
	ШаблонНаименованияДляЗапроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, "%");
	Запрос.УстановитьПараметр("ШаблонНаименования", ОбщегоНазначения.СформироватьСтрокуДляПоискаВЗапросе(ШаблонНаименованияДляЗапроса));
	УжеСозданныеОбъекты = Запрос.Выполнить().Выгрузить();
	
	Период = НачалоГода(ТекущаяДатаСеанса());
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПоступлениеТоваров.Ссылка
	|ИЗ
	|	Документ._ДемоПоступлениеТоваров КАК ПоступлениеТоваров
	|ГДЕ
	|	ПоступлениеТоваров.Дата = &Период
	|	И ПоступлениеТоваров.Организация = &Организация
	|	И ПоступлениеТоваров.МестоХранения = &МестоХранения
	|	И ПоступлениеТоваров.Партнер = &Партнер
	|	И ПоступлениеТоваров.Контрагент = &Контрагент
	|	И ПоступлениеТоваров.Договор = &Договор";
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("МестоХранения", МестоХранения);
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("Договор", Договор);
	УжеСозданныеДокументы = Запрос.Выполнить().Выгрузить();
	
	Для НомерЭлемента = 1 По Настройки.РегистрыНакопленияКоличество Цикл
		Наименование = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонНаименования, Формат(НомерЭлемента, "ЧГ="));
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Артикул", Наименование, "Оригинал"));
		Если Найденные.Количество() = 0 Тогда
			СправочникОбъект = Справочники._ДемоНоменклатура.СоздатьЭлемент();
			СправочникОбъект.Наименование    = Наименование;
			СправочникОбъект.ВидНоменклатуры = ВидНоменклатуры;
			СправочникОбъект.Артикул = "Оригинал";
			ЗаписатьОбъект(Настройки, СправочникОбъект);
			Оригинал = СправочникОбъект.Ссылка;
		Иначе
			Оригинал = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Оригинал, Истина);
		
		Найденные = УжеСозданныеОбъекты.НайтиСтроки(Новый Структура("Наименование, Артикул", Наименование, "Дубль"));
		Если Найденные.Количество() = 0 Тогда
			СправочникОбъект = Справочники._ДемоНоменклатура.СоздатьЭлемент();
			СправочникОбъект.Наименование    = Наименование;
			СправочникОбъект.ВидНоменклатуры = ВидНоменклатуры;
			СправочникОбъект.Артикул = "Дубль";
			ЗаписатьОбъект(Настройки, СправочникОбъект, Ложь, Ложь);
			Дубль = СправочникОбъект.Ссылка;
		Иначе
			Дубль = Найденные[0].Ссылка;
		КонецЕсли;
		Зарегистрировать(Результат, Сценарий, Дубль, Истина, Оригинал);
		
		Если УжеСозданныеДокументы.Количество() = 0 Тогда
			ДокументОбъект = Документы._ДемоПоступлениеТоваров.СоздатьДокумент();
			ДокументОбъект.Дата          = Период;
			ДокументОбъект.Организация   = Организация;
			ДокументОбъект.МестоХранения = МестоХранения;
			ДокументОбъект.Партнер       = Партнер;
			ДокументОбъект.Контрагент    = Контрагент;
			ДокументОбъект.Договор       = Договор;
		Иначе
			ДокументОбъект = УжеСозданныеДокументы[0].Ссылка.ПолучитьОбъект();
		КонецЕсли;
		
		// 3 вида пересечения по измерениям:
		// - есть запись по дублю, но нет записи по оригиналу
		// - есть запись по оригиналу, но нет записи по дублю
		// - есть обе записи.
		СтруктураЗаполнения = Новый Структура("Номенклатура, Количество, Цена", Оригинал, 3, 1);
		Найденные = ДокументОбъект.Товары.НайтиСтроки(СтруктураЗаполнения);
		Если Найденные.Количество() = 0 Тогда
			ЗаполнитьЗначенияСвойств(ДокументОбъект.Товары.Добавить(), СтруктураЗаполнения);
		КонецЕсли;
		
		СтруктураЗаполнения = Новый Структура("Номенклатура, Количество, Цена", Дубль, 5, 1);
		Найденные = ДокументОбъект.Товары.НайтиСтроки(СтруктураЗаполнения);
		Если Найденные.Количество() = 0 Тогда
			ЗаполнитьЗначенияСвойств(ДокументОбъект.Товары.Добавить(), СтруктураЗаполнения);
		КонецЕсли;
		
		ЗаписатьОбъект(Настройки, ДокументОбъект);
		ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
		Зарегистрировать(Результат, Сценарий, ДокументОбъект.Ссылка, Ложь);
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписатьОбъект(Настройки, Объект, ПроверятьЗаполнение = Неопределено, ВключитьБизнесЛогику = Истина)
	Если ПроверятьЗаполнение = Неопределено Тогда
		ПроверятьЗаполнение = Настройки.ПроверятьЗаполнение;
	КонецЕсли;
	Если ПроверятьЗаполнение И Не Объект.ПроверитьЗаполнение() Тогда
		Сообщения = ПолучитьСообщенияПользователю(Истина);
		Подробно = "";
		Для Каждого СообщениеОтОбъекта Из Сообщения Цикл
			Подробно = СокрП(Подробно + Символы.ПС + Символы.ПС + СокрЛ(СообщениеОтОбъекта.Текст));
		КонецЦикла;
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось записать %1 ""%2"" по причине:
				|%3'"),
			ТипЗнч(Объект),
			Строка(Объект), Подробно);
	КонецЕсли;
	ОбновлениеИнформационнойБазы.ЗаписатьОбъект(Объект, Истина, ВключитьБизнесЛогику);
КонецПроцедуры

Процедура Зарегистрировать(Результат, Сценарий, Ссылка, Пометка, СсылкаОригинала = Неопределено)
	СтрокаТаблицы = Результат.СозданныеОбъекты.Добавить();
	СтрокаТаблицы.Сценарий = Сценарий;
	СтрокаТаблицы.Ссылка = Ссылка;
	СтрокаТаблицы.Тип = ТипЗнч(Ссылка);
	СтрокаТаблицы.Пометка = Пометка;
	
	Если СсылкаОригинала <> Неопределено Тогда
		СтрокаТаблицы.ЭтоДубль = Истина;
		СтрокаТаблицы.Оригинал = СсылкаОригинала;
		Если Результат.ТипыДублей.Найти(СтрокаТаблицы.Тип) = Неопределено Тогда
			Результат.ТипыДублей.Добавить(СтрокаТаблицы.Тип);
		КонецЕсли;
	КонецЕсли;
	
	ОбъектМетаданных = Метаданные.НайтиПоТипу(СтрокаТаблицы.Тип);
	ПолноеИмя = ВРег(ОбъектМетаданных.ПолноеИмя());
	СтрокаТаблицы.Вид = Лев(ПолноеИмя, СтрНайти(ПолноеИмя, ".")-1);
	Если СтрокаТаблицы.Вид = "СПРАВОЧНИК"
		Или СтрокаТаблицы.Вид = "ДОКУМЕНТ"
		Или СтрокаТаблицы.Вид = "ПЕРЕЧИСЛЕНИЕ"
		Или СтрокаТаблицы.Вид = "ПЛАНВИДОВХАРАКТЕРИСТИК"
		Или СтрокаТаблицы.Вид = "ПЛАНСЧЕТОВ"
		Или СтрокаТаблицы.Вид = "ПЛАНВИДОВРАСЧЕТА"
		Или СтрокаТаблицы.Вид = "БИЗНЕСПРОЦЕСС"
		Или СтрокаТаблицы.Вид = "ЗАДАЧА"
		Или СтрокаТаблицы.Вид = "ПЛАНОБМЕНА" Тогда
		СтрокаТаблицы.Ссылочный = Истина;
	КонецЕсли;
	
КонецПроцедуры

// АПК:1328-вкл

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли