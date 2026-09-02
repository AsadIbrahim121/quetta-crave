-- =====================================================================
-- QUETTA CRAVE - COMPLETE STANDALONE MYSQL DATABASE (SCHEMA + SEED DATA)
-- Fast Food Restaurant & Grill
-- Location: Rahim Colony, Circular Road near GOGO Pizza, Quetta, Balochistan
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `quetta_crave` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE `quetta_crave`;

-- ---------------------------------------------------------------------
-- 1. DROP EXISTING VIEWS & TABLES (Reverse Dependency Order)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS `v_popular_dishes`;
DROP VIEW IF EXISTS `v_order_summary`;
DROP PROCEDURE IF EXISTS `sp_create_order`;

DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `contact_messages`;
DROP TABLE IF EXISTS `admin_users`;

-- ---------------------------------------------------------------------
-- 2. TABLE DEFINITIONS (7 Relational Tables with Constraints)
-- ---------------------------------------------------------------------

-- Table 1: categories (Food menu categories)
CREATE TABLE `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `icon` VARCHAR(50) DEFAULT 'fa-burger',
  `image_url` VARCHAR(500),
  `display_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 2: products (Menu items linked to categories)
CREATE TABLE `products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_id` INT NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `slug` VARCHAR(150) NOT NULL UNIQUE,
  `description` TEXT NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL CHECK (`price` >= 0),
  `image_url` VARCHAR(500) NOT NULL,
  `badge` VARCHAR(50) DEFAULT NULL,
  `rating` DECIMAL(2, 1) DEFAULT 5.0 CHECK (`rating` >= 0.0 AND `rating` <= 5.0),
  `is_featured` TINYINT(1) DEFAULT 0,
  `is_available` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_category` (`category_id`),
  INDEX `idx_featured` (`is_featured`),
  INDEX `idx_available` (`is_available`),
  CONSTRAINT `fk_product_category` 
    FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 3: orders (Customer orders in Quetta with Pakistani payment options)
CREATE TABLE `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `customer_name` VARCHAR(100) NOT NULL,
  `customer_email` VARCHAR(100) NOT NULL,
  `customer_phone` VARCHAR(30) NOT NULL,
  `delivery_address` TEXT NOT NULL,
  `subtotal` DECIMAL(10, 2) NOT NULL CHECK (`subtotal` >= 0),
  `delivery_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (`delivery_fee` >= 0),
  `total_amount` DECIMAL(10, 2) NOT NULL CHECK (`total_amount` >= 0),
  `payment_method` VARCHAR(100) DEFAULT 'Cash on Delivery',
  `transaction_ref` VARCHAR(100) DEFAULT NULL,
  `order_notes` TEXT,
  `status` ENUM('Pending', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_order_number` (`order_number`),
  INDEX `idx_payment_method` (`payment_method`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 4: order_items (Detailed line items per order)
CREATE TABLE `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `product_id` INT DEFAULT NULL,
  `product_name` VARCHAR(150) NOT NULL,
  `price` DECIMAL(10, 2) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1 CHECK (`quantity` > 0),
  `subtotal` DECIMAL(10, 2) NOT NULL,
  CONSTRAINT `fk_order_items_order` 
    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` 
    FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) 
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 5: reviews (Customer 5-Star Ratings & Testimonials)
CREATE TABLE `reviews` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_name` VARCHAR(100) NOT NULL,
  `customer_email` VARCHAR(100) NOT NULL,
  `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `comment` TEXT NOT NULL,
  `favorite_dish` VARCHAR(100),
  `is_approved` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_rating` (`rating`),
  INDEX `idx_approved` (`is_approved`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 6: contact_messages (Customer feedback and party catering inquiries)
CREATE TABLE `contact_messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(30),
  `subject` VARCHAR(150),
  `message` TEXT NOT NULL,
  `is_read` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table 7: admin_users (Strict authentication for management portal)
CREATE TABLE `admin_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(50) DEFAULT 'Super Admin',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- 3. SQL VIEWS & STORED PROCEDURES
-- ---------------------------------------------------------------------

-- View: Popular Menu Dishes with Category Info
CREATE VIEW `v_popular_dishes` AS
SELECT 
  p.id,
  p.name AS product_name,
  c.name AS category_name,
  p.price,
  p.badge,
  p.rating,
  p.image_url,
  p.is_available
FROM `products` p
JOIN `categories` c ON p.category_id = c.id
WHERE p.is_available = 1
ORDER BY p.rating DESC, p.id ASC;

-- View: Order Summary Overview with Payment Methods
CREATE VIEW `v_order_summary` AS
SELECT 
  o.id,
  o.order_number,
  o.customer_name,
  o.customer_phone,
  o.payment_method,
  o.total_amount,
  o.status,
  o.created_at,
  COUNT(oi.id) AS total_items
FROM `orders` o
LEFT JOIN `order_items` oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, o.customer_name, o.customer_phone, o.payment_method, o.total_amount, o.status, o.created_at
ORDER BY o.created_at DESC;

-- Stored Procedure: Place Order with Automatic Free Delivery Calculation & Payment Option
DELIMITER //
CREATE PROCEDURE `sp_create_order`(
  IN p_order_number VARCHAR(50),
  IN p_customer_name VARCHAR(100),
  IN p_customer_email VARCHAR(100),
  IN p_customer_phone VARCHAR(30),
  IN p_delivery_address TEXT,
  IN p_subtotal DECIMAL(10, 2),
  IN p_payment_method VARCHAR(100),
  IN p_transaction_ref VARCHAR(100),
  IN p_order_notes TEXT,
  OUT p_order_id INT,
  OUT p_delivery_fee DECIMAL(10, 2),
  OUT p_total_amount DECIMAL(10, 2)
)
BEGIN
  -- Check Free Delivery threshold (Rs. 1,000+)
  IF p_subtotal >= 1000.00 THEN
    SET p_delivery_fee = 0.00;
  ELSE
    SET p_delivery_fee = 150.00;
  END IF;

  SET p_total_amount = p_subtotal + p_delivery_fee;

  INSERT INTO `orders` (
    `order_number`, `customer_name`, `customer_email`, `customer_phone`,
    `delivery_address`, `subtotal`, `delivery_fee`, `total_amount`, 
    `payment_method`, `transaction_ref`, `order_notes`
  ) VALUES (
    p_order_number, p_customer_name, p_customer_email, p_customer_phone,
    p_delivery_address, p_subtotal, p_delivery_fee, p_total_amount, 
    COALESCE(p_payment_method, 'Cash on Delivery'), p_transaction_ref, p_order_notes
  );

  SET p_order_id = LAST_INSERT_ID();
END //
DELIMITER ;

-- ---------------------------------------------------------------------
-- 4. INITIAL SEED DATA INSERTIONS
-- ---------------------------------------------------------------------

-- Seed Admin User (Management Account)
INSERT INTO `admin_users` (`id`, `username`, `password_hash`, `full_name`, `role`) VALUES
(1, 'CRAVELODGE', '$2a$10$TxcT1enFkoOmqJS2WYLige8rONTzy5Drh7YhyUALKJEBmA6kariJ2', 'Quetta Crave Management', 'Super Admin');

-- Seed 5 Main Categories
INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `icon`, `image_url`, `display_order`) VALUES
(1, 'Gourmet Smash Burgers', 'burgers', 'Juicy smashed beef patties and crunchy fried chicken burgers on butter-toasted brioche buns', 'fa-burger', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80', 1),
(2, 'Artisan Cheesy Pizzas', 'pizzas', 'Stone-baked thin and stuffed crust pizzas loaded with premium mozzarella and fresh toppings', 'fa-pizza-slice', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80', 2),
(3, 'Crispy Fried Chicken & Broast', 'crispy-chicken', 'Golden crispy chicken seasoned with our secret blend of 11 herbs and spices', 'fa-drumstick-bite', 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80', 3),
(4, 'Quetta Crave Shawarma & Wraps', 'shawarma-wraps', 'Authentic charcoal grilled chicken shawarmas and crispy wraps in soft Lebanese bread', 'fa-bowl-rice', 'https://images.unsplash.com/photo-1561651823-34feb02250e4?auto=format&fit=crop&w=800&q=80', 4),
(5, 'Loaded Fries, Shakes & Desserts', 'sides-desserts', 'Gooey cheese fries, thick creamy milkshakes, and warm molten desserts to finish off', 'fa-ice-cream', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80', 5);

-- Seed 25 Menu Items (5 items per category with exact descriptions, PKR pricing, badges, ratings)
INSERT INTO `products` (`id`, `category_id`, `name`, `slug`, `description`, `price`, `image_url`, `badge`, `rating`, `is_featured`, `is_available`) VALUES
-- Category 1: Gourmet Smash Burgers
(1, 1, 'Quetta Crave Monster Smash Burger', 'quetta-crave-monster-smash-burger', 'Double prime beef smash patties, melted cheddar, caramelized sweet onions, secret house sauce, toasted brioche bun.', 750.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80', 'Chef Special', 5.0, 1, 1),
(2, 1, 'Zinger Fire Tower Burger', 'zinger-fire-tower-burger', 'Extra crispy spicy fried chicken breast fillet, melted pepper jack cheese, jalapenos, peri-peri drizzle, and iceberg lettuce.', 650.00, 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?auto=format&fit=crop&w=800&q=80', 'Best Seller', 4.9, 1, 1),
(3, 1, 'Royal Truffle Mushroom Burger', 'royal-truffle-mushroom-burger', '100% Angus smash beef, sautéed garlic butter wild mushrooms, Swiss cheese, and signature truffle aioli.', 850.00, 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?auto=format&fit=crop&w=800&q=80', 'Gourmet', 4.8, 0, 1),
(4, 1, 'Smoky BBQ Bacon Crunch Burger', 'smoky-bbq-bacon-crunch-burger', 'Smoked beef patty, crispy turkey bacon strips, golden battered onion rings, and tangy smoky BBQ glaze.', 790.00, 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80', 'Popular', 4.9, 0, 1),
(5, 1, 'Classic American Cheeseburger', 'classic-american-cheeseburger', 'Juicy grilled beef patty, dual American cheddar slices, tangy pickles, and classic mustard-mayo on sesame bun.', 550.00, 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?auto=format&fit=crop&w=800&q=80', 'Value Pick', 4.7, 0, 1),

-- Category 2: Artisan Cheesy Pizzas
(6, 2, 'Quetta Crown Crust Special Pizza', 'quetta-crown-crust-special-pizza', 'Loaded crown crust stuffed with cheese & spicy kebab, tikka chicken chunks, bell peppers, black olives, ranch swirl.', 1450.00, 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80', 'Must Try', 5.0, 1, 1),
(7, 2, 'Peri Peri Firestorm Pizza', 'peri-peri-firestorm-pizza', 'Spicy peri peri marinated grilled chicken, red onions, pickled jalapenos, mozzarella, and spicy peri mayo drizzle.', 1250.00, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80', 'Spicy', 4.9, 0, 1),
(8, 2, 'Cheesy Lovers 4-Cheese Delight', 'cheesy-lovers-4-cheese-delight', 'Decadent blend of Mozzarella, sharp Cheddar, shaved Parmesan, and Gouda over slow-cooked herb tomato marinara.', 1150.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80', 'Vegetarian', 4.8, 0, 1),
(9, 2, 'Creamy Malai Boti Pizza', 'creamy-malai-boti-pizza', 'Tender charcoal-smoked malai boti chicken chunks, button mushrooms, sweet corn, and creamy white garlic sauce.', 1350.00, 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&w=800&q=80', 'Best Seller', 5.0, 1, 1),
(10, 2, 'Pepperoni Passion Supreme Pizza', 'pepperoni-passion-supreme-pizza', 'Generously layered artisan beef pepperoni, rich marinara sauce, double mozzarella, and oregano sprinkle.', 1300.00, 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?auto=format&fit=crop&w=800&q=80', 'Classic', 4.9, 0, 1),

-- Category 3: Crispy Fried Chicken & Broast
(11, 3, 'Golden Crispy Broast 3-Piece Combo', 'golden-crispy-broast-3-piece-combo', '3 pieces of signature crunchy fried chicken, seasoned fries, creamy garlic mayo dip, and fresh dinner roll.', 690.00, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?auto=format&fit=crop&w=800&q=80', 'Hot & Fresh', 5.0, 1, 1),
(12, 3, 'Buffalo Flaming Hot Wings (8 Pcs)', 'buffalo-flaming-hot-wings-8pcs', '8 pcs crispy fried wings tossed in tangy flaming New York buffalo glaze, served with cool ranch dipping sauce.', 550.00, 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=800&q=80', 'Spicy', 4.9, 0, 1),
(13, 3, 'Crispy Chicken Tenders Basket', 'crispy-chicken-tenders-basket', '5 pcs golden crunchy tenderloins, honey mustard & garlic mayo dips, served with a basket of seasoned fries.', 520.00, 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=800&q=80', 'Kids & Adults', 4.8, 0, 1),
(14, 3, 'Honey Garlic Glazed Crispy Chicken', 'honey-garlic-glazed-crispy-chicken', '4 pcs crunchy fried chicken cuts glazed in sweet honey garlic reduction and toasted sesame seeds.', 640.00, 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=800&q=80', 'Trending', 4.9, 0, 1),
(15, 3, 'Crave Family Feast Chicken Bucket', 'crave-family-feast-chicken-bucket', '8 pcs crispy fried chicken, 2 large fries, 2 coleslaw bowls, 4 dinner rolls, 2 signature dips, and 1.5L soft drink.', 1890.00, 'https://images.unsplash.com/photo-1585325701956-60dd9c8553bc?auto=format&fit=crop&w=800&q=80', 'Best Value', 5.0, 1, 1),

-- Category 4: Shawarma & Wraps
(16, 4, 'Jumbo Arabic Garlic Chicken Shawarma', 'jumbo-arabic-garlic-chicken-shawarma', 'Charcoal grilled sliced chicken, signature thick garlic toum, salted fries & crunchy pickled cucumbers in pita.', 380.00, 'https://images.unsplash.com/photo-1561651823-34feb02250e4?auto=format&fit=crop&w=800&q=80', 'Top Rated', 5.0, 1, 1),
(17, 4, 'Spicy Zinger Tortilla Wrap', 'spicy-zinger-tortilla-wrap', 'Crispy chicken strip, shredded cabbage, spicy chipotle sauce, and melted cheddar wrapped in toasted tortilla.', 450.00, 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80', 'Best Seller', 4.9, 0, 1),
(18, 4, 'Cheesy Charcoal Malai Shawarma', 'cheesy-charcoal-malai-shawarma', 'Tender malai chicken cubes, melted mozzarella, garlic cream sauce, and mint mayo wrapped in soft Lebanese bread.', 420.00, 'https://images.unsplash.com/photo-1603064752734-4c48eff53d05?auto=format&fit=crop&w=800&q=80', 'Chef Choice', 4.8, 0, 1),
(19, 4, 'Quetta Crave Loaded Shawarma Platter', 'quetta-crave-loaded-shawarma-platter', 'Deconstructed platter: grilled spiced chicken, fragrant yellow rice, garlic hummus, pickled veggies, and toasted pita triangles.', 650.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80', 'Special Platter', 5.0, 1, 1),
(20, 4, 'Beef Seekh Kebab Paratha Roll', 'beef-seekh-kebab-paratha-roll', 'Spiced charcoal grilled beef seekh kebab, mint-coriander chutney, and thinly sliced red onions in crispy paratha.', 350.00, 'https://images.unsplash.com/photo-1628294895950-9805252327bc?auto=format&fit=crop&w=800&q=80', 'Traditional', 4.8, 0, 1),

-- Category 5: Loaded Fries, Shakes & Desserts
(21, 5, 'Loaded Animal Style Cheesy Fries', 'loaded-animal-style-cheesy-fries', 'Crisp skin-on fries drenched in hot liquid cheddar cheese, spiced minced chicken, sliced jalapenos, and Crave special sauce.', 490.00, 'https://images.unsplash.com/photo-1585109649139-366815a0d713?auto=format&fit=crop&w=800&q=80', 'Must Try', 5.0, 1, 1),
(22, 5, 'Gourmet Lotus Biscoff Shake', 'gourmet-lotus-biscoff-shake', 'Thick creamy vanilla ice cream shake blended with authentic Lotus Biscoff spread, crushed biscuits, and caramel swirl.', 450.00, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=800&q=80', 'Super Thick', 5.0, 1, 1),
(23, 5, 'Nutella Hazelnut Freakshake', 'nutella-hazelnut-freakshake', 'Rich chocolate hazelnut shake crowned with whipped cream, Nutella drizzle, and chocolate brownie crumble.', 480.00, 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?auto=format&fit=crop&w=800&q=80', 'Choco Craze', 4.9, 0, 1),
(24, 5, 'Warm Molten Lava Cake with Ice Cream', 'warm-molten-lava-cake-with-ice-cream', 'Warm dark chocolate cake with an oozing Belgian chocolate center served with premium vanilla ice cream scoop.', 420.00, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80', 'Dessert King', 4.9, 0, 1),
(25, 5, 'Crispy Golden Mozzarella Cheese Sticks', 'crispy-golden-mozzarella-cheese-sticks', '6 pcs stretchy mozzarella sticks encased in herb-seasoned golden breadcrumb crust, served with warm marinara dip.', 390.00, 'https://images.unsplash.com/photo-1531749668029-2db88e4276c7?auto=format&fit=crop&w=800&q=80', 'Cheesy', 4.8, 0, 1);

-- Seed 5-Star Customer Reviews
INSERT INTO `reviews` (`id`, `customer_name`, `customer_email`, `rating`, `comment`, `favorite_dish`, `is_approved`) VALUES
(1, 'Hamza Khan', 'hamza.k@gmail.com', 5, 'Hands down the best smash burger in Quetta! The beef was incredibly juicy and the toasted brioche bun had the perfect crunch. Rahim Colony now has the ultimate food spot!', 'Quetta Crave Monster Smash Burger', 1),
(2, 'Dr. Ayesha Mengal', 'ayesha.mengal@yahoo.com', 5, 'Ordered the Quetta Crown Crust pizza and Loaded Animal Fries. The delivery was completely FREE because our order was Rs. 1940 and arrived piping hot within 25 minutes! 10/10.', 'Quetta Crown Crust Special Pizza', 1),
(3, 'Tariq Baloch', 'tariq.b@outlook.com', 5, 'The Zinger Tower burger and Buffalo wings are sensational. Extremely clean ambiance near GOGO Pizza on Circular Road, and staff is super courteous.', 'Zinger Fire Tower Burger', 1),
(4, 'Sardar Bilal Achakzai', 'bilal.achakzai@gmail.com', 5, 'Authentic Arabic Garlic Shawarma taste right here in Quetta. The toum garlic sauce is phenomenal. Highly recommended!', 'Jumbo Arabic Garlic Chicken Shawarma', 1),
(5, 'Zainab Qureshi', 'zainab.q@gmail.com', 5, 'The Lotus Biscoff shake and Molten Lava cake are to die for! Truly 5-star quality and fast delivery.', 'Gourmet Lotus Biscoff Shake', 1);

-- Seed Initial Contact Inquiries
INSERT INTO `contact_messages` (`id`, `name`, `email`, `phone`, `subject`, `message`, `is_read`) VALUES
(1, 'Farhan Kasi', 'farhan.kasi@gmail.com', '03337891234', 'Catering Inquiry for Birthday Party', 'Hi Quetta Crave team, I want to order 20 monster smash burgers and loaded fries for a birthday party this Saturday at Rahim Colony. Do you offer party discounts?', 0);