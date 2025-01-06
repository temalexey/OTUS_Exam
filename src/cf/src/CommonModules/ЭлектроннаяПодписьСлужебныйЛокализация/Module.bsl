///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Определяет внутренний идентификатор классификатора для подсистемы РаботаСКлассификаторами.
//
// Возвращаемое значение:
//  Строка - идентификатор классификатора.
//
Функция ИдентификаторКлассификатора() Экспорт
	
	Возврат "AccreditedCA";

КонецФункции

// См. РаботаСКлассификаторамиПереопределяемый.ПриЗагрузкеКлассификатора.
Процедура ЗагрузитьДанныеАккредитованныхУЦ(Версия, Адрес, Обработан, ДополнительныеПараметры) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеУЦ = ПрочитатьАрхивКлассификатора(Адрес, Версия);
	
	ХранилищеЗначения = Новый ХранилищеЗначения(ДанныеУЦ, Новый СжатиеДанных(6));
	УстановитьПривилегированныйРежим(Истина);
	Константы.АккредитованныеУдостоверяющиеЦентры.Установить(ХранилищеЗначения);
	
	Обработан = Истина;
		
КонецПроцедуры 

Функция ОбновитьКлассификатор() Экспорт
	
	ДатаПоследнегоОбновления = Константы.ДатаПоследнегоОбновленияКлассификатораОшибок.Получить();
	ДатаПоследнегоИзменения = Неопределено;
	
	АдресКлассификатора = АдресКлассификатораОшибок();
	ПолныйАдрес = АдресКлассификатора.Протокол + АдресКлассификатора.АдресСервера + "/" + АдресКлассификатора.АдресРесурса;
	ДанныеКлассификатора = Неопределено;
	ТекстОшибки = "";
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		
		МодульПолучениеФайловИзИнтернетаКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернетаКлиентСервер");
		ПараметрыПолученияФайла = МодульПолучениеФайловИзИнтернетаКлиентСервер.ПараметрыПолученияФайла();
		ПараметрыПолученияФайла.Заголовки.Вставить("If-Modified-Since", 
			ОбщегоНазначенияКлиентСервер.ДатаHTTP(ДатаПоследнегоОбновления));
		
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		РезультатЗагрузки = МодульПолучениеФайловИзИнтернета.СкачатьФайлВоВременноеХранилище(
			ПолныйАдрес, ПараметрыПолученияФайла, Ложь);
			
		Если РезультатЗагрузки.КодСостояния = 304 Тогда // Классификатор не был обновлен.
			Возврат "";
		ИначеЕсли РезультатЗагрузки.Статус Тогда
			ДатаПоследнегоИзменения = ЭлектроннаяПодписьСлужебный.ДатаПоследнегоИзмененияФайла(РезультатЗагрузки);
			ДанныеКлассификатора = ПолучитьИзВременногоХранилища(РезультатЗагрузки.Путь);
			УдалитьИзВременногоХранилища(РезультатЗагрузки.Путь);
		Иначе
			Возврат РезультатЗагрузки.СообщениеОбОшибке;
		КонецЕсли;
		
	Иначе
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Отсутствует подсистема ""%1"".'"),
			"СтандартныеПодсистемы.ПолучениеФайловИзИнтернета");
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекстОшибки)
	   И Не ЗначениеЗаполнено(ДанныеКлассификатора) Тогда
		
		ТекстОшибки = НСтр("ru = 'Получены пустые данные.'");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось загрузить классификатор по адресу:
			           |%1
			           |по причине:
			           |%2'"),
			ПолныйАдрес,
			ТекстОшибки);
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.ЗаписатьДанныеКлассификатора(ДанныеКлассификатора, ДатаПоследнегоИзменения);
	
	Возврат "";
	
КонецФункции

Функция КлассификаторОшибокКриптографии() Экспорт
	
	ОбработкаПрограммыЭлектроннойПодписиИШифрования = Метаданные.Обработки.Найти(
		"ПрограммыЭлектроннойПодписиИШифрования");

	Если ОбработкаПрограммыЭлектроннойПодписиИШифрования = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ЭлектроннаяПодписьСлужебный.ПредставлениеКлассификатораОшибок(
		Обработки["ПрограммыЭлектроннойПодписиИШифрования"].ПолучитьМакет("КлассификаторОшибокКриптографии"));
	
КонецФункции

Функция АккредитованныеУдостоверяющиеЦентры() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ДанныеУдостоверяющихЦентров = Константы.АккредитованныеУдостоверяющиеЦентры.Получить().Получить();
	
	Если ДанныеУдостоверяющихЦентров = Неопределено 
		Или Не ДанныеУдостоверяющихЦентров.Свойство("ДругиеНастройки")
		Или ДанныеУдостоверяющихЦентров.ДатыОкончанияДействия.Версия < 24 Тогда
		
		ДанныеУдостоверяющихЦентров = ДанныеУдостоверяющихЦентровИзМакета();
		Если ДанныеУдостоверяющихЦентров = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
	КонецЕсли;
	
	РазрешенныеНеаккредитованныеУЦ = Новый Соответствие;
	
	МассивЗначенийПоиска = СтрРазделить(Константы.РазрешенныеНеаккредитованныеУЦ.Получить(), ",;" + Символы.ПС, Ложь);
	Для Каждого ТекущееЗначениеПоиска Из МассивЗначенийПоиска Цикл
		ЗначениеПоиска = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(ТекущееЗначениеПоиска);
		Если Не ЗначениеЗаполнено(ЗначениеПоиска) Тогда
			Продолжить;
		КонецЕсли;
		РазрешенныеНеаккредитованныеУЦ.Вставить(СокрЛП(ЗначениеПоиска), Истина);
	КонецЦикла;
	
	Результат = Новый Структура;
	Результат.Вставить("ПериодыДействия", ДанныеУдостоверяющихЦентров.ПериодыДействия.Данные);
	Результат.Вставить("ДатаОбновления", ДанныеУдостоверяющихЦентров.ПериодыДействия.ДатаОбновления);
	Результат.Вставить("ДатыОкончанияДействия", ДанныеУдостоверяющихЦентров.ДатыОкончанияДействия.Данные);
	Результат.Вставить("ГосударственныеУЦ", ДанныеУдостоверяющихЦентров.ГосударственныеУЦ);
	Результат.Вставить("РазрешенныеНеаккредитованныеУЦ", РазрешенныеНеаккредитованныеУЦ);
	Результат.Вставить("ДругиеНастройки", ДанныеУдостоверяющихЦентров.ДругиеНастройки);
	
	Возврат Результат;
	
КонецФункции

Функция ДоступностьСозданияЗаявления() Экспорт

	ЗаявлениеДоступно = ЭлектроннаяПодпись.ОбщиеНастройки().ЗаявлениеНаВыпускСертификатаДоступно;
	МосковскоеВремя = НачалоДня(МосковскоеВремя());

	ДоступностьСозданияЗаявления = Новый Структура;
	ДоступностьСозданияЗаявления.Вставить("ДляФизическихЛиц", ЗаявлениеДоступно И МосковскоеВремя >= '20210401');
	ДоступностьСозданияЗаявления.Вставить("ДляРуководителейЮридическихЛиц", ЗаявлениеДоступно И МосковскоеВремя
		< '20220101');
	ДоступностьСозданияЗаявления.Вставить("ДляСотрудниковЮридическихЛиц", ЗаявлениеДоступно И МосковскоеВремя
		< '20230901');
	ДоступностьСозданияЗаявления.Вставить("ДляИндивидуальныхПредпринимателей", ЗаявлениеДоступно И МосковскоеВремя
		< '20220101');

	Возврат ДоступностьСозданияЗаявления;

КонецФункции

#Область ПолучениеДистрибутивовКриптопровайдеров

// Получает дистрибутив КриптоПро CSP
//
// Параметры:
//  ПараметрыЗагрузки - Структура:
//    * Продукт - Строка - тип продукта КриптоПро (x64/x86) для загрузки.
//    * КонтактноеЛицо - Строка - контактное лицо запросившее дистрибутив.
//    * ЭлектроннаяПочта - Строка - электронная почта для регистрации дистрибутива.
//
Функция ДистрибутивCryptoProCSP(Параметры) Экспорт
	
	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ПараметрыДистрибутива", Неопределено);
	СтруктураВозврата.Вставить("Ошибка", "");
	
	ИмяПрограммыКриптоПро = ЭлектроннаяПодписьКлиентСерверЛокализация.ИмяПрограммыКриптоПро();
	
	АдресЗагрузки = "https://www.cryptopro.ru/products/csp/downloads/kontur";
	ВидОперации = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Получение серийного номера %1'", ОбщегоНазначения.КодОсновногоЯзыка()), ИмяПрограммыКриптоПро);
	
	Попытка
		ОписаниеСоединения = СоединениеССерверомИнтернета(ВидОперации, АдресЗагрузки, 60, Истина);
	Исключение
		СтруктураВозврата.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат СтруктураВозврата;
	КонецПопытки;
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	Запрос = Новый HTTPЗапрос("/products/csp/downloads/kontur", Заголовки);
	
	СтрокаЗапроса = "product=%1&username=%2&email=%3&company=%4";
	СтрокаЗапроса = СтрШаблон(СтрокаЗапроса,
		Параметры.Продукт,
		КодироватьСтроку(Параметры.КонтактноеЛицо, СпособКодированияСтроки.URLВКодировкеURL), 
		КодироватьСтроку(Параметры.ЭлектроннаяПочта, СпособКодированияСтроки.URLВКодировкеURL),
		"");
	
	Запрос.УстановитьТелоИзСтроки(СтрокаЗапроса);
		
	Попытка
		Ответ = ОписаниеСоединения.HTTPСоединение.ОтправитьДляОбработки(Запрос);
	Исключение
		ИнформацияОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка,,, ИнформацияОбОшибке);
		СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сервис получения серийных номеров для %1 временно недоступен. Подробности см. в Журнале регистрации.
				|Повторите попытку позже.'"), ИмяПрограммыКриптоПро);
		Возврат СтруктураВозврата;
	КонецПопытки;
	
	Если Ответ.КодСостояния = 200 И Ответ.Заголовки.Получить("Distribution-Number") <> Неопределено Тогда
		
		Дистрибутив = Ответ.ПолучитьТелоКакДвоичныеДанные();
		ПараметрыДистрибутива = НовыйПараметрыДистрибутива();
		ПараметрыДистрибутива.НомерДистрибутива = Ответ.Заголовки["Distribution-Number"];
		ПараметрыДистрибутива.КонтрольнаяСумма = Ответ.Заголовки["GOST"];
		ПараметрыДистрибутива.Версия = Ответ.Заголовки["Version"];
		
		ВременныйКаталог = ФайловаяСистема.СоздатьВременныйКаталог();
		
		Дистрибутив.Записать(ВременныйКаталог + "Setup.exe");
		
		ПараметрыДистрибутива.ИмяФайлаДистрибутива = "Setup.exe";
		
		Если ЗначениеЗаполнено(Параметры.СерийныйНомер) Тогда
			ПараметрыДистрибутива.КомандаЗапуска = СтрШаблон("%1 -args ""PIDKEY=%2""",
				ПараметрыДистрибутива.ИмяФайлаДистрибутива, Параметры.СерийныйНомер);
		Иначе
			ПараметрыДистрибутива.КомандаЗапуска = ПараметрыДистрибутива.ИмяФайлаДистрибутива;
		КонецЕсли;
			
		Файлы = Новый Массив;
		Для каждого Файл Из НайтиФайлы(ВременныйКаталог, ПолучитьМаскуВсеФайлы()) Цикл
			ОписаниеФайла = Новый Структура;
			ОписаниеФайла.Вставить("Имя", Файл.Имя);
			ОписаниеФайла.Вставить("ДвоичныеДанные", Новый ДвоичныеДанные(Файл.ПолноеИмя));
			Файлы.Добавить(ОписаниеФайла);
		КонецЦикла; 
		ПараметрыДистрибутива.Дистрибутив = Файлы;
		ФайловаяСистема.УдалитьВременныйКаталог(ВременныйКаталог);
	Иначе
		СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка при получении серийного номера %1, подробности см. в журнале регистрации'"),
			ИмяПрограммыКриптоПро);
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	СтруктураВозврата.Вставить("ПараметрыДистрибутива", ПараметрыДистрибутива);
	Возврат СтруктураВозврата;

КонецФункции

// Получает дистрибутив VipNet CSP
//
// Параметры:
//   ПараметрыПоиска - Структура:
//    * Разрядность - Число - разрядность операционной системы (x64/x86) для загрузки дистрибутива.
//    * КонтактноеЛицо - Строка - контактное лицо запросившее дистрибутив.
//    * ЭлектроннаяПочта - Строка - электронная почта для регистрации дистрибутива.
//
// Возвращаемое значение:
//    Структура:
//     * ПараметрыДистрибутива см. НовыйПараметрыДистрибутива
//
Функция ДистрибутивViPNetCSP(Параметры) Экспорт

	ИмяПрограммыVipNet = ЭлектроннаяПодписьКлиентСерверЛокализация.ИмяПрограммыVipNet();

	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("ПараметрыДистрибутива", Неопределено);
	СтруктураВозврата.Вставить("Ошибка", "");
	
	Если Параметры.Разрядность = 64 Тогда
		ВидДистрибутива = "latest_win64bit_all";
	Иначе
		ВидДистрибутива = "latest_win32bit_all";
	КонецЕсли;
	
	АдресЗагрузки = "https://getserial.infotecs.ru/partner/csp/service/GetSerialNumberByAbonentInfo/";
	ВидОперации = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Получение серийного номера %1'", ОбщегоНазначения.КодОсновногоЯзыка()), ИмяПрограммыVipNet);
	
	Попытка
		ОписаниеСоединения = СоединениеССерверомИнтернета(ВидОперации, АдресЗагрузки, 60, Ложь);
	Исключение
		СтруктураВозврата.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат СтруктураВозврата;
	КонецПопытки;
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	Запрос = Новый HTTPЗапрос("/partner/csp/service/GetSerialNumberByAbonentInfo/", Заголовки);
	
	ИдентификаторЗапроса = Строка(Новый УникальныйИдентификатор);
	
	Хеширование = Новый ХешированиеДанных(ХешФункция.MD5);
	Хеширование.Добавить(СокрЛП(ИдентификаторЗапроса) + "1594xV9dHsW7vNN");
	
	MD5 = СтрЗаменить(НРег(Хеширование.ХешСумма), " ", "");
	
	СтрокаЗапроса = "i_id_request=%1&i_id_partner=%2&i_req_sign=%3&i_contact_person=%4&i_email=%5&i_id_file=%6";
	СтрокаЗапроса = СтрШаблон(СтрокаЗапроса, 
		ИдентификаторЗапроса, "1594", MD5, 
		КодироватьСтроку(Параметры.КонтактноеЛицо, СпособКодированияСтроки.URLВКодировкеURL), 
		КодироватьСтроку(Параметры.ЭлектроннаяПочта, СпособКодированияСтроки.URLВКодировкеURL),
		КодироватьСтроку(ВидДистрибутива, СпособКодированияСтроки.URLВКодировкеURL));
	
	Запрос.УстановитьТелоИзСтроки(СтрокаЗапроса);
	
	Попытка
		Ответ = ОписаниеСоединения.HTTPСоединение.ОтправитьДляОбработки(Запрос);
	Исключение
		
		ИнформацияОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка,,, ИнформацияОбОшибке);
		СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сервис получения серийных номеров для %1 временно недоступен. Подробности см. в Журнале регистрации.
			|Повторите попытку позже.'"), ИмяПрограммыVipNet);
		Возврат СтруктураВозврата;
		
	КонецПопытки;
	
	Если Ответ.КодСостояния = 200 Тогда
		ОтветJSON = ОбщегоНазначения.JSONВЗначение(Ответ.ПолучитьТелоКакСтроку(), , Ложь);
		
		Если ОтветJSON.Свойство("error_code") И ОтветJSON.error_code = 100 Тогда
			ПараметрыДистрибутива = НовыйПараметрыДистрибутива();
			ПараметрыДистрибутива.СерийныйНомер = ОтветJSON.i_sn;
			
			Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
				МодульПолучениеФайловИзИнтернетаКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернетаКлиентСервер");
				ПараметрыПолученияФайла = МодульПолучениеФайловИзИнтернетаКлиентСервер.ПараметрыПолученияФайла();
				МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
				Файл = МодульПолучениеФайловИзИнтернета.СкачатьФайлВоВременноеХранилище(ОтветJSON.i_download_url, ПараметрыПолученияФайла);
				Если Не Файл.Статус Тогда 
					Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не удалось скачать дистрибутив %1. Подробности см.в Журнале регистрации.
						|Повторите попытку позже.'"), ИмяПрограммыVipNet);
					СтруктураВозврата.Вставить("ПараметрыДистрибутива", ПараметрыДистрибутива);
					СтруктураВозврата.Вставить("Ошибка", Ошибка);
					Возврат СтруктураВозврата;
				КонецЕсли;
				Дистрибутив = ПолучитьИзВременногоХранилища(Файл.Путь);
			Иначе
			
				ПутьДляСохранения = ПолучитьИмяВременногоФайла();
				Заголовки = Новый Соответствие;
				Попытка
					Ответ = ОписаниеСоединения.HTTPСоединение.Получить(Новый HTTPЗапрос(ОтветJSON.i_download_url,
						Заголовки), ПутьДляСохранения);
				Исключение

					ИнформацияОбОшибке = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
					ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка, , , ИнформацияОбОшибке);
					СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не удалось скачать дистрибутив %1. Подробности см.в Журнале регистрации.
							|Повторите попытку позже.'"), ИмяПрограммыVipNet);
					Возврат СтруктураВозврата;

				КонецПопытки;
				
				Если Ответ.КодСостояния = 200 Тогда
					Дистрибутив = Новый ДвоичныеДанные(ПутьДляСохранения);
					ФайловаяСистема.УдалитьВременныйФайл(ПутьДляСохранения);
				Иначе
									
					ИнформацияОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'HTTP ответ - %1'"), Строка(Ответ.КодСостояния));
					ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка, , , ИнформацияОбОшибке);
					СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Не удалось скачать дистрибутив %1. Подробности см.в Журнале регистрации.
							|Повторите попытку позже.'"), ИмяПрограммыVipNet);
					Возврат СтруктураВозврата;
					
				КонецЕсли;
				
			КонецЕсли;
			
			ПараметрыДистрибутива.КонтрольнаяСумма = ОтветJSON.i_distr_checksum;

			ВременныйКаталог = ФайловаяСистема.СоздатьВременныйКаталог();
			Поток = Новый ПотокВПамяти;
			Дистрибутив.Записать(Поток);

			ЧтениеZip = Новый ЧтениеZipФайла(Поток);
			ЧтениеZip.ИзвлечьВсе(ВременныйКаталог);
			ЧтениеZip.Закрыть();
			Поток.Закрыть();

			ТекстСкрипта = "Serial Number: %1
						   |E-mail: %2
						   |User name: %3
						   |Company: %4";

			ТекстСкрипта = СтрШаблон(ТекстСкрипта, ПараметрыДистрибутива.СерийныйНомер,
				Параметры.ЭлектроннаяПочта, Параметры.КонтактноеЛицо, "");

			ТекстовыйФайл = Новый ЗаписьТекста(ВременныйКаталог + "cspreg.txt", КодировкаТекста.OEM);
			ТекстовыйФайл.Записать(ТекстСкрипта);
			ТекстовыйФайл.Закрыть();
			Файлы = Новый Массив;
			Для Каждого Файл Из НайтиФайлы(ВременныйКаталог, ПолучитьМаскуВсеФайлы(), Истина) Цикл
				Если Файл.ЭтоКаталог() Тогда
					Продолжить;
				КонецЕсли;

				ОписаниеФайла = Новый Структура;
				ОписаниеФайла.Вставить("Имя", Файл.Имя);
				ОписаниеФайла.Вставить("ДвоичныеДанные", Новый ДвоичныеДанные(Файл.ПолноеИмя));
				Файлы.Добавить(ОписаниеФайла);

				Если СтрНачинаетсяС(Файл.Имя, "ViPNet") 
					И СтрЗаканчиваетсяНа(Файл.Имя, ".exe")
					И СтрНайти(Файл.Имя, "hash") = 0 Тогда
					
					// Версию возьмем из имени файла, пример: ViPNet_CSP_RUS_4.4.0.61581.exe
					НачалоВерсии = СтрНайти(Файл.ИмяБезРасширения, "_", НаправлениеПоиска.СКонца, , 1) + 1;
					Версия = Сред(Файл.Имя, НачалоВерсии, 11);
					ПараметрыДистрибутива.Версия = Версия;
					ПараметрыДистрибутива.ИмяФайлаДистрибутива = Файл.Имя;
					ПараметрыДистрибутива.КомандаЗапуска = ПараметрыДистрибутива.ИмяФайлаДистрибутива;
					
				КонецЕсли;
			КонецЦикла;

			ПараметрыДистрибутива.Дистрибутив = Файлы;
			ФайловаяСистема.УдалитьВременныйКаталог(ВременныйКаталог);
		Иначе
			ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("error_code: %1",
				ОтветJSON.error_code));
			СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Сервис получения серийных номеров для %1 временно недоступен. Подробности см. в Журнале регистрации.
					 |Повторите попытку позже.'"), ИмяПрограммыVipNet);
			Возврат СтруктураВозврата;
		КонецЕсли;

	Иначе
		ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка, , , Ответ.ПолучитьТелоКакСтроку());
		СтруктураВозврата.Ошибка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сервис получения серийных номеров для %1 временно недоступен. Подробности см. в Журнале регистрации.
				 |Повторите попытку позже.'"), ИмяПрограммыVipNet);
		Возврат СтруктураВозврата;
	КонецЕсли;
	
	СтруктураВозврата.Вставить("ПараметрыДистрибутива", ПараметрыДистрибутива);
	Возврат СтруктураВозврата;
	
КонецФункции

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Версия классификатора ошибок.
//
// Возвращаемое значение:
//  Строка - версия классификатора.
//
Функция ВерсияКлассификатора() Экспорт
	
	Возврат "3.0.1.49";

КонецФункции

// Новый параметры дистрибутива.
// 
// Возвращаемое значение:
//  Структура:
//   * Дистрибутив - Массив из Структура:
//                  ** Имя - Строка
//                  ** ДвоичныеДанные - ДвоичныеДанные
//   * НомерДистрибутива - Строка
//   * КонтрольнаяСумма - Строка
//   * Версия - Строка
//   * СерийныйНомер - Строка
//   * ИмяФайлаДистрибутива - Строка
//   * КомандаЗапуска - см. ФайловаяСистемаКлиент.ЗапуститьПрограмму.КомандаЗапуска
//
Функция НовыйПараметрыДистрибутива()

	Структура = Новый Структура;
	Структура.Вставить("Дистрибутив", Новый Массив);
	Структура.Вставить("НомерДистрибутива", "");
	Структура.Вставить("КонтрольнаяСумма", "");
	Структура.Вставить("Версия", "");
	Структура.Вставить("СерийныйНомер", "");
	Структура.Вставить("ИмяФайлаДистрибутива", "");
	Структура.Вставить("КомандаЗапуска", "");
	
	Возврат Структура;

КонецФункции

// Возвращает описание HTTP соединения.
// 
// Параметры:
//   URL - Строка
//   Таймаут - Число
//   ПроверятьДоставкуПакетовПриОшибке - см. ПолучениеФайловИзИнтернета.ДиагностикаСоединения.ПроверятьДоставкуПакетов.
// Возвращаемое значение:
//   Структура:
//    * HTTPСоединение - HTTPСоединение
//    * СтруктураURI - см. ОбщегоНазначенияКлиентСервер.СтруктураURI
//
Функция СоединениеССерверомИнтернета(ВидОперации, URL, Таймаут = Неопределено, 
	ПроверятьДоставкуПакетовПриОшибке = Истина)

	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URL);
	Схема        = ?(ЗначениеЗаполнено(СтруктураURI.Схема), СтруктураURI.Схема, "http");
	Прокси       = Неопределено;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		Прокси = МодульПолучениеФайловИзИнтернета.ПолучитьПрокси(Схема);
	КонецЕсли;
	
	Если Таймаут = Неопределено Тогда
		Таймаут = 60;
	КонецЕсли;
	
	Попытка
		Соединение = Новый HTTPСоединение(
			СтруктураURI.Хост,
			СтруктураURI.Порт,
			СтруктураURI.Логин,
			СтруктураURI.Пароль, 
			Прокси,
			Таймаут,
			?(НРег(Схема) = "http", Неопределено, ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение()));
	Исключение
		
		ШаблонЗапроса = "%1:%2ping";
		СсылкаНаРесурс = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонЗапроса,
			СтруктураURI.Хост, СтруктураURI.Порт);
		
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось установить HTTP-соединение с сервером %1:%2
			           |по причине:
			           |%3'"),
			СтруктураURI.Хост, Формат(СтруктураURI.Порт, "ЧГ="),
			ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
			МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
			РезультатДиагностики = МодульПолучениеФайловИзИнтернета.ДиагностикаСоединения(СсылкаНаРесурс,,
				ПроверятьДоставкуПакетовПриОшибке);
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = '%1
				           |Результат диагностики:
				           |%2'"),
				РезультатДиагностики.ОписаниеОшибки);
		КонецЕсли;
		
		ЗаписьЖурналаРегистрации(ВидОперации, УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
		
		ВызватьИсключение ТекстОшибки;
		
	КонецПопытки;
	
	ОписаниеСоединения = Новый Структура;
	ОписаниеСоединения.Вставить("HTTPСоединение", Соединение);
	ОписаниеСоединения.Вставить("СтруктураURI", СтруктураURI);
	
	Возврат ОписаниеСоединения;
	
КонецФункции

Функция ПрочитатьАрхивКлассификатора(Знач Архив, Версия = 0)
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Если ТипЗнч(Архив) = Тип("Строка") Тогда
		Архив = ПолучитьИзВременногоХранилища(Архив); // ДвоичныеДанные
	КонецЕсли;
	Архив.Записать(ИмяАрхива);
		
	КаталогОбновлений = ФайловаяСистема.СоздатьВременныйКаталог(
		Строка(Новый УникальныйИдентификатор));
	
	ЧтениеZipФайла = Новый ЧтениеZipФайла(ИмяАрхива);
	ИмяФайлаПериодыДействия = Неопределено;
	ИмяФайлаДатыОкончания   = Неопределено;
	ИмяФайлаДругиеНастройки = Неопределено;
	
	Для Каждого ЭлементАрхива Из ЧтениеZipФайла.Элементы Цикл
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "AccreditedCA") Тогда
			ИмяФайлаПериодыДействия = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "CAExpirationDateList") Тогда
			ИмяФайлаДатыОкончания = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "Settings") Тогда
			ИмяФайлаДругиеНастройки = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	
	ЧтениеZipФайла.Закрыть();
	
	ДанныеУЦ = Новый Структура;
	ДанныеУЦ.Вставить("ПериодыДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
	ДанныеУЦ.Вставить("ДатыОкончанияДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
	ДанныеУЦ.Вставить("ГосударственныеУЦ", Новый Соответствие);
	ДанныеУЦ.Вставить("ДругиеНастройки", Новый Соответствие);
	
	Если ИмяФайлаДатыОкончания <> Неопределено Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(КаталогОбновлений + ИмяФайлаДатыОкончания);
		ДатыОкончания = ПрочитатьJSON(ЧтениеJSON); // Структура
		ЧтениеJSON.Закрыть();
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		Для Каждого УЦ Из ДатыОкончания Цикл
			Соответствие.Вставить(УЦ.ОГРН, ПрочитатьДатуJSON(УЦ.ДатаОкончанияДействия, ФорматДатыJSON.ISO));
		КонецЦикла;
	
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Соответствие;
		
	Иначе
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Новый Соответствие;
	КонецЕсли;
	
	ДанныеУЦ.ДатыОкончанияДействия.Версия = Версия;
	ДанныеУЦ.ДатыОкончанияДействия.ДатаОбновления = ТекущаяДатаСеанса();
	
	Если ИмяФайлаПериодыДействия <> Неопределено Тогда
		
		СписокУЦ = ПрочитатьФайлПериодовДействияУЦ(КаталогОбновлений + ИмяФайлаПериодыДействия);
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		ГосударственныеУЦ = Новый Соответствие;
		Для Каждого УЦ Из СписокУЦ Цикл
			
			Наименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(УЦ.Наименование);
			КраткоеНаименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(УЦ.КраткоеНаименование);
			
			ПериодыДействияМассив = Новый Массив;
			Для Каждого ТекущийПериод Из УЦ.ПериодыДействия Цикл
				ПериодДействияСтруктура = Новый Структура("ДатаС, ДатаПо");
				ПериодДействияСтруктура.ДатаС = ПрочитатьДатуJSON(ТекущийПериод.ДатаС, ФорматДатыJSON.ISO);
				Если ЗначениеЗаполнено(ТекущийПериод.ДатаПо) Тогда
					ПериодДействияСтруктура.ДатаПо = ПрочитатьДатуJSON(ТекущийПериод.ДатаПо, ФорматДатыJSON.ISO);
				КонецЕсли;
				ПериодыДействияМассив.Добавить(ПериодДействияСтруктура);
			КонецЦикла;
			
			Соответствие.Вставить(УЦ.ОГРН, ПериодыДействияМассив);
			Соответствие.Вставить(Наименование, ПериодыДействияМассив);
			Соответствие.Вставить(КраткоеНаименование, ПериодыДействияМассив);
			Если УЦ.Государственный Тогда
				ГосударственныеУЦ.Вставить(УЦ.ОГРН, Истина);
				ГосударственныеУЦ.Вставить(Наименование, Истина);
				ГосударственныеУЦ.Вставить(КраткоеНаименование, Истина);
			КонецЕсли;
		КонецЦикла;
		
		ДанныеУЦ.ПериодыДействия.Данные = Соответствие;
		ДанныеУЦ.ГосударственныеУЦ = ГосударственныеУЦ;
		ДанныеУЦ.ПериодыДействия.Версия = Версия;
		ДанныеУЦ.ПериодыДействия.ДатаОбновления = ТекущаяДатаСеанса();
		
	КонецЕсли;
	
	Если ИмяФайлаДругиеНастройки <> Неопределено Тогда
		
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(КаталогОбновлений + ИмяФайлаДругиеНастройки);
		ДанныеУЦ.ДругиеНастройки = ПрочитатьJSON(
			ЧтениеJSON, Истина, "ДатаПрекращенияДействияСертификатовВыданныхКоммерческимиУЦ", ФорматДатыJSON.ISO); // Соответствие
		ЧтениеJSON.Закрыть();
		
	КонецЕсли;
	
	ФайловаяСистема.УдалитьВременныйКаталог(КаталогОбновлений);
	ФайловаяСистема.УдалитьВременныйФайл(ИмяАрхива);
	
	Возврат ДанныеУЦ;
	
КонецФункции

Функция ДанныеУдостоверяющихЦентровИзМакета()
	
	ОбработкаПрограммыЭлектроннойПодписиИШифрования = Метаданные.Обработки.Найти(
		"ПрограммыЭлектроннойПодписиИШифрования");

	Если ОбработкаПрограммыЭлектроннойПодписиИШифрования = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаВерсий = Новый ТаблицаЗначений;
	ТаблицаВерсий.Колонки.Добавить("ИмяМакета");
	ТаблицаВерсий.Колонки.Добавить("РасширеннаяВерсия", ОбщегоНазначения.ОписаниеТипаСтрока(23));
	
	Для Каждого Макет Из ОбработкаПрограммыЭлектроннойПодписиИШифрования.Макеты Цикл
		Если Макет.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные Тогда
			Продолжить;
		КонецЕсли;
		ИмяМакета = Макет.Имя;
		НачалоИмениМакета = "КлассификаторАУЦ";
		Если СтрНачинаетсяС(ВРег(ИмяМакета), ВРег(НачалоИмениМакета)) Тогда
			Если Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1, 1) <> "_" Тогда
				Продолжить;
			КонецЕсли;
			
			Версия = Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1);
			ЧастиВерсии = СтрРазделить(Версия, "_", Ложь);
			Если ЧастиВерсии.Количество() <> 4 Тогда
				Продолжить;
			КонецЕсли;
			
			РасширенныеЧастиВерсии = Новый Массив;
			Для Каждого ЧастьВерсии Из ЧастиВерсии Цикл
				РасширенныеЧастиВерсии.Добавить(ВРег(Прав("0000" + ЧастьВерсии, 5)));
			КонецЦикла;
			СтрокаТаблицыВерсий = ТаблицаВерсий.Добавить();
			СтрокаТаблицыВерсий.ИмяМакета = ИмяМакета;
			СтрокаТаблицыВерсий.РасширеннаяВерсия = СтрСоединить(РасширенныеЧастиВерсии, "_");
		КонецЕсли;
	КонецЦикла;
	
	Если ТаблицаВерсий.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаВерсий.Сортировать("РасширеннаяВерсия Убыв");
	ДвоичныеДанныеКлассификатора = Обработки["ПрограммыЭлектроннойПодписиИШифрования"].ПолучитьМакет(
		ТаблицаВерсий[0].ИмяМакета);

	ДанныеУЦ = ПрочитатьАрхивКлассификатора(ДвоичныеДанныеКлассификатора);

	Возврат ДанныеУЦ;
		
КонецФункции

// Прочитать файл периодов действия УЦ.
// 
// Параметры:
//  ИмяФайла - Строка - имя файла
// 
// Возвращаемое значение:
//  Массив из Структура:
//   * ОГРН - Строка
//   * Наименование - Строка
//   * КраткоеНаименование - Строка
//   * ПериодыДействия - Массив из Структура:
//      ** ДатаС - Строка
//      ** ДатаПо - Строка
//
Функция ПрочитатьФайлПериодовДействияУЦ(ИмяФайла)
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(ИмяФайла);
	СписокУЦ = ПрочитатьJSON(ЧтениеJSON); // Структура
	ЧтениеJSON.Закрыть();
	
	Возврат СписокУЦ;
	
КонецФункции

Функция АдресКлассификатораОшибок()
	
	АдресКлассификатора = Новый Структура;
	АдресКлассификатора.Вставить("Протокол", "http://");
	АдресКлассификатора.Вставить("АдресСервера", "downloads.v8.1c.ru");
	АдресКлассификатора.Вставить("АдресРесурса", "content/LED/settings/ErrorClassifier/classifier3.json");

	Возврат АдресКлассификатора;
	
КонецФункции

// Для функции ДоступностьСозданияЗаявления.
Функция МосковскоеВремя()
	
	Если ПолучитьДопустимыеЧасовыеПояса().Найти("Europe/Moscow") <> Неопределено Тогда
		ЧасовойПоясМосквы = "Europe/Moscow";
	Иначе
		ЧасовойПоясМосквы = "GMT+3";
	КонецЕсли;
	
	Возврат МестноеВремя(ТекущаяУниверсальнаяДата(), ЧасовойПоясМосквы);
	
КонецФункции

#КонецОбласти
