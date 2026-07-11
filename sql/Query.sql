CREATE TABLE Customers (
    Customer_ID     VARCHAR(10) PRIMARY KEY,
    Age             INT,
    Gender          VARCHAR(10),
    Income          INT,
    City            VARCHAR(20),
    Region          VARCHAR(20),
    Email           VARCHAR(50),
    Phone           VARCHAR(15),
    Signup_Date     DATE,
    Customer_Segment VARCHAR(20)
);

CREATE TABLE Inventory(
	Product_ID varchar(15) primary key ,
    Product_Name varchar(50),
    Category varchar(20),
    Stock int,
    Reorder_level int,
    Warehouse varchar(50),
    Unit_Price DECIMAL(10,2),
    Supplier varchar(50),
    Last_restocked_Date date
    );
    
create table Employees(
	Employee_ID varchar(20) primary key,
    Employee_Name varchar(30),
    Region varchar(50),
    Team varchar(50),
    Sales_Target int,
    Hire_Date date,
    Email varchar(50),
    Performance_Rating Decimal(2,1)
);
    
create table Logistics(
	Shipment_ID varchar(20) primary key,
    Customer_ID     VARCHAR(10),
    Product_ID varchar(15),
    Shipment_Date date,
    Delivery_Days int,
    Carrier varchar(20),
    cost decimal(10,1),
    Status varchar(20),
    Quantity int,
    Discount_Applied decimal(3,1),
    Payment_Mode varchar(20),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Inventory(Product_ID)
    );

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/gagan/OneDrive/Documents/Retail-Analytics-Project/dataset/Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;