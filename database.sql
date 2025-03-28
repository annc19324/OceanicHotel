USE master;
GO
--tìm tất cả các kết nối đang sử dụng cơ sở dữ liệu
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

--ngắt tất cả kết nối hiện tại và chuyển cơ sở dữ liệu sang chế độ người dùng đơn.
ALTER DATABASE OceanHotel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

--Nếu cơ sở dữ liệu vẫn đang bị sử dụng, bạn có thể kiểm tra các kết nối còn lại bằng cách chạy truy vấn sau:
SELECT * FROM sys.sysprocesses WHERE dbid = DB_ID('OceanHotel');

--xoa
drop database OceanHotel


CREATE DATABASE OceanHotel;

USE OceanHotel;

-- Bảng Users
CREATE TABLE Users 
(
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- Lưu password đã được hash
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(10) CHECK (role IN ('admin', 'user')) DEFAULT 'user',
    avatar VARCHAR(255), -- Đường dẫn đến ảnh đại diện (có thể NULL)
    is_active BIT DEFAULT 1, -- Tài khoản có hoạt động hay không
    created_at DATETIME DEFAULT GETDATE()
);

-- Bảng Rooms
CREATE TABLE Rooms 
(
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL, -- Ví dụ: 101, 102, 201, 202,...
    room_type VARCHAR(20) CHECK (room_type IN ('Single', 'Double', 'Suite', 'Deluxe')) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL, -- Giá phòng theo đêm
    is_available BIT DEFAULT 1, -- Phòng còn trống hay không
    description TEXT, -- Mô tả thêm về phòng (có thể NULL)
    created_at DATETIME DEFAULT GETDATE()
);

-- Bảng Bookings
CREATE TABLE Bookings
(
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Người đặt phòng
    room_id INT NOT NULL, -- Phòng được đặt
    check_in_date DATE NOT NULL, -- Ngày nhận phòng
    check_out_date DATE NOT NULL, -- Ngày trả phòng
    total_price DECIMAL(10, 2) NOT NULL, -- Tổng giá (tính từ số ngày và giá phòng)
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending', -- Trạng thái đặt phòng
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Bookings_Users FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Bookings_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- Bảng Booking_History
CREATE TABLE Booking_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL, -- Tham chiếu đến đặt phòng
    changed_by INT NOT NULL, -- Người thực hiện thay đổi (admin hoặc user)
    old_status VARCHAR(20) CHECK (old_status IN ('Pending', 'Confirmed', 'Cancelled')), -- Trạng thái cũ
    new_status VARCHAR(20) CHECK (new_status IN ('Pending', 'Confirmed', 'Cancelled')), -- Trạng thái mới
    changed_at DATETIME DEFAULT GETDATE(), -- Thời gian thay đổi
    CONSTRAINT FK_BookingHistory_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CONSTRAINT FK_BookingHistory_Users FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);

-- Bảng Room_Edit_History
CREATE TABLE Room_Edit_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL, -- Tham chiếu đến phòng
    changed_by INT NOT NULL, -- Người thực hiện thay đổi (admin)
    change_description TEXT NOT NULL, -- Mô tả thay đổi (ví dụ: "Giá phòng thay đổi từ 500,000 VND lên 600,000 VND")
    changed_at DATETIME DEFAULT GETDATE(), -- Thời gian thay đổi
    CONSTRAINT FK_RoomEditHistory_Rooms FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CONSTRAINT FK_RoomEditHistory_Users FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);

-- Bảng Login_History
CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Tham chiếu đến người dùng
    login_time DATETIME DEFAULT GETDATE(), -- Thời gian đăng nhập
    ip_address VARCHAR(45), -- Địa chỉ IP
    CONSTRAINT FK_LoginHistory_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Bảng Transactions
CREATE TABLE Transactions 
(
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL, -- Tham chiếu đến đặt phòng
    user_id INT NOT NULL, -- Người thực hiện giao dịch
    amount DECIMAL(10, 2) NOT NULL, -- Số tiền giao dịch
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')) DEFAULT 'Pending', -- Trạng thái giao dịch
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Transactions_Bookings FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Bảng Settings
CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE, -- Ví dụ: 'default_language', 'default_theme'
    setting_value VARCHAR(255) NOT NULL, -- Ví dụ: 'en', 'light'
    updated_at DATETIME DEFAULT GETDATE()
);
GO



INSERT INTO Users (username, password, email, role, avatar, is_active, created_at)
VALUES 
('nguyen_van_a', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'nguyen.van.a@example.com', 'user', 'avatar1.jpg', 1, GETDATE()),
('le_thi_b', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'le.thi.b@example.com', 'user', 'avatar2.jpg', 1, GETDATE()),
('pham_minh_c', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'pham.minh.c@example.com', 'admin', 'avatar3.jpg', 1, GETDATE()),
('tran_quang_d', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'tran.quang.d@example.com', 'user', 'avatar4.jpg', 1, GETDATE()),
('hoang_thu_e', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'hoang.thu.e@example.com', 'user', 'avatar5.jpg', 1, GETDATE()),
('nguyen_hieu_f', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'nguyen.hieu.f@example.com', 'admin', 'avatar6.jpg', 1, GETDATE()),
('le_thuy_g', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'le.thuy.g@example.com', 'user', 'avatar7.jpg', 1, GETDATE()),
('pham_hoa_h', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'pham.hoa.h@example.com', 'user', 'avatar8.jpg', 1, GETDATE()),
('tran_mai_i', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'tran.mai.i@example.com', 'admin', 'avatar9.jpg', 1, GETDATE()),
('hoang_tuan_j', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'hoang.tuan.j@example.com', 'user', 'avatar10.jpg', 1, GETDATE()),
('nguyen_bao_k', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'nguyen.bao.k@example.com', 'user', 'avatar11.jpg', 1, GETDATE()),
('le_thu_l', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'le.thu.l@example.com', 'admin', 'avatar12.jpg', 1, GETDATE()),
('pham_quoc_m', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'pham.quoc.m@example.com', 'user', 'avatar13.jpg', 1, GETDATE()),
('tran_hoai_n', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'tran.hoai.n@example.com', 'user', 'avatar14.jpg', 1, GETDATE()),
('hoang_nhat_o', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'hoang.nhat.o@example.com', 'admin', 'avatar15.jpg', 1, GETDATE()),
('nguyen_hai_p', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'nguyen.hai.p@example.com', 'user', 'avatar16.jpg', 1, GETDATE()),
('le_quang_q', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'le.quang.q@example.com', 'user', 'avatar17.jpg', 1, GETDATE()),
('pham_quyen_r', '$2a$10$SE9.eLOCvujSs9pXv3pmZ.cFhBqdYMkhip/2x548gXx793ZN6C4pa', 'pham.quyen.r@example.com', 'admin', 'avatar18.jpg', 1, GETDATE())


INSERT INTO Rooms (room_number, room_type, price_per_night, is_available, description, created_at) VALUES
('101', 'Single', 50.00, 1, 'Phòng đơn nhỏ gọn, thích hợp cho 1 người', '2025-03-27 08:00:00'),
('102', 'Single', 55.00, 0, 'Phòng đơn với cửa sổ hướng biển', '2025-03-27 08:05:00'),
('103', 'Double', 80.00, 1, 'Phòng đôi cơ bản với 2 giường đơn', '2025-03-27 08:10:00'),
('104', 'Double', 85.00, 1, 'Phòng đôi rộng rãi, có ban công', '2025-03-27 08:15:00'),
('105', 'Suite', 150.00, 0, 'Suite cao cấp với phòng khách riêng', '2025-03-27 08:20:00'),
('201', 'Single', 60.00, 1, 'Phòng đơn tầng 2, gần thang máy', '2025-03-27 08:25:00'),
('202', 'Double', 90.00, 0, 'Phòng đôi với view thành phố', '2025-03-27 08:30:00'),
('203', 'Deluxe', 120.00, 1, 'Phòng Deluxe với bồn tắm', '2025-03-27 08:35:00'),
('204', 'Suite', 160.00, 1, 'Suite sang trọng, có bàn làm việc', '2025-03-27 08:40:00'),
('205', 'Double', 95.00, 0, 'Phòng đôi tầng cao, yên tĩnh', '2025-03-27 08:45:00'),
('301', 'Single', 65.00, 1, 'Phòng đơn với giường cỡ lớn', '2025-03-27 08:50:00'),
('302', 'Double', 100.00, 1, 'Phòng đôi với nội thất hiện đại', '2025-03-27 08:55:00'),
('303', 'Deluxe', 130.00, 0, 'Phòng Deluxe có ban công rộng', '2025-03-27 09:00:00'),
('304', 'Suite', 170.00, 1, 'Suite cao cấp với view biển', '2025-03-27 09:05:00'),
('305', 'Single', 70.00, 0, 'Phòng đơn tầng 3, gần khu vực ăn uống', '2025-03-27 09:10:00'),
('401', 'Double', 105.00, 1, 'Phòng đôi với cửa sổ lớn', '2025-03-27 09:15:00'),
('402', 'Deluxe', 140.00, 1, 'Phòng Deluxe với tiện nghi đầy đủ', '2025-03-27 09:20:00'),
('403', 'Suite', 180.00, 0, 'Suite sang trọng, có phòng tắm đôi', '2025-03-27 09:25:00'),
('404', 'Single', 75.00, 1, 'Phòng đơn tầng 4, thoáng mát', '2025-03-27 09:30:00'),
('405', 'Double', 110.00, 1, 'Phòng đôi với giường king-size', '2025-03-27 09:35:00');