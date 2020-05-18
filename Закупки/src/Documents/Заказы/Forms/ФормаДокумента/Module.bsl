&НаКлиенте
Процедура КатегорияТоваровПриИзменении(Элемент)
	КатегорияТоваровПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура КатегорияТоваровПриИзмененииНаСервере()
	Объект.Статус = Справочники.СтатусЗаказа.НайтиПоНаименованию("Не утвержден");
	Объект.Поставщик = Справочники.Поставщики.НайтиПоРеквизиту("КатегорияТоваров", Объект.КатегорияТоваров);
КонецПроцедуры


&НаКлиенте
Процедура ЗаполнитьТЧПоЗаявкам(Команда)
	ЗаполнитьТЧПоЗаявкамНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧПоЗаявкамНаСервере()
	Объект.Товары.Очистить();
	ТекКатегория = Объект.КатегорияТоваров;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВнутренниеЗаявки.Товар КАК Номенклатура,
		|	СУММА(ВнутренниеЗаявки.Количество) КАК Количество,
		|	ВнутренниеЗаявки.Цена КАК Цена
		|ИЗ
		|	Документ.ВнутренниеЗаявки КАК ВнутренниеЗаявки
		|ГДЕ
		|	ВнутренниеЗаявки.КатегорияТоваров = &ТекКатегория
		|	И ВнутренниеЗаявки.ПометкаУдаления = ЛОЖЬ
		|СГРУППИРОВАТЬ ПО
		|	ВнутренниеЗаявки.Товар,
		|	ВнутренниеЗаявки.Цена";
		
	Запрос.УстановитьПараметр("ТекКатегория", ТекКатегория);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Строка = Объект.Товары.Добавить();
		Строка.Номенклатура = Выборка.Номенклатура;
		Строка.Количество = Выборка.Количество;
		Строка.Цена = Выборка.Цена;
		Строка.Сумма = Строка.Цена * Строка.Количество;
	КонецЦикла;
	
	Объект.СуммаЗаказа = Объект.Товары.Итог("Сумма");

КонецПроцедуры


&НаКлиенте
Процедура ТоварыПередУдалением(Элемент, Отказ)
	ТоварыПередУдалениемНаСервере(
			Элементы.Товары.ТекущиеДанные.Номенклатура, 
			Элементы.Товары.ТекущиеДанные.Количество, 
			Элементы.Товары.ТекущиеДанные.Цена);
КонецПроцедуры

&НаСервере
Процедура ТоварыПередУдалениемНаСервере(Товар, колво, цена)
	Если Не Документы.ВнутренниеЗаявки.НайтиПоРеквизиту("Товар", Товар).Пустая() Тогда
		ТекТовар = Документы.ВнутренниеЗаявки.НайтиПоРеквизиту("Товар", Товар).ПолучитьОбъект();
		ТекТовар.УстановитьПометкуУдаления(Ложь);
		ТекТовар.Записать(РежимЗаписиДокумента.Проведение);
	Иначе 
		НовЗаявка = Документы.ВнутренниеЗаявки.СоздатьДокумент();
		НовЗаявка.Дата = ТекущаяДата();
		НовЗаявка.Товар = Товар;
		НовЗаявка.КатегорияТоваров = Объект.КатегорияТоваров;
		НовЗаявка.Количество = колво;
		НовЗаявка.Цена = цена;
		НовЗаявка.Записать(РежимЗаписиДокумента.Проведение);
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	Стр = Элементы.Товары.ТекущиеДанные;
	Стр.Сумма = Стр.Количество * Стр.Цена;
	Объект.СуммаЗаказа = Объект.Товары.Итог("Сумма");
	Проверка(Стр.Количество, Стр.Номенклатура);
КонецПроцедуры


Процедура Проверка(Колво, товар)
	Если Объект.Статус = Справочники.СтатусЗаказа.НайтиПоНаименованию("Согласован") или Объект.Статус = Справочники.СтатусЗаказа.НайтиПоНаименованию("Утвержден") Тогда
		Если (товар.ТекущееКоличество+колво) < товар.МинимальноеКоличество Тогда
			НовЗаявка = Документы.ВнутренниеЗаявки.СоздатьДокумент();
			НовЗаявка.Дата = ТекущаяДата();
			НовЗаявка.Товар = товар.Ссылка;
			НовЗаявка.КатегорияТоваров = Справочники.КатегорииТоваров.НайтиПоНаименованию(товар.Родитель.Наименование);
			НовЗаявка.Цена = товар.Цена;
			НовЗаявка.Количество = товар.МаксимальноеКоличество - (товар.ТекущееКоличество + колво);
			НовЗаявка.Записать(РежимЗаписиДокумента.Проведение);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры



&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	Стр = Элементы.Товары.ТекущиеДанные;
	Стр.Сумма = Стр.Количество * Стр.Цена;
	Объект.СуммаЗаказа = Объект.Товары.Итог("Сумма");
КонецПроцедуры


&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)
	Стр = Элементы.Товары.текущиеДанные;
	Стр.Цена = ПолучитьЦену(Стр.Номенклатура);
КонецПроцедуры

Функция ПолучитьЦену(Номенклатура)
	Возврат Номенклатура.Цена;
КонецФункции












