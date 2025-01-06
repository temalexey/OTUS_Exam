///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

#Область ВыборочнаяРегистрацияДанных

// Возвращает структуру с параметрами выборочной регистрации объектов,
// которая храниться в регистре сведений ПравилаДляОбменаДанными.
//
// Параметры:
//   ИмяПланаОбмена - строка - имя плана обмена.
//
// Возвращаемое значение:
//   ПараметрыВыборочнойРегистрации - Структура
//                                  - Неопределено - параметры выборочной регистрации объектов.
//   В случае, если выборочная регистрация не используется для указанного плана обмена возвращаем Неопределено.
//
Функция ПараметрыВыборочнойРегистрацииПоИмениПланаОбмена(ИмяПланаОбмена) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИмяПланаОбмена", ИмяПланаОбмена);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПравилаДляОбменаДанными.ПараметрыВыборочнойРегистрации КАК ПараметрыВыборочнойРегистрации
	|ИЗ
	|	РегистрСведений.ПравилаДляОбменаДанными КАК ПравилаДляОбменаДанными
	|ГДЕ
	|	ПравилаДляОбменаДанными.ВидПравил = ЗНАЧЕНИЕ(Перечисление.ВидыПравилДляОбменаДанными.ПравилаРегистрацииОбъектов)
	|	И ПравилаДляОбменаДанными.ИмяПланаОбмена = &ИмяПланаОбмена";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда // для одного плана обмена может быть только одна запись в правилах регистрации
		
		ПараметрыВыборочнойРегистрации = Выборка.ПараметрыВыборочнойРегистрации.Получить();
		
		// ПараметрыВыборочнойРегистрации может содержать 2 ключа:
		// - ЭтоПланОбменаXDTO;
		// - ТаблицаРеквизитовРегистрации.
		
		Возврат ПараметрыВыборочнойРегистрации;
		
	КонецЕсли;
	
	Возврат ОбменДаннымиРегистрацияСервер.НовыеПараметрыВыборочнойРегистрацииДанныхПланаОбмена(ИмяПланаОбмена);
	
КонецФункции

// Возвращаем режим выборочной регистрации, который установлен в настройках плана обмена.
// В случаях, когда настройка не заполнена возвращает значение по-умолчанию ("Модифицированность").
// Если для плана обмена ОУФ указан неподдерживаемый режим "СогласноПравиламXML", то будет возвращено значение по-умолчанию.
//
// Возвращаемое значение:
//   Строка - Значение настройки плана обмена "РежимВыборочнойРегистрации".
//
// Описание значений:
//
//   // Режим "Отключен" - все объекты считаем измененными, регистрируем без отбора
//                         (см. ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииОтключен());
//   // Режим "СогласноПравиламXML" - регистрируем к обмену объекты, у которых есть изменения в полях ПКС
//                         (см. ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииСогласноПравиламXML());
//   // Режим "Модифицированность" - регистрируем объекты, у которых свойство Модифицированность = Истина
//                         (см. ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииМодифицированность()).
//
Функция РежимВыборочнойРегистрацииДанныхПланаОбмена(ИмяПланаОбмена) Экспорт
	
	ЗначениеНастройки = ОбменДаннымиСервер.ЗначениеНастройкиПланаОбмена(ИмяПланаОбмена, "РежимВыборочнойРегистрации");
	Если ОбменДаннымиПовтИсп.ЭтоПланОбменаXDTO(ИмяПланаОбмена)
		И ЗначениеНастройки = ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииСогласноПравиламXML() Тогда
		
		// Для обменов в формате XDTO поддерживается только режим выборочной регистрации "Модифицированность".
		// Что бы исправить неявную ошибку внедрения неявно исправим значение выборочной регистрации.
		ЗначениеНастройки = ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииМодифицированность();
		
	ИначеЕсли ЗначениеНастройки = Неопределено Тогда
		
		// Если настройку не описывали, то возвращаем значение по умолчанию.
		ЗначениеНастройки = ОбменДаннымиРегистрацияСервер.РежимВыборочнойРегистрацииМодифицированность();
		
	КонецЕсли;
	
	Возврат ЗначениеНастройки;
	
КонецФункции

#КонецОбласти

#КонецОбласти