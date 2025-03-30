USE master;
GO

-- Xóa cơ sở dữ liệu nếu có và tạo lại
DROP DATABASE IF EXISTS OceanHotel;
CREATE DATABASE OceanHotel;
USE OceanHotel;
GO
--finally
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


CREATE TABLE Rooms 
(
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL, -- Ví dụ: 101, 102, 201, 202,...
    price_per_night DECIMAL(10, 2) NOT NULL, -- Giá phòng theo đêm
    is_available BIT DEFAULT 1, -- Phòng còn trống hay không
    description TEXT, -- Mô tả thêm về phòng (có thể NULL)
    created_at DATETIME DEFAULT GETDATE(),
    image_url VARCHAR(255), -- Đường dẫn đến hình ảnh phòng
    max_adults INT NOT NULL DEFAULT 2, -- Số người lớn tối đa, mặc định 2
    max_children INT NOT NULL DEFAULT 0, -- Số trẻ em tối đa, mặc định 0
    type_id INT NULL, -- Tham chiếu đến Room_Types
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id)
);


CREATE TABLE Bookings
(
    booking_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment primary key
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL, -- Ngày nhận phòng
    check_out_date DATE NOT NULL, -- Ngày trả phòng
    total_price DECIMAL(10, 2) NOT NULL, -- Tổng giá
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending',
    num_adults INT NOT NULL DEFAULT 1,  -- Số người lớn, mặc định 1
    num_children INT NOT NULL DEFAULT 0,  -- Số trẻ em, mặc định 0
    created_at DATETIME DEFAULT GETDATE(), -- Thời gian tạo
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);


CREATE TABLE Room_Types 
(
    type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE, 
    default_price DECIMAL(10, 2) NOT NULL, 
    max_adults INT NOT NULL, 
    max_children INT NOT NULL, 
    description NVARCHAR(500), 
    created_at DATETIME DEFAULT GETDATE()
);


CREATE TABLE Room_Type_Images 
(
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    type_id INT NOT NULL,
    image_url NVARCHAR(255) NOT NULL,
    is_primary BIT NOT NULL DEFAULT 0, 
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id) ON DELETE CASCADE
);


CREATE TABLE Booking_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    changed_by INT NOT NULL,
    old_status VARCHAR(20) CHECK (old_status IN ('Pending', 'Confirmed', 'Cancelled')),
    new_status VARCHAR(20) CHECK (new_status IN ('Pending', 'Confirmed', 'Cancelled')),
    changed_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);


CREATE TABLE Room_Edit_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL, 
    changed_by INT NOT NULL, 
    change_description TEXT NOT NULL, 
    changed_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);


CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    login_time DATETIME DEFAULT GETDATE(),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE Transactions 
(
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')) DEFAULT 'Pending',
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);


CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value VARCHAR(255) NOT NULL,
    updated_at DATETIME DEFAULT GETDATE()
);


CREATE TABLE Reviews
(
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);


ALTER TABLE Rooms
DROP COLUMN room_type; 

ALTER TABLE Rooms
ADD type_id INT NULL;  -- Cột tham chiếu tới Room_Types

ALTER TABLE Rooms
ADD CONSTRAINT FK_Rooms_RoomTypes FOREIGN KEY (type_id) REFERENCES Room_Types(type_id);


-- Thêm dữ liệu mẫu cho Room_Types
INSERT INTO Room_Types (type_name, default_price, max_adults, max_children, description)
VALUES 
('Single', 150000, 1, 0, 'Phòng đơn nhỏ gọn, phù hợp cho 1 người.'),
('Double', 225000, 2, 1, 'Phòng đôi thoải mái cho 2 người lớn và 1 trẻ em.'),
('Deluxe', 450000, 3, 2, 'Phòng cao cấp với không gian rộng rãi.'),
('Suite', 750000, 4, 2, 'Phòng sang trọng với tiện nghi cao cấp.');

-- Thêm hình ảnh mẫu cho Room_Types
INSERT INTO Room_Type_Images (type_id, image_url, is_primary)
SELECT type_id, 'single.png', 1 FROM Room_Types WHERE type_name = 'Single';
INSERT INTO Room_Type_Images (type_id, image_url, is_primary)
SELECT type_id, 'single1.png', 0 FROM Room_Types WHERE type_name = 'Single';
INSERT INTO Room_Type_Images (type_id, image_url, is_primary)
SELECT type_id, 'double.png', 1 FROM Room_Types WHERE type_name = 'Double';
INSERT INTO Room_Type_Images (type_id, image_url, is_primary)
SELECT type_id, 'deluxe.png', 1 FROM Room_Types WHERE type_name = 'Deluxe';
INSERT INTO Room_Type_Images (type_id, image_url, is_primary)
SELECT type_id, 'suite.png', 1 FROM Room_Types WHERE type_name = 'Suite';





SELECT type_id, COUNT(*) as primary_count
FROM Room_Type_Images
WHERE is_primary = 1
GROUP BY type_id
HAVING COUNT(*) > 1;

SELECT * FROM Room_Type_Images WHERE type_id = 1; -- Thay type_id bằng giá trị thực tế


