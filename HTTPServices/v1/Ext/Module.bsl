﻿Функция ПолучитьСтруктуруИзКодаИJSONСтроки(КодHTTP, JSONСтрока)
	Возврат Новый Структура("КодHTTP,JSONСтрока", КодHTTP, JSONСтрока);	
КонецФункции

Функция ПреобразоватьСтруктуруВJSONСтроку(Структура)
	ЗаписьJSON	= Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	//СериализаторXDTO.ЗаписатьJSON(ЗаписьJSON, Структура, НазначениеТипаXML.Явное);
	ЗаписатьJSON(ЗаписьJSON, Структура);
	Возврат ЗаписьJSON.Закрыть(); 
КонецФункции

Функция ПреобразоватьJSONСтрокуВСтруктуру(JSONСтрока)
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(JSONСтрока);
	Структура = ПрочитатьJSON(ЧтениеJSON, Ложь);
	ЧтениеJSON.Закрыть();
	Возврат Структура;
КонецФункции

// Формирует HTTP-ответ из Структуры с полями КодHTTP и JSON-строка
Функция ОтправитьJSON(СтруктураОтвета)
	Ответ = Новый HTTPСервисОтвет(СтруктураОтвета.КодHTTP);
	Ответ.Заголовки.Вставить("Content-Type","application/zip; charset=utf-8");
	ИмяФайлаJSON = КаталогВременныхФайлов() + ПолучитьРазделительПути() + "response.json";
	ИмяФайлаZIP  = ПолучитьИмяВременногоФайла("zip");
	Файл = Новый ЗаписьТекста(ИмяФайлаJSON);
	Файл.ЗаписатьСтроку(СтруктураОтвета.JSONСтрока);
	Файл.Закрыть();
	АрхивZIP = Новый ЗаписьZipФайла(ИмяФайлаZIP);
	АрхивZIP.Добавить(ИмяФайлаJSON);
	АрхивZIP.Записать();
	Ответ.УстановитьИмяФайлаТела(ИмяФайлаZIP);
	Возврат Ответ;	
КонецФункции

// Из стандартных полей ошибки
// формирует JSON-строку
Функция СформироватьСтруктуруОшибки(Ошибка)
	ОшибкаJSON = Новый Структура("code,message,fields", Ошибка.Код, Ошибка.Текст, Ошибка.Поля);
	Возврат ПолучитьСтруктуруИзКодаИJSONСтроки(Ошибка.КодHTTP, ПреобразоватьСтруктуруВJSONСтроку(ОшибкаJSON));
КонецФункции

// Возвращает таблицу с ошибками по коду
// Колонки: Код, Текст, Поля
Функция ПолучитьОшибкуПоКоду(КодОшибки, ПоляОшибки="")
	ТаблицаОшибок = Новый ТаблицаЗначений;
	
	СтрокаКолонок = "Код;Текст;Поля;КодHTTP";
	Для каждого ИмяКолонки Из ОбработкаДанных.ПолучитьСписокИзСтроки(СтрокаКолонок, ";") Цикл
		ТаблицаОшибок.Колонки.Добавить(ИмяКолонки);
	КонецЦикла;
	
	Стр = ТаблицаОшибок.Добавить(); Стр.Код = 01; Стр.Поля = ПоляОшибки; Стр.КодHTTP = 405; 
	Стр.Текст = "Метод не поддерживается";
	Стр = ТаблицаОшибок.Добавить(); Стр.Код = 02; Стр.Поля = ПоляОшибки; Стр.КодHTTP = 404; 
	Стр.Текст = "Не удалось получить информацию о сервере";
	Стр = ТаблицаОшибок.Добавить(); Стр.Код = 03; Стр.Поля = ПоляОшибки; Стр.КодHTTP = 405; 
	Стр.Текст = "Неизвестный тип сервера";
	Стр = ТаблицаОшибок.Добавить(); Стр.Код = 91; Стр.Поля = ПоляОшибки; Стр.КОдHTTP = 401;
	Стр.Текст = "Не заданы параметры подключения к IIKO";
	Стр = ТаблицаОшибок.Добавить();	Стр.Код = 99; Стр.Поля = ПоляОшибки; Стр.КодHTTP = 520; 
	Стр.Текст = "Неизвестная ошибка";
	
	НайденнаяОшибка = ТаблицаОшибок.Найти(КодОшибки);
	Если НайденнаяОшибка = Неопределено Тогда
		НайденнаяОшибка = ТаблицаОшибок.Найти(99);
	КонецЕсли;
	
	Возврат НайденнаяОшибка;
КонецФункции

Функция ПолучитьПараметрыПодключения(ЗаголовкиЗапроса)
	// IIKO_PASS - sha-1 хэш пароля	
	ИменаПараметровПодключения = "IIKO_HOST;IIKO_PORT;IIKO_LOGIN;IIKO_PASS;IIKO_COOKIE";
	ПараметрыСписком = ОбработкаДанных.ПолучитьСписокИзСтроки(ИменаПараметровПодключения, ";");
	СтруктураВозврата = Новый Структура;
	Для каждого ИмяПараметра Из ПараметрыСписком Цикл
		ЗначениеПараметра = ЗаголовкиЗапроса.Получить(ИмяПараметра.Значение);
		Если ЗначениеПараметра = Неопределено Тогда
			Возврат Неопределено;
		Иначе
			СтруктураВозврата.Вставить(ИмяПараметра.Значение, ЗначениеПараметра);
		КонецЕсли;
	КонецЦикла;
	Возврат СтруктураВозврата;
КонецФункции

Функция ВыполнитьМетодВыполнитьМетодGET(Запрос)
	ИмяМетода = Запрос.ПараметрыURL["method_name"];
	// функции возвращают результат в виде структуры с полями: КодHTTP, JSONСтрока
	ПараметрыПодключения = ПолучитьПараметрыПодключения(Запрос.Заголовки);
	// IIKO_DBMS_TYPE - тип СУБД (MS - Microsoft SQL Server, PG - PostgreSQL)
	ТипСУБД = IIKOСправочники.ВыполнитьНаСервереАйко("MS", "ТипСУБД",,ПараметрыПодключения)[0].Получить("dbVendor");
	Если ВРег(ТипСУБД) = "MSSQL" Тогда
		DBMS_TYPE = "MS";
	Иначе
		DBMS_TYPE = "PG";
	КонецЕсли;
	ПараметрыПодключения.Вставить("IIKO_DBMS_TYPE", DBMS_TYPE);
	Если ПараметрыПодключения = Неопределено Тогда
		Ошибка = ПолучитьОшибкуПоКоду(91, "");
		Результат = СформироватьСтруктуруОшибки(Ошибка);
	Иначе
		ССправочников = IIKOСправочники.ПолучитьСоответствиеСправочниковIIKO();
		КлючЗапроса = ССправочников.Получить(ИмяМетода);
		Если КлючЗапроса = Неопределено Тогда
			МассивСправочников = ОбработкаДанных.ПолучитьМассивКлючей(ССправочников);
			Ошибка = ПолучитьОшибкуПоКоду(01, "["+СтрСоединить(МассивСправочников, ",")+"]");
			Результат = СформироватьСтруктуруОшибки(Ошибка);
		Иначе
			АйкоМассивСоответствий = IIKOСправочники.ВыполнитьНаСервереАйко(ПараметрыПодключения.IIKO_DBMS_TYPE, КлючЗапроса,,ПараметрыПодключения);
			Результат = ПолучитьСтруктуруИзКодаИJSONСтроки(200, ПреобразоватьСтруктуруВJSONСтроку(АйкоМассивСоответствий));
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОтправитьJSON(Результат);
КонецФункции

Функция IIKOСоздатьДокумент(ПП, Запрос)
	ИмяМетода = Запрос.ПараметрыURL["method_name"];
	СтруктураДокумента = ПреобразоватьJSONСтрокуВСтруктуру(Запрос.ПолучитьТелоКакСтроку());
	СДокументов = IIKOДокументы.ПолучитьСоответствиеДокументовIIKO();
	
	Если СДокументов.Получить(ИмяМетода) <> Неопределено Тогда
		СтруктураДокумента.Вставить("ИмяМетода", ИмяМетода);
	Иначе
		МассивДокументов = ОбработкаДанных.ПолучитьМассивКлючей(СДокументов);
		Ошибка = ПолучитьОшибкуПоКоду(01, "["+СтрСоединить(МассивДокументов, ",")+"]");
		Возврат СформироватьСтруктуруОшибки(Ошибка);
	КонецЕсли;
	
	ИнфоСервера = ОбработкаДанных.ПолучитьИнфоСервера(ПП);
	
	Если ИнфоСервера = Неопределено Тогда
		Ошибка = ПолучитьОшибкуПоКоду(02);
		Возврат СформироватьСтруктуруОшибки(Ошибка);
	КонецЕсли;
	ПП.Вставить("version", ИнфоСервера.version);
	// IIKO_BACK_TYPE - тип бэк-офиса (RMS или CHAIN)
	Редакция = ВРег(ИнфоСервера.edition);
	Если Редакция = "DEFAULT" Тогда
		ПП.Вставить("IIKO_BACK_TYPE", "IIKO_RMS");
	ИначеЕсли Редакция = "CHAIN" Тогда
		ПП.Вставить("IIKO_BACK_TYPE", "IIKO_CHAIN");
	Иначе
		Ошибка = ПолучитьОшибкуПоКоду(03);
		Возврат СформироватьСтруктуруОшибки(Ошибка);
	КонецЕсли;
	
	РезультатСтруктура = IIKOДокументы.ПередатьXMLДокументВАйко(СтруктураДокумента, ПП);
	Возврат ПолучитьСтруктуруИзКодаИJSONСтроки(200, ПреобразоватьСтруктуруВJSONСтроку(РезультатСтруктура));
КонецФункции

Функция ВыполнитьМетодВыполнитьМетодPOST(Запрос)
	
	// функции возвращают результат в виде структуры с полями: КодHTTP, JSONСтрока
	ПараметрыПодключения = ПолучитьПараметрыПодключения(Запрос.Заголовки);
	Если ПараметрыПодключения = Неопределено Тогда
		Ошибка = ПолучитьОшибкуПоКоду(91, "");
		Результат = СформироватьСтруктуруОшибки(Ошибка);
	Иначе                                                     
		Результат = IIKOСоздатьДокумент(ПараметрыПодключения, Запрос);
	КонецЕсли;
	
	Возврат ОтправитьJSON(Результат);
КонецФункции
