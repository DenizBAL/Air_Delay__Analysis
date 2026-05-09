--- VERİ TEMİZLEME (DATA CLEANING)

CREATE CLUSTERED INDEX IX_AirLineDelay_Year --- Airline_Delay_Cause Verisi clustered index kullanıp yıl ve ay'a göre tekrar sıraladık. 
ON Airline_Delay_Cause (year asc,month asc)	--- Index sıralaması ile analiz verimi ve performansı arttılmış ve yeni veri ekleme kolaylaşmış oldu.


--Tablodaki null değerleri bulmak.
DECLARE @TableName NVARCHAR(255) = 'Airline_Delay_Cause';
DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM ' + @TableName + ' WHERE ';

SELECT @SQL = @SQL + COLUMN_NAME + ' IS NULL OR '
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName;

SET @SQL = LEFT(@SQL, LEN(@SQL) - 3);

EXEC sp_executesql @SQL;


---- VERİ ATAMA (DATA IMPUTATION)

-- Uçuş verisinde 15 dakikalık geçikme (arr_del15),hava olayları(weather_delay) vb sorunlarla uçuşlarda gecikmeler olmuştur.
-- Uçuşların yapıldığı bilgisi 'arr_flights' sütunundan alındı. 'Arr_flights' uçuşların toplam sayısını vermektedir. 
-- Uçuşlar gerçekleşmemiş 'Null' satırları, analiz ve hikaye mantığı için veriden çıkarılmıştır.
-- Data Imputation (Veri Atama) yöntemiyle, uçuşu gerçekleşmiş ancak gecikme detayı girilmemiş satırlar '0' olarak kabul edilerek veri bütünlüğü sağlanmıştır.

DELETE FROM Airline_Delay_Cause WHERE arr_flights IS NULL; 

UPDATE Airline_Delay_Cause 
SET 
	arr_del15=ISNULL(arr_del15,0),
	carrier_ct=ISNULL(carrier_ct,0),
	weather_ct=ISNULL(weather_ct,0),
	nas_ct = ISNULL(nas_ct, 0),
    security_ct = ISNULL(security_ct, 0),
    late_aircraft_ct = ISNULL(late_aircraft_ct, 0),
    arr_cancelled = ISNULL(arr_cancelled, 0),
    arr_diverted = ISNULL(arr_diverted, 0),
    arr_delay = ISNULL(arr_delay, 0),
    carrier_delay = ISNULL(carrier_delay, 0),
    weather_delay = ISNULL(weather_delay, 0),
    nas_delay = ISNULL(nas_delay, 0),
    security_delay = ISNULL(security_delay, 0),
    late_aircraft_delay = ISNULL(late_aircraft_delay, 0)
WHERE arr_flights IS NOT NULL;
