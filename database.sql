USE master;
GO

-- Tìm tất cả các kết nối đang sử dụng cơ sở dữ liệu
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

-- Ngắt tất cả kết nối hiện tại và chuyển cơ sở dữ liệu sang chế độ người dùng đơn.
ALTER DATABASE OceanHotel SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

-- Nếu cơ sở dữ liệu vẫn đang bị sử dụng, bạn có thể kiểm tra các kết nối còn lại bằng cách chạy truy vấn sau:
SELECT * FROM sys.sysprocesses WHERE dbid = DB_ID('OceanHotel');

-- Xóa cơ sở dữ liệu
DROP DATABASE IF EXISTS OceanHotel;

-- Tạo lại cơ sở dữ liệu
CREATE DATABASE OceanHotel;

USE OceanHotel;
GO


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
    booking_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment primary key
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL, -- Ngày nhận phòng
    check_out_date DATE NOT NULL, -- Ngày trả phòng
    total_price DECIMAL(10, 2) NOT NULL, -- Tổng giá (tính từ số ngày và giá phòng)
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending',  -- ENUM replaced by VARCHAR with a CHECK constraint
    num_adults INT NOT NULL DEFAULT 1,  -- Số người lớn, mặc định 1
    num_children INT NOT NULL DEFAULT 0,  -- Số trẻ em, mặc định 0
    created_at DATETIME DEFAULT GETDATE(), -- Thời gian tạo
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
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
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);

-- Bảng Room_Edit_History
CREATE TABLE Room_Edit_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL, -- Tham chiếu đến phòng
    changed_by INT NOT NULL, -- Người thực hiện thay đổi (admin)
    change_description TEXT NOT NULL, -- Mô tả thay đổi (ví dụ: "Giá phòng thay đổi từ 500,000 VND lên 600,000 VND")
    changed_at DATETIME DEFAULT GETDATE(), -- Thời gian thay đổi
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);

-- Bảng Login_History
CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL, -- Tham chiếu đến người dùng
    login_time DATETIME DEFAULT GETDATE(), -- Thời gian đăng nhập
    ip_address VARCHAR(45), -- Địa chỉ IP
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
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
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Bảng Settings
CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE, -- Ví dụ: 'default_language', 'default_theme'
    setting_value VARCHAR(255) NOT NULL, -- Ví dụ: 'en', 'light'
    updated_at DATETIME DEFAULT GETDATE()
);

-- Bảng Reviews
CREATE TABLE Reviews
(
    review_id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-increment primary key
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Điểm đánh giá từ 1-5
    comment TEXT, -- Nhận xét của khách
    created_at DATETIME DEFAULT GETDATE(), -- Thời gian tạo được thay bằng DATETIME
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);
GO

-- Thêm cột vào bảng Rooms
ALTER TABLE Rooms
ADD image_url VARCHAR(255), -- Đường dẫn đến hình ảnh phòng
    max_adults INT NOT NULL DEFAULT 2, -- Số người lớn tối đa, mặc định 2
    max_children INT NOT NULL DEFAULT 0; -- Số trẻ em tối đa, mặc định 0

-- Thêm cột vào bảng Bookings
ALTER TABLE Bookings
ADD num_adults INT NOT NULL DEFAULT 1, -- Số người lớn, mặc định 1
    num_children INT NOT NULL DEFAULT 0; -- Số trẻ em, mặc định 0
GO
