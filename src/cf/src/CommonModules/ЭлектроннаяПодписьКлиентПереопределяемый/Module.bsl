///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Вызывается после создания на сервере, но до открытия форм ПодписаниеДанных, РасшифровкаДанных.
// Используется для дополнительных действий, которые требуют серверного вызова, чтобы не
// вызывать сервер лишний раз.
//
// Параметры:
//  Операция          - Строка - строка Подписание или Расшифровка.
//
//  ВходныеПараметры  - Произвольный - значение свойства ПараметрыДополнительныхДействий
//                      параметра ОписаниеДанных методов Подписать, Расшифровать общего
//                      модуля ЭлектроннаяПодписьКлиент.
//                      
//  ВыходныеПараметры - Произвольный - произвольные данные, которые были возвращены
//                      с сервера из одноименной процедуры общего модуля.
//                      ЭлектроннаяПодписьПереопределяемый.
//
Процедура ПередНачаломОперации(Операция, ВходныеПараметры, ВыходныеПараметры) Экспорт
	
	
	
КонецПроцедуры

// Вызывается из формы ПроверкаСертификата, если при создании формы были добавлены дополнительные проверки.
//
// Параметры:
//  Параметры - Структура:
//   * ОжидатьПродолжения   - Булево - возвращаемое значение. Если Истина, тогда дополнительная проверка
//                            будет выполнятся асинхронно, продолжение возобновится после выполнения оповещения.
//                            Начальное значение Ложь.
//   * Оповещение           - ОписаниеОповещения - обработка, которую нужно вызывать для продолжения
//                              после асинхронного выполнения дополнительной проверки.
//   * Сертификат           - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - проверяемый сертификат.
//   * Проверка             - Строка - имя проверки, добавленное в процедуре ПриСозданииФормыПроверкаСертификата
//                              общего модуля ЭлектроннаяПодписьПереопределяемый.
//   * МенеджерКриптографии - МенеджерКриптографии - подготовленный менеджер криптографии для
//                              выполнения проверки.
//                         - Неопределено - если стандартные проверки отключены в процедуре
//                              ПриСозданииФормыПроверкаСертификата общего модуля ЭлектроннаяПодписьПереопределяемый.
//   * ОписаниеОшибки       - Строка - возвращаемое значение. Описание ошибки, полученной при выполнении проверки.
//                              Это описание сможет увидеть пользователь при нажатии на картинку результата.
//   * ЭтоПредупреждение    - Булево - возвращаемое значение. Вид картинки Ошибка/Предупреждение,
//                            начальное значение - Ложь.
//   * Пароль   - Строка - пароль, введенный пользователем.
//                   - Неопределено - если свойство ВводитьПароль установлено в Ложь в процедуре
//                            ПриСозданииФормыПроверкаСертификата общего модуля ЭлектроннаяПодписьПереопределяемый.
//   * РезультатыПроверок   - Структура:
//      * Ключ     - Строка - имя стандартной или дополнительной проверки или имя ошибки. Ключ свойства, содержащего
//                 ошибку, содержит имя проверки с окончанием Ошибка.
//      * Значение - Неопределено - проверка не выполнялась (ОписаниеОшибки осталось Неопределено).
//                 - Булево - результат выполнения дополнительной проверки.
//                 - Строка - когда ключ свойства содержит окончание Ошибка и результат выполненной проверки Ложь,
//                 содержит описание возникшей ошибки.
//
Процедура ПриДополнительнойПроверкеСертификата(Параметры) Экспорт
	
	// _Демо начало примера
	_ДемоСтандартныеПодсистемыКлиент.ПриДополнительнойПроверкеСертификата(Параметры);
	// _Демо конец примера
	
КонецПроцедуры

// Вызывается при открытии инструкции по работе с программами электронной подписи и шифрования.
//
// Параметры:
//  Раздел - Строка - начальное значение "БухгалтерскийИНалоговыйУчет",
//                    можно указать "УчетВГосударственныхУчреждениях".
//
Процедура ПриОпределенииРазделаСтатьиНаИТС(Раздел) Экспорт
	
	
	
КонецПроцедуры

// Вызывается после интерактивного добавления в справочник сертификатов электронной подписи.
//
// Параметры:
//  Параметры - Структура:
//    * Сертификаты - Массив Из Структура:
//     ** НовыйСертификат  - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - добавленный сертификат.
//     ** СтарыйСертификат - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования, Неопределено - найденный сертификат 
//             с аналогичными свойствами субъекта, подлежащий замене.
//
Процедура ПослеДобавленияВСправочникСертификатовЭлектроннойПодписи(Параметры) Экспорт
	
	// _Демо начало примера
	_ДемоСтандартныеПодсистемыКлиент.ПослеДобавленияВСправочникСертификатовЭлектроннойПодписи(Параметры);
	// _Демо конец примера
	
КонецПроцедуры

#КонецОбласти
