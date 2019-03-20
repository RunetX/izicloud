&НаКлиенте
Функция MSXML(Путь, ДлинаСтроки=100)
	Возврат "convert(xml, [xml]).value('("+Путь+")[1]', 'nvarchar("+ДлинаСтроки+")')";
КонецФункции

&НаКлиенте
Функция PGXML(Путь)
	Возврат "(xpath('"+Путь+"/text()',xml::xml))[1]";	
КонецФункции

&НаКлиенте
Функция PGXMLC(Путь)
	Возврат "cast((xpath('"+Путь+"/text()',xml::xml)) AS text[])";  // {строка}
КонецФункции

&НаКлиенте
Функция XML(ТипБД, Путь, ДлинаСтроки=100, Условие=Ложь)
	Если ТипБД = "MS" Тогда
		Возврат MSXML(Путь, ДлинаСтроки);
	ИначеЕсли ТипБД = "PG" Тогда
		Если Условие Тогда
			Возврат PGXMLC(Путь);
		Иначе
			Возврат PGXML(Путь);
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

&НаКлиенте
Функция CV(ТипБД, Значение)
	Если ТипБД = "MS" Тогда
		Возврат Значение;
	ИначеЕсли ТипБД = "PG" Тогда
		Возврат "{" + Значение + "}";
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

&НаКлиенте
Процедура ДобавитьЗапросКАйко(ЗапросыКАйко, СтрокаЗапроса)
	Поля = "Текст, СтрокаПолей";
	ПараметрыСтрокиЗапроса = СтрРазделить(СтрокаЗапроса, ";");
	КлючЗапроса = ПараметрыСтрокиЗапроса[0];
	ЗапросыКАйко.Вставить(КлючЗапроса, Новый Структура(Поля, ПараметрыСтрокиЗапроса[1], ПараметрыСтрокиЗапроса[2]));
КонецПроцедуры

&НаКлиенте
Функция ПолучитьЗапросыКАйко(ТипБД)
	ЗапросыКАйко = Новый Соответствие;	
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "НомерОбъекта;select max(revision) as res from entity;res");	
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ТипСУБД;select dbVendor from DBVersion;dbVendor");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "Справочники;select id,type,xml from entity where type in ([entity_types]);id,type,xml");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "Подразделения;select id, 
	|"+XML(ТипБД, "/r/departmentId")+" as code,
	|"+XML(ТипБД, "/r/name")+" as name from entity where type = 'Department';id,code,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "Номенклатура;select id, 
	|"+XML(ТипБД, "/r/type")+			 " as type,
	|"+XML(ТипБД, "/r/num")+			 " as vcode, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name,
	|"+XML(ТипБД, "/r/parent")+			 " as parent,
	|"+XML(ТипБД, "/r/mainUnit")+		 " as unit
	|from entity where type = 'Product' and deleted = '0';id,type,vcode,name,parent,unit");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ГруппыНоменклатуры;select id,
	|"+XML(ТипБД, "/r/num")+			 " as code,
	|"+XML(ТипБД, "/r/parent")+			 " as parent,
	|"+XML(ТипБД, "/r/name/customValue")+" as name
	|from entity where type = 'ProductGroup' and deleted = '0';id,code,parent,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "Склады;select id, 
	|"+XML(ТипБД, "/r/code")+" as code,
	|"+XML(ТипБД, "/r/name/customValue")+" as name from entity where type = 'Store';id,code,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдСкладаПоКоду;select id from entity where type = 'Store' 
	|and "+XML(ТипБД, "/r/code",,Истина)+" = '"+CV(ТипБД, "[store_code]")+"';id");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ЕдиницыИзмерения;select id, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name 
	|from entity where type = 'MeasureUnit';id,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдТовараПоАртикулу;select id from entity where type = 'Product'
	|and "+XML(ТипБД, "/r/num",,Истина)+" = '"+CV(ТипБД, "[product_code]")+"';id");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдКодИмяТовараПоАртикулу;select id, 
	|"+XML(ТипБД, "/r/num")+" as vcode, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name from entity where type = 'Product'
	|and "+XML(ТипБД, "/r/num",,Истина)+" = '"+CV(ТипБД, "[product_code]")+"';id,vcode,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "КодИмяТовараПоИд;select 
	|"+XML(ТипБД, "/r/num")+" as vcode, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name from entity where type = 'Product' 
	| and id = '[product_id]';vcode,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдГруппыНоменклатурыПоКоду;select id from entity where type = 'ProductGroup'
	| and "+XML(ТипБД, "/r/num",,Истина)+" = '"+CV(ТипБД, "[pgroup_code]")+"';id");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "Поставщики;select id, 
	|"+XML(ТипБД, "/r/code")+" as vendor_code, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name
	|from entity where type = 'User' and "+XML(ТипБД, "/r/supplier", "5", Истина)+" = '"+CV(ТипБД, "true")+"';id,vendor_code,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдПоставщикаПоКоду;select id from entity where type = 'User' 
	|and "+XML(ТипБД, "/r/code",,Истина)+" = '"+CV(ТипБД, "[vendor_code]")+"';id");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ВидыОплаты;select 
	|"+XML(ТипБД, "/r/localId")+" as code, 
	|"+XML(ТипБД, "/r/name/customValue")+" as name
	|from entity where type = 'NonCashPaymentType';code,name");
	
	ДобавитьЗапросКАйко(ЗапросыКАйко, "СтатьиРасходов;select id,
	|"+XML(ТипБД, "/r/name/customValue")+" as name
	|from entity where type = 'Account' and
	|("+XML(ТипБД, "/r/type",,Истина)+"= '"+CV(ТипБД, "OTHER_EXPENSES")+
	"' or "+XML(ТипБД, "/r/type",,Истина)+" = '"+CV(ТипБД, "COST_OF_GOODS_SOLD")+"');name");
	
	Если ТипБД = "MS" Тогда
		СтрокаЗапроса = "select id from [doc_type] where documentNumber='[doc_number]'
		| and (dateCreated >= convert(datetime,'[year]-01-01 00:00:00.000', 120)
		| and  dateCreated <= convert(datetime,'[year]-12-31 23:59:59.999', 120))";	
	Иначе
		СтрокаЗапроса = "select id from [doc_type] where documentNumber='[doc_number]'
		| and dateCreated >= '[year]-01-01 00:00:00.000' and  dateCreated <= '[year]-12-31 23:59:59.999'"
	КонецЕсли;
	ДобавитьЗапросКАйко(ЗапросыКАйко, "ИдДокументаПоКоду;"+СтрокаЗапроса+";id");
	
	Возврат ЗапросыКАйко;
КонецФункции

&НаСервере
Процедура ЗаполнитьТЗ(СС)	
	НаборЗаписей = РегистрыСведений.IIKOSQLЗапросы.СоздатьНаборЗаписей();	
	Для каждого ЭлС Из СС Цикл
		ТипБД = ЭлС.Ключ;
		СоответствиеЗапросов = ЭлС.Значение;
		Для каждого СЗ из СоответствиеЗапросов Цикл
			НоваяЗапись = НаборЗаписей.Добавить();	
			НоваяЗапись.ТипБД = ТипБД;
			НоваяЗапись.ТипЗапроса = СЗ.Ключ;
			НоваяЗапись.Текст = СЗ.Значение.Текст;
			НоваяЗапись.Поля = СЗ.Значение.СтрокаПолей;
		КонецЦикла;
	КонецЦикла;	
	НаборЗаписей.Записать();
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	СС = Новый Соответствие;
	СС.Вставить("MS", ПолучитьЗапросыКАйко("MS"));
	СС.Вставить("PG", ПолучитьЗапросыКАйко("PG"));
	ЗаполнитьТЗ(СС);
КонецПроцедуры
