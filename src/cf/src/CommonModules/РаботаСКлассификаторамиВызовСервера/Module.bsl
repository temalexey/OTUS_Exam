///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Подсистема "ИнтернетПоддержкаПользователей.РаботаСКлассификаторами".
// ОбщийМодуль.РаботаСКлассификаторамиВызовСервера.
//
// Серверные процедуры и функции загрузки классификаторов:
//  - настройка режима обновления классификаторов.
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Определяет расписание регламентного задания обновления классификаторов.
//
// Возвращаемое значение:
//  Структура:
//   * Расписание - Неопределено, РасписаниеРегламентногоЗадания - расписание обновления классификаторов.
//   * ВариантОбновления - Число
//
Функция НастройкиОбновленияКлассификаторов() Экспорт
	
	// Расписание и вариант обновления классификаторов не являются секретной информацией
	// и может быть получена любым пользователем ИБ.
	Если РаботаСКлассификаторами.ИнтерактивнаяЗагрузкаКлассификаторовДоступна() Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("Расписание",        Неопределено);
	Результат.Вставить("ВариантОбновления", Константы.ВариантОбновленияКлассификаторов.Получить());
	
	ЗаданияОбновления = РаботаСКлассификаторами.ЗаданияОбновлениеКлассификаторов();
	Если ЗаданияОбновления.Количество() <> 0 Тогда
		Результат.Расписание = ЗаданияОбновления[0].Расписание;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Задает расписание регламентного задания.
//
// Параметры:
//  Расписание - РасписаниеРегламентногоЗадания - расписание обновления классификаторов.
//
Процедура ЗаписатьРасписаниеОбновления(Знач Расписание) Экспорт
	
	Если РаботаСКлассификаторами.ИнтерактивнаяЗагрузкаКлассификаторовДоступна() Тогда
		УстановитьПривилегированныйРежим(Истина);
	КонецЕсли;
	
	ЗаданияОбновления = РаботаСКлассификаторами.ЗаданияОбновлениеКлассификаторов();
	Если ЗаданияОбновления.Количество() <> 0 Тогда
		РегламентныеЗаданияСервер.УстановитьРасписаниеРегламентногоЗадания(
			ЗаданияОбновления[0],
			Расписание);
	КонецЕсли;
	
КонецПроцедуры

// Включает автоматическое обновление классификаторов из сервиса.
//
Процедура ВключитьАвтоматическоеОбновлениеКлассификаторовИзСервиса() Экспорт
	
	РаботаСКлассификаторами.ВключитьАвтоматическоеОбновлениеКлассификаторовИзСервиса();
	
КонецПроцедуры

#КонецОбласти
