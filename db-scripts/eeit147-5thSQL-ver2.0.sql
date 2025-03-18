USE master;

/* 刪除shopping_website資料庫指令
USE master ;  
GO  
DROP DATABASE shopping_website

USE master;
ALTER DATABASE shopping_website SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE shopping_website;
*/

CREATE DATABASE shopping_website;

USE shopping_website;

CREATE TABLE users(
    user_id INT PRIMARY KEY IDENTITY(1, 1),
    username NVARCHAR(50) UNIQUE NOT NULL,
    [password] VARCHAR(255) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    full_name NVARCHAR(50),
    phone VARCHAR(20),
    user_photo NVARCHAR(255),
    [address] NVARCHAR(255)
);

CREATE TABLE product_category(
    category_id INT PRIMARY KEY IDENTITY(1, 1),
    category_name VARCHAR(255)
);

CREATE TABLE products(
    product_id INT PRIMARY KEY IDENTITY(1, 1),
    sku VARCHAR(255),
    product_name VARCHAR(255),
    [description] VARCHAR(255),
    unit_price DECIMAL(38, 2),
    image_url VARCHAR(255),
    active BIT DEFAULT 1,
    unit_in_stock INT,
    date_create DATETIME DEFAULT GETDATE(),
    last_update DATETIME DEFAULT GETDATE(),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES product_category(category_id)
);


CREATE TABLE shopping_cart(
    cart_id INT PRIMARY KEY IDENTITY(1, 1),
    user_id INT NOT NULL UNIQUE,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE cart_items(
    cart_item_id INT PRIMARY KEY IDENTITY(1, 1),
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(12, 2),
    FOREIGN KEY (cart_id) REFERENCES shopping_cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY IDENTITY(1, 1),
    user_id INT NOT NULL,
    order_date DATETIME DEFAULT GETDATE(),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    payment_method NVARCHAR(50),
    payment_status VARCHAR(50) CHECK(payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    shipping_address NVARCHAR(255),
    shipping_status VARCHAR(50) CHECK (shipping_status IN ('Processing', 'Shipped', 'Delivered', 'Cancelled')),
    ec_pay_trade_no VARCHAR(30) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY IDENTITY(1, 1),
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments(
    payment_id INT PRIMARY KEY IDENTITY(1, 1),
    order_id INT NOT NULL UNIQUE,
    user_id INT NOT NULL,
    payment_date DATETIME DEFAULT GETDATE(),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_method NVARCHAR(50),
    payment_status VARCHAR(50) CHECK (payment_status IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    ec_pay_trade_no VARCHAR(30) NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE shipment(
    shipment_id INT PRIMARY KEY IDENTITY(1, 1),
    order_id INT NOT NULL UNIQUE,
    tracking_number VARCHAR(50) UNIQUE,
    carrier NVARCHAR(50),
    estimated_delivery DATETIME,
    delivery_status VARCHAR(50) CHECK (delivery_status IN ('Pending', 'InTransit', 'Delivered')),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
); 


-- 客服對話紀錄表
CREATE TABLE chat_sessions (
    chat_id INT IDENTITY(1,1) PRIMARY KEY,
    chat_user_id INT NOT NULL FOREIGN KEY REFERENCES users(user_id),
    support_id INT NULL FOREIGN KEY REFERENCES users(user_id),
    Status NVARCHAR(20) CHECK (Status IN ('Open', 'Closed')) DEFAULT 'Open',
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    closed_at DATETIME NULL
);
GO

-- 訊息表
CREATE TABLE messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    chat_id INT NOT NULL FOREIGN KEY REFERENCES chat_sessions(chat_id),
    sender_id INT NOT NULL FOREIGN KEY REFERENCES users(user_id),
    message_text NVARCHAR(MAX) NOT NULL,
    is_ai_response BIT DEFAULT 0, -- 0: 人類, 1: AI 回覆
    sent_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 常見問題表
CREATE TABLE faqs (
    faq_id INT IDENTITY(1,1) PRIMARY KEY,
    question NVARCHAR(500) NOT NULL,
    answer NVARCHAR(1000) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- 客戶回饋表
CREATE TABLE feedback (
    feedback_id INT IDENTITY(1,1) PRIMARY KEY,
    feedback_user_id INT NOT NULL FOREIGN KEY REFERENCES users(user_id) ON DELETE CASCADE,
    rating INT CHECK (Rating BETWEEN 1 AND 5) NOT NULL,
    comment NVARCHAR(1000),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE [dbo].[user_vip](
	[end_date] [date] NULL,
	[is_vip] [bit] NOT NULL,
	[member_id] [int] NULL,
	[start_date] [date] NOT NULL,
	[vip_id] [int] IDENTITY(1,1) NOT NULL,
	[vip_level] [int] NULL,
	[vip_photo] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[vip_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[user_vip_history](
	[end_date] [date] NOT NULL,
	[history_id] [int] IDENTITY(1,1) NOT NULL,
	[member_id] [int] NULL,
	[start_date] [date] NOT NULL,
	[vip_level] [int] NULL,
	[vip_photo] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[history_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[shops] (
    [shop_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [shops_user_id] INT NOT NULL FOREIGN KEY ([user_id]) REFERENCES [dbo].[users]([user_id]),
    [store_name] NVARCHAR(1000) NOT NULL,
    [store_description] NVARCHAR(1000),
    [created_at] DATETIME NOT NULL DEFAULT GETDATE(),
    [seller_photo] VARBINARY(MAX),
    [seller_status] TINYINT NOT NULL,
    [shop_status] BIT NOT NULL
);


CREATE TABLE [dbo].[reviews] (
    [review_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- 主鍵，自動遞增
    [reviews_product_id] INT NOT NULL,  -- 外鍵，參考 products 表格的 product_id
    [reviews_user_id] INT NOT NULL,  -- 外鍵，參考 users 表格的 member_id
    [rating] INT CHECK (rating BETWEEN 1 AND 5) NOT NULL,  -- 評分，介於 1 到 5 之間
    [comment] NVARCHAR(1000),  -- 評論內容
    [photo] VARBINARY(MAX),  -- 圖片，儲存為二進制數據
    [updated_at] DATETIME NOT NULL DEFAULT GETDATE(),  -- 更新時間，預設為當前時間
    CONSTRAINT FK_Product FOREIGN KEY ([reviews_product_id]) REFERENCES [dbo].[products]([product_id]),  -- 外鍵約束：product_id 參考 products 表格
    CONSTRAINT FK_User FOREIGN KEY ([reviews_user_id]) REFERENCES [dbo].[users]([user_id])  -- 外鍵約束：user_id 參考 users 表格
);


-- 插入假資料到 users 表
INSERT INTO users (username, [password], email, full_name, phone, user_photo, [address]) VALUES
('alice123', 'password123', 'alice@example.com', 'Alice Johnson', '0912345678', 'alice.jpg', '台北市信義區123號'),
('bob456', 'password456', 'bob@example.com', 'Bob Smith', '0923456789', 'bob.jpg', '台中市南屯區456號'),
('charlie789', 'password789', 'charlie@example.com', 'Charlie Brown', '0934567890', 'charlie.jpg', '高雄市三民區789號'),
('tomlee', 'securepass1', 'tomlee@example.com', 'Tom Lee', '0911222333', 'tomlee.jpg', '台北市中正區100號'),
('janewang', 'securepass2', 'janewang@example.com', 'Jane Wang', '0922333444', 'janewang.jpg', '台南市東區200號');


-- 插入假資料到 product_category 表
INSERT INTO product_category (category_name) VALUES
('電子產品'),
('家居用品'),
('運動器材');


-- 插入假資料到 products 表
INSERT INTO products (sku, product_name, [description], unit_price, image_url, active, unit_in_stock, date_create, last_update, category_id) VALUES
('ELEC001', '藍牙耳機', '高品質無線藍牙耳機', 1999.99, 'bluetooth.jpg', 1, 100, '2025-02-15 10:30:00', '2025-03-10 15:45:00', 1),
('HOME001', '不鏽鋼水壺', '保溫效果佳的不鏽鋼水壺', 599.50, 'bottle.jpg', 1, 200, '2025-02-20 08:15:00', '2025-03-08 12:10:00', 2),
('SPORT001', '瑜伽墊', '環保無毒瑜伽墊', 899.00, 'yoga_mat.jpg', 1, 150, '2025-01-28 14:00:00', '2025-03-05 09:20:00', 3),
('ELEC002', '智慧手環', '多功能健康監測智慧手環', 1299.00, 'smart_band.jpg', 1, 80, '2025-02-25 16:40:00', '2025-03-09 11:30:00', 1),
('HOME002', '電動牙刷', '高速震動清潔電動牙刷', 799.00, 'electric_toothbrush.jpg', 1, 120, '2025-01-18 09:50:00', '2025-03-07 17:00:00', 2);



-- 插入假資料到 shopping_cart 表
INSERT INTO shopping_cart (user_id, added_at) VALUES
(1, '2025-03-01 10:15:00'),
(2, '2025-03-02 14:45:00'),
(3, '2025-03-05 09:30:00'),
(4, '2025-03-07 20:10:00'),
(5, '2025-03-10 16:00:00');



-- 插入假資料到 cart_items 表
INSERT INTO cart_items (cart_id, product_id, quantity, price) VALUES
(1, 1, 2, 1999.99),
(2, 2, 1, 599.50),
(3, 3, 3, 899.00);


-- 插入假資料到 orders 表
INSERT INTO orders (user_id, order_date, total_amount, payment_method, payment_status, shipping_address, shipping_status, ec_pay_trade_no) VALUES
(1, '2025-03-01 11:30:00', 2999.99, 'Credit Card', 'Paid', '台北市中正區忠孝東路100號', 'Shipped', 'TNO202503010001'),
(2, '2025-03-03 15:20:00', 1599.50, 'ATM Transfer', 'Pending', '新北市板橋區文化路200號', 'Processing', 'TNO202503030002'),
(3, '2025-03-05 18:10:00', 899.00, 'Credit Card', 'Paid', '台中市西屯區福星路50號', 'Delivered', 'TNO202503050003'),
(4, '2025-03-08 09:45:00', 4299.00, 'Mobile Payment', 'Paid', '高雄市三民區博愛一路80號', 'Shipped', 'TNO202503080004'),
(5, '2025-03-10 20:30:00', 1299.00, 'Credit Card', 'Failed', '台南市東區東門路150號', 'Cancelled', NULL);



-- 插入假資料到 order_items 表
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 1999.99),
(2, 2, 1, 599.50),
(3, 3, 3, 899.00);


-- 插入假資料到 payments 表
INSERT INTO payments (order_id, user_id, payment_date, amount, payment_method, payment_status, ec_pay_trade_no) VALUES
(1, 1, '2025-03-01 11:45:00', 2999.99, 'Credit Card', 'Paid', 'TNO202503010001'),
(2, 2, '2025-03-03 16:00:00', 1599.50, 'ATM Transfer', 'Pending', 'TNO202503030002'),
(3, 3, '2025-03-05 18:30:00', 899.00, 'Credit Card', 'Paid', 'TNO202503050003'),
(4, 4, '2025-03-08 10:00:00', 4299.00, 'Mobile Payment', 'Paid', 'TNO202503080004'),
(5, 5, '2025-03-10 21:00:00', 1299.00, 'Credit Card', 'Failed', NULL);


-- 插入假資料到 shipment 表
INSERT INTO shipment (order_id, tracking_number, carrier, estimated_delivery, delivery_status) VALUES
(1, 'TRACK123456', 'UPS', '2025-03-15 10:00:00', 'InTransit'),
(2, 'TRACK987654', 'DHL', '2025-03-18 14:00:00', 'Pending'),
(3, 'TRACK112233', 'FedEx', '2025-03-12 09:00:00', 'Delivered');


INSERT INTO [dbo].[reviews] ([product_id], [user_id], [rating], [comment], [updated_at]) 
VALUES 
    (1, 1, 5, N'非常好用，效果出乎意料。很滿意這次的購物體驗，值得推薦。', DATEADD(MINUTE, -10, GETDATE())),
    (2, 2, 4, N'商品質量還不錯，但物流稍慢了一點。', DATEADD(MINUTE, -10, GETDATE())),
    (3, 3, 3, N'普通商品，沒有太大驚喜。性價比一般。', DATEADD(MINUTE, -10, GETDATE())),
    (4, 4, 2, N'商品與描述不符，質量不好，不太滿意。', DATEADD(MINUTE, -10, GETDATE())),
    (5, 5, 5, N'超級喜歡這款產品，物超所值，非常實用。', DATEADD(MINUTE, -10, GETDATE())),
    (1, 2, 4, N'質量很好，使用起來很方便，適合日常使用。', DATEADD(MINUTE, -10, GETDATE())),
    (2, 3, 3, N'商品還可以，沒有很特別，適合基本需求。', DATEADD(MINUTE, -10, GETDATE())),
    (3, 4, 1, N'商品質量差，完全不符合預期。', DATEADD(MINUTE, -10, GETDATE())),
    (4, 5, 4, N'商品不錯，符合描述，但還是希望能再提升質量。', DATEADD(MINUTE, -10, GETDATE())),
    (5, 1, 5, N'這款產品完全符合我的需求，性價比超高，會再次購買。', DATEADD(MINUTE, -10, GETDATE()));


INSERT INTO [dbo].[shops] 
([user_id], [store_name], [store_description], [created_at], [seller_status], [shop_status])
VALUES
(1, '美味小吃店', '提供各式小吃，口味獨特，絕對讓你回味無窮。', GETDATE(), 1, 1),
(2, 'Fashion World', '最流行的時尚服飾店，讓你成為街頭最亮眼的存在。', GETDATE(), 1, 1),
(3, '舒適家居館', '舒適的居家生活用品，讓你在家也能享受度假感覺。', GETDATE(), 1, 1),
(4, '綠意花園', '提供新鮮的植物和花卉，裝點你的家，讓生活更有生氣。', GETDATE(), 1, 1),
(5, 'Tech Gadget Store', '最新科技產品，讓你領先潮流。', GETDATE(), 1, 1),
(1, '手工藝品專賣店', '每一個手工藝品都充滿藝術氣息，為您的家增添獨特風格。', GETDATE(), 1, 1),
(2, '運動用品專賣店', '提供各式運動用品，讓你輕鬆開啟運動生活。', GETDATE(), 1, 1),
(3, '美妝與保養', '專業的美容與保養產品，讓你的肌膚永遠年輕光滑。', GETDATE(), 1, 1),
(4, '電玩世界', '遊戲愛好者的天堂，讓你享受無限的遊戲樂趣。', GETDATE(), 1, 1),
(5, '寵物用品店', '為你的寵物挑選最合適的用品，讓牠們的生活更幸福。', GETDATE(), 1, 1);



/****** activity ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[best_sell_rankings](
	[best_sell_rankings_id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[number_count] [int] NOT NULL,
	[bsr_discount] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[best_sell_rankings_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[best_sell_tracking]    Script Date: 2025/3/4 下午 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[best_sell_tracking](
	[best_sell_tracking_id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[love_count] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[best_sell_tracking_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[buy_one_get_one]    Script Date: 2025/3/4 下午 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[buy_one_get_one](
	[bogo_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[users_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity] [int] NULL,
	[bogo_condition] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[bogo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[coupon]    Script Date: 2025/3/4 下午 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[coupon](
	[coupon_id] [int] IDENTITY(1,1) NOT NULL,
	[users_id] [int] NOT NULL,
	[coupon_discount] [int] NOT NULL,
	[coupon_date_timeout] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[coupon_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[discount]    Script Date: 2025/3/4 下午 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[discount](
	[discount_id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[date_time] [datetime] NOT NULL,
	[discount_percent] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[discount_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Limited_time_sale]    Script Date: 2025/3/4 下午 09:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[limited_time_sale](
	[limited_time_sale_id] [int] IDENTITY(1,1) NOT NULL,
	[limited_time_start] [datetime] NOT NULL,
	[limited_time_end] [datetime] NOT NULL,
	[limited_time_list_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[limited_time_sale_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[best_sell_rankings] ON 

INSERT [dbo].[best_sell_rankings] ([best_sell_rankings_id], [product_id], [number_count], [bsr_discount]) VALUES (1, 23, 14, 250)
INSERT [dbo].[best_sell_rankings] ([best_sell_rankings_id], [product_id], [number_count], [bsr_discount]) VALUES (2, 11, 90, 199)
SET IDENTITY_INSERT [dbo].[best_sell_rankings] OFF
GO
SET IDENTITY_INSERT [dbo].[best_sell_tracking] ON 

INSERT [dbo].[best_sell_tracking] ([best_sell_tracking_id], [product_id], [love_count]) VALUES (1, 11, 1000)
SET IDENTITY_INSERT [dbo].[best_sell_tracking] OFF
GO
SET IDENTITY_INSERT [dbo].[buy_one_get_one] ON 

INSERT [dbo].[buy_one_get_one] ([bogo_id], [order_id], [users_id], [product_id], [quantity], [bogo_condition]) VALUES (1, 21, 1, 11, 20, 0)
SET IDENTITY_INSERT [dbo].[buy_one_get_one] OFF
GO
SET IDENTITY_INSERT [dbo].[coupon] ON 

INSERT [dbo].[Coupon] ([coupon_id], [users_id], [coupon_discount], [coupon_date_timeout]) VALUES (2, 101, 60, CAST(N'2025-03-31T23:59:59.000' AS DateTime))
INSERT [dbo].[Coupon] ([coupon_id], [users_id], [coupon_discount], [coupon_date_timeout]) VALUES (3, 102, 60, CAST(N'2025-04-30T23:59:59.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[coupon] OFF
GO
SET IDENTITY_INSERT [dbo].[discount] ON 

INSERT [dbo].[discount] ([discount_id], [product_id], [date_time], [discount_percent]) VALUES (1, 101, CAST(N'2025-03-01T10:00:00.000' AS DateTime), 75)
INSERT [dbo].[discount] ([discount_id], [product_id], [date_time], [discount_percent]) VALUES (2, 102, CAST(N'2025-04-01T08:30:00.000' AS DateTime), 80)
SET IDENTITY_INSERT [dbo].[discount] OFF
GO
SET IDENTITY_INSERT [dbo].[limited_time_sale] ON 

INSERT [dbo].[limited_time_sale] ([limited_time_sale_id], [limited_time_start], [limited_time_end], [limited_time_list_id]) VALUES (1, CAST(N'2025-03-01T10:00:00.000' AS DateTime), CAST(N'2025-04-01T08:30:00.000' AS DateTime), 1)
INSERT [dbo].[limited_time_sale] ([limited_time_sale_id], [limited_time_start], [limited_time_end], [limited_time_list_id]) VALUES (2, CAST(N'2025-03-01T10:00:00.000' AS DateTime), CAST(N'2025-04-15T08:30:00.000' AS DateTime), 2)
SET IDENTITY_INSERT [dbo].[limited_time_sale] OFF
GO