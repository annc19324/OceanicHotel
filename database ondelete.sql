DROP DATABASE IF EXISTS OceanicHotel;
CREATE DATABASE OceanicHotel;
USE OceanicHotel;
GO

-- Bảng Users: Quản lý thông tin người dùng, lễ tân và admin
CREATE TABLE Users 
(
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL, 
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(15) CHECK (role IN ('admin', 'user', 'receptionist')) DEFAULT 'user',
    cccd VARCHAR(12) UNIQUE,
    full_name NVARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    avatar VARCHAR(255),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    language VARCHAR(10) DEFAULT 'en',
    theme VARCHAR(10) DEFAULT 'light'
);
CREATE INDEX idx_users_role ON Users(role);
CREATE INDEX idx_users_cccd ON Users(cccd);

-- Bảng Room_Types: Loại phòng
CREATE TABLE Room_Types 
(
    type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL UNIQUE,
    default_price DECIMAL(10, 2) NOT NULL,
    max_adults INT NOT NULL CHECK (max_adults > 0),
    max_children INT NOT NULL CHECK (max_children >= 0),
    description NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);

-- Bảng Room_Type_Images: Ảnh của loại phòng
CREATE TABLE Room_Type_Images 
(
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    type_id INT NOT NULL,
    image_url NVARCHAR(255) NOT NULL,
    is_primary BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id) ON DELETE CASCADE
);
CREATE INDEX idx_room_type_images_primary ON Room_Type_Images(type_id, is_primary);

-- Bảng Rooms: Thông tin phòng
CREATE TABLE Rooms 
(
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    type_id INT NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    is_available BIT DEFAULT 1,
    description TEXT,
    max_adults INT NOT NULL,
    max_children INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id) ON DELETE CASCADE
);
CREATE INDEX idx_rooms_available ON Rooms(is_available);

-- Bảng Room_Images: Ảnh chi tiết của từng phòng
CREATE TABLE Room_Images 
(
    image_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    image_url NVARCHAR(255) NOT NULL,
    caption NVARCHAR(100),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);
CREATE INDEX idx_room_images_room_id ON Room_Images(room_id);

-- Bảng Discounts: Quản lý mã giảm giá
CREATE TABLE Discounts 
(
    discount_id INT IDENTITY(1,1) PRIMARY KEY,
    discount_code VARCHAR(20) UNIQUE NOT NULL,
    discount_percentage DECIMAL(5, 2) NOT NULL CHECK (discount_percentage BETWEEN 0 AND 100),
    description NVARCHAR(255),
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    max_usage INT,
    usage_count INT DEFAULT 0,
    condition_type VARCHAR(20) CHECK (condition_type IN ('NewUser', 'LoyalUser', 'SpecialEvent', 'EarlyBird', 'Random')),
    condition_value VARCHAR(50),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE()
);

-- Bảng Bookings: Đặt phòng
CREATE TABLE Bookings
(
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    discount_id INT,
    discounted_price DECIMAL(10, 2),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending',
    num_adults INT NOT NULL DEFAULT 1 CHECK (num_adults > 0),
    num_children INT NOT NULL DEFAULT 0 CHECK (num_children >= 0),
    booking_method VARCHAR(10) CHECK (booking_method IN ('Online', 'Onsite')) DEFAULT 'Online',
    created_at DATETIME DEFAULT GETDATE(),
    receptionist_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE,
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id) ON DELETE SET NULL
);
CREATE INDEX idx_bookings_status ON Bookings(status);
CREATE INDEX idx_bookings_method ON Bookings(booking_method);

-- Bảng Booking_History: Lịch sử thay đổi đặt phòng
CREATE TABLE Booking_History 
(
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    changed_by INT NOT NULL,
    old_status VARCHAR(20) CHECK (old_status IN ('Pending', 'Confirmed', 'Cancelled')),
    new_status VARCHAR(20) CHECK (new_status IN ('Pending', 'Confirmed', 'Cancelled')),
    changed_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Login_History: Lịch sử đăng nhập
CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    login_time DATETIME DEFAULT GETDATE(),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Bảng Transactions: Giao dịch
CREATE TABLE Transactions 
(
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')) DEFAULT 'Pending',
    payment_method VARCHAR(20) CHECK (payment_method IN ('Cash', 'Card', 'Online')) DEFAULT 'Online',
    created_at DATETIME DEFAULT GETDATE(),
    receptionist_id INT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Bảng Settings: Cài đặt hệ thống (bao gồm ảnh nền)
CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value VARCHAR(255) NOT NULL,
    updated_at DATETIME DEFAULT GETDATE()
);

-- Bảng Reviews: Đánh giá
CREATE TABLE Reviews
(
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    room_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id) ON DELETE CASCADE
);

-- Cập nhật dữ liệu không hợp lệ trong Booking_History
UPDATE Booking_History 
SET old_status = NULL 
WHERE old_status NOT IN ('Pending', 'Confirmed', 'Cancelled') AND old_status IS NOT NULL;