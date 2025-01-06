#Область СлужебныйПрограммныйИнтерфейс

// Информация о подключении локальной базы к службе поддержки
// 
// Возвращаемое значение:
//  Структура - содержит поля:
//  	* АдресВнешнегоАнонимногоИнтерфейсаУСП - Строка - адрес http-сервиса ext_sd службы поддержки
//  	* АдресАнонимногоСервисаИнтеграцииСИнформационнымЦентромУСП - Строка - адрес web-сервиса службы поддержки
//  	* ПодтвержденКодДляИнтеграцииСУСП - Булево - если Истина, то база подключена к службе поддержки
//  	* АдресПочтыАбонентаДляИнтеграцииСУСП - Строка - E-mail пользователя, 
//			от имени которого локальной база подключена к службе поддержки
//  	* КодРегистрацииВУСП - Строка - код, при помощи которого база зарегистрирована в службе поддержки
//
Функция ДанныеНастроекИнтеграцииСУСП() Экспорт
	
	Возврат ИнформационныйЦентрСервер.ДанныеНастроекИнтеграцииСУСП();
	
КонецФункции

// Проверяет код пользователя для работы со службой поддержки.
//
// Параметры:
//  КодПользователя	 - Строка - проверяемый код
//  Email			 - Строка - e-mail пользователя, код которого проверяется
// 
// Возвращаемое значение:
//  Структура - с полями:
//  	* КодВерный - Булево
//  	* ТекстСообщения - Строка - заполянется, если код некорректен
//
Функция ПроверитьКодПользователя(КодПользователя, Email) Экспорт
	
	Возврат ИнформационныйЦентрСервер.ПроверитьКодПользователя(КодПользователя, Email);
	
КонецФункции


// Email пользователя для работы с обращениями
// 
// Возвращаемое значение:
//  Строка - e-mail
//
Функция EmailПользователя() Экспорт
	
	Возврат ПользователиСлужебный.ОписаниеПользователя(Пользователи.АвторизованныйПользователь()).АдресЭлектроннойПочты;
	
КонецФункции

Процедура СохранитьКодПользователя(Знач ИмяКомпьютера = Неопределено, 
	Знач ЧастьКодаИБ = "", Знач ВременныйФайлЧастиКода) Экспорт
	
	Если ИмяКомпьютера = Неопределено Тогда // веб-клиент
		Возврат;
	КонецЕсли;
	
	ХешИмениКомпьютера = ХешСуммаCRC32(ИмяКомпьютера);
	
	КодНаКомпьютере = Новый Структура;
	КодНаКомпьютере.Вставить("ЧастьКодаВИБ", ЧастьКодаИБ);
	КодНаКомпьютере.Вставить("ВременныйФайлЧастиКода", ВременныйФайлЧастиКода);
	
	КодыНаКомпьютерах = Новый Соответствие;
	КодыНаКомпьютерах.Вставить(ХешИмениКомпьютера, КодНаКомпьютере);
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(
		Пользователи.ТекущийПользователь(), КодыНаКомпьютерах, "ДанныеАвторизацииВСлужбеПоддержки");
	
КонецПроцедуры

// Прочитать код пользователя.
// 
// Параметры:
//  ИмяКомпьютера - Строка - имя компьютера
// 
// Возвращаемое значение:
//  Строка - код пользователя.
Функция ПрочитатьКодПользователя(Знач ИмяКомпьютера) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	КодыНаКомпьютерах = ОбщегоНазначения.ПрочитатьДанныеИзБезопасногоХранилища(
		Пользователи.ТекущийПользователь(), "ДанныеАвторизацииВСлужбеПоддержки");
		
	Если КодыНаКомпьютерах = Неопределено Тогда
		Возврат "";
	КонецЕсли;
		
	ХешИмениКомпьютера = ХешСуммаCRC32(ИмяКомпьютера);
	
	КодНаКомпьютере = КодыНаКомпьютерах.Получить(ХешИмениКомпьютера);
	
	Если КодНаКомпьютере = Неопределено Тогда
		Возврат "";
	КонецЕсли;
	
	Если Тип(КодНаКомпьютере) <> Тип("Структура") Тогда
		Возврат "";
	КонецЕсли;
	
	Если Не КодНаКомпьютере.Свойство("ЧастьКодаВИБ") 
		Или Не ЗначениеЗаполнено(КодНаКомпьютере.ЧастьКодаВИБ) Тогда
		Возврат "";
	КонецЕсли;
	
	Если Не КодНаКомпьютере.Свойство("ВременныйФайлЧастиКода") 
		Или Не ЗначениеЗаполнено(КодНаКомпьютере.ВременныйФайлЧастиКода) Тогда
		Возврат "";
	КонецЕсли;
	
	Возврат КодНаКомпьютере;
	
КонецФункции

// Записывает предупреждение в ЖР.
//
Процедура ЗаписатьПредупреждение(ТекстПредупреждения) Экспорт
	
	ЗаписьЖурналаРегистрации(
		ИнформационныйЦентрСервер.ПолучитьИмяСобытияДляЖурналаРегистрации(), 
		УровеньЖурналаРегистрации.Предупреждение,,,
		ТекстПредупреждения);
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает хеш-сумму данных по алгоритму CRC32.
//
// Параметры:
//   Данные - Строка, ДвоичныеДанные - данные для расчета.
//
// Возвращаемое значение:
//   Число - хеш-сумма, рассчитанная по алгоритму CRC32.
//
Функция ХешСуммаCRC32(Данные)

	ХешированиеДанных = Новый ХешированиеДанных(ХешФункция.CRC32);
	ХешированиеДанных.Добавить(Данные);
	
	Возврат ХешированиеДанных.ХешСумма;

КонецФункции

#КонецОбласти