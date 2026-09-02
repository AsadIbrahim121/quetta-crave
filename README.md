# 🍔 QUETTA CRAVE — Gourmet Fast Food & Grill

[![Live Website](https://img.shields.io/badge/Website-LIVE%2024%2F7-brightgreen?style=for-the-badge&logo=github)](https://asadibrahim121.github.io/quetta-crave/)
[![GitHub Pages](https://img.shields.io/badge/Hosted%20On-GitHub%20Pages-blue?style=for-the-badge&logo=githubpages)](https://asadibrahim121.github.io/quetta-crave/)
[![Halal](https://img.shields.io/badge/100%25-Halal%20Prime-orange?style=for-the-badge)](https://asadibrahim121.github.io/quetta-crave/)
[![Free Delivery](https://img.shields.io/badge/Delivery-FREE%20Rs.%201000%2B-yellow?style=for-the-badge)](https://asadibrahim121.github.io/quetta-crave/)

> **Quetta Crave** is a modern, high-performance, full-featured web application and relational database system for Quetta's premier fast food restaurant located at **Rahim Colony, Circular Road near GOGO Pizza, Quetta, Balochistan, Pakistan**.

---

## 🌐 Live Website (24/7 Uptime)

The restaurant website is live and hosted 24/7 on GitHub Pages:
🔗 **[https://asadibrahim121.github.io/quetta-crave/](https://asadibrahim121.github.io/quetta-crave/)**

---

## ✨ Features & Highlights

### 🎨 Visuals & UI/UX
- **3D Pop-Up Branding**: Animated glowing website badge with interactive hover card (*Rahim Colony near GOGO Pizza*).
- **Ambient Floating Animations**: Dynamic staggered floating food cards, stickers, and shimmering text effects.
- **Mobile First & Ultra-Responsive**: Smooth experience across mobile phones, tablets, and 4K desktop screens.

### 🍔 Menu & Product Catalog
- **25+ Signature Dishes** organized into 5 categories:
  1. **Gourmet Smash Burgers** (Monster Smash, Zinger Tower, Truffle Mushroom, etc.)
  2. **Artisan Cheesy Pizzas** (Crown Crust, Peri Peri Firestorm, 4-Cheese Delight, Malai Boti)
  3. **Crispy Fried Chicken & Broast** (Golden Broast Combo, Hot Wings, Tenders Basket, Family Bucket)
  4. **Shawarmas & Wraps** (Jumbo Arabic Garlic Toum Shawarma, Malai Shawarma, Beef Paratha Roll)
  5. **Loaded Fries, Shakes & Desserts** (Animal Cheesy Fries, Lotus Biscoff Shake, Molten Lava Cake)

### 🛒 Real-Time Cart & Free Delivery Engine
- Instant dynamic calculation of cart subtotal, delivery fee, and grand total.
- **Free Delivery Progress Bar**: Unlocks **FREE Delivery** automatically for orders of **Rs. 1,000 and above** (Rs. 150 standard fee for smaller orders).

### 💳 Pakistani Payment Methods Integration
- **Cash on Delivery (COD)**: Doorstep payment upon rider arrival.
- **EasyPaisa Direct Transfer**: Account Title `QUETTA CRAVE RESTAURANT`, Mobile: `0333-7895555`, Till ID: `88291`.
- **JazzCash Direct Transfer**: Account Title `QUETTA CRAVE RESTAURANT`, Mobile: `0300-7895555`, Till ID: `44102`.
- **Pakistani Bank Card / SadaPay / NayaPay**: Direct Meezan Bank IBAN & SadaPay options with transaction reference input.

### ⭐ 5-Star Reviews & Customer Proof
- Interactive testimonial cards with customer names and favorite dishes.
- Built-in interactive **5-Star Review Submission Modal** saving ratings to persistent storage.

### 📍 Location & Contact
- **Address**: Rahim Colony, Circular Road near GOGO Pizza, Quetta, Balochistan
- **Timing**: Daily 12:00 PM – 02:00 AM (Midnight)
- **Hotline**: `(081) 282-5555` / `+92 333 7895555`
- **Embedded Google Map** with direct routing.

### 🔐 Protected Admin Management Portal
- Clean, secure unprefilled login modal.
- **Credentials**:
  - **Username**: `CRAVELODGE`
  - **Password**: `foodfanatic007`
- **Capabilities**:
  - Full **CRUD** operations (Create, Read, Update, Delete) on menu items with live category selector and image updater.
  - Live customer order dashboard displaying order numbers, customer details, payment methods, delivery addresses, and status.
  - Customer review management and moderation.
  - Built-in dish photo drag & drop uploader.

---

## 🗄️ Database Architecture (`database.sql`)

The repository includes a complete production-grade standalone MySQL schema with views, stored procedures, and seed data:

- `categories`: Menu category taxonomy with slug, icons, and display ordering.
- `products`: 25 pre-seeded menu items with foreign key constraints, ratings, and pricing.
- `orders`: Quetta delivery orders with Pakistani payment methods and transaction references.
- `order_items`: Relational line-items linked to orders with cascading integrity.
- `reviews`: Verified 5-star customer feedback and ratings.
- `contact_messages`: Catering inquiries and user messages.
- `admin_users`: Administrative role-based access.
- `sp_create_order`: Stored procedure implementing business logic for free delivery threshold calculation.
- `v_popular_dishes` & `v_order_summary`: Optimized analytics views.

---

## 🚀 24/7 Hosting & Deployment

This project is deployed on **GitHub Pages**, providing:
- **Zero Downtime**: Guaranteed 24/7 continuous uptime backed by GitHub's global CDN network.
- **SSL Encryption**: Automated HTTPS certificate management.
- **Instant Updates**: Any update pushed to the `main` branch automatically deploys to the live website.

---

© 2026 **QUETTA CRAVE**. Near GOGO Pizza, Rahim Colony, Quetta. All Rights Reserved.
