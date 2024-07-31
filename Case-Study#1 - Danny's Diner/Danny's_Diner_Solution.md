# **Case Study #1 - Danny's Diner**

### 1. What is the total amount each customer spent at the restaurant?

```sql
select
	s.customer_id,
	sum(m.price) as total_amount_spent
from sales s
join menu m
on
	s.product_id = m.product_id
group by s.customer_id;

```
### Result Set 

| customer_id | total_amount_Spent |
|:-------------|:-------------|
| A           | 76         |
| B           | 74         |
| C           | 36         |

---

### 2. How many days has each customer visited the restaurant?

```sql
select
	customer_id,
	count(distinct order_date) as no_of_days_visited
from sales 
group by customer_id;

```
### Result Set 

| customer_id | no_of_days_visited |
|:-------------|:-------------|
| A           | 4         |
| B           | 6         |
| C           | 2         |

---

### 3. What was the first item from the menu purchased by each customer?

```sql
-- Using Subquery
select
	distinct s.customer_id,
	m.product_name
from sales s
join menu m
on
	s.product_id = m.product_id
where (s.customer_id, s.order_date) in (select customer_id, min(order_date) from  sales group by 1);

```
```sql
- Using CTE
With Ranking as
(
Select s.customer_id, 
       m.product_name, 
       s.order_date,
       DENSE_RANK() OVER (PARTITION BY S.Customer_ID Order by S.order_date) as rnk
From menu m
join sales s
On m.product_id = s.product_id
group by s.customer_id, m.product_name,s.order_date
)
Select
	Customer_id,
	product_name
From Ranking
Where rnk = 1;

```

### Result Set 

| customer_id | product_name |
|:-------------|:-------------|
| A           | sushi         |
| A           | curry         |
| B           | curry         |
| C           | ramen         |

---

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
select
	m.product_name as most_purchased_item,
	count(*) as order_count
from sales s
join menu m
On m.product_id = s.product_id
group by m.product_name
order by purchased_num desc
limit 1;

```
### Result Set 

| most_purchased_item | order_count |
|:--------------------|:------------|
| ramen           | 8         |

---

### 5. Which item was the most popular for each customer?

```sql
with ranking(customer_id,product_name,order_count,dense_rnk) as(
select
	s.customer_id, 
	m.product_name,
	count(s.product_id),
	dense_rank() over( partition by s.customer_id order by count(s.product_id) desc) 
From sales s
join menu m
On s.product_id = m.product_id
group by s.customer_id, m.product_name)

select
	customer_id,
	product_name,
	order_count
from ranking
where dense_rnk = 1;

```
### Result Set 

| customer_id  | product_name  | order_count  |
|:-------------|:--------------|:-------------|
| A   | ramen   | 3   |
| B   | curry   | 2   |
| B   | sushi   | 2   |
| B   | ramen   | 2   |
| C   | ramen   | 3   |

---

### 6. Which item was purchased first by the customer after they became a member?

```sql
with membership_table as(
select
	s.customer_id, 
	s.product_id,
	s.order_date
from 
sales s join 
members m 
on s.customer_id = m.customer_id 
and s.order_date >= m.join_date),
ranking as(
select
	m.customer_id, 
	p.product_name,
        dense_rank() over(partition by m.customer_id order by m.order_date) as dense_rnk
from 
membership_table m
join menu p 
on m.product_id = p.product_id
)
select
	customer_id,
	product_name from ranking
where dense_rnk =1;


```
### Result Set 

| customer_id  | product_name  |
|:-------------|:--------------|
| A   | curry   |
| B   | sushi   | 
 
---

### 7. Which item was purchased just before the customer became a member?

```sql
with non_member_table as(
select
	s.customer_id, 
	s.product_id,
        s.order_date,
        m.join_date
from 
sales s join 
members m 
on s.customer_id = m.customer_id 
and s.order_date < m.join_date
),
ranking as(
select
	nm.customer_id, 
	p.product_name,
        nm.order_date,
        nm.join_date,
        dense_rank() over(partition by nm.customer_id order by nm.order_date desc) as dense_rnk
from 
non_member_table nm
join menu p 
on nm.product_id = p.product_id
)
select
	customer_id,
	product_name,
	order_date,
	join_date
from ranking
where dense_rnk =1;


```
### Result Set 

| customer_id  | product_name  |order_date  |join_date  |
|:-------------|:--------------|:-----------|:----------|
| A   | sushi   | 2021-01-01   | 2021-01-07    |
| A   | curry   | 2021-01-01   | 2021-01-07    |
| B   | sushi   | 2021-01-04   | 2021-01-09    |
