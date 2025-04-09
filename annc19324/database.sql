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
    created_at DATETIME DEFAULT GETDATE()
);
CREATE INDEX idx_users_role ON Users(role);
CREATE INDEX idx_users_cccd ON Users(cccd);
-- **Chức năng**: Lưu trữ thông tin của tất cả người dùng trong hệ thống, bao gồm khách hàng (user), lễ tân (receptionist), và quản trị viên (admin). 
-- - `role`: Phân quyền (admin quản lý hệ thống, receptionist xử lý đặt phòng tại chỗ, user đặt phòng online).
-- - `cccd`, `full_name`, `phone_number`: Thông tin cá nhân để nhận diện khách hàng, đặc biệt khi đặt phòng tại chỗ.
-- - `is_active`: Kiểm soát trạng thái tài khoản (1: hoạt động, 0: bị khóa).

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
-- **Chức năng**: Quản lý các loại phòng (Single, Double, Suite, v.v.) trong khách sạn.
-- - `type_name`: Tên loại phòng, hiển thị trên trang chủ để người dùng chọn.
-- - `default_price`: Giá mặc định, dùng làm tham chiếu khi tạo phòng mới.
-- - `max_adults`, `max_children`: Giới hạn số người tối đa cho mỗi loại phòng.
-- - `description`: Mô tả chi tiết về loại phòng (ví dụ: "Phòng đôi có ban công").

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
-- **Chức năng**: Lưu trữ nhiều ảnh cho mỗi loại phòng để hiển thị trên website.
-- - `type_id`: Liên kết với loại phòng trong `Room_Types`.
-- - `image_url`: Đường dẫn đến ảnh (ví dụ: "/assets/images/suite_main.jpg").
-- - `is_primary`: Xác định ảnh chính (1: ảnh chính hiển thị trên trang chủ, 0: ảnh phụ).

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
    FOREIGN KEY (type_id) REFERENCES Room_Types(type_id)
);
CREATE INDEX idx_rooms_available ON Rooms(is_available);
-- **Chức năng**: Quản lý thông tin chi tiết của từng phòng cụ thể trong khách sạn.
-- - `room_number`: Số phòng (ví dụ: "101", "202").
-- - `type_id`: Liên kết với loại phòng trong `Room_Types`.
-- - `price_per_night`: Giá cụ thể của phòng (có thể khác `default_price` trong `Room_Types`).
-- - `is_available`: Trạng thái phòng (1: trống, 0: đã đặt), dùng để lọc phòng trống khi người dùng đặt.

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
-- **Chức năng**: Lưu trữ nhiều ảnh chi tiết cho từng phòng cụ thể.
-- - `room_id`: Liên kết với phòng trong `Rooms`.
-- - `image_url`: Đường dẫn đến ảnh (ví dụ: "/assets/images/room_101_kitchen.jpg").
-- - `caption`: Chú thích ảnh (ví dụ: "Nhà bếp", "Ban công"), giúp người dùng hiểu rõ hơn về phòng.

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
-- **Chức năng**: Quản lý các chương trình giảm giá để áp dụng cho đặt phòng.
-- - `discount_code`: Mã giảm giá (ví dụ: "NEW10", "SPECIAL5").
-- - `discount_percentage`: Phần trăm giảm (ví dụ: 10.00 cho 10%).
-- - `start_date`, `end_date`: Thời gian hiệu lực của mã.
-- - `max_usage`, `usage_count`: Giới hạn và đếm số lần sử dụng.
-- - `condition_type`, `condition_value`: Điều kiện áp dụng (ví dụ: "NewUser" cho khách mới, "EarlyBird" với 10 người sớm nhất).

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
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id),
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);
CREATE INDEX idx_bookings_status ON Bookings(status);
CREATE INDEX idx_bookings_method ON Bookings(booking_method);
-- **Chức năng**: Quản lý thông tin đặt phòng của khách hàng.
-- - `user_id`: Người đặt phòng (khách hàng).
-- - `room_id`: Phòng được đặt.
-- - `check_in_date`, `check_out_date`: Thời gian nhận và trả phòng.
-- - `total_price`, `discounted_price`: Giá trước và sau khi áp dụng giảm giá.
-- - `discount_id`: Liên kết với mã giảm giá trong `Discounts`.
-- - `booking_method`: Phân biệt đặt online hay tại chỗ (Onsite do lễ tân xử lý).
-- - `receptionist_id`: Lễ tân xử lý (NULL nếu đặt online).

-- Bảng Booking_History: Lịch sử thay đổi đặt phòng
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
-- **Chức năng**: Ghi lại lịch sử thay đổi trạng thái của đặt phòng.
-- - `booking_id`: Liên kết với đặt phòng trong `Bookings`.
-- - `changed_by`: Người thực hiện thay đổi (user, receptionist, hoặc admin).
-- - `old_status`, `new_status`: Trạng thái trước và sau khi thay đổi (ví dụ: từ "Pending" sang "Confirmed").

-- Bảng Login_History: Lịch sử đăng nhập
CREATE TABLE Login_History 
(
    login_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    login_time DATETIME DEFAULT GETDATE(),
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);




-- **Chức năng**: Theo dõi lịch sử đăng nhập của người dùng để đảm bảo an toàn và kiểm tra hoạt động.
-- - `user_id`: Người đăng nhập.
-- - `login_time`: Thời gian đăng nhập.
-- - `ip_address`: Địa chỉ IP của thiết bị, hỗ trợ kiểm tra bảo mật.

-- Bảng Transactions: Giao dịch
CREATE TABLE Transactions 
(
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending', 'Refunded')) DEFAULT 'Pending',
    payment_method VARCHAR(20) CHECK (payment_method IN ('Cash', 'Card', 'Online')) DEFAULT 'Online',
    created_at DATETIME DEFAULT GETDATE(),
    receptionist_id INT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (receptionist_id) REFERENCES Users(user_id)
);
-- **Chức năng**: Quản lý các giao dịch thanh toán liên quan đến đặt phòng.
-- - `booking_id`: Liên kết với đặt phòng trong `Bookings`.
-- - `user_id`: Người thực hiện giao dịch (khách hàng).
-- - `amount`: Số tiền thanh toán (dựa trên `discounted_price` nếu có giảm giá).
-- - `payment_method`: Phương thức thanh toán (Cash tại quầy, Card, hoặc Online).
-- - `receptionist_id`: Lễ tân xử lý (NULL nếu thanh toán online).

-- Bảng Settings: Cài đặt hệ thống (bao gồm ảnh nền)
CREATE TABLE Settings 
(
    setting_id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value VARCHAR(255) NOT NULL,
    updated_at DATETIME DEFAULT GETDATE()
);
-- **Chức năng**: Lưu trữ các cấu hình hệ thống, bao gồm đường dẫn ảnh nền cho các trang.
-- - `setting_key`: Tên cài đặt (ví dụ: "login_background", "dashboard_background", "tax_rate").
-- - `setting_value`: Giá trị cài đặt (ví dụ: "/assets/images/noel_login_bg.jpg" cho ảnh nền đăng nhập dịp Noel).
-- - `updated_at`: Thời gian cập nhật, giúp theo dõi lần thay đổi cuối cùng.
-- - **Ví dụ sử dụng**: Admin thay đổi `setting_value` từ ảnh Noel sang ảnh thường khi hết sự kiện.

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
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);
-- **Chức năng**: Lưu trữ đánh giá của khách hàng về phòng sau khi sử dụng.
-- - `booking_id`: Liên kết với đặt phòng đã hoàn thành.
-- - `user_id`: Người viết đánh giá.
-- - `room_id`: Phòng được đánh giá.
-- - `rating`: Điểm từ 1 đến 5.
-- - `comment`: Nhận xét chi tiết, giúp cải thiện dịch vụ.



UPDATE Booking_History 
SET old_status = NULL 
WHERE old_status NOT IN ('Pending', 'Confirmed', 'Cancelled') AND old_status IS NOT NULL;

ALTER TABLE Users
ADD language VARCHAR(10) DEFAULT 'en',
    theme VARCHAR(10) DEFAULT 'light';


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