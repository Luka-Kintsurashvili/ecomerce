select *
from sales_target;

select *
from order_details;

select distinct CustomerName
from `list of orders`
;

-- Top 5 customers by total spend
select  CustomerName, sum(amount) as amount
from order_details
join `list of orders`
on Order_ID = `Order ID`
group by CustomerName
order by amount desc
limit 5;

-- Most profitable product category
select Category, sum(Profit) as profit
from order_details
group by Category
order by profit desc
;

-- State with most orders
select State, sum(Amount) as amount
from order_details
join `list of orders`
on `Order ID` = Order_ID
group by State
order by amount desc;

-- Actual sales vs target by category
select
sales_target.Category,
sum(order_details.Amount) as sum_of_amount,
sum(sales_target.Target) as sum_of_target,
sum(order_details.Amount) - sum(sales_target.Target) as difference
from order_details
join sales_target
on order_details.Category = sales_target.Category
group by sales_target.Category;


-- Customers with more than 2 orders
select CustomerName, count(`Order ID`) as order_count
from `list of orders`
WHERE CustomerName IS NOT NULL AND CustomerName != ''
group by CustomerName
having order_count > 2
order by order_count
;


