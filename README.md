# 🌾 Agribusiness Database Management System

**Week 2 Project – Database Design and SQL Implementation**

## Project Information

- **Author:** Sayantani Das
- **Department:** B.Tech CSE
- **Project:** Agribusiness Database Management System
- **Database:** MySQL 8.0+

## 📌 Project Overview

The Agribusiness Database Management System is designed to manage agricultural operations using a relational database.

The project focuses on organizing information about farmers, farms, fields, crops, planting activities, harvest production, expenses, customers, and sales.

The database helps store agricultural information systematically and supports business analysis through SQL queries.

## 🎯 Project Objectives

- Design a relational database for agricultural management.
- Maintain farmer and farm information.
- Track crop planting and harvesting activities.
- Record agricultural expenses.
- Manage customer and sales information.
- Analyze crop production and sales performance.
- Generate useful business insights using SQL queries.

## 🗄️ Database Tables

The project contains 10 relational tables:

| Table Name | Description                       |
| ---------- | --------------------------------- |
| Farmers    | Stores farmer details             |
| Farms      | Stores farm information           |
| Fields     | Stores individual field details   |
| Seasons    | Maintains agricultural seasons    |
| Crops      | Stores crop information           |
| Plantings  | Tracks crop planting activities   |
| Harvests   | Records harvested crop quantities |
| Expenses   | Maintains agricultural expenses   |
| Customers  | Stores customer information       |
| Sales      | Records agricultural sales        |

## 🛠️ Technologies Used

- MySQL 8.0+
- SQL
- Google Colab
- Python
- Jupyter Notebook

## 📊 Key SQL Operations

The project includes SQL operations such as:

- Database and table creation
- Primary key and foreign key constraints
- Data insertion
- INNER JOIN and LEFT JOIN
- Aggregate functions
- GROUP BY and ORDER BY
- Subqueries
- Revenue analysis
- Crop production analysis
- Farm expense analysis
- Customer sales analysis

## 📁 Project Structure

```text
Agribusiness-Database-Management/
│
├── Agribusiness_Week2_Report.docx
├── agribusiness_database.sql
├── Agribusiness_Week2_SQL_Project.ipynb
├── agribusiness_er_diagram.png
└── README.md
```

## 🚀 How to Run the Project

### Step 1: Download the SQL Script

Download `agribusiness_database.sql` from this repository.

### Step 2: Open MySQL

Open MySQL Workbench or another MySQL-compatible environment.

### Step 3: Execute the SQL Script

Run the SQL script to create the database, tables, constraints, sample records, and analytical queries.

### Step 4: Verify the Database

Execute:

```sql
USE agribusiness_db;

SHOW TABLES;
```

### Step 5: Run Analytical Queries

Execute the queries included in the SQL script to analyze agricultural production, expenses, and sales.

### Google Colab

The project also includes a Google Colab notebook for executing the MySQL database workflow.

Open the `.ipynb` notebook in Google Colab and follow its instructions. Upload the SQL script when prompted.

## 📈 Expected Outcomes

The database helps users:

- Understand farm-level agricultural activities.
- Monitor crop production and harvest quantities.
- Compare agricultural expenses.
- Analyze sales and revenue.
- Organize customer and farmer records.
- Support better agribusiness decision-making.

## 📝 Dataset Information

This project uses synthetic sample data created for academic and demonstration purposes. It represents example farmers, farms, crops, harvests, expenses, customers, and sales records.

The dataset is not an official government agricultural dataset.

## 🔮 Future Scope

- Develop a web-based farm management application.
- Integrate real-time agricultural market prices.
- Add crop yield prediction using machine learning.
- Build interactive dashboards using Power BI.
- Integrate weather and soil information.
- Support larger agricultural datasets.

## 👩‍💻 Author

**Rounak Mazumder**
B.Tech CSE

---

*Agribusiness Database Management System – Week 2 Academic Project.*
