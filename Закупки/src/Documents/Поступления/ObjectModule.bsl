Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Движения.ПоступлениеТоваров.Записывать = Истина;
		Для Каждого ТекСтрокаТовары Из Товары Цикл
			Движение = Движения.ПоступлениеТоваров.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = ЭтотОбъект.Дата;
			Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
			Движение.Количество = ТекСтрокаТовары.Количество;
		КонецЦикла;
КонецПроцедуры
