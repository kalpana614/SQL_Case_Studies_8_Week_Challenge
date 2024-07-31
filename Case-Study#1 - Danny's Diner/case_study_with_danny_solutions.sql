/* --------------------
   Case Study Questions
--------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as total_amount_spent
from sales s
join menu m
on
	s.product_id = m.product_id
group by 
	s.customer_id;
  
-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as no_of_days_visited
from sales 
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?

-- Using Subquery
select distinct s.customer_id, m.product_name
from sales s
join menu m
on
	s.product_id = m.product_id
where (s.customer_id, s.order_date) in (select customer_id, min(order_date) from  sales group by 1);

-- Using CTE 

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
Select Customer_id, product_name
From Ranking
Where rnk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name,count(*) as purchased_num
from sales s
join menu m
On m.product_id = s.product_id
group by m.product_name
order by purchased_num desc
limit 1;

-- 5. Which item was the most popular for each customer?
with ranking(customer_id,product_name,order_count,dense_rnk) as(
select s.customer_id, 
m.product_name,
count(s.product_id),
dense_rank() over( partition by s.customer_id order by count(s.product_id) desc) 
From sales s
join menu m
On s.product_id = m.product_id
group by s.customer_id, m.product_name)

select customer_id,product_name, order_count
from ranking
where dense_rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?

with membership_table as(
select s.customer_id, 
	   s.product_id,
       s.order_date
from 
sales s join 
members m 
on s.customer_id = m.customer_id 
and s.order_date >= m.join_date),
ranking as(
select m.customer_id, 
	p.product_name,
    dense_rank() over(partition by m.customer_id order by m.order_date) as dense_rnk
from 
membership_table m
join menu p 
on m.product_id = p.product_id
)
select customer_id,product_name from ranking
where dense_rnk =1;


-- 7. Which item was purchased just before the customer became a member?
with non_member_table as(
select s.customer_id, 
	   s.product_id,
       s.order_date
from 
sales s join 
members m 
on s.customer_id = m.customer_id 
and s.order_date < m.join_date
),
ranking as(
select nm.customer_id, 
	p.product_name,
    dense_rank() over(partition by nm.customer_id order by nm.order_date desc) as dense_rnk
from 
non_member_table nm
join menu p 
on nm.product_id = p.product_id
)
select customer_id,product_name from ranking
where dense_rnk =1;

-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, 
	   count(m.product_id) as total_items,
	   sum(m.price) as amount_spent
from sales s 
join menu m
on s.product_id = m.product_id
join members mem 
on s.customer_id = mem.customer_id 
and s.order_date < mem.join_date
group by s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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
    
select customer_id, sum(points) as total_points
from points_table p
group by 1;

-- or
With Points as
(
Select *, Case When product_id = 1 THEN price*20
               Else price*10
	       End as Points
From Menu
)
Select S.customer_id, Sum(P.points) as Points
From Sales S
Join Points p
On p.product_id = S.product_id
Group by S.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


SELECT 
    s.customer_id,
    SUM(CASE
        WHEN (DATEDIFF(mem.join_date, s.order_date) < 7) THEN m.price * 20
        ELSE m.price * 10
    END) AS Points
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
        JOIN
    members mem ON s.customer_id = mem.customer_id
        AND s.order_date >= mem.join_date
WHERE
    MONTH(s.order_date) = 1
GROUP BY s.customer_id
;
