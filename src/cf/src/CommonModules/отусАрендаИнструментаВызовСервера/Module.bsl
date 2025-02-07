#Область СлужебныйПрограммныйИнтерфейс

// Возвращает цены депозита и аренды инструмента
//
// Параметры:
//	Инструмент - СправочникСсылка._ДемоНоменклатура - Инструмент
//	Дата - Дата - Дата запроса цен
//
// Возвращаемое значение:
//	Структура - Структура с значениями:
//		* Депозит - Число - стоимость депозита
//		* Аренда - Число - стоимость аренды
//
Функция ПолучитьЦеныИнструмента(Инструмент, Дата = '00010101') Экспорт
				
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	отусСтоимостьДепозитаАрендыСрезПоследних.Инструмент КАК Инструмент,
	|	отусСтоимостьДепозитаАрендыСрезПоследних.Депозит КАК Депозит,
	|	отусСтоимостьДепозитаАрендыСрезПоследних.Аренда КАК Аренда
	|ИЗ
	|	РегистрСведений.отусСтоимостьДепозитаАренды.СрезПоследних(&Дата, Инструмент = &Инструмент) КАК отусСтоимостьДепозитаАрендыСрезПоследних";
	
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Инструмент", Инструмент);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Новый Структура("Депозит,Аренда", Число(Выборка.Депозит), Число(Выборка.Аренда));
	КонецЕсли;
	
	Возврат Новый Структура("Депозит,Аренда", 0, 0);
		
КонецФункции 

#КонецОбласти
