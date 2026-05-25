# E-Commerce Orders: Multi-Table SQL Analysis

**Tools:** MySQL &nbsp;|&nbsp; **Dataset:** [Kaggle — E-Commerce Sales Dataset](https://www.kaggle.com/datasets/benroshan/ecommerce-data) &nbsp;|&nbsp; **Author:** Luka Kintsurashvili

---

## Overview

An end-to-end SQL analysis of an e-commerce business across 3 relational tables. I explored customer spending behavior, product profitability, regional performance, and target attainment — uncovering a data quality issue along the way that would have silently skewed the results.

---

## The Dataset

Three tables, each holding a different piece of the puzzle:

| Table | Rows | Key Columns |
|---|---|---|
| `list of orders` | 500+ | Order ID, CustomerName, State, City |
| `order_details` | 500+ | Order ID, Amount, Profit, Category |
| `sales_target` | 12 | Category, Month, Target |

The tables are connected via `Order ID` — making JOINs necessary for any customer or location-level analysis.

---

## Data Quality

Before diving into analysis, I ran a quick audit and found something worth flagging:

```sql
SELECT COUNT(*)
FROM `list of orders`
WHERE CustomerName IS NULL OR CustomerName = '';
```

**Result: 60 rows with missing CustomerName.**

These rows were invisible in standard queries but would silently corrupt any customer-level aggregation. I excluded them explicitly for all customer analysis and flagged it as a structural limitation — in a production database, a `CustomerID` column would prevent this entirely.

---

## Analysis

### Who are the highest-value customers?

Joined `order_details` and `list of orders` to connect spending data with customer names, then ranked by total spend.

```sql
SELECT CustomerName, SUM(Amount) AS total_spent
FROM order_details
JOIN `list of orders` ON Order_ID = `Order ID`
GROUP BY CustomerName
ORDER BY total_spent DESC
LIMIT 5;
```

---

### Which product category is most profitable?

```sql
SELECT Category, SUM(Profit) AS total_profit
FROM order_details
GROUP BY Category
ORDER BY total_profit DESC;
```

---

### Which regions drive the most revenue?

```sql
SELECT State, SUM(Amount) AS total_amount
FROM order_details
JOIN `list of orders` ON `Order ID` = Order_ID
GROUP BY State
ORDER BY total_amount DESC;
```

---

### Are we actually hitting sales targets?

Cross-referenced actual revenue against monthly targets by category to see where the business was over- or under-performing.

```sql
SELECT
    sales_target.Category,
    SUM(order_details.Amount)   AS actual_sales,
    SUM(sales_target.Target)    AS target_sales,
    SUM(order_details.Amount) - SUM(sales_target.Target) AS difference
FROM order_details
JOIN sales_target ON order_details.Category = sales_target.Category
GROUP BY sales_target.Category;
```

A positive `difference` means the category beat its target. Negative means it fell short.

---

### Who are the repeat buyers?

```sql
SELECT CustomerName, COUNT(`Order ID`) AS order_count
FROM `list of orders`
WHERE CustomerName IS NOT NULL AND CustomerName != ''
GROUP BY CustomerName
HAVING order_count > 2
ORDER BY order_count DESC;
```

---

## Key Findings

| Area | Finding |
|---|---|
| Top spender | Madhav ($2,520 total) |
| Most profitable category | Clothing ($4,728 profit) |
| Top state by revenue | Madhya Pradesh |
| Sales vs target | Electronics missed target by the largest margin |
| Repeat buyers | 4 customers placed more than 2 orders |

---

## SQL Concepts Used

- Multi-table `JOIN` across 3 related tables
- `GROUP BY` with `SUM`, `COUNT`
- `ORDER BY` + `LIMIT`
- `HAVING` for post-aggregation filtering
- `WHERE` for pre-aggregation filtering and data quality exclusion
- Derived columns (`actual - target AS difference`)

---

## Data Limitation

Customer names are the only identifier in this dataset — there is no `CustomerID`. Two different customers sharing the same name would be treated as one person. In a real production database, this would be solved with a unique ID column at the customer level.

---

*Part of my data analytics portfolio — [Portfolio](https://luka-kintsurashvili.github.io/LukaKintsurashvili.portfelio/) | [LinkedIn](https://www.linkedin.com/in/luka-kintsurashvili-b016193b3/)*
