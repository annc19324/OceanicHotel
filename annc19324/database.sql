-- Đặt cơ sở dữ liệu về chế độ single-user để ngắt tất cả kết nối hiện tại
ALTER DATABASE OceanicHotel 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Xóa cơ sở dữ liệu
DROP DATABASE OceanicHotel;

-- (Tùy chọn) Đặt lại về chế độ multi-user nếu cần cho các cơ sở dữ liệu khác
ALTER DATABASE OceanicHotel 
SET MULTI_USER;

CREATE DATABASE OceanicHotel;
USE OceanicHotel;
GO
-- Bảng Users: Quản lý thông tin người dùng, lễ tân và admin
CREATE TABLE Users 
(
    user_id INT IDENTITY(1,1) PRIMARY KEY,              -- ID tự tăng, khóa chính
    username VARCHAR(50) UNIQUE NOT NULL,              -- Tên đăng nhập, duy nhất
    password VARCHAR(255) NOT NULL,                    -- Mật khẩu (đã mã hóa)
    email VARCHAR(100) UNIQUE NOT NULL,                -- Email, duy nhất
    role VARCHAR(15) CHECK (role IN ('admin', 'user', 'receptionist')) DEFAULT 'user', -- Vai trò: admin, user, receptionist
    cccd VARCHAR(12) UNIQUE,                           -- Số CCCD, duy nhất (có thể NULL)
    full_name NVARCHAR(100) NOT NULL,                  -- Họ tên đầy đủ
    phone_number VARCHAR(15) UNIQUE,                   -- Số điện thoại, duy nhất (có thể NULL)
    date_of_birth DATE,                                -- Ngày sinh (có thể NULL)
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')), -- Giới tính: Nam, Nữ, Khác
    avatar VARCHAR(255),                               -- Đường dẫn ảnh đại diện (có thể NULL)
    is_active BIT DEFAULT 1,                           -- Trạng thái tài khoản: 1 (hoạt động), 0 (khóa)
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo tài khoản
    language VARCHAR(10) DEFAULT 'en',                 -- Ngôn ngữ mặc định: 'en' (tiếng Anh)
    theme VARCHAR(10) DEFAULT 'light'                  -- Giao diện mặc định: 'light' (sáng)
);
CREATE INDEX idx_users_role ON Users(role);            -- Index cho cột role để tìm kiếm nhanh
CREATE INDEX idx_users_cccd ON Users(cccd);            -- Index cho cột cccd để tra cứu nhanh

-- Bảng Room_Types: Quản lý các loại phòng
CREATE TABLE Room_Types 
(
    type_id INT IDENTITY(1,1) PRIMARY KEY,             -- ID tự tăng, khóa chính
    type_name NVARCHAR(50) NOT NULL UNIQUE,            -- Tên loại phòng (Single, Double, Suite), duy nhất
    default_price DECIMAL(10, 2) NOT NULL,             -- Giá mặc định (ví dụ: 500.00)
    max_adults INT NOT NULL CHECK (max_adults > 0),    -- Số người lớn tối đa, lớn hơn 0
    max_children INT NOT NULL CHECK (max_children >= 0), -- Số trẻ em tối đa, lớn hơn hoặc bằng 0
    description NVARCHAR(500),                         -- Mô tả loại phòng (có thể NULL)
    created_at DATETIME DEFAULT GETDATE()              -- Thời gian tạo
);

-- Bảng Room_Type_Images: Ảnh của loại phòng
CREATE TABLE Room_Type_Images 
(
    image_id INT IDENTITY(1,1) PRIMARY KEY,            -- ID tự tăng, khóa chính
    type_id INT NOT NULL,                              -- ID loại phòng, khóa ngoại
    image_url NVARCHAR(255) NOT NULL,                  -- Đường dẫn ảnh (ví dụ: "/images/suite.jpg")
    is_primary BIT DEFAULT 0,                          -- Ảnh chính: 1 (chính), 0 (phụ)
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id) ON DELETE CASCADE -- Khóa ngoại, xóa liên quan
);
CREATE INDEX idx_room_type_images_primary ON Room_Type_Images(type_id, is_primary); -- Index để lọc ảnh chính nhanh

-- Bảng Rooms: Quản lý thông tin từng phòng cụ thể
CREATE TABLE Rooms 
(
    room_id INT IDENTITY(1,1) PRIMARY KEY,             -- ID tự tăng, khóa chính
    room_number VARCHAR(10) UNIQUE NOT NULL,           -- Số phòng (ví dụ: "101"), duy nhất
    type_id INT NOT NULL,                              -- ID loại phòng, khóa ngoại
    price_per_night DECIMAL(10, 2) NOT NULL,           -- Giá mỗi đêm (có thể khác giá mặc định)
    is_available BIT DEFAULT 1,                        -- Trạng thái: 1 (trống), 0 (đã đặt)
    description NVARCHAR(500),                                  -- Mô tả phòng (có thể NULL)
    max_adults INT NOT NULL,                           -- Số người lớn tối đa
    max_children INT NOT NULL,                         -- Số trẻ em tối đa
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id) -- Khóa ngoại liên kết Room_Types
);
CREATE INDEX idx_rooms_available ON Rooms(is_available); -- Index để lọc phòng trống nhanh

-- Bảng Room_Images: Ảnh chi tiết của từng phòng
CREATE TABLE Room_Images 
(
    image_id INT IDENTITY(1,1) PRIMARY KEY,            -- ID tự tăng, khóa chính
    room_id INT NOT NULL,                              -- ID phòng, khóa ngoại
    image_url NVARCHAR(255) NOT NULL,                  -- Đường dẫn ảnh (ví dụ: "/images/room_101.jpg")
    caption NVARCHAR(100),                             -- Chú thích ảnh (có thể NULL)
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE -- Khóa ngoại, xóa liên quan
);
CREATE INDEX idx_room_images_room_id ON Room_Images(room_id); -- Index để tìm ảnh theo phòng nhanh

-- Bảng Discounts: Quản lý mã giảm giá
CREATE TABLE Discounts 
(
    discount_id INT IDENTITY(1,1) PRIMARY KEY,         -- ID tự tăng, khóa chính
    discount_code VARCHAR(20) UNIQUE NOT NULL,         -- Mã giảm giá (ví dụ: "NEW10"), duy nhất
    discount_percentage DECIMAL(5, 2) NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100), -- Phần trăm giảm (0-100)
    description NVARCHAR(255),                         -- Mô tả mã giảm giá (có thể NULL)
    start_date DATETIME NOT NULL,                      -- Ngày bắt đầu hiệu lực
    end_date DATETIME NOT NULL,                        -- Ngày kết thúc hiệu lực
    max_usage INT,                                     -- Số lần sử dụng tối đa (có thể NULL)
    usage_count INT DEFAULT 0,                         -- Số lần đã sử dụng
    condition_type VARCHAR(20) CHECK (condition_type IN ('NewUser', 'LoyalUser', 'SpecialEvent', 'EarlyBird', 'Random')), -- Loại điều kiện
    condition_value VARCHAR(50),                       -- Giá trị điều kiện (có thể NULL)
    is_active BIT DEFAULT 1,                           -- Trạng thái: 1 (hoạt động), 0 (hết hiệu lực)
    created_at DATETIME DEFAULT GETDATE()              -- Thời gian tạo
);

-- Bảng Bookings: Quản lý đặt phòng
CREATE TABLE Bookings
(
    booking_id INT IDENTITY(1,1) PRIMARY KEY,          -- ID tự tăng, khóa chính
    user_id INT NOT NULL,                              -- ID người đặt, khóa ngoại
    room_id INT NOT NULL,                              -- ID phòng, khóa ngoại
    check_in_date DATE NOT NULL,                       -- Ngày nhận phòng
    check_out_date DATE NOT NULL,                      -- Ngày trả phòng
    total_price DECIMAL(10, 2) NOT NULL,               -- Tổng giá trước giảm
    discount_id INT,                                   -- ID mã giảm giá, khóa ngoại (có thể NULL)
    discounted_price DECIMAL(10, 2),                   -- Giá sau khi giảm (có thể NULL)
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending', -- Trạng thái đặt phòng
    num_adults INT NOT NULL DEFAULT 1 CHECK (num_adults > 0), -- Số người lớn, mặc định 1
    num_children INT NOT NULL DEFAULT 0 CHECK (num_children >= 0), -- Số trẻ em, mặc định 0
    booking_method VARCHAR(10) CHECK (booking_method IN ('Online', 'Onsite')) DEFAULT 'Online', -- Phương thức đặt: Online/Onsite
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    receptionist_id INT,                               -- ID lễ tân (NULL nếu đặt online), khóa ngoại
    FOREIGN KEY (user_id) REFERENCES Users(user_id),   -- Khóa ngoại liên kết Users
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),   -- Khóa ngoại liên kết Rooms
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id), -- Khóa ngoại liên kết Users
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id) -- Khóa ngoại liên kết Discounts
);
CREATE INDEX idx_bookings_status ON Bookings(status);  -- Index để lọc theo trạng thái nhanh
CREATE INDEX idx_bookings_method ON Bookings(booking_method); -- Index để lọc theo phương thức nhanh

-- Bảng Booking_History: Lịch sử thay đổi đặt phòng
CREATE TABLE Booking_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,          -- ID tự tăng, khóa chính
    booking_id INT NOT NULL,                           -- ID đặt phòng, khóa ngoại
    changed_by INT NOT NULL,                           -- ID người thay đổi, khóa ngoại
    old_status VARCHAR(20) CHECK (old_status IN ('Pending', 'Confirmed', 'Cancelled')), -- Trạng thái cũ
    new_status VARCHAR(20) CHECK (new_status IN ('Pending', 'Confirmed', 'Cancelled')), -- Trạng thái mới
    changed_at DATETIME DEFAULT GETDATE(),             -- Thời gian thay đổi
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id), -- Khóa ngoại liên kết Bookings
    FOREIGN KEY (changed_by) REFERENCES Users(user_id) -- Khóa ngoại liên kết Users
);

-- Bảng Login_History: Lịch sử đăng nhập
CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,            -- ID tự tăng, khóa chính
    user_id INT NOT NULL,                              -- ID người dùng, khóa ngoại
    login_time DATETIME DEFAULT GETDATE(),             -- Thời gian đăng nhập
    ip_address VARCHAR(45),                            -- Địa chỉ IP (IPv4/IPv6, có thể NULL)
    FOREIGN KEY (user_id) REFERENCES Users(user_id)    -- Khóa ngoại liên kết Users
);

-- Bảng Transactions: Quản lý giao dịch thanh toán
CREATE TABLE Transactions 
(
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,      -- ID tự tăng, khóa chính
    booking_id INT NOT NULL,                           -- ID đặt phòng, khóa ngoại
    user_id INT NOT NULL,                              -- ID người thanh toán, khóa ngoại
    amount DECIMAL(10, 2) NOT NULL,                    -- Số tiền giao dịch
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending', 'Refunded')) DEFAULT 'Pending', -- Trạng thái giao dịch
    payment_method VARCHAR(20) CHECK (payment_method IN ('Cash', 'Card', 'Online')) DEFAULT 'Online', -- Phương thức thanh toán
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    receptionist_id INT,                               -- ID lễ tân (NULL nếu online), khóa ngoại
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id), -- Khóa ngoại liên kết Bookings
    FOREIGN KEY (user_id) REFERENCES Users(user_id),   -- Khóa ngoại liên kết Users
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id) -- Khóa ngoại liên kết Users
);

-- Bảng Settings: Cài đặt hệ thống
CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,          -- ID tự tăng, khóa chính
    setting_key VARCHAR(50) NOT NULL UNIQUE,           -- Tên cài đặt (ví dụ: "login_background"), duy nhất
    setting_value VARCHAR(255) NOT NULL,               -- Giá trị cài đặt (ví dụ: "/images/noel_bg.jpg")
    updated_at DATETIME DEFAULT GETDATE()              -- Thời gian cập nhật
);

-- Bảng Reviews: Đánh giá của khách hàng
CREATE TABLE Reviews
(
    review_id INT IDENTITY(1,1) PRIMARY KEY,           -- ID tự tăng, khóa chính
    booking_id INT NOT NULL,                           -- ID đặt phòng, khóa ngoại
    user_id INT NOT NULL,                              -- ID người đánh giá, khóa ngoại
    room_id INT NOT NULL,                              -- ID phòng, khóa ngoại
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- Điểm đánh giá (1-5)
    comment TEXT,                                      -- Nhận xét (có thể NULL)
    created_at DATETIME DEFAULT GETDATE(),             -- Thời gian tạo
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id), -- Khóa ngoại liên kết Bookings
    FOREIGN KEY (user_id) REFERENCES Users(user_id),   -- Khóa ngoại liên kết Users
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)    -- Khóa ngoại liên kết Rooms
);


-- Cập nhật dữ liệu cũ trong Booking_History nếu cần
UPDATE Booking_History 
SET old_status = NULL 
WHERE old_status NOT IN ('Pending', 'Confirmed', 'Cancelled') AND old_status IS NOT NULL;

USE OceanicHotel;
GO

CREATE TRIGGER trg_AfterBookingUpdate
ON Bookings
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật trạng thái phòng thành trống khi booking bị hủy hoặc quá ngày check-out
    UPDATE Rooms
    SET is_available = 1
    FROM Rooms r
    INNER JOIN inserted i ON r.room_id = i.room_id
    INNER JOIN deleted d ON i.booking_id = d.booking_id
    WHERE (i.status = 'Cancelled' AND d.status != 'Cancelled') -- Khi trạng thái thay đổi thành Cancelled
       OR (i.check_out_date < CAST(GETDATE() AS DATE) AND i.status = 'Confirmed'); -- Khi quá ngày check-out và trạng thái là Confirmed
END;
GO

-- Sửa cột description từ TEXT sang NVARCHAR(MAX)
ALTER TABLE Rooms
ALTER COLUMN description NVARCHAR(500);

ALTER TABLE Bookings
DROP CONSTRAINT CK__Bookings__status__71D1E811;

ALTER TABLE Bookings
ADD CONSTRAINT CK_Bookings_Status CHECK (status IN ('Pending', 'Confirmed', 'Cancelled', 'Success'));

EXEC sp_help 'Bookings';

USE OceanicHotel;
GO

-- Xóa ràng buộc CHECK cũ
ALTER TABLE Bookings
DROP CONSTRAINT CK__Bookings__status__71D1E811;

-- Thêm ràng buộc CHECK mới với 'Success'
ALTER TABLE Bookings
ADD CONSTRAINT CK_Bookings_Status CHECK (status IN ('Pending', 'Confirmed', 'Cancelled', 'Success'));


USE OceanicHotel;
GO

-- Xóa ràng buộc CHECK trên old_status
ALTER TABLE Booking_History
DROP CONSTRAINT CK__Booking_H__old_s__00200768;

-- Xóa ràng buộc CHECK trên new_status
ALTER TABLE Booking_History
DROP CONSTRAINT CK__Booking_H__new_s__01142BA1;

-- Thêm ràng buộc CHECK mới cho old_status
ALTER TABLE Booking_History
ADD CONSTRAINT CK_Booking_History_Old_Status CHECK (old_status IN ('Pending', 'Confirmed', 'Cancelled', 'Success') OR old_status IS NULL);

-- Thêm ràng buộc CHECK mới cho new_status
ALTER TABLE Booking_History
ADD CONSTRAINT CK_Booking_History_New_Status CHECK (new_status IN ('Pending', 'Confirmed', 'Cancelled', 'Success'));

EXEC sp_help 'Booking_History';