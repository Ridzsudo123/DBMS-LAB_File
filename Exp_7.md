# Experiment 7 – Normalization of a Sales Database from UNF to BCNF

## Aim

To identify functional dependencies in a denormalized Sales table and normalize it step-by-step from **Unnormalized Form (UNF) to 1NF, 2NF, 3NF, and BCNF**. To implement the normalized schema using SQL and verify lossless join and dependency preservation.

## Software / Tools Required

- MySQL 8.0 or compatible SQL database
- MySQL Workbench, phpMyAdmin, or MySQL command-line client
- Text editor and GitHub Markdown

---

## 1. Theory

### 1.1 Database Normalization

Normalization organizes data into well-structured relations to reduce redundancy and prevent insertion, update, and deletion anomalies. It uses functional dependencies and keys to determine how a relation should be decomposed.

### 1.2 Anomalies

| Anomaly | Meaning | Example |
|---|---|---|
| Insertion | A fact cannot be inserted without unrelated data | A product cannot be recorded until it appears in an order |
| Update | The same fact must be changed in several rows | Changing a customer's city requires changing every sales row for that customer |
| Deletion | Deleting one fact accidentally removes another | Deleting the only sale of a product also removes its stored details |

### 1.3 Functional Dependency

A functional dependency **X → Y** means each value of attribute set X determines exactly one value of attribute set Y.

Functional dependencies assumed in this experiment:

- `OrderID → OrderDate, CustomerID, SalespersonID`
- `CustomerID → CustomerName, CustomerCity`
- `SalespersonID → SalespersonName`
- `ProductID → ProductName, CategoryID`
- `CategoryID → CategoryName`
- `(OrderID, ProductID) → Quantity, UnitPrice`

The left-hand side is called the **determinant**.

### 1.4 Keys

| Key | Definition | Example |
|---|---|---|
| Super key | Any attribute set that uniquely identifies a row | `(OrderID, ProductID, OrderDate)` |
| Candidate key | A minimal super key | `(OrderID, ProductID)` |
| Primary key | Candidate key selected to identify rows | `(OrderID, ProductID)` in ORDER_ITEMS |
| Foreign key | Attribute(s) referring to a key in another table | `CustomerID` in ORDERS |
| Composite key | Key consisting of multiple attributes | `(OrderID, ProductID)` |

For this experiment, assume each product appears at most once per order. Thus `(OrderID, ProductID)` identifies an order line. `UnitPrice` is the price at the time of sale and may change between orders.

### 1.5 Normal Forms

| Normal Form | Requirement |
|---|---|
| **UNF** | Data may contain repeating groups or non-atomic lists |
| **1NF** | Every attribute contains one atomic value; no repeating groups |
| **2NF** | In 1NF, and every non-prime attribute depends on the whole candidate key, not just part of it |
| **3NF** | For every non-trivial FD X → A, X is a super key or A is a prime attribute |
| **BCNF** | For every non-trivial FD X → Y, X must be a super key |

BCNF is stricter than 3NF. A relation in BCNF is also in 3NF.

### 1.6 Lossless Join

A decomposition is **lossless** when joining its decomposed relations reconstructs exactly the original relation without losing rows or creating spurious rows. A useful sufficient condition for a binary decomposition R into R1 and R2 is that the common attributes functionally determine all attributes of at least one component.

### 1.7 Dependency Preservation

A decomposition is **dependency-preserving** when the original functional dependencies can be enforced by checking the decomposed relations individually, without joining all the relations together.

---

## 2. Problem Statement

A company stores sales information in one denormalized relation:

`SALES(OrderID, OrderDate, CustomerID, CustomerName, CustomerCity, SalespersonID, SalespersonName, ProductID, ProductName, CategoryID, CategoryName, Quantity, UnitPrice)`

### Sample Data

| OrderID | OrderDate | CustomerID | CustomerName | CustomerCity | SalespersonID | SalespersonName | ProductID | ProductName | CategoryID | CategoryName | Quantity | UnitPrice |
|---:|---|---|---|---|---|---|---|---|---|---|---:|---:|
| 101 | 2026-01-10 | C01 | Aanya Sharma | Delhi | SP01 | Rohan Mehta | P01 | Keyboard | CAT1 | Accessories | 2 | 800.00 |
| 101 | 2026-01-10 | C01 | Aanya Sharma | Delhi | SP01 | Rohan Mehta | P02 | Mouse | CAT1 | Accessories | 1 | 500.00 |
| 102 | 2026-01-11 | C02 | Kabir Singh | Jaipur | SP02 | Neha Verma | P03 | Monitor | CAT2 | Displays | 1 | 7500.00 |
| 103 | 2026-01-12 | C01 | Aanya Sharma | Delhi | SP01 | Rohan Mehta | P03 | Monitor | CAT2 | Displays | 2 | 7500.00 |

In UNF, an order may contain a repeating list of products in one field/group. The sample above expands that group into one row per order-product pair, producing atomic values for 1NF.

---

## 3. Functional Dependencies Identified

| No. | Functional Dependency | Explanation |
|---:|---|---|
| 1 | `OrderID → OrderDate, CustomerID, SalespersonID` | Each order has one date, customer, and salesperson |
| 2 | `CustomerID → CustomerName, CustomerCity` | Customer ID determines customer details |
| 3 | `SalespersonID → SalespersonName` | Salesperson ID determines salesperson name |
| 4 | `ProductID → ProductName, CategoryID` | Product ID determines product name and category |
| 5 | `CategoryID → CategoryName` | Category ID determines category name |
| 6 | `(OrderID, ProductID) → Quantity, UnitPrice` | Each order line stores quantity and sale-time price |

**Candidate key:** `(OrderID, ProductID)`.

---

## 4. Normalization Procedure

### 4.1 Unnormalized Form (UNF)

A business record might store products as a repeating group:

| OrderID | CustomerID | Products |
|---:|---|---|
| 101 | C01 | P01 – Keyboard, Qty 2, ₹800; P02 – Mouse, Qty 1, ₹500 |
| 102 | C02 | P03 – Monitor, Qty 1, ₹7,500 |

**Problem:** The Products field contains multiple values, making searching and updating individual product lines difficult.

### 4.2 First Normal Form (1NF)

Expand each product in the repeating group into a separate row and ensure every value is atomic.

`SALES_1NF(OrderID, OrderDate, CustomerID, CustomerName, CustomerCity, SalespersonID, SalespersonName, ProductID, ProductName, CategoryID, CategoryName, Quantity, UnitPrice)`

Candidate key: `(OrderID, ProductID)`.

**Result:** Repeating groups are removed, but customer, order, product, salesperson, and category details are still repeated.

### 4.3 Second Normal Form (2NF)

2NF requires 1NF and no partial dependency of a non-prime attribute on part of a candidate key.

The composite key is `(OrderID, ProductID)`, but:

- `OrderID → OrderDate, CustomerID, CustomerName, CustomerCity, SalespersonID, SalespersonName`
- `ProductID → ProductName, CategoryID, CategoryName`

These are partial dependencies. Decompose into:

1. `ORDERS_2NF(OrderID, OrderDate, CustomerID, CustomerName, CustomerCity, SalespersonID, SalespersonName)`
2. `PRODUCTS_2NF(ProductID, ProductName, CategoryID, CategoryName)`
3. `ORDER_ITEMS(OrderID, ProductID, Quantity, UnitPrice)`

Transitive dependencies remain in the first two relations: customer details depend on CustomerID, salesperson name on SalespersonID, and category name on CategoryID.

### 4.4 Third Normal Form (3NF)

Remove the transitive dependencies by decomposing into:

| Relation | Attributes | Primary Key |
|---|---|---|
| **CUSTOMERS** | CustomerID, CustomerName, CustomerCity | CustomerID |
| **SALESPERSONS** | SalespersonID, SalespersonName | SalespersonID |
| **CATEGORIES** | CategoryID, CategoryName | CategoryID |
| **PRODUCTS** | ProductID, ProductName, CategoryID | ProductID |
| **ORDERS** | OrderID, OrderDate, CustomerID, SalespersonID | OrderID |
| **ORDER_ITEMS** | OrderID, ProductID, Quantity, UnitPrice | (OrderID, ProductID) |

The foreign keys connect the relations, and customer, salesperson, and category facts are stored once.

### 4.5 Boyce–Codd Normal Form (BCNF)

BCNF requires every determinant in every non-trivial functional dependency to be a super key.

| Relation | Dependency | Determinant is a super key? |
|---|---|---|
| CUSTOMERS | `CustomerID → CustomerName, CustomerCity` | Yes |
| SALESPERSONS | `SalespersonID → SalespersonName` | Yes |
| CATEGORIES | `CategoryID → CategoryName` | Yes |
| PRODUCTS | `ProductID → ProductName, CategoryID` | Yes |
| ORDERS | `OrderID → OrderDate, CustomerID, SalespersonID` | Yes |
| ORDER_ITEMS | `(OrderID, ProductID) → Quantity, UnitPrice` | Yes |

Under the stated business rules, every relation in the 3NF decomposition is already in BCNF. No further decomposition is required.

---

## 5. Final Relational Schema

```text
CUSTOMERS(
    CustomerID PK,
    CustomerName,
    CustomerCity
)

SALESPERSONS(
    SalespersonID PK,
    SalespersonName
)

CATEGORIES(
    CategoryID PK,
    CategoryName
)

PRODUCTS(
    ProductID PK,
    ProductName,
    CategoryID FK -> CATEGORIES.CategoryID
)

ORDERS(
    OrderID PK,
    OrderDate,
    CustomerID FK -> CUSTOMERS.CustomerID,
    SalespersonID FK -> SALESPERSONS.SalespersonID
)

ORDER_ITEMS(
    OrderID PK, FK -> ORDERS.OrderID,
    ProductID PK, FK -> PRODUCTS.ProductID,
    Quantity,
    UnitPrice
)
```

---

## 6. SQL Implementation (MySQL 8.0)

Run these statements in order in a test database. The script creates the denormalized source, inserts sample data, creates normalized tables, and copies the data.

### 6.1 Create and Populate the Original Sales Table

```sql
CREATE DATABASE IF NOT EXISTS SalesNormalization;
USE SalesNormalization;

DROP VIEW IF EXISTS ReconstructedSales;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS PRODUCTS;
DROP TABLE IF EXISTS CATEGORIES;
DROP TABLE IF EXISTS SALESPERSONS;
DROP TABLE IF EXISTS CUSTOMERS;
DROP TABLE IF EXISTS SALES_RAW;

CREATE TABLE SALES_RAW (
    OrderID INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60) NOT NULL,
    SalespersonID VARCHAR(10) NOT NULL,
    SalespersonName VARCHAR(100) NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID VARCHAR(10) NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO SALES_RAW VALUES
(101, '2026-01-10', 'C01', 'Aanya Sharma', 'Delhi',
 'SP01', 'Rohan Mehta', 'P01', 'Keyboard', 'CAT1', 'Accessories', 2, 800.00),
(101, '2026-01-10', 'C01', 'Aanya Sharma', 'Delhi',
 'SP01', 'Rohan Mehta', 'P02', 'Mouse', 'CAT1', 'Accessories', 1, 500.00),
(102, '2026-01-11', 'C02', 'Kabir Singh', 'Jaipur',
 'SP02', 'Neha Verma', 'P03', 'Monitor', 'CAT2', 'Displays', 1, 7500.00),
(103, '2026-01-12', 'C01', 'Aanya Sharma', 'Delhi',
 'SP01', 'Rohan Mehta', 'P03', 'Monitor', 'CAT2', 'Displays', 2, 7500.00);

SELECT * FROM SALES_RAW;
```

### 6.2 Create the Normalized Tables

```sql
CREATE TABLE CUSTOMERS (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerCity VARCHAR(60) NOT NULL
);

CREATE TABLE SALESPERSONS (
    SalespersonID VARCHAR(10) PRIMARY KEY,
    SalespersonName VARCHAR(100) NOT NULL
);

CREATE TABLE CATEGORIES (
    CategoryID VARCHAR(10) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE PRODUCTS (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID VARCHAR(10) NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORIES(CategoryID)
);

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    SalespersonID VARCHAR(10) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (SalespersonID) REFERENCES SALESPERSONS(SalespersonID)
);

CREATE TABLE ORDER_ITEMS (
    OrderID INT NOT NULL,
    ProductID VARCHAR(10) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);
```

### 6.3 Insert Data into the Normalized Tables

```sql
INSERT INTO CUSTOMERS
SELECT DISTINCT CustomerID, CustomerName, CustomerCity
FROM SALES_RAW;

INSERT INTO SALESPERSONS
SELECT DISTINCT SalespersonID, SalespersonName
FROM SALES_RAW;

INSERT INTO CATEGORIES
SELECT DISTINCT CategoryID, CategoryName
FROM SALES_RAW;

INSERT INTO PRODUCTS
SELECT DISTINCT ProductID, ProductName, CategoryID
FROM SALES_RAW;

INSERT INTO ORDERS
SELECT DISTINCT OrderID, OrderDate, CustomerID, SalespersonID
FROM SALES_RAW;

INSERT INTO ORDER_ITEMS
SELECT OrderID, ProductID, Quantity, UnitPrice
FROM SALES_RAW;
```

---

## 7. Verify the Normalized Data

### 7.1 Display the Tables

```sql
SELECT * FROM CUSTOMERS;
SELECT * FROM SALESPERSONS;
SELECT * FROM CATEGORIES;
SELECT * FROM PRODUCTS;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEMS;
```

### 7.2 Reconstruct the Sales Relation with JOINs

```sql
CREATE VIEW ReconstructedSales AS
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.CustomerName,
    c.CustomerCity,
    s.SalespersonID,
    s.SalespersonName,
    p.ProductID,
    p.ProductName,
    cat.CategoryID,
    cat.CategoryName,
    oi.Quantity,
    oi.UnitPrice
FROM ORDERS o
JOIN CUSTOMERS c ON o.CustomerID = c.CustomerID
JOIN SALESPERSONS s ON o.SalespersonID = s.SalespersonID
JOIN ORDER_ITEMS oi ON o.OrderID = oi.OrderID
JOIN PRODUCTS p ON oi.ProductID = p.ProductID
JOIN CATEGORIES cat ON p.CategoryID = cat.CategoryID;

SELECT * FROM ReconstructedSales
ORDER BY OrderID, ProductID;
```

The reconstructed relation should contain the same four rows as SALES_RAW.

---

## 8. Lossless Join Verification

### 8.1 Source Rows Missing from the Reconstructed Relation

```sql
SELECT r.*
FROM SALES_RAW r
LEFT JOIN ReconstructedSales n
  ON n.OrderID = r.OrderID
 AND n.ProductID = r.ProductID
WHERE n.OrderID IS NULL;
```

**Expected result:** zero rows.

### 8.2 Reconstructed Rows Missing from the Source

```sql
SELECT n.*
FROM ReconstructedSales n
LEFT JOIN SALES_RAW r
  ON r.OrderID = n.OrderID
 AND r.ProductID = n.ProductID
WHERE r.OrderID IS NULL;
```

**Expected result:** zero rows.

### 8.3 Compare Row Counts

```sql
SELECT 'SALES_RAW' AS RelationName, COUNT(*) AS RowCount
FROM SALES_RAW
UNION ALL
SELECT 'ReconstructedSales', COUNT(*)
FROM ReconstructedSales;
```

**Expected result:** both counts are 4.

These queries test reconstruction on the sample data. The decomposition is designed to be lossless because the entity relations are joined through their keys, while ORDER_ITEMS retains the original composite key and line-level attributes.

---

## 9. Dependency Preservation Verification

The following queries search the source sample for violations of the functional dependencies. A dependency is violated if one determinant value maps to more than one distinct dependent value.

### 9.1 Order Dependency

```sql
SELECT OrderID
FROM SALES_RAW
GROUP BY OrderID
HAVING COUNT(DISTINCT OrderDate) > 1
    OR COUNT(DISTINCT CustomerID) > 1
    OR COUNT(DISTINCT SalespersonID) > 1;
```

Expected: zero rows.

### 9.2 Customer Dependency

```sql
SELECT CustomerID
FROM SALES_RAW
GROUP BY CustomerID
HAVING COUNT(DISTINCT CustomerName) > 1
    OR COUNT(DISTINCT CustomerCity) > 1;
```

Expected: zero rows.

### 9.3 Salesperson Dependency

```sql
SELECT SalespersonID
FROM SALES_RAW
GROUP BY SalespersonID
HAVING COUNT(DISTINCT SalespersonName) > 1;
```

Expected: zero rows.

### 9.4 Product Dependency

```sql
SELECT ProductID
FROM SALES_RAW
GROUP BY ProductID
HAVING COUNT(DISTINCT ProductName) > 1
    OR COUNT(DISTINCT CategoryID) > 1;
```

Expected: zero rows.

### 9.5 Category Dependency

```sql
SELECT CategoryID
FROM SALES_RAW
GROUP BY CategoryID
HAVING COUNT(DISTINCT CategoryName) > 1;
```

Expected: zero rows.

### 9.6 Order Line Dependency

```sql
SELECT OrderID, ProductID
FROM SALES_RAW
GROUP BY OrderID, ProductID
HAVING COUNT(DISTINCT Quantity) > 1
    OR COUNT(DISTINCT UnitPrice) > 1;
```

Expected: zero rows.

The dependencies are preserved in the final schema because each dependency can be checked within one relation: order attributes in ORDERS, customer attributes in CUSTOMERS, salesperson attributes in SALESPERSONS, product attributes in PRODUCTS, category attributes in CATEGORIES, and order-line attributes in ORDER_ITEMS. Primary keys enforce the determinants, while foreign keys enforce referential integrity.

**Important:** These queries check the sample data for violations; they do not prove a functional dependency for every possible future database state. The schema constraints and stated business rules provide the design-level justification.

---

## 10. Summary of Normalization

| Stage | Main action | Outcome |
|---|---|---|
| UNF | Identify repeating product groups | Repeating groups and redundancy exist |
| 1NF | Store one product per row with atomic values | Repeating groups removed |
| 2NF | Separate order-level and product-level facts from order-line facts | Partial dependencies removed |
| 3NF | Separate customers, salespersons, and categories into their own relations | Transitive dependencies removed |
| BCNF | Check every determinant in each final relation | Every determinant is a super key; no further decomposition needed |

## Result

The denormalized Sales relation was analyzed using functional dependencies and normalized step-by-step from **UNF to 1NF, 2NF, 3NF, and BCNF**. The final schema consists of **CUSTOMERS, SALESPERSONS, CATEGORIES, PRODUCTS, ORDERS, and ORDER_ITEMS**.

SQL tables, primary keys, foreign keys, and sample data were created. JOIN queries reconstructed the original sales relation, and verification queries checked for missing rows and sample violations of the identified functional dependencies. Under the stated assumptions, the final decomposition is **lossless, dependency-preserving, and in BCNF**.
