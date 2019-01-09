Функция ПолучитьЗаголовкиСCookie(ПП)
	CookieЗаголовки	= Новый Соответствие;
	CookieЗаголовки.Вставить("Cookie", ПП.IIKO_COOKIE);
	CookieЗаголовки.Вставить("Connection", "keep-alive");
	Возврат CookieЗаголовки;
КонецФункции

Функция ПолучитьСоответствиеСправочниковIIKO() Экспорт
	СМетодКлюч = Новый Соответствие;
	СМетодКлюч.Вставить("products", 	"Номенклатура");
	СМетодКлюч.Вставить("units", 		"ЕдиницыИзмерения");
	СМетодКлюч.Вставить("stores", 		"Склады");
	СМетодКлюч.Вставить("suppliers", 	"Поставщики");
	СМетодКлюч.Вставить("departments", 	"Подразделения");
	СМетодКлюч.Вставить("expenseAccounts", "СтатьиРасходов");
	Возврат СМетодКлюч;
КонецФункции

Функция MSXML(Путь, ДлинаСтроки=100)
	Возврат "convert(xml, [xml]).value('("+Путь+")[1]', 'nvarchar("+ДлинаСтроки+")')";
КонецФункции

Функция PGXML(Путь)
	Возврат "(xpath('"+Путь+"/text()',xml::xml))[1]";	
КонецФункции

Функция PGXMLC(Путь)
	Возврат "cast((xpath('"+Путь+"/text()',xml::xml)) AS text[])";  // {строка}
КонецФункции

Функция ПолучитьЗапросКАйко(ТипЗапроса) Экспорт
	ЗапросыКАйко = Новый Соответствие;
	
	Поля = "Текст, СтрокаПолей";
	
	ЗапросКАйко = Новый Структура(Поля, "select max(revision) as res from entity", "res");
	ЗапросыКАйко.Вставить("НомерОбъекта", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select serverversion from dbversion", "serverversion");	
	ЗапросыКАйко.Вставить("Версия", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+MSXML("/r/departmentId")+" as code,
	|"+MSXML("/r/name")+" as name from entity where type = 'Department'", "id,code,name");
	ЗапросыКАйко.Вставить("MSПодразделения", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/departmentId")+" as code, 
	|"+PGXML("/r/name")+" as name from entity where type = 'Department'", "id,code,name");
	ЗапросыКАйко.Вставить("PGПодразделения", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+MSXML("/r/type")+			" as type,
	|"+MSXML("/r/num")+				" as vcode, 
	|"+MSXML("/r/name/customValue")+" as name,
	|"+MSXML("/r/mainUnit")+		" as unit
	|from entity where entity.type = 'Product'", "id,type,vcode,name,unit");
	ЗапросыКАйко.Вставить("MSНоменклатура", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select top 100 id, 
	|"+MSXML("/r/type")+			" as type,
	|"+MSXML("/r/num")+				" as vcode, 
	|"+MSXML("/r/name/customValue")+" as name,
	|"+MSXML("/r/mainUnit")+		" as unit
	|from entity where entity.type = 'Product'", "id,type,vcode,name,unit");
	ЗапросыКАйко.Вставить("MSНоменклатура100", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/type")+			" as type, 
	|"+PGXML("/r/num")+				" as vcode, 
	|"+PGXML("/r/name/customValue")+" as name,
	|"+PGXML("/r/mainUnit")+		" as unit
	|from entity where type = 'Product' and deleted = 'f'", "id,type,vcode,name,unit");
	ЗапросыКАйко.Вставить("PGНоменклатура", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/type")+			" as type, 
	|"+PGXML("/r/num")+				" as vcode, 
	|"+PGXML("/r/name/customValue")+" as name,
	|"+PGXML("/r/mainUnit")+		" as unit
	|from entity where type = 'Product' and deleted = 'f' limit 100", "id,type,vcode,name,unit");
	ЗапросыКАйко.Вставить("PGНоменклатура100", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+MSXML("/r/code")+" as code,
	|"+MSXML("/r/name/customValue")+" as name from entity where type = 'Store'", "id,code,name");
	ЗапросыКАйко.Вставить("MSСклады", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/code")+" as code, 
	|"+PGXML("/r/name/customValue")+" as name from entity where type = 'Store'", "id,code,name");
	ЗапросыКАйко.Вставить("PGСклады", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'Store' 
	|and "+MSXML("/r/code")+" = '[store_code]'", "id");
	ЗапросыКАйко.Вставить("MSИдСкладаПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'Store' 
	|and "+PGXMLC("/r/code")+" = '{[store_code]}'", "id");
	ЗапросыКАйко.Вставить("PGИдСкладаПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+MSXML("/r/name/customValue")+" as name 
	|from entity where type = 'MeasureUnit'", "id,name");
	ЗапросыКАйко.Вставить("MSЕдиницыИзмерения", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/name/customValue")+" as name 
	|from entity where type = 'MeasureUnit'", "id,name");
	ЗапросыКАйко.Вставить("PGЕдиницыИзмерения", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'Product'
	|and "+MSXML("/r/num")+" = '[product_code]'", "id");
	ЗапросыКАйко.Вставить("MSИдТовараПоАртикулу", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'Product'
	|and "+PGXMLC("/r/num")+" = '{[product_code]}'", "id");
	ЗапросыКАйко.Вставить("PGИдТовараПоАртикулу", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/num")+" as vcode, 
	|"+PGXML("/r/name/customValue")+" as name from entity where type = 'Product'
	|and "+PGXMLC("/r/num")+" = '{[product_code]}'", "id,vcode,name");
	ЗапросыКАйко.Вставить("PGИдКодИмяТовараПоАртикулу", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select 
	|"+PGXML("/r/num")+" as vcode, 
	|"+PGXML("/r/name/customValue")+" as name from entity where type = 'Product' 
	| and id = '[product_id]'", "vcode,name");
	ЗапросыКАйко.Вставить("PGКодИмяТовараПоИд", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'ProductGroup'
	| and "+MSXML("/r/num")+" = '[pgroup_code]'", "id");
	ЗапросыКАйко.Вставить("MSИдГруппыНоменклатурыПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'ProductGroup' 
	| and "+PGXMLC("/r/num")+" = '{[pgroup_code]}'", "id");
	ЗапросыКАйко.Вставить("PGИдГруппыНоменклатурыПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+MSXML("/r/code")+" as vendor_code, 
	|"+MSXML("/r/name/customValue")+" as name
	|from entity where type = 'User' and "+MSXML("/r/supplier", "5")+" = 'true'", 
	"id,vendor_code,name");
	ЗапросыКАйко.Вставить("MSПоставщики", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select top 100 id, 
	|"+MSXML("/r/code")+" as vendor_code, 
	|"+MSXML("/r/name/customValue")+" as name
	|from entity where type = 'User' and "+MSXML("/r/supplier", "5")+" = 'true'", 
	"id,vendor_code,name");
	ЗапросыКАйко.Вставить("MSПоставщики100", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/code")+" as vendor_code, 
	|"+PGXML("/r/name/customValue")+" as name
	|from entity where type = 'User' and "+PGXMLC("/r/supplier")+" = '{true}'",
	"id,vendor_code,name");
	ЗапросыКАйко.Вставить("PGПоставщики", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id, 
	|"+PGXML("/r/code")+" as vendor_code, 
	|"+PGXML("/r/name/customValue")+" as name
	|from entity where type = 'User' and "+PGXMLC("/r/supplier")+" = '{true}' limit 100",
	"id,vendor_code,name");
	ЗапросыКАйко.Вставить("PGПоставщики100", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'User' 
	|and "+MSXML("/r/code")+" = '[vendor_code]'", "id");
	ЗапросыКАйко.Вставить("MSИдПоставщикаПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from entity where type = 'User' 
	|and "+PGXMLC("/r/code")+" = '{[vendor_code]}'", "id");
	ЗапросыКАйко.Вставить("PGИдПоставщикаПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select 
	|"+MSXML("/r/localId")+" as code, 
	|"+MSXML("/r/name/customValue")+" as name
	|from entity where type = 'NonCashPaymentType'", "code,name");
	ЗапросыКАйко.Вставить("MSВидыОплаты", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select 
	|"+PGXML("/r/localId")+" as code, 
	|"+PGXML("/r/name/customValue")+" as name
	|from entity where type = 'NonCashPaymentType'", "code,name");
	ЗапросыКАйко.Вставить("PGВидыОплаты", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id,
	|"+MSXML("/r/name/customValue")+" as name
	|from entity where type = 'Account' and 
	|("+MSXML("/r/type")+" = 'OTHER_EXPENSES' or "+MSXML("/r/type")+" = 'COST_OF_GOODS_SOLD')", "name");
	ЗапросыКАйко.Вставить("MSСтатьиРасходов", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id,
	|"+PGXML("/r/name/customValue")+" as name
	|from entity where type = 'Account' and
	|("+PGXMLC("/r/type")+"= '{OTHER_EXPENSES}' or "+PGXMLC("/r/type")+" = '{COST_OF_GOODS_SOLD}')", "name");
	ЗапросыКАйко.Вставить("PGСтатьиРасходов", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from [doc_type] where documentNumber='[doc_number]'
	| and (dateCreated >= convert(datetime,'[year]-01-01 00:00:00.000', 120)
	| and  dateCreated <= convert(datetime,'[year]-12-31 23:59:59.999', 120))", "id");
	ЗапросыКАйко.Вставить("MSИдДокументаПоКоду", ЗапросКАйко);
	
	ЗапросКАйко = Новый Структура(Поля, "select id from [doc_type] where documentNumber='[doc_number]'
	| and dateCreated >= '[year]-01-01 00:00:00.000' and  dateCreated <= '[year]-12-31 23:59:59.999'", "id");
	ЗапросыКАйко.Вставить("PGИдДокументаПоКоду", ЗапросКАйко);
	
	Возврат ЗапросыКАйко.Получить(ТипЗапроса); 
КонецФункции

Функция ВыполнитьНаСервереАйко(ТипЗапроса, СоответствиеПараметров=Неопределено, ПП) Экспорт// ПП - параметры подключения
	ИмяФайла = ПолучитьИмяВременногоФайла("xml");
	ЗапросКАйко = ПолучитьЗапросКАйко(ТипЗапроса);
	Если ЗапросКАйко <> Неопределено Тогда
		Попытка
			HTTPСоединение = Новый HTTPСоединение(ПП.IIKO_HOST, Число(ПП.IIKO_PORT));	
		Исключение
			ОбработкаДанных.ЗаписатьВЛог(ОписаниеОшибки());
			Возврат Неопределено;
		КонецПопытки;
		Если СоответствиеПараметров <> Неопределено Тогда
			SQLЗапрос = ЗапросКАйко.Текст;
			Для Каждого Параметр Из СоответствиеПараметров Цикл
				SQLЗапрос = СтрЗаменить(SQLЗапрос, "["+Строка(Параметр.Ключ)+"]", Параметр.Значение);
			КонецЦикла;
		Иначе
			SQLЗапрос = ЗапросКАйко.Текст;
		КонецЕсли;
		Попытка
			
			HTTPЗапрос = Новый HTTPЗапрос("/resto/service/maintance/sql.jsp?sql="+
											КодироватьСтроку(SQLЗапрос, СпособКодированияСтроки.КодировкаURL),
											ПолучитьЗаголовкиСCookie(ПП));
			HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос, ИмяФайла);
		Исключение
			ОбработкаДанных.ЗаписатьВЛог(ОписаниеОшибки());
			Возврат Неопределено;
		КонецПопытки;
		Если HTTPОтвет.КодСостояния = 200 Тогда
			ОтветМассивСоответствий = Новый Массив;
			Попытка
				ЧтениеXml = Новый ЧтениеXML;
				ЧтениеXml.ОткрытьФайл(ИмяФайла);
				ЧтениеXml.Прочитать();			
				Пока ЧтениеXml.Прочитать() Цикл 
					Если ЧтениеXml.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
						Если ЧтениеXml.Имя = "row" Тогда
							ОтветСоответствие = Новый Соответствие;	
						Иначе
							Для Каждого ИмяПоля Из СтрРазделить(ЗапросКАйко.СтрокаПолей, ",") Цикл
								Если ЧтениеXml.Имя = ИмяПоля Тогда
									ЧтениеXml.Прочитать();
									ОтветСоответствие.Вставить(ИмяПоля, ЧтениеXml.Значение);
								КонецЕсли;
							КонецЦикла;
						КонецЕсли;
					ИначеЕсли ЧтениеXml.ТипУзла = ТипУзлаXML.КонецЭлемента И ЧтениеXml.Имя = "row" Тогда
						ОтветМассивСоответствий.Добавить(ОтветСоответствие);
					КонецЕсли;
				КонецЦикла;
				ЧтениеXml.Закрыть();
			Исключение
				ОбработкаДанных.ЗаписатьВЛог("Не удалось прочитать XML-файл");
				Возврат Неопределено;
			КонецПопытки;
			Возврат ОтветМассивСоответствий;
		КонецЕсли;
	Иначе
		ОбработкаДанных.ЗаписатьВЛог("Неизвестный тип запроса "+ТипЗапроса);
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

// Возвращает структуру с полями:
// Результат - Истина, если все ок
// Ошибка - если Результат - Ложь, содержит ошибку из XML-ответа Айко
// УидАйко - идентификатор созданного объекта в случае успешного создания
Функция ОбработатьHTTPОтветПриСозданииОбъектаАйко(HTTPОтвет)
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		//ЗаписатьВЛог("Веб-сервер вернул код, отличный от 200 при создании объекта Айко!");
		Возврат Неопределено;	
	КонецЕсли;
	
	XMLОтвета = ОбработкаДанных.РасшифроватьGZIP(HTTPОтвет.ПолучитьТелоКакДвоичныеДанные());
	СтруктураОтвета = Новый Структура;
	ЧтениеXml = Новый ЧтениеXML();
	ЧтениеXml.УстановитьСтроку(XMLОтвета);
		
	Пока ЧтениеXml.Прочитать() Цикл
		Если ЧтениеXml.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если ЧтениеXml.Имя = "returnValue" Тогда
				ЧтениеXml.Прочитать();
				СтруктураОтвета.Вставить("УидАйко", ЧтениеXml.Значение);
			КонецЕсли;
			Если ЧтениеXml.Имя = "success" Тогда
				ЧтениеXml.Прочитать();
				Если ЧтениеXml.Значение = "true" Тогда
					СтруктураОтвета.Вставить("Результат", Истина);
				Иначе
					СтруктураОтвета.Вставить("Результат", Ложь);
				КонецЕсли;
			КонецЕсли;
			Если ЧтениеXml.Имя = "errorString" Тогда
				ЧтениеXml.Прочитать();
				СтруктураОтвета.Вставить("Ошибка", ЧтениеXml.Значение);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЧтениеXml.Закрыть();
	
	Возврат СтруктураОтвета;
КонецФункции