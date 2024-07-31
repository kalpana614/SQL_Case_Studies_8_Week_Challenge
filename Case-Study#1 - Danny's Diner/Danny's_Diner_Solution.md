# **Case Study #1 - Danny's Diner**

### 1. What is the total amount each customer spent at the restaurant?

```sql
select
	s.customer_id,
	sum(m.price) as total_amount_spent
from sales s
join menu m
	on s.product_id = m.product_id
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
	on s.product_id = m.product_id
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
from sales s
join members m 
	on s.customer_id = m.customer_id 
	and s.order_date >= m.join_date),
ranking as(
select
	m.customer_id, 
	p.product_name,
        dense_rank() over(partition by m.customer_id order by m.order_date) as dense_rnk
from membership_table m
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
from non_member_table nm
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

---

### 8. What is the total items and amount spent for each member before they became a member?

```sql
select
	s.customer_id, 
	count(m.product_id) as total_items,
	sum(m.price) as amount_spent
from sales s 
join menu m
	on s.product_id = m.product_id
join members mem 
	on s.customer_id = mem.customer_id 
	and s.order_date < mem.join_date
group by s.customer_id
order by s.customer_id;

```
### Result Set 

| customer_id  | product_name  |order_date  |
|:-------------|:--------------|:-----------|
| A   | 2   | 25   |
| B   | 3   | 40  | 

---

### 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
-- Solution 1
with points_table as(
select distinct 
	s.customer_id,
	m.product_name, 
	sum(m.price) as total_price,
	case 
    		when m.product_name = "sushi" then 20 *sum(m.price) 
    		else 10 *sum(m.price)
    		end as points
from sales s 
join menu m
	on s.product_id = m.product_id
group by s.customer_id,
	m.product_name)
    
select
	customer_id,
	sum(points) as total_points
from points_table p
group by 1;

```
```sql
-- Solution 2
With Points as
(
Select
	*,
	Case
		 When product_id = 1 THEN price*20
                 Else price*10
	         End as Points
From Menu
)
Select
	S.customer_id, S
	um(P.points) as Points
From Sales S
Join Points p
	On p.product_id = S.product_id
Group by S.customer_id;

```
### Result Set 

| customer_id  | total_points  |
|:-------------|:--------------|
| A   | 860   |
| B   | 940   | 
| C   | 360   | 

---

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
SELECT 
	s.customer_id,
    SUM(CASE
        WHEN (DATEDIFF(mem.join_date, s.order_date) < 7) THEN m.price * 20
        ELSE m.price * 10
		END) AS Points
FROM sales s
JOIN menu m 
	ON s.product_id = m.product_id
JOIN members mem 
	ON s.customer_id = mem.customer_id
	AND s.order_date >= mem.join_date
	AND MONTH(s.order_date) = 1
GROUP BY s.customer_id
order by s.customer_id
;


```

### Result Set 

| customer_id  | Points  |
|:-------------|:--------------|
| A   | 1020   |
| B   | 440   | 

---
[Back to Repository](../)
