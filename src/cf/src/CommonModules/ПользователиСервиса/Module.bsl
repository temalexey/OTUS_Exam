
#Область ПрограммныйИнтерфейс

// Возвращает признак использования в сервисе общих настроек входа пользователей
// @skip-warning
// @skip-check module-empty-method - особенность реализации.
// 
// Возвращаемое значение:
//  Булево
Функция ИспользоватьОбщиеНастройкиВходаПользователейСервиса() Экспорт
КонецФункции

// Обновить активность пользователя сервиса.
// @skip-warning
// @skip-check module-empty-method - особенность реализации.
// 
// Параметры:
//  ТекущийПользователь - Неопределено - Текущий авторизованный пользователь
//  					- СправочникСсылка.Пользователи
//  ДатаПоследнейАктивности - Неопределено - Начало дня даты текущего сеанса
//							- Дата
Процедура ОбновитьАктивностьПользователяСервиса(
	ТекущийПользователь = Неопределено,
	ДатаПоследнейАктивности = Неопределено) Экспорт
КонецПроцедуры

#КонецОбласти
