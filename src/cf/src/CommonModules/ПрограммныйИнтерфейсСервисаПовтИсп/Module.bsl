
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Версия EXT-Api менеджера сервиса.
// 
// Возвращаемое значение:
//  Число - версия EXT-Api менеджера сервиса.
Функция ВерсияExtAPIМенеджераСервиса() Экспорт
	
	Возврат ПрограммныйИнтерфейсСервисаСлужебный.ВерсияExtAPIМенеджераСервиса();

КонецФункции

// Признак поддержки метода в адресе.
// 
// Возвращаемое значение:
//  Булево - менеджер сервиса поддерживает метод в адресе.
Функция МенеджерСервисаПоддерживаетМетодВАдресе() Экспорт

	Возврат ПрограммныйИнтерфейсСервисаСлужебный.МенеджерСервисаПоддерживаетМетодВАдресе();

КонецФункции

// Свойства версии интерфейса.
// 
// Возвращаемое значение:
//  Структура:
//   * Версия - Число
//   * ВерсияМенеджераСервиса - Строка - в формате Редакция.Подредакция.Версия.Сборка
//   * ЧасовойПоясМенеджераСервиса - Строка - часовой пояс.
Функция СвойстваВерсииИнтерфейса() Экспорт
	
	Служебный = ПрограммныйИнтерфейсСервисаСлужебный;
	Адрес = АдресВерсииВнешнегоПрограммногоИнтерфейса();
	
	Если РаботаВМоделиСервиса.РазделениеВключено() Тогда
		Ответ = РаботаВМоделиСервисаБТС.ОтправитьЗапросВМенеджерСервиса("POST", Адрес);
	Иначе
		Ответ = Служебный.ОтправитьЗапросВСервисИзЛокальнойБазы("POST", Адрес);
	КонецЕсли;
		
	ПотокДанных = Ответ.ПолучитьТелоКакПоток();
	ДанныеОтвета = РаботаВМоделиСервисаБТС.СтруктураИзПотокаJSON(ПотокДанных);
	Переименования = Новый Соответствие;
	Переименования.Вставить("version", "Версия");
	Переименования.Вставить("sm_version", "ВерсияМенеджераСервиса");
	Переименования.Вставить("sm_timezone", "ЧасовойПоясМенеджераСервиса");
	
	Возврат Служебный.ПереименоватьСвойства(ДанныеОтвета, Переименования);
	
КонецФункции

// Соединение с менеджером сервиса из локальной базы.
// 
// Параметры:
//  ДанныеСервера - см. ОбщегоНазначенияКлиентСервер.СтруктураURI
//  Таймаут - Число - таймаут
// 
// Возвращаемое значение:
//  HTTPСоединение - соединение с менеджером сервиса.
Функция СоединениеСМенеджеромСервисаИзЛокальнойБазы(ДанныеСервера, Таймаут = 60) Экспорт
	
	Возврат ПрограммныйИнтерфейсСервисаСлужебный.СоединениеСМенеджеромСервисаИзЛокальнойБазы(ДанныеСервера, Таймаут);
	
КонецФункции

// Абонент этого приложения.
// 
// Параметры:
//  Пользователь - СправочникСсылка.Пользователи - Пользователь
//  Токен - Строка
// 
// Возвращаемое значение:
//  Структура - данные абонента:
//  * Наименование - Строка
//  * Код - Число
//  * РольПользователя - ПеречислениеСсылка.РолиПользователейАбонентов
Функция АбонентЭтогоПриложения(Знач Пользователь = Неопределено, Знач Токен = Неопределено) Экспорт

	Служебный = ПрограммныйИнтерфейсСервисаСлужебный;
	Метод = "tenant/account";

	ДанныеЗапроса = Служебный.ШаблонЗапроса(Метод);
	ДанныеЗапроса.Вставить("id", РаботаВМоделиСервиса.ЗначениеРазделителяСеанса());
	ДанныеЗапроса.Вставить("auth", Служебный.СвойстваАвторизации(Неопределено, Пользователь, Токен));
	Адрес = Служебный.АдресИсполненияВнешнегоПрограммногоИнтерфейса(Метод);
	Результат = РаботаВМоделиСервисаБТС.ОтправитьЗапросВМенеджерСервиса("POST", Адрес, ДанныеЗапроса);

	ДанныеОтвета = Служебный.РезультатВыполнения(Результат);
	Абонент = ДанныеОтвета.account;
	ПолеРоль = "role";
	Абонент[ПолеРоль] = Перечисления.РолиПользователейАбонентов.ЗначениеПоИмени(Абонент[ПолеРоль]);

	Переименования = Служебный.ПереименованияАбонент();
	Переименования.Вставить(ПолеРоль, "РольПользователя");

	Возврат Служебный.ПереименоватьСвойства(Абонент, Переименования);

КонецФункции

// Обслуживающие организации абонента.
// 
// Возвращаемое значение:
//  ТаблицаЗначений:
//   * Наименование - Строка
//   * Код - Число
//   * Сайт - Строка
//   * Телефон - Строка
//   * Почта - Строка
//   * Город - Строка
//   * Идентификатор - Строка
//   * РазрешеноАвтоматическоеВыставлениеСчетов - Булево
//   * РазрешеноПереопределениеТарифов - Булево
//   * ТолькоСтраницаВыбораТарифа - Булево
Функция ОбслуживающиеОрганизацииАбонента() Экспорт
	
	Служебный = ПрограммныйИнтерфейсСервисаСлужебный;
	Метод = "account/servants/list";
	Абонент = ПрограммныйИнтерфейсСервиса.АбонентЭтогоПриложения();
	ДанныеЗапроса = Служебный.ШаблонЗапроса(Метод);
	ДанныеЗапроса.Вставить("id", Абонент.Код);
	Результат = Служебный.ОтправитьДанныеВМенеджерСервиса(ДанныеЗапроса, Метод);
	ДанныеОтвета = Служебный.РезультатВыполнения(Результат);

	Переименования = Служебный.ПереименованияАбонент(Истина);
	Переименования.Вставить("servant_id", Служебный.ОписаниеКолонки(
		"Идентификатор", ОбщегоНазначения.ОписаниеТипаСтрока(50)));
	Переименования.Вставить("tariff_subscribe_allowed", Служебный.ОписаниеКолонки(
		"РазрешеноПодписыватьНаТарифы", Новый ОписаниеТипов("Булево")));
	Переименования.Вставить("automatic_billing_allowed", Служебный.ОписаниеКолонки(
		"РазрешеноАвтоматическоеВыставлениеСчетов", Новый ОписаниеТипов("Булево")));
	Переименования.Вставить("tariff_override_allowed", Служебный.ОписаниеКолонки(
		"РазрешеноПереопределениеТарифов", Новый ОписаниеТипов("Булево")));
	Переименования.Вставить("tariff_selection_page_only", Служебный.ОписаниеКолонки(
		"ТолькоСтраницаВыбораТарифа", Новый ОписаниеТипов("Булево")));
	
	Возврат Служебный.МассивСтруктурВТаблицуЗначений(ДанныеОтвета.servants, Переименования);

КонецФункции

// Тариф сервиса.
// 
// Параметры:
//  КодТарифа - Строка - код тарифа
// 
// Возвращаемое значение:
//  см. ПрограммныйИнтерфейсСервиса.ТарифСервиса
Функция ТарифСервиса(КодТарифа) Экспорт

	Служебный = ПрограммныйИнтерфейсСервисаСлужебный;
	Метод = "tariff/info";
	ДанныеЗапроса = Служебный.ШаблонЗапроса(Метод);
	ДанныеЗапроса.Вставить("id", КодТарифа);
	Результат = Служебный.ОтправитьДанныеВМенеджерСервиса(ДанныеЗапроса, Метод);
	ДанныеОтвета = Служебный.РезультатВыполнения(Результат);
	Тариф = ДанныеОтвета.tariff;

	Переименования = Служебный.ПереименованияТариф();
	
	Переименования.Вставить("condition", "УсловиеИспользования");
	Переименования.Вставить("services", Служебный.ОписаниеКолонки("Услуги", Новый ОписаниеТипов("ТаблицаЗначений")));
	Переименования.Вставить("extensions", Служебный.ОписаниеКолонки("Расширения", Новый ОписаниеТипов("ТаблицаЗначений")));
	Переименования.Вставить("applications", Служебный.ОписаниеКолонки(
		"Конфигурации", Новый ОписаниеТипов("ТаблицаЗначений")));
	Переименования.Вставить("validity_periods", Служебный.ОписаниеКолонки(
		"ПериодыДействия", Новый ОписаниеТипов("ТаблицаЗначений")));
	Переименования.Вставить("notification_periods", Служебный.ОписаниеКолонки(
		"ПериодыОповещенийОбОкончанииПодписки", Новый ОписаниеТипов("ТаблицаЗначений")));

	ПереименованияУслуги = Новый Соответствие;
	ПереименованияУслуги.Вставить("id", "Код");
	ПереименованияУслуги.Вставить("name", "Наименование");
	ПереименованияУслуги.Вставить("type", Служебный.ОписаниеКолонки(
		"ТипУслуги", Новый ОписаниеТипов("ПеречислениеСсылка.ТипыУслуг")));
	ПереименованияУслуги.Вставить("description", "Описание");
	ПереименованияУслуги.Вставить("amount", "КоличествоЛицензий");
	ПереименованияУслуги.Вставить("extend_amount", "КоличествоДопЛицензийРасширяющейПодписки");
	ПереименованияУслуги.Вставить("provider_id", "ИдентификаторПоставщика");
	ПереименованияУслуги.Вставить("provider_name", "НаименованиеПоставщика");

	ПереименованияРасширенияТарифа = Служебный.ПереименованияРасширенияТарифа();

	ПереименованияКонфигурации = Новый Соответствие;
	ПереименованияКонфигурации.Вставить("id", "Код");
	ПереименованияКонфигурации.Вставить("name", "Наименование");
	ПереименованияКонфигурации.Вставить("description", "Описание");

	ПереименованияПериодыДействия = Служебный.ПереименованияТарифПериодыДействия();
	
	ПереименованияПериодыОповещений = Новый Соответствие;
	ПереименованияПериодыОповещений.Вставить("days_quantity", Служебный.ОписаниеКолонки(
		"КоличествоДней", ОбщегоНазначения.ОписаниеТипаЧисло(2, 0, ДопустимыйЗнак.Неотрицательный)));

	Служебный.ПереименоватьСвойства(Тариф, Переименования);

	// Обработаем описание для абонентов
	СтруктураВложений = Новый Структура;
	Для Каждого Вложение Из Тариф.ОписаниеДляАбонентов.images Цикл
		ДанныеКартинки = ПолучитьДвоичныеДанныеИзBase64Строки(Вложение.data);
		СтруктураВложений.Вставить(Вложение.name, Новый Картинка(ДанныеКартинки, Истина));
	КонецЦикла;
	ОписаниеДляАбонентов = Новый ФорматированныйДокумент;
	ОписаниеДляАбонентов.УстановитьHTML(Тариф.ОписаниеДляАбонентов.html, СтруктураВложений);
	Тариф.ОписаниеДляАбонентов = ОписаниеДляАбонентов;

	Тариф.Услуги = Служебный.МассивСтруктурВТаблицуЗначений(Тариф.Услуги, ПереименованияУслуги);
	Тариф.Расширения = Служебный.МассивСтруктурВТаблицуЗначений(Тариф.Расширения, ПереименованияРасширенияТарифа);
	Тариф.Конфигурации = Служебный.МассивСтруктурВТаблицуЗначений(Тариф.Конфигурации, ПереименованияКонфигурации);
	Тариф.ПериодыДействия = Служебный.МассивСтруктурВТаблицуЗначений(Тариф.ПериодыДействия, ПереименованияПериодыДействия);
	Тариф.ПериодыОповещенийОбОкончанииПодписки = Служебный.МассивСтруктурВТаблицуЗначений(
		Тариф.ПериодыОповещенийОбОкончанииПодписки, ПереименованияПериодыОповещений);

	Возврат Тариф;

КонецФункции

// Тариф обслуживающей организации.
// 
// Параметры:
//  КодОО - Число - код обслуживающей организации
//  КодТарифа -Строка - код тарифа обслуживающей организации
// 
// Возвращаемое значение:
//  см. ПрограммныйИнтерфейсСервиса.ТарифОбслуживающейОрганизации
Функция ТарифОбслуживающейОрганизации(КодОО, КодТарифа) Экспорт

	Служебный = ПрограммныйИнтерфейсСервисаСлужебный;
	Метод = "account/servant_tariffs/info";
	ДанныеЗапроса = Служебный.ШаблонЗапроса(Метод);
	ДанныеЗапроса.Вставить("servant", КодОО);
	ДанныеЗапроса.Вставить("id", КодТарифа);
	Результат = Служебный.ОтправитьДанныеВМенеджерСервиса(ДанныеЗапроса, Метод);
	ДанныеОтвета = Служебный.РезультатВыполнения(Результат);
	Тариф = ДанныеОтвета.servant_tariff;

	Переименования = Служебный.ПереименованияТарифОбслуживающейОрганизации(Метод);
	ПереименованияПериоды = Служебный.ПереименованияТарифОбслуживающейОрганизацииПериодыДействия();
	Служебный.ПереименоватьСвойства(Тариф, Переименования);

	СтруктураВложений = Новый Структура;
	Для Каждого Вложение Из Тариф.ОписаниеДляАбонентов.images Цикл
		ДанныеКартинки = ПолучитьДвоичныеДанныеИзBase64Строки(Вложение.data);
		СтруктураВложений.Вставить(Вложение.name, Новый Картинка(ДанныеКартинки, Истина));
	КонецЦикла;
	ОписаниеДляАбонентов = Новый ФорматированныйДокумент;
	ОписаниеДляАбонентов.УстановитьHTML(Тариф.ОписаниеДляАбонентов.html, СтруктураВложений);
	Тариф.ОписаниеДляАбонентов = ОписаниеДляАбонентов;

	Тариф.ПериодыДействия = Служебный.МассивСтруктурВТаблицуЗначений(Тариф.ПериодыДействия, ПереименованияПериоды);

	Возврат Тариф;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция АдресВерсииВнешнегоПрограммногоИнтерфейса()

	Возврат "hs/ext_api/version";

КонецФункции

#КонецОбласти

#КонецЕсли