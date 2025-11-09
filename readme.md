# 🏪 Stationery Store Management Database Project

This project is a **SQL-based database management system** for a stationery store.  
It includes complete database schema creation, relationships, triggers, sequences, and data population scripts.



## 📋 Project Overview

The **Stationery Store Management System** is designed to manage customers, employees, orders, suppliers, products, and inventory efficiently.  
It ensures data integrity and automates stock management through triggers.


## 🧩 Features

- ✅ **Customer Management** – Store customer details and link them with orders.
- ✅ **Order Processing** – Record customer orders and associated items.
- ✅ **Inventory Management** – Automatically update stock after sales.
- ✅ **Supplier Management** – Maintain supplier contact and address details.
- ✅ **Employee Management** – Manage employee details and transaction responsibilities.
- ✅ **Triggers & Sequences** – Automate data consistency and audit trails.
- ✅ **Role-Based Access Control** – Separate privileges for Admin, Manager, and Salesperson.



## 🗃 Database Objects

### Tables
- `Customer`
- `Order_T`
- `Order_Item`
- `Product`
- `Category`
- `Supplier`
- `Employee`
- `Inventory_Transaction`
- `Product_Price_Audit`

### Sequences
- `SEQ_Transaction_ID`
- `Product_Price_Audit_Seq`

### Triggers
- `update_product_stock`
- `inv_trans_after_order`
- `check_product_stock`
- `set_order_date`
- `audit_product_price_change`

### Roles
- `Admin`
- `Manager`
- `Salesperson`


## ⚙️ Installation

1. Open **Oracle SQL Developer** or any SQL tool.
2. Connect to your database (Oracle 10g+ recommended).
3. Execute the SQL script:  
   
   @Stationary Store Management.sql
Verify tables, triggers, and sequences are created.

📊 Sample Data
The script includes sample data for:

10 Customers

10 Suppliers

10 Employees

20 Products

10 Orders with Order Items

This allows you to test functionality immediately after import.

##👤 Roles & Privileges
Role	Privileges
Admin	Full access to all tables and triggers
Manager	Can view and update inventory, orders, and employees
Salesperson	Can create orders and register new customers

##🧠 Learning Outcomes
Database design and normalization

Use of foreign keys and constraints

Implementation of triggers and audit logs

Managing role-based permissions

Writing maintainable and modular SQL scripts
