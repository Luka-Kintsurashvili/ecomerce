# E-Commerce Orders: SQL + Excel Analysis

**Tools:** MySQL, Excel &nbsp;|&nbsp; **Dataset:** [Kaggle — E-Commerce Sales Dataset](https://www.kaggle.com/datasets/benroshan/ecommerce-data) &nbsp;|&nbsp; **Author:** Luka Kintsurashvili

---

## Overview

An end-to-end analysis of an e-commerce business — starting with raw data across 3 relational SQL tables, and ending with an Excel dashboard summarizing the key findings. I explored customer spending behavior, product profitability, regional performance, and target attainment — uncovering a data quality issue along the way that would have silently skewed the results.

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

| Customer | Total Spent |
|---|---|
| Yaanvi | $9,177 |
| Pooja | $9,030 |
| Abhishek | $8,135 |
| Surabhi | $6,889 |
| Soumya | $6,869 |

---

### Which product category is most profitable?

```sql
SELECT Category, SUM(Profit) AS total_profit
FROM order_details
GROUP BY Category
ORDER BY total_profit DESC;
```

| Category | Actual Sales | Target | Difference |
|---|---|---|---|
| Electronics | $1,983,204 | $39,732,000 | -$37,748,796 |
| Clothing | $1,668,648 | $165,126,000 | -$163,457,352 |
| Furniture | $1,526,172 | $32,294,700 | -$30,768,528 |

---

### Which regions drive the most revenue?

```sql
SELECT State, SUM(Amount) AS total_amount
FROM order_details
JOIN `list of orders` ON `Order ID` = Order_ID
GROUP BY State
ORDER BY total_amount DESC;
```

| State | Revenue |
|---|---|
| Madhya Pradesh | $105,140 |
| Maharashtra | $95,348 |
| Delhi | $22,531 |
| Uttar Pradesh | $22,359 |
| Rajasthan | $21,149 |

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

All three categories missed their targets significantly — most notably Clothing, which fell short by over $163M. This suggests the targets in the dataset may be set at an annual scale while actual sales reflect a shorter period.

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

| Customer | Orders |
|---|---|
| Shreya | 6 |
| Abhishek | 5 |
| Pooja | 5 |
| Shubham | 5 |
| Priyanka | 4 |

---

## Excel Dashboard

After extracting the data via SQL, I exported the results into Excel and built a summary dashboard with pivot tables covering:

- **Top customers by spend**
- **Revenue by state** (ranked)
- **Actual vs target by category**
- **Repeat buyer leaderboard**

---

## Key Findings

| Area | Finding |
|---|---|
| Top spender | Yaanvi ($9,177) |
| Most revenue by region | Madhya Pradesh ($105,140) |
| All categories | Missed sales targets |
| Largest target gap | Clothing (-$163M) |
| Most repeat orders | Shreya (6 orders) |

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
