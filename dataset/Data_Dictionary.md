# Dataset Documentation — E-commerce Retail Analytics Project

## Overview
Synthetic, relationally-consistent dataset built for an end-to-end analytics project
(Advanced Excel → SQL → Python → Power BI → Tableau).

| Table       | Rows     | File            | Grain                  |
|-------------|----------|-----------------|-------------------------|
| Customers   | 100,000  | Customers.csv   | One row per customer    |
| Inventory   | 2,000    | Inventory.csv   | One row per product/SKU |
| Employees   | 200      | Employees.csv   | One row per employee    |
| Logistics   | 150,000  | Logistics.csv   | One row per shipment    |

**Total rows: 252,200**

---

## Table Schemas

### 1. Customers.csv
| Column           | Type    | Description                                  |
|------------------|---------|-----------------------------------------------|
| Customer_ID      | String  | Primary Key. Format: CUST000001               |
| Age              | Integer | 18–70, normally distributed around 32         |
| Gender           | String  | Male / Female / Other                         |
| Income           | Integer | Annual income in INR (right-skewed/lognormal) |
| City             | String  | One of 20 major Indian cities                 |
| Region           | String  | North / South / East / West / Central — derived from City, matches Employees.Region |
| Email            | String  | Synthetic, unique per customer                |
| Phone            | String  | Synthetic 10-digit Indian mobile number        |
| Signup_Date      | Date    | Between 2021-01-01 and 2026-04-01. Always before all of that customer's Shipment_Date values |
| Customer_Segment | String  | Budget / Regular / Premium — based on income percentile (50th/85th cuts), so the split stays usable for BI slicing |

### 2. Inventory.csv
| Column               | Type    | Description                                   |
|----------------------|---------|--------------------------------------------------|
| Product_ID           | String  | Primary Key. Format: PROD00001                 |
| Product_Name         | String  | Generated product name + model number           |
| Category             | String  | 7 categories (Electronics, Fashion, etc.)        |
| Stock                | Integer | Current stock on hand                            |
| Reorder_Level        | Integer | Threshold stock level that should trigger reorder |
| Warehouse            | String  | One of 7 regional warehouses                      |
| Unit_Price           | Float   | INR, range varies by Category (Electronics highest, Groceries lowest) |
| Supplier             | String  | One of 10 synthetic supplier companies             |
| Last_Restocked_Date  | Date    | Between 2025-01-01 and 2026-06-23. Loosely tied to Stock (lower stock → older restock date) |

### 3. Employees.csv
| Column              | Type    | Description                                |
|---------------------|---------|-----------------------------------------------|
| Employee_ID         | String  | Primary Key. Format: EMP0001                 |
| Employee_Name       | String  | Synthetic full name                           |
| Region              | String  | North / South / East / West / Central         |
| Team                | String  | Sales / Customer Success / Logistics Ops / Key Accounts / Inside Sales |
| Sales_Target        | Integer | Annual sales target in INR, varies by team    |
| Hire_Date           | Date    | Between 2020-01-01 and 2026-05-01              |
| Email               | String  | Synthetic, firstname.lastname@retailcorp.com   |
| Performance_Rating  | Float   | 1.0–5.0. Mildly correlated with tenure plus random noise |

### 4. Logistics.csv
| Column           | Type    | Description                                          |
|------------------|---------|----------------------------------------------------------|
| Shipment_ID      | String  | Primary Key. Format: SHIP0000001                       |
| Customer_ID      | String  | Foreign Key → Customers.Customer_ID                    |
| Product_ID       | String  | Foreign Key → Inventory.Product_ID                     |
| Shipment_Date    | Date    | Between 2024-06-01 and 2026-06-23. Always on/after that customer's Signup_Date |
| Delivery_Days    | Integer | Days taken to deliver (carrier-dependent distribution)   |
| Carrier          | String  | One of 7 carriers (BlueDart, Delhivery, DTDC, etc.)       |
| Cost             | Float   | Shipping/courier fee in INR (carrier-dependent — NOT the product price) |
| Status           | String  | Delivered / In Transit / Delayed / Returned / Cancelled   |
| Quantity         | Integer | Units in this shipment, 1–10, right-skewed (most orders are 1-3 units) |
| Discount_Applied | Float   | 0.0 / 0.10 / 0.20 / 0.30 — discount rate applied to the order |
| Payment_Mode     | String  | UPI / Credit Card / Debit Card / Cash on Delivery / Net Banking / Wallet |

> **Note on Cost vs. order value**: `Cost` is the shipping/courier fee only.
> For total order/revenue value, derive it yourself:
> `Order_Value = Quantity × Inventory.Unit_Price × (1 - Discount_Applied)`
> (join Logistics → Inventory on Product_ID). Building this as a calculated
> column in Python or DAX is a good, explicit modeling decision to call out
> in your project writeup.

---

## Relationships (for SQL joins / Power BI model / Tableau relationships)

```
Customers (1) ────< (Many) Logistics
Inventory (1) ────< (Many) Logistics
Customers.Region (Many) >──── (Many) Employees.Region
```

Suggested Power BI / Tableau model: **star schema** with `Logistics` as the
fact table, and `Customers`, `Inventory` as dimension tables. `Employees`
joins to `Customers` via `Region` — this is a many-to-many relationship
(many employees per region, many customers per region), so when attributing
shipment/revenue metrics to employees, be explicit that you're reporting
**territory-level performance**, not individually-attributed sales. Calling
this out correctly in your dashboard/README is itself a good signal of data
modeling maturity.

---

## Built-in Patterns to Discover (good for analysis & dashboard storytelling)

- **Carrier trade-offs**: FedEx is fastest but most expensive; DTDC is
  slowest but cheapest. BlueDart and Shadowfax sit in between. This is a
  natural "cost vs. speed" trade-off chart for Tableau/Power BI.
- **City distribution**: Customer base is weighted toward metro cities
  (Bengaluru, Mumbai, Delhi) — good for a geo/map visual.
- **Income distribution**: Lognormal/right-skewed — a good example to show
  median vs. mean in Excel/Python, and demonstrates handling skewed data.
- **Inventory risk**: Some products have `Stock` below `Reorder_Level` —
  filter these for a "Products needing reorder" dashboard view.
- **Sales target variance by team**: Key Accounts has the highest average
  target, Logistics Ops the lowest — useful for an Employees-side bar chart.
- **Shipment status mix**: ~78% Delivered, with Delayed/Returned/Cancelled
  as minority classes — good for a funnel or status breakdown visual.

---

## Known Data Notes
- All data is **synthetic** (Faker-generated names, randomized IDs) —
  no real personal or company data is included. Safe for public GitHub/LinkedIn.
- Random seed = 42, so the dataset is reproducible if you re-run the
  generation script.
- `Employees` table is intentionally small (200 rows) and `Inventory` is
  intentionally small (2,000 rows) since these reflect realistic real-world
  cardinality (a company doesn't have 100,000 employees or 100,000 distinct
  SKUs) — keeping this rationale in your README shows graders/recruiters you
  understand data modeling, not just data generation.
