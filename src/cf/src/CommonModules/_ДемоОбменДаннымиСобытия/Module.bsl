///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

//////////////////////////////////////////////////////////////////////////////
// Обработчики событий подписок для плана обмена "_ДемоОбменВРаспределеннойИнформационнойБазе".

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписью.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьИзменение(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписью("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюДокумента.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьИзменениеДокумента(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюДокумента("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ, РежимЗаписи, РежимПроведения);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюКонстанты.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьИзменениеКонстанты(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюКонстанты("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьИзменениеНабораЗаписей(Источник, Отказ, Замещение) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ, Замещение);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьИзменениеНабораЗаписейРасчетаПередЗаписью(Источник, Отказ, Замещение, ТолькоЗапись, ЗаписьФактическогоПериодаДействия, ЗаписьПерерасчетов) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ, Замещение);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередУдалением.
//
Процедура _ДемоОбменВРаспределеннойИнформационнойБазеЗарегистрироватьУдаление(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередУдалением("_ДемоОбменВРаспределеннойИнформационнойБазе", Источник, Отказ);
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////
// Обработчики событий подписок для плана обмена "_ДемоАвтономнаяРабота".

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписью.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьИзменение(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписью("_ДемоАвтономнаяРабота", Источник, Отказ);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюДокумента.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьИзменениеДокумента(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюДокумента("_ДемоАвтономнаяРабота", Источник, Отказ, РежимЗаписи, РежимПроведения);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюКонстанты.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьИзменениеКонстанты(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюКонстанты("_ДемоАвтономнаяРабота", Источник, Отказ);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьИзменениеНабораЗаписей(Источник, Отказ, Замещение) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра("_ДемоАвтономнаяРабота", Источник, Отказ, Замещение);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьИзменениеНабораЗаписейРасчетаПередЗаписью(Источник, Отказ, Замещение, ТолькоЗапись, ЗаписьФактическогоПериодаДействия, ЗаписьПерерасчетов) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередЗаписьюРегистра("_ДемоАвтономнаяРабота", Источник, Отказ, Замещение);
	
КонецПроцедуры

// Описание см. в ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередУдалением.
//
Процедура _ДемоАвтономнаяРаботаЗарегистрироватьУдаление(Источник, Отказ) Экспорт
	
	// Проверка ОбменДанными.Загрузка не требуется, т.к. подписка используется в механизме обмена данными,
	// который в ходе загрузке данных в базу регистрирует эти данные к выгрузке на других узлах плана обмена.
	ОбменДаннымиСобытия.МеханизмРегистрацииОбъектовПередУдалением("_ДемоАвтономнаяРабота", Источник, Отказ);
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////
// Служебные процедуры для целей автоматизированного тестирования обменов.

#КонецОбласти
