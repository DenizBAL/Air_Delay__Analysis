SELECT 
	   year,
	   SUM(arr_flights) AS 'Toplam_Uçuş',
	   SUM(arr_del15) AS 'Toplam_Gecikme_Süresi',
	   --Gecikme Oranı(%)
	   CAST(SUM(arr_del15)*100.0/NULLIF(SUM(arr_flights),0) AS DECIMAL(10,2)) AS 'Gecikme_Oranı_Yüzde'
FROM Airline_Delay_Cause
GROUP BY year
ORDER BY year ASC
-- 2013 yılı verileri kısmi olduğu için Toplam_Uçuş diğer yıllara göre daha düşüktür.
-- 2020 Yılında pandemi döneminde hava trafiği,uçuş sayısı azaldığı için geçikme oranı aynı oranda azalmış görünmektedir.
-- 2023 yılında şirketin Toplam_Uçuşları %35 oranında düşüş yaşamış. Aynı zamanda geçikme oranı en yüksek seviyeye ulaşmıştır.
-- Pandemi sonrası uçuşların artması ve personel eksikliği böyle bir sonuca neden olmuş olabilir.


SELECT 
	year,
	SUM(carrier_ct) AS 'Şirket_Hatası',
	SUM(weather_ct) AS 'Hava_Durumu',
	SUM(nas_ct) AS 'Hava_Trafik_Sistemi',
	SUM(late_aircraft_ct) AS 'Ucağın_Geç_Gelmesi'
FROM Airline_Delay_Cause
GROUP BY year
ORDER BY year ASC
-- Hava Yolunun Seferlerde Gecikme Nedenleri (Yıl bazında toplam uçuş değerlerine göre):
-- Pandemi sonrası (2021'den 2022'ye geçişte) şirket kaynaklı hatalar yaklaşık 12 milyon birden artmış.
-- 2021-2022 Yılı havayollarının ani talep artışına hazırlıksız yakalandığının kanıtı. Personel eksikliği, uçak bakım süreçlerindeki aksamalar ve operasyonel yönetim hataları bu yıl tavan yapmış.
-- Hemen her yıl en yüksek rakamlar 'Uçağın_Gec_Gelmesi' sütünda yer almaktadır. Havacılıkta her şey birbirine bağlıdır. Sabah yapılan 15 dakikalık bir Şirket Hatası, akşam yapılacak son uçuşun saatlerce gecikmesine neden oluyor.
-- Yolcular genelde gecikmeleri kar veya fırtınaya bağlar, ancak verilere bakıldığında. Gecikmelerin asıl sebebi kötü hava değil, kötü yönetim ve yoğun trafik olduğu gözlemleniyor.


SELECT 
	carrier_name,
	SUM(arr_flights) AS 'Toplam_Uçuş',
	SUM(arr_del15) AS 'Toplam_Gecikme_Süresi',
	--Gecikme Oranı(%)
	CAST(SUM(arr_del15)*100.0/NULLIF(SUM(arr_flights),0) AS DECIMAL(10,2)) AS 'Gecikme_Oranı_Yüzde',
	--Şirket Kaynaklı Ortalama Gecikme Süresi (dakika)
	CAST(AVG(carrier_delay)AS DECIMAL(10,2)) AS 'Ortalama_Şirket_Gecikme_Süresi'
FROM Airline_Delay_Cause
GROUP BY carrier_name
HAVING SUM(arr_flights)>1000
ORDER BY 'Gecikme_Oranı_Yüzde' ASC

-- Gecikme_Oranı_Yüzde Kolonuna bakılarak:
-- Hawaiian Airlines (%12.35), Endeavor Air (%13.68) ve Delta Air Lines (%13.84) yer alıyor. Bu 3 şirket havacılıkta stabile yakın bir uçuş deneyimi yaşatmaktadır.
-- %20'den fazla gecikme olan şirketlerin nerdeyse 4 biletten 1 tanesinde gecikme yaşatacağı garanti etmektedir.

SELECT 
	carrier_name,
	SUM(carrier_ct) AS 'Sirket_Hatası',
	SUM(weather_ct) AS 'Hava Durumu',
	SUM(arr_del15) AS 'Ucağın_Geç_Gelmesi'
FROM Airline_Delay_Cause WHERE carrier_name IN ('Allegiant Air','Frontier Airlines Inc.','JetBlue Airways')
GROUP BY carrier_name
-- Hava yolunda bulunan ve gecikmelerin en çok yaşanılan 3 şirketin ortak problemi hava sorunu vs değilde daha çok şirket yönetiminden kaynaklı olduğu gözlemlenmiştir.



SELECT 
    month,
    AVG('Gecikme_Orani') as 'Ortalama_Gecikme_Yuzdesi'
FROM (
    SELECT 
        month,
        CAST(SUM(arr_del15) * 100.0 / NULLIF(SUM(arr_flights), 0) AS DECIMAL(10,2)) AS 'Gecikme_Orani'
    FROM Airline_Delay_Cause
    GROUP BY year, month
) AS AylikVeri
GROUP BY month
ORDER BY month ASC;
-- Yaz ayı Gecikme oranları %21.70 ve %21.40 ile zirve yapmış. Haziran-Temmuz ayları arası , tatil sezonunun en yoğun olduğu dönemdir. Uçuş sayısı artar, havalimanları kapasitesinin üzerine çıkmaktadır.
-- Eylül ayı %13.83 ile yılın en düşük gecikme oranına sahip.Huzurlu ve zamanında bir yolculuk istiyorsanız, eylül ayı sizin için en güvenli limandır.



SELECT TOP 10
    airport_name,
    SUM(arr_flights) AS 'Toplam_Ucus',
    CAST(SUM(arr_del15) * 100.0 / NULLIF(SUM(arr_flights), 0) AS DECIMAL(10,2)) AS 'Gecikme_Orani_Yuzde'
FROM Airline_Delay_Cause
GROUP BY airport_name
HAVING SUM(arr_flights) > 50000 
ORDER BY Gecikme_Orani_Yuzde DESC;
--En çok gecikmelerin olduğu hava limanları.

SELECT 
    carrier_name,
    SUM(arr_flights) AS 'Toplam_Ucus',
    SUM(arr_cancelled) AS 'Toplam_Iptal',
    -- İptal Oranı Yüzde
    CAST(SUM(arr_cancelled) * 100.0 / NULLIF(SUM(arr_flights), 0) AS DECIMAL(10,2)) AS 'Iptal_Orani_Yuzde',
    -- İptal Nedenleri Dağılımı
    SUM(carrier_ct) AS 'Sirket_Kaynakli_Iptal_Sayı',
    SUM(weather_ct) AS 'Hava_Durumu_Iptal_Sayı',
    SUM(nas_ct) AS 'Trafik_Sistemi_Iptal_Sayı',
    SUM(security_ct) AS 'Guvenlik_Iptal_Sayı'
FROM Airline_Delay_Cause
GROUP BY carrier_name
HAVING SUM(arr_flights) > 10000 
ORDER BY 'Iptal_Orani_Yuzde' DESC 
-- ExpressJet Airlines LLC,American Eagle Airlines Inc. Şirketleri bulundukları havalimanın altyapısının yetersizliğinde olduğunu gösterir.