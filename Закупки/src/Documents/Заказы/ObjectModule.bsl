Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	ЭтотОбъект.СуммаЗаказа = ЭтотОбъект.Товары.Итог("Сумма");
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	ЗакрытыйЗаказ = Справочники.СтатусЗаказа.НайтиПоНаименованию("Закрыт");
	
	Если ЭтотОбъект.Статус = ЗакрытыйЗаказ Тогда
		Движения.ОстаткиТоваров.Записывать = Истина;
		Для Каждого ТекСтрокаТовары Из Товары Цикл
			Движение = Движения.ОстаткиТоваров.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
			Движение.Количество = ТекСтрокаТовары.Количество;
		КонецЦикла;		
	КонецЕсли;
	
КонецПроцедуры


