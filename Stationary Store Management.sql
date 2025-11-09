DROP TABLE "PRODUCT_PRICE_AUDIT";
DROP TABLE "INVENTORY_TRANSACTION";
DROP TABLE "EMPLOYEE";
DROP TABLE "ORDER_ITEM";
DROP TABLE "ORDER_T";
DROP TABLE "CUSTOMER";
DROP TABLE "PRODUCT";
DROP TABLE "SUPPLIER";
DROP TABLE "CATEGORY";

-- Create CUSTOMER Table
CREATE TABLE Customer (
    Customer_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(15),
    Address VARCHAR2(100) NOT NULL
);

-- Create Order_T Table
CREATE TABLE Order_T (
    Order_ID NUMBER PRIMARY KEY,
    Order_Date DATE NOT NULL,
    Customer_ID NUMBER NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Create SUPPLIER Table
CREATE TABLE Supplier (
    Supplier_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(15) NOT NULL,
    Email VARCHAR2(70),
    Address VARCHAR2(100),
    City VARCHAR2(50),
    State VARCHAR2(50),
    Postal_Code VARCHAR2(10)
);

-- Create CATEGORY Table
CREATE TABLE Category (
    Category_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL
);

-- Create PRODUCT Table
CREATE TABLE Product (
    Product_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Unit_Price NUMBER(10, 2) NOT NULL,
    Stock_Quantity NUMBER NOT NULL,
    Category_ID NUMBER NOT NULL,
    Supplier_ID NUMBER NOT NULL,
    FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID),
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID)
);

-- Create ORDER_ITEM Table
CREATE TABLE Order_Item (
    Order_ID NUMBER NOT NULL,
    Product_ID NUMBER NOT NULL,
    Quantity NUMBER NOT NULL,
    PRIMARY KEY (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Order_T(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Create EMPLOYEE Table
CREATE TABLE Employee (
    Employee_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50) NOT NULL,
    Phone VARCHAR2(15) NOT NULL,
    Email VARCHAR2(50),
    Address VARCHAR2(100),
    City VARCHAR2(50),
    Hire_Date DATE NOT NULL,
    Salary NUMBER(10, 2) NOT NULL
);

-- Create INVENTORY_TRANSACTION Table
CREATE TABLE Inventory_Transaction (
    Transaction_ID NUMBER PRIMARY KEY,
    Quantity NUMBER NOT NULL,
    Transaction_Date DATE NOT NULL,
    Transaction_Type VARCHAR2(50) NOT NULL,
    Employee_ID NUMBER NOT NULL,
    Product_ID NUMBER NOT NULL,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Create Product_Price_Audit
CREATE TABLE Product_Price_Audit (
    Audit_ID NUMBER PRIMARY KEY,
    Product_ID NUMBER,        
    Old_Price NUMBER(10, 2),
    New_Price NUMBER(10, 2),
    Change_Date DATE DEFAULT SYSDATE,
    Changed_By VARCHAR2(50),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

CREATE SEQUENCE Product_Price_Audit_Seq START WITH 1 INCREMENT BY 1;


CREATE OR REPLACE TRIGGER update_product_stock
AFTER INSERT ON Order_Item
FOR EACH ROW
BEGIN
  UPDATE Product
  SET Stock_Quantity = Stock_Quantity - :NEW.Quantity
  WHERE Product_ID = :NEW.Product_ID;
END;
/

CREATE SEQUENCE SEQ_Transaction_ID
START WITH 611
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER inv_trans_after_order
AFTER INSERT ON Order_Item
FOR EACH ROW
BEGIN
  -- Sale transaction
  INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
  VALUES (SEQ_Transaction_ID.NEXTVAL, :NEW.Quantity, SYSDATE, 'Sale', 501, :NEW.Product_ID);
END;
/

CREATE OR REPLACE TRIGGER check_product_stock
BEFORE INSERT ON Order_Item
FOR EACH ROW
DECLARE
  available_stock INT;
BEGIN
  -- Get current stock for the product
  SELECT Stock_Quantity INTO available_stock FROM Product WHERE Product_ID = :NEW.Product_ID;

  -- Check if sufficient stock is available
  IF available_stock < :NEW.Quantity THEN
    RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for product ID ' || :NEW.Product_ID);
  END IF;
END;
/

CREATE OR REPLACE TRIGGER set_order_date
BEFORE INSERT ON Order_T
FOR EACH ROW
BEGIN
  -- Set the order date to current system date if not provided
  IF :NEW.Order_Date IS NULL THEN
    :NEW.Order_Date := SYSDATE;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER audit_product_price_change
AFTER UPDATE OF Unit_Price ON Product
FOR EACH ROW
BEGIN
    INSERT INTO Product_Price_Audit (Audit_ID,Product_ID,Old_Price,New_Price,Change_Date) 
    VALUES (Product_Price_Audit_Seq.NEXTVAL,:OLD.Product_ID,:OLD.Unit_Price,:NEW.Unit_Price,SYSDATE);
END;
/

--Create the Admin role
CREATE ROLE Admin;

--Create the Salesperson role
CREATE ROLE Salesperson;

--Create the Manager role
CREATE ROLE Manager;

--Grant full privileges to Admin
GRANT CREATE SESSION TO Admin;  
GRANT CREATE TABLE TO Admin;  
GRANT CREATE VIEW TO Admin;  
GRANT CREATE PROCEDURE TO Admin;  
GRANT CREATE TRIGGER TO Admin;  
GRANT CREATE SEQUENCE TO Admin;  
GRANT ALTER ANY TABLE TO Admin;  
GRANT DROP ANY TABLE TO Admin;  
GRANT SELECT ANY TABLE TO Admin;  
GRANT INSERT ANY TABLE TO Admin;  
GRANT UPDATE ANY TABLE TO Admin;  
GRANT DELETE ANY TABLE TO Admin;  
GRANT EXECUTE ANY PROCEDURE TO Admin;  
GRANT ALL ON Product TO Admin;  
GRANT ALL ON ORDER_T TO Admin;  
GRANT ALL ON Order_Item TO Admin;  
GRANT ALL ON Inventory_Transaction TO Admin;  
GRANT ALL ON Customer TO Admin;  
GRANT ALL ON Category TO Admin;  
GRANT ALL ON Supplier TO Admin;  
GRANT ALL ON Employee TO Admin;  
GRANT ALL ON Product_Price_Audit TO Admin;

--Grant privileges to MANAGER
GRANT CREATE SESSION TO Manager;
GRANT SELECT, INSERT, UPDATE ON Product TO Manager;
GRANT SELECT, INSERT, UPDATE ON ORDER_T TO Manager;
GRANT SELECT, INSERT, UPDATE ON Order_Item TO Manager;
GRANT SELECT, INSERT, UPDATE ON Customer TO Manager;
GRANT SELECT, INSERT, UPDATE ON Inventory_Transaction TO Manager;
GRANT SELECT, INSERT, UPDATE ON Employee TO Manager;

--Grant privileges to Salesperson
GRANT CREATE SESSION TO Salesperson;
GRANT SELECT, INSERT, UPDATE ON Product TO Salesperson;
GRANT SELECT, INSERT, UPDATE ON Order_T TO Salesperson;
GRANT SELECT, INSERT, UPDATE ON Order_Item TO Salesperson;
GRANT INSERT ON Customer TO Salesperson;




-- Insert data into Customer Table
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (11, 'Ahmed Khan', '03011234567', '123 Main Road, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (12, 'Ayesha Tariq', '03019876543', '456 Canal View, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (13, 'Zain Ali', '03214567890', '789 Shahrah-e-Faisal, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (14, 'Fatima Bibi', '03321231234', 'House 32, Gulberg, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (15, 'Ali Raza', '03005554433', '10 Civic Center, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (16, 'Rabia Anwar', '03455566778', 'Plot 4, Blue Area, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (17, 'Usman Tariq', '03007778899', '17 Clifton Block, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (18, 'Sara Malik', '03338885566', 'Street 9, Satellite Town, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (19, 'Hamza Sheikh', '03119992222', 'Garden Town, Lahore');
INSERT INTO Customer (Customer_ID, Name, Phone, Address)
VALUES (20, 'Hiba Ahmed', '03018889944', 'Phase 4, DHA, Lahore');

-- Insert data into Order_T Table
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (101, TO_DATE('2024-12-01', 'YYYY-MM-DD'), 11);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (102, TO_DATE('2024-12-02', 'YYYY-MM-DD'), 12);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (103, TO_DATE('2024-12-03', 'YYYY-MM-DD'), 13);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (104, TO_DATE('2024-12-04', 'YYYY-MM-DD'), 14);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (105, TO_DATE('2024-12-05', 'YYYY-MM-DD'), 15);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (106, TO_DATE('2024-12-06', 'YYYY-MM-DD'), 16);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (107, TO_DATE('2024-12-07', 'YYYY-MM-DD'), 17);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (108, TO_DATE('2024-12-08', 'YYYY-MM-DD'), 18);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (109, TO_DATE('2024-12-09', 'YYYY-MM-DD'), 19);
INSERT INTO Order_T (Order_ID, Order_Date, Customer_ID)
VALUES (110, TO_DATE('2024-12-10', 'YYYY-MM-DD'), 20);


-- Insert data into Supplier Table
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (201, 'Bilal Hassan', '03034445566', 'bilal.hassan@gmail.com', 'Block B, Model Town', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (202, 'Sana Khan', '03225556677', 'sana.khan@hotmail.com', 'Street 12, F-10', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (203, 'Farhan Malik', '03114442233', 'farhan.malik@yahoo.com', 'Phase 2, Gulshan-e-Iqbal', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (204, 'Aqsa Ahmed', '03442223344', 'aqsa.ahmed@gmail.com', 'Sector G-8', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (205, 'Shahzad Ali', '03011112233', 'shahzad.ali@gmail.com', 'Jinnah Colony', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (206, 'Zara Sheikh', '03339998877', 'zara.sheikh@gmail.com', 'Clifton Block 5', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (207, 'Omar Siddiqui', '03156667788', 'omar.siddiqui@yahoo.com', 'Satellite Town', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (208, 'Nadia Jamil', '03227776655', 'nadia.jamil@gmail.com', 'Block A, DHA', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (209, 'Hamid Raza', '03027778888', 'hamid.raza@hotmail.com', 'I.I. Chundrigar Road', 'Lahore', 'Punjab', '54000');
INSERT INTO Supplier (Supplier_ID, Name, Phone, Email, Address, City, State, Postal_Code)
VALUES (210, 'Mariam Anwar', '03443332211', 'mariam.anwar@gmail.com', 'Gulberg Greens', 'Lahore', 'Punjab', '54000');

-- Insert data into Category Table
INSERT INTO Category (Category_ID, Name)
VALUES (301, 'Stationery');
INSERT INTO Category (Category_ID, Name)
VALUES (302, 'Office Supplies');
INSERT INTO Category (Category_ID, Name)
VALUES (303, 'Art Supplies');
INSERT INTO Category (Category_ID, Name)
VALUES (304, 'School Supplies');
INSERT INTO Category (Category_ID, Name)
VALUES (305, 'Notebooks');
INSERT INTO Category (Category_ID, Name)
VALUES (306, 'Pens');
INSERT INTO Category (Category_ID, Name)
VALUES (307, 'Markers');
INSERT INTO Category (Category_ID, Name)
VALUES (308, 'Paper Products');
INSERT INTO Category (Category_ID, Name)
VALUES (309, 'Adhesives');
INSERT INTO Category (Category_ID, Name)
VALUES (310, 'Erasers');

-- Insert data into Product Table
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (401, 'Ballpoint Pen', 20.00, 200, 306, 201);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (402, 'Notebook', 100.00, 150, 305, 202);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (403, 'Permanent Marker', 50.00, 300, 307, 203);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (404, 'Glue Stick', 60.00, 100, 309, 204);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (405, 'Sketchbook', 200.00, 50, 303, 205);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (406, 'Ruler', 40.00, 120, 304, 206);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (407, 'Sharpener', 30.00, 180, 304, 207);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (408, 'Eraser', 10.00, 250, 310, 208);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (409, 'Sticky Notes', 80.00, 90, 308, 209);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (410, 'Highlighter', 35.00, 300, 307, 210);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (411, 'Binder Clips', 25.00, 200, 302, 201);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (412, 'Fountain Pen', 300.00, 100, 306, 202);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (413, 'Drawing Pencil Set', 120.00, 50, 303, 203);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (414, 'Paper Ream', 500.00, 30, 308, 204);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (415, 'Correction Tape', 70.00, 150, 309, 205);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (416, 'Colored Markers Pack', 400.00, 20, 307, 206);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (417, 'Compass', 150.00, 75, 304, 207);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (418, 'Plastic File Folder', 50.00, 120, 302, 208);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (419, 'Whiteboard', 800.00, 10, 308, 209);
INSERT INTO Product (Product_ID, Name, Unit_Price, Stock_Quantity, Category_ID, Supplier_ID)
VALUES (420, 'Poster Paint Set', 600.00, 25, 303, 210);

-- Insert data into Employee Table
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (501, 'Imran Sheikh', '03012345678', 'imran.sheikh@store.com', 'Street 45, DHA', 'Lahore', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 45000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (502, 'Ayesha Siddiq', '03123456789', 'ayesha.siddiq@store.com', 'Block C, Model Town', 'Lahore', TO_DATE('2019-06-12', 'YYYY-MM-DD'), 50000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (503, 'Ali Raza', '03214567890', 'ali.raza@store.com', 'Street 10, Gulberg', 'Lahore', TO_DATE('2021-03-22', 'YYYY-MM-DD'), 47000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (504, 'Fatima Khan', '03312345678', 'fatima.khan@store.com', 'Sector F, Johar Town', 'Lahore', TO_DATE('2022-11-01', 'YYYY-MM-DD'), 43000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (505, 'Usman Tariq', '03456789012', 'usman.tariq@store.com', 'Street 3, Wapda Town', 'Lahore', TO_DATE('2018-08-05', 'YYYY-MM-DD'), 48000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (506, 'Sara Ahmed', '03567890123', 'sara.ahmed@store.com', 'Street 2, Faisal Town', 'Lahore', TO_DATE('2023-05-17', 'YYYY-MM-DD'), 42000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (507, 'Hamza Malik', '03678901234', 'hamza.malik@store.com', 'Block A, Township', 'Lahore', TO_DATE('2020-09-10', 'YYYY-MM-DD'), 46000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (508, 'Nida Anwar', '03789012345', 'nida.anwar@store.com', 'Street 8, Cantt', 'Lahore', TO_DATE('2021-07-03', 'YYYY-MM-DD'), 49000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (509, 'Zain Tariq', '03890123456', 'zain.tariq@store.com', 'Street 6, Valencia Town', 'Lahore', TO_DATE('2022-01-25', 'YYYY-MM-DD'), 44000);
INSERT INTO Employee (Employee_ID, Name, Phone, Email, Address, City, Hire_Date, Salary)
VALUES (510, 'Hiba Sheikh', '03901234567', 'hiba.sheikh@store.com', 'Street 9, Phase 6 DHA', 'Lahore', TO_DATE('2019-04-18', 'YYYY-MM-DD'), 51000);

-- Insert data into Order_Item Table
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (101, 401, 5);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (102, 402, 3);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (103, 403, 10);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (104, 404, 2);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (105, 405, 1);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (106, 406, 4);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (107, 407, 8);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (108, 401, 6);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (109, 402, 2);
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity)
VALUES (110, 403, 9);

-- Insert data into Inventory_Transaction Table
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (601, 50, TO_DATE('2024-11-30', 'YYYY-MM-DD'), 'Restock', 501, 401);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (602, 30, TO_DATE('2024-12-01', 'YYYY-MM-DD'), 'Restock', 502, 402);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (603, 40, TO_DATE('2024-12-02', 'YYYY-MM-DD'), 'Sale', 503, 403);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (604, 10, TO_DATE('2024-12-03', 'YYYY-MM-DD'), 'Sale', 504, 404);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (605, 20, TO_DATE('2024-12-04', 'YYYY-MM-DD'), 'Restock', 505, 405);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (606, 15, TO_DATE('2024-12-05', 'YYYY-MM-DD'), 'Sale', 506, 406);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (607, 25, TO_DATE('2024-12-06', 'YYYY-MM-DD'), 'Restock', 507, 407);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (608, 10, TO_DATE('2024-12-07', 'YYYY-MM-DD'), 'Sale', 508, 401);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (609, 20, TO_DATE('2024-12-08', 'YYYY-MM-DD'), 'Restock', 509, 402);
INSERT INTO Inventory_Transaction (Transaction_ID, Quantity, Transaction_Date, Transaction_Type, Employee_ID, Product_ID)
VALUES (610, 5, TO_DATE('2024-12-09', 'YYYY-MM-DD'), 'Sale', 510, 403);
