//@strict-types

#Область ПрограммныйИнтерфейс

// Путь общего каталога временных файлов для доступа между сеансами.
//
// Возвращаемое значение:
//   Строка - полный путь к каталогу.
//
Функция ОбщийКаталогВременныхФайлов() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ОбщегоНазначения.ЭтоLinuxСервер() Тогда
		ОбщийВременныйКаталог = Константы.КаталогОбменаФайламиВМоделиСервисаLinux.Получить();
	Иначе
		ОбщийВременныйКаталог = Константы.КаталогОбменаФайламиВМоделиСервиса.Получить();
	КонецЕсли;
	
	Если ПустаяСтрока(ОбщийВременныйКаталог) Тогда
		ОбщийВременныйКаталог = СокрЛП(КаталогВременныхФайлов());
	Иначе
		ОбщийВременныйКаталог = СокрЛП(ОбщийВременныйКаталог);
	КонецЕсли;
	
	Если Не СтрЗаканчиваетсяНа(ОбщийВременныйКаталог, ПолучитьРазделительПути()) Тогда
		ОбщийВременныйКаталог = ОбщийВременныйКаталог + ПолучитьРазделительПути();
	КонецЕсли;
	
	Возврат ОбщийВременныйКаталог;
	
КонецФункции

// Регистрирует уникальное имя файла во временном хранилище.
// 
// Параметры:
//  Префикс - Строка - Префикс имени файла. Только английские буквы и цифры, до 20-и символов
//  Расширение - Строка - Расширение файла. Только английские буквы и цифры, до 4-х символов
//  МинутХранения - Число - Минут хранения файла. Не менее одной минуты
// 
// Возвращаемое значение:
//  Строка - имя зарегистрированного временного файла.
Функция НовыйФайлВременногоХранилища(Знач Префикс, Знач Расширение, МинутХранения) Экспорт

	Если Не ЗначениеЗаполнено(МинутХранения) Тогда
		ВызватьИсключение НСтр("ru = 'Не указан срок хранения нового файла временного хранилища'");
	КонецЕсли;
	
	Если Расширение <> Неопределено Тогда
		Расширение = ЧастьИмениФайла(Расширение, 4);
		Если ЗначениеЗаполнено(Расширение) Тогда
			Расширение = "." + Расширение;
		КонецЕсли;
	КонецЕсли;

	Если Префикс <> Неопределено Тогда
		Префикс = ЧастьИмениФайла(Префикс, 20);
		Если ЗначениеЗаполнено(Префикс) Тогда
			Префикс = Префикс + "_";
		КонецЕсли;
	КонецЕсли;
	
	Если РаботаВМоделиСервиса.РазделениеВключено() И РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		ОбластьДанных = РаботаВМоделиСервиса.ЗначениеРазделителяСеанса();
	Иначе
		ОбластьДанных = 0;
	КонецЕсли;

	ИмяФайла = "tmp_" + Формат(ОбластьДанных, "ЧН=0; ЧГ=0;") + "_" + Префикс + Новый УникальныйИдентификатор
		+ Расширение;

	ЗарегистрироватьФайлВременногоХранилища(ИмяФайла, МинутХранения);

	Возврат ИмяФайла;

КонецФункции

// Свойства файла временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
// 
// Возвращаемое значение:
//  Структура - Свойства файла временного хранилища:
// * Зарегистрирован - Булево
// * ДатаРегистрации - Дата
// * СрокХранения - Дата
// * ПутьWindows - Строка
// * ПутьLinux - Строка 
Функция СвойстваФайлаВременногоХранилища(ИмяФайла) Экспорт

	Результат = Новый Структура;
	Результат.Вставить("Зарегистрирован", Ложь);
	Результат.Вставить("ДатаРегистрации", Дата(1, 1, 1));
	Результат.Вставить("СрокХранения", Дата(1, 1, 1));
	Результат.Вставить("ПутьWindows", "");
	Результат.Вставить("ПутьLinux", "");
	
	УстановитьПривилегированныйРежим(Истина);
	Запись = МенеджерЗаписиФайлаВременногоХранилища(ИмяФайла);
	Запись.Прочитать();

	Результат.Зарегистрирован = Запись.Выбран();
	Если Результат.Зарегистрирован Тогда
		ЗаполнитьЗначенияСвойств(Результат, Запись);
	КонецЕсли;

	Возврат Результат;

КонецФункции

// Полное имя файла временного хранилища.
// 
// Параметры: 
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
// 
// Возвращаемое значение: 
//  Строка, Неопределено - полное имя файла. Неопределено - если файл не зарегистрирован
Функция ПолноеИмяФайлаВременногоХранилища(ИмяФайла) Экспорт
	
	СвойстваФайла = СвойстваФайлаВременногоХранилища(ИмяФайла);
	
	Если Не СвойстваФайла.Зарегистрирован Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ПолноеИмяФайлаВСеансе(ИмяФайла, СвойстваФайла.ПутьWindows, СвойстваФайла.ПутьLinux);
	
КонецФункции

// Полное имя файла в сеансе в зависимости от ОС рабочего сервера.
// 
// Параметры: 
//  Имя - Строка
//  ПутьWindows - Строка
//  ПутьLinux - Строка
// 
// Возвращаемое значение: 
//  Строка - полное имя файла в сеансе.
Функция ПолноеИмяФайлаВСеансе(Имя, ПутьWindows, ПутьLinux) Экспорт
	
	Если ОбщегоНазначения.ЭтоLinuxСервер() Тогда
		Путь = ПутьLinux;
	Иначе
		Путь = ПутьWindows;
	КонецЕсли;
	
	Если ПустаяСтрока(Путь) Тогда
		Путь = КаталогВременныхФайлов();
	КонецЕсли;
	
	Разделитель = ПолучитьРазделительПути();
	Если Не СтрЗаканчиваетсяНа(Путь, Разделитель) Тогда
		Путь = Путь + Разделитель;
	КонецЕсли;
	
	Возврат Путь + Имя;
	
КонецФункции

// Удалить файл временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
Процедура УдалитьФайлВременногоХранилища(ИмяФайла) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Запись = МенеджерЗаписиФайлаВременногоХранилища(ИмяФайла);
	Запись.Прочитать();
	Если Не Запись.Выбран() Тогда
		Возврат;
	КонецЕсли;
	
	ПолноеИмяФайла = ПолноеИмяФайлаВСеансе(ИмяФайла, Запись.ПутьWindows, Запись.ПутьLinux);
	Если Не УдалитьФайлыВПопытке(ПолноеИмяФайла, НСтр("ru = 'Удаление файла. Файл временного хранилища'",
		ОбщегоНазначения.КодОсновногоЯзыка())) Тогда
		Возврат;
	КонецЕсли;
		
	Запись.Удалить();

КонецПроцедуры

// Удалить все файлы временного хранилища, кроме заблокированных.
// 
// Параметры:
//  Граница - Дата - Универсальная дата, до которой следует удалить файлы
Процедура УдалитьВсеФайлыВременногоХранилища(Граница) Экспорт
	
	УдалитьФайлыВременногоХранилища(Граница);
	
КонецПроцедуры

// Заблокировать файл временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
//  ИдентификаторФормы - УникальныйИдентификатор, Неопределено - идентификатор формы, на время жизни которой файл будет
//  оставаться заблокированным. 
// 
// Возвращаемое значение:
//  Булево - Истина, если блокировка установлена
Функция ЗаблокироватьФайлВременногоХранилища(ИмяФайла, ИдентификаторФормы = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Ключ = КлючЗаписиФайлаВременногоХранилища(ИмяФайла);

	Попытка
		ЗаблокироватьДанныеДляРедактирования(Ключ, Неопределено, ИдентификаторФормы);
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

// Разблокировать файл временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
//  ИдентификаторФормы - УникальныйИдентификатор, Неопределено - идентификатор формы, в которой файл был заблокирован 
Процедура РазблокироватьФайлВременногоХранилища(ИмяФайла, ИдентификаторФормы = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Ключ = КлючЗаписиФайлаВременногоХранилища(ИмяФайла);
	РазблокироватьДанныеДляРедактирования(Ключ, ИдентификаторФормы);
	
КонецПроцедуры

// Файл временного хранилища заблокирован.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
// 
// Возвращаемое значение:
//  Булево
Функция ФайлВременногоХранилищаЗаблокирован(ИмяФайла) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Ключ = КлючЗаписиФайлаВременногоХранилища(ИмяФайла);
	
	Попытка
		ЗаблокироватьДанныеДляРедактирования(Ключ);
	Исключение
		Возврат Истина;
	КонецПопытки;
	
	РазблокироватьДанныеДляРедактирования(Ключ);
	
	Возврат Ложь;
	
КонецФункции

// Установить срок хранения файла временного хранилища относительно текущей универсальной даты.
// 
// Параметры:
//  ИмяФайла - Строка - имя зарегистрированного во временном хранилище файла
//  МинутХранения - Число - Минут хранения файла
// 
// Возвращаемое значение:
//  Булево - Истина, если срок хранения установлен
Функция УстановитьСрокХраненияФайлаВременногоХранилища(ИмяФайла, МинутХранения) Экспорт

	УстановитьПривилегированныйРежим(Истина);
	Запись = МенеджерЗаписиФайлаВременногоХранилища(ИмяФайла);
	Запись.Прочитать();
	
	Если Не Запись.Выбран() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Запись.СрокХранения = ТекущаяУниверсальнаяДата() + МинутХранения * 60;
	Запись.Записать();
	
	Возврат Истина;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Удаление файлов временного хранилища. Метод одноименного регламентного задания
Процедура УдалениеФайловВременногоХранилища() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(
		Метаданные.РегламентныеЗадания.УдалениеФайловВременногоХранилища);

	УдалитьФайлыВременногоХранилища(ТекущаяУниверсальнаяДата());

КонецПроцедуры

// Удалить файлы в попытке.
// 
// Параметры:
//  ИмяФайла - Строка
//  ИмяСобытияЖР - Неопределено, Строка - Имя события журнала регистрации
// 
// Возвращаемое значение:
//  Булево - Истина, если удаление произошло успешно
Функция УдалитьФайлыВПопытке(ИмяФайла, ИмяСобытияЖР = Неопределено) Экспорт
	
	Попытка

		УдалитьФайлы(ИмяФайла);
		Возврат Истина;

	Исключение

		Если ИмяСобытияЖР = Неопределено Тогда
			ИмяСобытияЖР = НСтр("ru = 'Удаление файла'", ОбщегоНазначения.КодОсновногоЯзыка());
		КонецЕсли;

		КомментарийСобытияЖР = ТехнологияСервиса.ПодробныйТекстОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(ИмяСобытияЖР, УровеньЖурналаРегистрации.Ошибка, Неопределено, Неопределено,
			КомментарийСобытияЖР);

	КонецПопытки;

	Возврат Ложь;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура УдалитьФайлыВременногоХранилища(Граница)

	УстановитьПривилегированныйРежим(Истина);

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Граница", Граница);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ФайлыВременногоХранилища.ИмяФайла КАК ИмяФайла,
	|	ФайлыВременногоХранилища.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанных
	|ИЗ
	|	РегистрСведений.ФайлыВременногоХранилища КАК ФайлыВременногоХранилища
	|ГДЕ
	|	ФайлыВременногоХранилища.СрокХранения < &Граница";

	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл

		Если ФайлВременногоХранилищаЗаблокирован(Выборка.ИмяФайла) Тогда
			Продолжить;
		КонецЕсли;
		
		Запись = МенеджерЗаписиФайлаВременногоХранилища(Выборка.ИмяФайла, Выборка.ОбластьДанных);
		Запись.Прочитать();
		Если Не Запись.Выбран() Тогда
			Продолжить;
		КонецЕсли;

		ПолноеИмяФайла = ПолноеИмяФайлаВСеансе(Запись.ИмяФайла, Запись.ПутьWindows, Запись.ПутьLinux);
		Если Не УдалитьФайлыВПопытке(ПолноеИмяФайла, НСтр("ru = 'Удаление файла. Файл временного хранилища'",
			ОбщегоНазначения.КодОсновногоЯзыка())) Тогда
			Продолжить;
		КонецЕсли;
		Запись.Удалить();

	КонецЦикла;
	
КонецПроцедуры

Процедура ЗарегистрироватьФайлВременногоХранилища(ИмяФайла, МинутХранения)
	
	УстановитьПривилегированныйРежим(Истина);
	ПутиФайла = ИменаОбщегоКаталогаВременныхФайлов();
	
	ДатаРегистрации = ТекущаяУниверсальнаяДата();
	Запись = РегистрыСведений.ФайлыВременногоХранилища.СоздатьМенеджерЗаписи();
	Запись.ИмяФайла = ИмяФайла;
	Запись.ДатаРегистрации = ДатаРегистрации;
	Запись.СрокХранения = ДатаРегистрации + Макс(1, МинутХранения) * 60;
	Запись.ПутьWindows = ПутиФайла.ПутьWindows; 
	Запись.ПутьLinux = ПутиФайла.ПутьLinux;
	Запись.Записать();
	
КонецПроцедуры

Функция ИменаОбщегоКаталогаВременныхФайлов()
	
	Результат = Новый Структура;

	ЭтоLinux = ОбщегоНазначения.ЭтоLinuxСервер();

	Результат.Вставить("ПутьWindows", КаталогОбменаИзКонстанты(
		Константы.КаталогОбменаФайламиВМоделиСервиса.Получить(), Не ЭтоLinux, "\"));
	
	Результат.Вставить("ПутьLinux", КаталогОбменаИзКонстанты(
		Константы.КаталогОбменаФайламиВМоделиСервисаLinux.Получить(), ЭтоLinux, "/"));

	Возврат Результат;

КонецФункции

Функция КаталогОбменаИзКонстанты(КаталогОбмена, ПоУмолчаниюКаталогВременныхФайлов, Разделитель)

	КаталогОбмена = СокрЛП(КаталогОбмена);
	Если ПустаяСтрока(КаталогОбмена) И ПоУмолчаниюКаталогВременныхФайлов Тогда
		КаталогОбмена = КаталогВременныхФайлов();
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КаталогОбмена) И Не СтрЗаканчиваетсяНа(КаталогОбмена, Разделитель) Тогда
		КаталогОбмена = КаталогОбмена + Разделитель;
	КонецЕсли;
	
	Возврат КаталогОбмена;

КонецФункции

Функция ЧастьИмениФайла(ИсходнаяСтрока, МаксДлина)

	Результат = "";
	ДлинаРезультата = 0;
	Для НомерСимвола = 1 По СтрДлина(ИсходнаяСтрока) Цикл
		Код = КодСимвола(ИсходнаяСтрока, НомерСимвола);
		Если (Код >= 48 И Код <= 57)
			Или (Код >= 65 И Код <= 90)
			Или (Код >= 97 И Код <= 122) Тогда
			Результат = Результат + Символ(Код);
			ДлинаРезультата = ДлинаРезультата + 1;
			Если ДлинаРезультата > МаксДлина Тогда
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ОбластьДанныхФайлаВременногоХранилища(ИмяФайла)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяФайла", ИмяФайла);
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ФайлыВременногоХранилища.ОбластьДанныхВспомогательныеДанные КАК ОбластьДанных
	|ИЗ
	|	РегистрСведений.ФайлыВременногоХранилища КАК ФайлыВременногоХранилища
	|ГДЕ
	|	ФайлыВременногоХранилища.ИмяФайла = &ИмяФайла";

	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.ОбластьДанных;
	КонецЕсли;

	Возврат Неопределено;

КонецФункции

// Менеджер записи файла временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка
//  ОбластьДанных - Число
// 
// Возвращаемое значение:
//  РегистрСведенийМенеджерЗаписи.ФайлыВременногоХранилища
Функция МенеджерЗаписиФайлаВременногоХранилища(ИмяФайла, ОбластьДанных = Неопределено)

	Запись = РегистрыСведений.ФайлыВременногоХранилища.СоздатьМенеджерЗаписи();
	Запись.ИмяФайла = ИмяФайла;

	Если РаботаВМоделиСервиса.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат Запись;
	КонецЕсли;

	Если ОбластьДанных = Неопределено Тогда
		ОбластьДанных = ОбластьДанныхФайлаВременногоХранилища(ИмяФайла);
	КонецЕсли;

	Если ЗначениеЗаполнено(ОбластьДанных) Тогда
		Запись.ОбластьДанныхВспомогательныеДанные = ОбластьДанных;
	КонецЕсли;

	Возврат Запись;

КонецФункции

// Ключ записи регистра файлы временного хранилища.
// 
// Параметры:
//  ИмяФайла - Строка - Имя файла
//  ОбластьДанных - Число, Неопределено - Область данных
// 
// Возвращаемое значение:
//  РегистрСведенийКлючЗаписи.ФайлыВременногоХранилища - Ключ записи регистра файлы временного хранилища
Функция КлючЗаписиФайлаВременногоХранилища(ИмяФайла, ОбластьДанных = Неопределено)
	
	ЗначенияКлюча = Новый Структура;
	ЗначенияКлюча.Вставить("ИмяФайла", ИмяФайла);
	
	Если ОбластьДанных = Неопределено Тогда
		ОбластьДанных = ОбластьДанныхФайлаВременногоХранилища(ИмяФайла);
	КонецЕсли;
	Если ЗначениеЗаполнено(ОбластьДанных) Тогда
		ЗначенияКлюча.Вставить("ОбластьДанныхВспомогательныеДанные", ОбластьДанных);
	КонецЕсли;

	Возврат РаботаВМоделиСервиса.СоздатьКлючЗаписиРегистраСведенийВспомогательныхДанных(
		РегистрыСведений.ФайлыВременногоХранилища, ЗначенияКлюча);

КонецФункции

#КонецОбласти