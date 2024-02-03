-- COLUMN ENCRYPTION
-- Step 1: Add a Column for Encrypted Email
ALTER TABLE Customer
ADD CustomerEmail_Encrypted VARBINARY(MAX);

-- Step 2: Create Master Key, Certificate, and Symmetric Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Restaurant123';

CREATE CERTIFICATE CustomerEmail_EncryptCert
WITH SUBJECT = 'CustomerEmail Encryption Certificate';

CREATE SYMMETRIC KEY CustomerEmail_EncryptKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CustomerEmail_EncryptCert;

-- Step 3: Open the Symmetric Key for Encryption
OPEN SYMMETRIC KEY CustomerEmail_EncryptKey
DECRYPTION BY CERTIFICATE CustomerEmail_EncryptCert;

-- Step 4: Update Encrypted Column with Encrypted Values
UPDATE Customer
SET CustomerEmail_Encrypted = ENCRYPTBYKEY(KEY_GUID('CustomerEmail_EncryptKey'), CustomerEmail);

-- Step 5: Close the Symmetric Key
CLOSE SYMMETRIC KEY CustomerEmail_EncryptKey;

-- Stored Procedure 1
CREATE PROCEDURE PlaceOrder
(
  @OrderDateTime DATETIME,
  @OrderPrepTime INT,
  @OrderType VARCHAR(50),
  @EmpID INT,
  @CustomerID INT
)
AS
BEGIN
  IF @OrderType NOT IN ('Dine-In', 'Takeout')
  BEGIN
    raiserror('OrderType must be either "Dine-In" or "Takeout"', 16, 1);
  END
  ELSE
  BEGIN
    INSERT INTO [Order] (OrderDateTime, OrderPrepTime, OrderType, EmpID, CustomerID)
    VALUES (@OrderDateTime, @OrderPrepTime, @OrderType, @EmpID, @CustomerID);
  END
END;

EXEC PlaceOrder
@OrderDateTime = '2023-11-16 21:45:00',
@OrderPrepTime = 30,
@OrderType = 'Dine-In',
@EmpID = 2005,
@CustomerID = 1000;

-- Stored Procedure 2
CREATE PROCEDURE ReserveTable
(
  @ReservationDateTime DATETIME,
  @TableNumber INT,
  @GuestCount INT,
  @CustomerID INT
)
AS
BEGIN
  INSERT INTO Reservation (ReservationDateTime, TableNumber, GuestCount, CustomerID)
  VALUES (@ReservationDateTime, @TableNumber, @GuestCount, @CustomerID);
END;

EXEC ReserveTable
  @ReservationDateTime = '2023-11-20 17:00:00.000',
  @TableNumber = 1,
  @GuestCount = 4,
  @CustomerID = 1004

-- Stored Procedure 3
 CREATE PROCEDURE GetFeedbackByOrder(
 @OrderID INT
)
AS
BEGIN
  SELECT
    FeedbackID,
    OrderID,
    CustomerID,
    Comments,
    Ratings
  FROM
    Feedback
  WHERE OrderID = @OrderID;
END;

EXEC GetFeedbackByOrder @OrderID = 1;

-- DML Trigger
CREATE TRIGGER trg_LogProductSupply
ON Product
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ProductSupplyLog (SupplierID, ProductID, QuantitySupplied)
    SELECT
        SupplierID,
        ProductID,
        ProductQuantity
    FROM
        inserted;
END;
select * from Product;

-- COLUMN ENCRYPTION
ALTER TABLE Customer
ADD ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE CustomerEmail_EncryptKey;

CREATE COLUMN CustomerEmail_Encrypted AS VARBINARY(MAX);

UPDATE Customer
SET CustomerEmail_Encrypted = ENCRYPTBYKEY(CustomerEmail, CustomerEmail_EncryptKey);

DROP COLUMN CustomerEmail;

-- NON-CLUSTERED INDEXING 1
CREATE NONCLUSTERED INDEX IX_Customer_Email
ON Customer (CustomerEmail)

-- NON-CLUSTERED INDEXING 2
CREATE NONCLUSTERED INDEX IX_Employee_Designation
ON Employee (EmpDesignation);

-- NON-CLUSTERED INDEXING 3
CREATE NONCLUSTERED INDEX IX_Product_SupplierID
ON Product (SupplierID);

-- NON-CLUSTERED INDEXING 4
CREATE NONCLUSTERED INDEX IX_Product_ProductName
ON Product (ProductName);

-- VIEW 1
CREATE VIEW most_ordered_items AS
    SELECT Top 3
        M.ItemID,
        M.ItemName,
        M.ItemPrice,
        SUM(OL.Quantity) AS TotalQuantitySold
    FROM
        OrderList OL
    JOIN
        Menu M ON OL.ItemID = M.ItemID
    GROUP BY
        M.ItemID, M.ItemName, M.ItemPrice
    ORDER BY
        TotalQuantitySold DESC, M.ItemPrice DESC;

SELECT ItemName from most_ordered_items;

-- VIEW 2
CREATE VIEW restaurant_reviews AS
   SELECT Ratings, count(*) as NumberOfCustomers from feedback
   GROUP BY Ratings;

SELECT * FROM restaurant_reviews;

-- VIEW 3
CREATE VIEW restaurant_rating AS
   SELECT AVG(Ratings) as restaurant_rating from feedback;

SELECT * from restaurant_rating;

-- VIEW 4
CREATE VIEW CustomerAgeGroups AS
    SELECT
        CustomerID,
        CustomerFName,
        CustomerLName,
        CustomerDOB,
        DATEDIFF(YEAR, CustomerDOB, GETDATE()) AS Age,
        CASE
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 15 AND 21 THEN 'Teenagers'
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 22 AND 40 THEN 'Young Adults'
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) BETWEEN 41 AND 60 THEN 'Middle Aged'
            WHEN DATEDIFF(YEAR, CustomerDOB, GETDATE()) > 60 THEN 'Senior Citizens'
            ELSE 'Children'
        END AS AgeGroup
    FROM
        Customer;

SELECT TOP 3
    AgeGroup,
    COUNT(OrderID) AS VisitCount
FROM
    CustomerAgeGroups CAG
JOIN
    [Order] O ON CAG.CustomerID = O.CustomerID
GROUP BY
    AgeGroup
ORDER BY
    VisitCount DESC;

-- VIEW 5
CREATE VIEW employees_hired AS
    SELECT
        MONTH(DateOfJoining) AS HireMonth,
        COUNT(*) AS NumberOfEmployeesHired
    FROM
        Employee
    GROUP BY
        MONTH(DateOfJoining);

SELECT * FROM employees_hired
ORDER BY HireMonth;

-- VIEW 6
CREATE VIEW ProductExpenditureView AS
    SELECT
        p.ProductName,
        sum(psl.QuantitySupplied * p.ProductCostPerUnit) AS ProductExpenditure
    FROM
        ProductSupplyLog psl
    JOIN
        Product p ON psl.ProductID = p.ProductID
    GROUP BY p.ProductName;

SELECT sum(ProductExpenditure) as TotalExpenditureTillDate from ProductExpenditureView;

-- VIEW 7
CREATE VIEW EmployeeExpenditureView
AS
    SELECT
    EmpID,
    DateOfJoining,
    EmpSalary,
    DATEDIFF(MONTH, DateOfJoining, GETDATE())/12.0 AS YearsSinceJoining,
    EmpSalary * DATEDIFF(MONTH, DateOfJoining, GETDATE()) / 12.0 AS TotalExpenditureTillDate
    FROM
    Employee;

SELECT sum(TotalExpenditureTillDate) as TotalExpenditure FROM EmployeeExpenditureView;

-- VIEW 8
CREATE VIEW IncomeView
AS
    SELECT OrderType, SUM(OrderAmount) As TotalIncomeOfType
    FROM [Order]
    GROUP BY OrderType;

SELECT SUM(TotalIncomeOfType) as TotalIncome FROM IncomeView;

-- VIEW 9
CREATE VIEW RevenueView AS
SELECT e.TotalExpenditure + p.TotalExpenditure AS Expenditure, i.TotalIncome
AS Income, i.TotalIncome - e.TotalExpenditure-p.TotalExpenditure AS Revenue
    FROM 
    (SELECT sum(TotalExpenditureTillDate) AS TotalExpenditure FROM EmployeeExpenditureView) e, 
    (SELECT sum(ProductExpenditure) AS TotalExpenditure FROM ProductExpenditureView) p,
    (SELECT SUM(TotalIncomeOfType) AS TotalIncome FROM IncomeView) i;

SELECT * FROM RevenueView

