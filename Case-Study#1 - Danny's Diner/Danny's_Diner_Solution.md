# **Case Study #1 - Danny's Diner**

### 1. What is the total amount each customer spent at the restaurant?

```sql
elect s.customer_id, sum(m.price) as total_amount_spent
from sales s
join menu m
on
	s.product_id = m.product_id
group by 
	s.customer_id;

```plaintext
### Result Set for Query: Total Amount Each Customer Spent

| customer_id | total_amount_Spent |
|:-------------|:-------------|
| A           | 76         |
| B           | 74         |
| C           | 36         |

```plaintext
### 1. What is the total amount each customer spent at the restaurant?
