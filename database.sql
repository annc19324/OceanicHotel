

USE master;
GO
--t�m t?t c? c�c k?t n?i ?ang s? d?ng c? s? d? li?u
SELECT
    spid, 
    dbid, 
    login_time,
    last_batch,
    loginame,
    hostname,
    program_name
FROM sys.sysprocesses
WHERE dbid = DB_ID('OceanHotel');

--ng?t t?t c? k?t n?i hi?n t?i v� chuy?n c? s? d? li?u sang ch? ?? ng??i d�ng ??n.
ALTER DATABASE OceanHotel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

--N?u c? s? d? li?u v?n ?ang b? s? d?ng, b?n c� th? ki?m tra c�c k?t n?i c�n l?i b?ng c�ch ch?y truy v?n sau:
SELECT * FROM sys.sysprocesses WHERE dbid = DB_ID('OceanHotel');

--xoa
drop database OceanHotel