-- ============================================================
-- AGRIBUSINESS FARM MANAGEMENT DATABASE
-- Author: Sayantani Das | Department: B.Tech CSE
-- DBMS: MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS agribusiness_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE agribusiness_db;

-- Drop tables in dependency-safe order for repeatable execution.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS harvests;
DROP TABLE IF EXISTS plantings;
DROP TABLE IF EXISTS crops;
DROP TABLE IF EXISTS seasons;
DROP TABLE IF EXISTS fields;
DROP TABLE IF EXISTS farms;
DROP TABLE IF EXISTS farmers;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Farmers: people who own/manage farms.
CREATE TABLE farmers (
    farmer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(120) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Farms: a farmer may manage multiple farms.
CREATE TABLE farms (
    farm_id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    farm_name VARCHAR(120) NOT NULL,
    location VARCHAR(180) NOT NULL,
    total_area_ha DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_farm_area CHECK (total_area_ha > 0),
    CONSTRAINT fk_farms_farmer FOREIGN KEY (farmer_id)
      REFERENCES farmers(farmer_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. Fields: each farm is divided into separately managed fields.
CREATE TABLE fields (
    field_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    area_ha DECIMAL(10,2) NOT NULL,
    soil_type VARCHAR(60),
    irrigation_type VARCHAR(60),
    CONSTRAINT chk_field_area CHECK (area_ha > 0),
    CONSTRAINT uq_field_name_per_farm UNIQUE (farm_id, field_name),
    CONSTRAINT fk_fields_farm FOREIGN KEY (farm_id)
      REFERENCES farms(farm_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Seasons: reusable crop seasons/production periods.
CREATE TABLE seasons (
    season_id INT AUTO_INCREMENT PRIMARY KEY,
    season_name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT chk_season_dates CHECK (end_date >= start_date),
    CONSTRAINT uq_season_period UNIQUE (season_name, start_date, end_date)
) ENGINE=InnoDB;

-- 5. Crops: crop catalogue with standard unit of measurement.
CREATE TABLE crops (
    crop_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL UNIQUE,
    crop_category VARCHAR(60),
    standard_unit VARCHAR(20) NOT NULL DEFAULT 'tonne'
) ENGINE=InnoDB;

-- 6. Plantings: associative/event table linking field, crop and season.
CREATE TABLE plantings (
    planting_id INT AUTO_INCREMENT PRIMARY KEY,
    field_id INT NOT NULL,
    crop_id INT NOT NULL,
    season_id INT NOT NULL,
    sowing_date DATE NOT NULL,
    expected_harvest_date DATE,
    seed_quantity_kg DECIMAL(12,2),
    status ENUM('PLANNED','GROWING','HARVESTED','CANCELLED')
      NOT NULL DEFAULT 'PLANNED',
    CONSTRAINT chk_seed_qty CHECK (seed_quantity_kg IS NULL OR seed_quantity_kg >= 0),
    CONSTRAINT fk_plantings_field FOREIGN KEY (field_id)
      REFERENCES fields(field_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_plantings_crop FOREIGN KEY (crop_id)
      REFERENCES crops(crop_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_plantings_season FOREIGN KEY (season_id)
      REFERENCES seasons(season_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_planting_crop_season (crop_id, season_id),
    INDEX idx_planting_field_date (field_id, sowing_date)
) ENGINE=InnoDB;

-- 7. Harvests: one planting can have multiple harvest records.
CREATE TABLE harvests (
    harvest_id INT AUTO_INCREMENT PRIMARY KEY,
    planting_id INT NOT NULL,
    harvest_date DATE NOT NULL,
    quantity_tonnes DECIMAL(12,3) NOT NULL,
    quality_grade VARCHAR(20),
    CONSTRAINT chk_harvest_qty CHECK (quantity_tonnes >= 0),
    CONSTRAINT fk_harvests_planting FOREIGN KEY (planting_id)
      REFERENCES plantings(planting_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_harvest_date (harvest_date)
) ENGINE=InnoDB;

-- 8. Expenses: cost incurred by a farm; optionally attributable to a planting.
CREATE TABLE expenses (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    farm_id INT NOT NULL,
    planting_id INT NULL,
    expense_date DATE NOT NULL,
    expense_category ENUM('SEEDS','FERTILIZER','LABOUR','IRRIGATION',
                          'MACHINERY','TRANSPORT','OTHER') NOT NULL,
    description VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_expense_amount CHECK (amount >= 0),
    CONSTRAINT fk_expenses_farm FOREIGN KEY (farm_id)
      REFERENCES farms(farm_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_expenses_planting FOREIGN KEY (planting_id)
      REFERENCES plantings(planting_id) ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_expense_farm_date (farm_id, expense_date)
) ENGINE=InnoDB;

-- 9. Customers: buyers of harvested agricultural products.
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    customer_type ENUM('WHOLESALER','RETAILER','PROCESSOR','INDIVIDUAL')
      NOT NULL DEFAULT 'WHOLESALER',
    phone VARCHAR(20),
    email VARCHAR(120),
    city VARCHAR(80)
) ENGINE=InnoDB;

-- 10. Sales: sale transactions linked to customer and harvested planting.
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    harvest_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity_tonnes DECIMAL(12,3) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_sale_qty CHECK (quantity_tonnes > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_harvest FOREIGN KEY (harvest_id)
      REFERENCES harvests(harvest_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_sales_date (sale_date),
    INDEX idx_sales_customer_date (customer_id, sale_date)
) ENGINE=InnoDB;

-- -------------------- SAMPLE DATA --------------------

INSERT INTO farmers (first_name,last_name,phone,email) VALUES
('Amit','Roy','9000000001','amit.roy@example.com'),
('Mita','Sen','9000000002','mita.sen@example.com'),
('Rahul','Das','9000000003','rahul.das@example.com');

INSERT INTO farms (farmer_id,farm_name,location,total_area_ha) VALUES
(1,'Green Valley Farm','Nadia, West Bengal',12.50),
(2,'Sunrise Agro','Hooghly, West Bengal',9.00),
(3,'Riverbank Farms','Burdwan, West Bengal',15.00);

INSERT INTO fields (farm_id,field_name,area_ha,soil_type,irrigation_type) VALUES
(1,'North Field',5.00,'Alluvial','Canal'),
(1,'South Field',7.50,'Loamy','Drip'),
(2,'East Field',9.00,'Alluvial','Canal'),
(3,'Main Field',15.00,'Clay Loam','Sprinkler');

INSERT INTO seasons (season_name,start_date,end_date) VALUES
('Kharif 2025','2025-06-01','2025-10-31'),
('Rabi 2025-26','2025-11-01','2026-03-31'),
('Kharif 2026','2026-06-01','2026-10-31');

INSERT INTO crops (crop_name,crop_category,standard_unit) VALUES
('Rice','Cereal','tonne'),
('Wheat','Cereal','tonne'),
('Potato','Vegetable','tonne'),
('Mustard','Oilseed','tonne');

INSERT INTO plantings
(field_id,crop_id,season_id,sowing_date,expected_harvest_date,seed_quantity_kg,status) VALUES
(1,1,1,'2025-06-15','2025-10-10',45,'HARVESTED'),
(2,3,2,'2025-11-20','2026-02-20',180,'HARVESTED'),
(3,2,2,'2025-11-10','2026-03-15',120,'HARVESTED'),
(4,1,3,'2026-06-18','2026-10-15',130,'HARVESTED'),
(1,4,2,'2025-11-25','2026-03-05',25,'HARVESTED');

INSERT INTO harvests (planting_id,harvest_date,quantity_tonnes,quality_grade) VALUES
(1,'2025-10-12',18.500,'A'),
(2,'2026-02-22',32.000,'A'),
(3,'2026-03-17',21.500,'B'),
(4,'2026-10-18',52.000,'A'),
(5,'2026-03-08',6.200,'A');

INSERT INTO expenses
(farm_id,planting_id,expense_date,expense_category,description,amount) VALUES
(1,1,'2025-07-01','FERTILIZER','Fertilizer purchase',18000.00),
(1,1,'2025-08-15','LABOUR','Field labour',12000.00),
(1,2,'2026-01-10','IRRIGATION','Water and irrigation',6500.00),
(2,3,'2026-02-01','FERTILIZER','Fertilizer purchase',14000.00),
(3,4,'2026-07-05','SEEDS','Rice seeds',9000.00),
(3,NULL,'2026-07-20','MACHINERY','Equipment maintenance',7500.00),
(1,5,'2026-02-10','LABOUR','Harvest labour',5000.00);

INSERT INTO customers (customer_name,customer_type,phone,email,city) VALUES
('Eastern Grain Traders','WHOLESALER','9111111111','orders@easterngrain.example','Kolkata'),
('Fresh Basket Retail','RETAILER','9222222222','buy@freshbasket.example','Howrah'),
('Bengal Food Processing','PROCESSOR','9333333333','procurement@bfp.example','Burdwan');

INSERT INTO sales (customer_id,harvest_id,sale_date,quantity_tonnes,unit_price) VALUES
(1,1,'2025-10-20',15.000,24000.00),
(2,2,'2026-02-25',25.000,18000.00),
(3,3,'2026-03-20',18.000,26000.00),
(1,4,'2026-10-25',40.000,25000.00),
(2,5,'2026-03-12',5.000,52000.00);

-- ============================================================
-- ANALYTICAL QUERIES (MySQL 8.0+)
-- ============================================================

-- Q1. List farms with their owners and locations.
SELECT f.farm_id, f.farm_name,
       CONCAT(fr.first_name, ' ', fr.last_name) AS farmer_name,
       f.location, f.total_area_ha
FROM farms AS f
JOIN farmers AS fr ON fr.farmer_id = f.farmer_id
ORDER BY f.farm_name;

-- Q2. Total harvested quantity by crop.
SELECT c.crop_name, SUM(h.quantity_tonnes) AS total_harvest_tonnes
FROM harvests AS h
JOIN plantings AS p ON p.planting_id = h.planting_id
JOIN crops AS c ON c.crop_id = p.crop_id
GROUP BY c.crop_id, c.crop_name
ORDER BY total_harvest_tonnes DESC;

-- Q3. Yield per hectare by planting (field area is the denominator).
SELECT p.planting_id, f.farm_name, fld.field_name, c.crop_name,
       SUM(h.quantity_tonnes) AS harvested_tonnes,
       fld.area_ha,
       ROUND(SUM(h.quantity_tonnes) / fld.area_ha, 2) AS yield_tonnes_per_ha
FROM plantings AS p
JOIN fields AS fld ON fld.field_id = p.field_id
JOIN farms AS f ON f.farm_id = fld.farm_id
JOIN crops AS c ON c.crop_id = p.crop_id
JOIN harvests AS h ON h.planting_id = p.planting_id
GROUP BY p.planting_id, f.farm_name, fld.field_name, c.crop_name, fld.area_ha
ORDER BY yield_tonnes_per_ha DESC;

-- Q4. Production by crop and season.
SELECT s.season_name, c.crop_name,
       SUM(h.quantity_tonnes) AS production_tonnes
FROM harvests h
JOIN plantings p ON p.planting_id = h.planting_id
JOIN seasons s ON s.season_id = p.season_id
JOIN crops c ON c.crop_id = p.crop_id
GROUP BY s.season_id, s.season_name, c.crop_id, c.crop_name
ORDER BY s.start_date, production_tonnes DESC;

-- Q5. Revenue by farm.
SELECT f.farm_name,
       SUM(sa.quantity_tonnes * sa.unit_price) AS revenue
FROM sales sa
JOIN harvests h ON h.harvest_id = sa.harvest_id
JOIN plantings p ON p.planting_id = h.planting_id
JOIN fields fld ON fld.field_id = p.field_id
JOIN farms f ON f.farm_id = fld.farm_id
GROUP BY f.farm_id, f.farm_name
ORDER BY revenue DESC;

-- Q6. Total expenses by farm and expense category.
SELECT f.farm_name, e.expense_category,
       SUM(e.amount) AS total_expense
FROM expenses e
JOIN farms f ON f.farm_id = e.farm_id
GROUP BY f.farm_id, f.farm_name, e.expense_category
ORDER BY f.farm_name, total_expense DESC;

-- Q7. Farm-level operating surplus (sales revenue less recorded expenses).
-- This is a simplified contribution measure, not audited net profit.
WITH farm_revenue AS (
    SELECT fld.farm_id, SUM(sa.quantity_tonnes * sa.unit_price) AS revenue
    FROM sales sa
    JOIN harvests h ON h.harvest_id = sa.harvest_id
    JOIN plantings p ON p.planting_id = h.planting_id
    JOIN fields fld ON fld.field_id = p.field_id
    GROUP BY fld.farm_id
),
farm_cost AS (
    SELECT farm_id, SUM(amount) AS expenses
    FROM expenses
    GROUP BY farm_id
)
SELECT f.farm_name,
       COALESCE(r.revenue,0) AS revenue,
       COALESCE(c.expenses,0) AS expenses,
       COALESCE(r.revenue,0) - COALESCE(c.expenses,0) AS operating_surplus
FROM farms f
LEFT JOIN farm_revenue r ON r.farm_id = f.farm_id
LEFT JOIN farm_cost c ON c.farm_id = f.farm_id
ORDER BY operating_surplus DESC;

-- Q8. Monthly sales revenue.
SELECT DATE_FORMAT(sale_date,'%Y-%m') AS sales_month,
       SUM(quantity_tonnes * unit_price) AS monthly_revenue
FROM sales
GROUP BY DATE_FORMAT(sale_date,'%Y-%m')
ORDER BY sales_month;

-- Q9. Best customers by total purchase value.
SELECT cu.customer_name,
       SUM(sa.quantity_tonnes * sa.unit_price) AS purchase_value,
       SUM(sa.quantity_tonnes) AS purchased_tonnes
FROM customers cu
JOIN sales sa ON sa.customer_id = cu.customer_id
GROUP BY cu.customer_id, cu.customer_name
ORDER BY purchase_value DESC;

-- Q10. Unsold harvest quantity by harvest record.
-- A LEFT JOIN retains harvests that have no corresponding sales.
SELECT h.harvest_id, c.crop_name, h.quantity_tonnes,
       COALESCE(SUM(sa.quantity_tonnes),0) AS sold_tonnes,
       h.quantity_tonnes - COALESCE(SUM(sa.quantity_tonnes),0) AS unsold_tonnes
FROM harvests h
JOIN plantings p ON p.planting_id = h.planting_id
JOIN crops c ON c.crop_id = p.crop_id
LEFT JOIN sales sa ON sa.harvest_id = h.harvest_id
GROUP BY h.harvest_id, c.crop_name, h.quantity_tonnes
HAVING unsold_tonnes > 0
ORDER BY unsold_tonnes DESC;

-- Q11. Farms ranked by total harvested production using a window function.
WITH farm_production AS (
    SELECT f.farm_id, f.farm_name, SUM(h.quantity_tonnes) AS total_tonnes
    FROM farms f
    JOIN fields fld ON fld.farm_id = f.farm_id
    JOIN plantings p ON p.field_id = fld.field_id
    JOIN harvests h ON h.planting_id = p.planting_id
    GROUP BY f.farm_id, f.farm_name
)
SELECT farm_name, total_tonnes,
       DENSE_RANK() OVER (ORDER BY total_tonnes DESC) AS production_rank
FROM farm_production;

-- Q12. Average selling price per crop.
SELECT c.crop_name,
       ROUND(SUM(sa.quantity_tonnes * sa.unit_price) /
             NULLIF(SUM(sa.quantity_tonnes),0),2) AS avg_price_per_tonne
FROM sales sa
JOIN harvests h ON h.harvest_id = sa.harvest_id
JOIN plantings p ON p.planting_id = h.planting_id
JOIN crops c ON c.crop_id = p.crop_id
GROUP BY c.crop_id, c.crop_name
ORDER BY avg_price_per_tonne DESC;

-- Q13. Plantings not yet marked harvested or cancelled.
SELECT p.planting_id, f.farm_name, fld.field_name, c.crop_name,
       p.sowing_date, p.expected_harvest_date, p.status
FROM plantings p
JOIN fields fld ON fld.field_id = p.field_id
JOIN farms f ON f.farm_id = fld.farm_id
JOIN crops c ON c.crop_id = p.crop_id
WHERE p.status IN ('PLANNED','GROWING')
ORDER BY p.expected_harvest_date;

-- Q14. Expense trend by month.
SELECT DATE_FORMAT(expense_date,'%Y-%m') AS expense_month,
       SUM(amount) AS monthly_expense
FROM expenses
GROUP BY DATE_FORMAT(expense_date,'%Y-%m')
ORDER BY expense_month;

-- Q15. Top-yielding crop in each season using a window function.
WITH crop_season_yield AS (
    SELECT s.season_name, c.crop_name,
           SUM(h.quantity_tonnes) AS total_tonnes
    FROM harvests h
    JOIN plantings p ON p.planting_id = h.planting_id
    JOIN seasons s ON s.season_id = p.season_id
    JOIN crops c ON c.crop_id = p.crop_id
    GROUP BY s.season_id, s.season_name, c.crop_id, c.crop_name
),
ranked AS (
    SELECT *, DENSE_RANK() OVER
      (PARTITION BY season_name ORDER BY total_tonnes DESC) AS crop_rank
    FROM crop_season_yield
)
SELECT season_name, crop_name, total_tonnes
FROM ranked
WHERE crop_rank = 1
ORDER BY season_name;

-- End of script.
