

USE master;
GO
--tìm t?t c? các k?t n?i ?ang s? d?ng c? s? d? li?u
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

--ng?t t?t c? k?t n?i hi?n t?i và chuy?n c? s? d? li?u sang ch? ?? ng??i dùng ??n.
ALTER DATABASE OceanHotel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

--N?u c? s? d? li?u v?n ?ang b? s? d?ng, b?n có th? ki?m tra các k?t n?i còn l?i b?ng cách ch?y truy v?n sau:
SELECT * FROM sys.sysprocesses WHERE dbid = DB_ID('OceanHotel');

--xoa
drop database OceanHotel