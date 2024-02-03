-- Database creation
CREATE database RestaurantManagement
USE RestaurantManagement

-- Customer Table Schema
CREATE TABLE Customer(
CustomerID INT IDENTITY(1000,1),
CustomerFName VARCHAR(20) NOT NULL,
CustomerLName VARCHAR(20) NOT NULL,
CustomerContact CHAR(10) NOT NULL,
CustomerDOB DATE NOT NULL,
CustomerEmail VARCHAR(50) NOT NULL,
CONSTRAINT Customer_PK PRIMARY KEY(CustomerID),
CONSTRAINT CHK_CustomerContact CHECK(CustomerContact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT CHK_CustomerEmail  CHECK (CustomerEmail LIKE '%_@__%.__%')
);

-- Employee Table Schema
CREATE TABLE Employee(
EmpID INT IDENTITY(2000,1) PRIMARY KEY,
EmpFName VARCHAR(20) NOT NULL,
EmpLName VARCHAR(20) NOT NULL,
EmpContact CHAR(10) NOT NULL, 
DateOfBirth DATE NOT NULL,
DateOfJoining DATE NOT NULL,
EmpSalary MONEY NOT NULL,
EmpDesignation VARCHAR(20) NOT NULL,
ManagerID INT,
CONSTRAINT CHK_DateOfBirth CHECK (DateOfBirth < GETDATE()),
CONSTRAINT CHK_EmpContact CHECK(EmpContact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT CHK_DateOfJoining CHECK (DateOfJoining <= GETDATE() AND DateOfJoining >=DateOfBirth),
CONSTRAINT CHK_EmpSalary CHECK (EmpSalary > 0),
CONSTRAINT FK_Emp_Emp FOREIGN KEY (ManagerID) REFERENCES Employee (EmpID)
);

-- Supplier Table Schema
CREATE TABLE Supplier (
    SupplierID INT IDENTITY(1, 1) PRIMARY KEY,
    SupplierName VARCHAR(50) NOT NULL,
    SupplierContact CHAR(10) NOT NULL,
    SupplierEmail VARCHAR(50) NOT NULL, 
    CONSTRAINT CHK_SupplierContact CHECK (SupplierContact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT CHK_SupplierEmail CHECK (SupplierEmail LIKE '%_@__%.__%')
);

-- Function to Calculate TotalValue in Product Table
CREATE FUNCTION CalculateTotalValue(@Quantity INT, @Cost DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Quantity * @Cost;
END;

-- Funtion to Calcualte No. of Days left before expiry
CREATE FUNCTION dbo.CalculateDaysUntilExpiry(@ExpiryDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, GETDATE(), @ExpiryDate);
END;

-- Product Table Schema
CREATE TABLE Product
(
  ProductID INT IDENTITY(200, 1) PRIMARY KEY,
  ProductName VARCHAR(255) NOT NULL,
  ProductQuantity INT NOT NULL CHECK (ProductQuantity >= 0),
  UnitOfMeasurements VARCHAR(255) NOT NULL,
  DateOfExpiry DATE,
  ProductCostPerUnit DECIMAL(10,2) NOT NULL CHECK (ProductCostPerUnit >= 0),
  SupplierID INT NOT NULL,
  CONSTRAINT FK_Product_Supplier FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID),
  TotalValue AS dbo.CalculateTotalValue(ProductQuantity, ProductCostPerUnit),
  DaysUntilExpiry AS dbo.CalculateDaysUntilExpiry(DateOfExpiry)
);

-- Function to Calaculate Bill for the OrderID
CREATE FUNCTION CalcualteBill(@orderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Bill DECIMAL(10,2);
    SELECT @Bill = SUM(m.ItemPrice*ol.Quantity) FROM OrderList ol
    JOIN Menu m ON m.ItemID = ol.ItemID
    where OrderID=@orderID
    RETURN @Bill;
END;

-- Order Table Schema
CREATE TABLE [Order] (
    OrderID INT IDENTITY (1, 1),
    OrderDateTime DATETIME NOT NULL,
    OrderPrepTime INT NOT NULL,
    OrderType VARCHAR(50) NOT NULL,
    EmpID INT,
    CustomerID INT,
    CONSTRAINT Order_PK PRIMARY KEY (OrderID),
    CONSTRAINT Order_Emp_FK FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    CONSTRAINT Order_Customer_FK FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT CHK_OrderType CHECK (OrderType IN ('Dine-In', 'Takeout'))
    OrderAmount AS dbo.CalcualteBill(OrderID),
);

-- Menu Table Schema
CREATE TABLE Menu (
    ItemID INT IDENTITY (500, 1),
    ItemName VARCHAR(50) NOT NULL,
    ItemDescription VARCHAR(255) DEFAULT '',
    ItemPrice MONEY NOT NULL CHECK (ItemPrice >= 0),
    ItemCategory VARCHAR(50) NOT NULL,
    CONSTRAINT Menu_PK PRIMARY KEY(ItemID),
    CONSTRAINT CHK_ItemPrice CHECK (ItemPrice >= 0),
    CONSTRAINT CHK_ItemCategory CHECK (ItemCategory in ('MainCourse', 'Dessert', 'Starters', 'Soups', 'Drinks')),
    CONSTRAINT UNQ_ItemName UNIQUE (ItemName)
);

-- ProductMenuRegistry Table Schema
CREATE TABLE ProductMenuRegistry (
    ProductID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT PK_ProductMenuRegistry PRIMARY KEY (ProductID, ItemID),
    CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    CONSTRAINT FK_Menu FOREIGN KEY (ItemID) REFERENCES Menu(ItemID)
);

-- OrderList Table Schema
CREATE TABLE OrderList (
    OrderID INT,
    ItemID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ItemID),
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    FOREIGN KEY (ItemID) REFERENCES Menu(ItemID)
);

-- RestaurantTable Table Schema
CREATE TABLE RestaurantTable (
    TableNumber INT IDENTITY(1, 1),
    TableStatus VARCHAR(50) NOT NULL,
    SeatingCapacity INT NOT NULL,
    CONSTRAINT Table_PK PRIMARY KEY(TableNumber),
    CONSTRAINT CHK_Seating CHECK (SeatingCapacity > 0)
);

-- Reservation Table Schema
CREATE TABLE Reservation (
    ReservationID INT IDENTITY (3000, 1) ,
    ReservationDateTime DATETIME NOT NULL,
    TableNumber INT NOT NULL,
    GuestCount INT NOT NULL,
    CustomerID INT NOT NULL,
    CONSTRAINT Reservation_PK PRIMARY KEY(ReservationID),
    CONSTRAINT Reservation_Table_FK FOREIGN KEY (TableNumber) REFERENCES RestaurantTable(TableNumber),
    CONSTRAINT Reservation_Customer_FK FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Feedback Table Schema
CREATE TABLE Feedback (
    FeedbackID INT,
    OrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    Comments VARCHAR(255),
    Ratings INT NOT NULL,
    CONSTRAINT Feedback_PK PRIMARY KEY(FeedbackID),
    CONSTRAINT Feedback_Order_FK FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT Feedback_Customer_FK FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    CONSTRAINT CHK_Ratings CHECK (Ratings >= 1 AND Ratings <= 5)
);

-- ProductSupplyLog Table Schema for Trigger
CREATE TABLE ProductSupplyLog (
    LogID INT IDENTITY(1, 1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    ProductID INT NOT NULL,
    SupplyDate DATETIME NOT NULL DEFAULT GETDATE(),
    QuantitySupplied INT NOT NULL,
    CONSTRAINT FK_SupplyLog_Supplier FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID),
    CONSTRAINT FK_SupplyLog_Product FOREIGN KEY (ProductID) REFERENCES Product (ProductID)
);















