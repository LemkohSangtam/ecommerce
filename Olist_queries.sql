use e_commerce;

drop view if exists kpi_2 ;
#kpi 2
#Number of Orders with review score 5 and payment type as credit card.
create view kpi_2 as
select  r.review_score,p.payment_type, count(r.order_id) as no_of_orders
from olist_order_reviews_dataset r
join olist_order_payments_dataset p
	on r. order_id = p. order_id
where r.review_score = 5 and payment_type = 'credit_card';

select * from e_commerce.kpi_2;

#kpi_1
#Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
drop view if exists kpi_1;
create view kpi_1 as
Select 
    If(weekday(o.order_purchase_timestamp) < 5, 'Weekday', 'Weekend') AS `Day_type`,
    SUM(p.payment_value) AS `Total_Payment_Value`
from olist_orders_dataset o
join olist_order_payments_dataset p
	on o.order_id = p.order_id
#where
#	year(o.order_purchase_timestamp)=2018
group by 
    `Day_Type`;

select * from e_commerce.kpi_1;

#kpi_3
#Average number of days taken for order_delivered_customer_date for pet_shop
#create view kpi_3 as
select 
	avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)) as avg_delivery_days
from
	olist_orders_dataset o
join  product_category_name_translation p
	on o.order_id = p.order_id
where
	p.product_category_name_english = 'pet_shop';

ALTER TABLE product_category_name_translation CHANGE ï»¿order_id order_id VARCHAR(255);

select * from e_commerce.kpi_3;

#
select 
	avg(datediff(order_delivered_customer_date,order_purchase_timestamp)) as avg_delivery_days
from
	olist_orders_dataset; 
#

#
#kpi_4
#Average price and payment values from customers of sao paulo city
create view kpi_4 as
Select avg(i.price) AS average_price, avg(p.payment_value) AS average_payment
from olist_order_items_dataset i
join olist_order_payments_dataset p
	on i.order_id = p.order_id 
join olist_sellers_dataset s
	on i.seller_id = s.seller_id 
where seller_city = 'Sao Paulo';

select * from e_commerce.kpi_4;

#kpi_5
#Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
drop view if exists kpi_5;
create view kpi_5 as 
Select Datediff(o.order_delivered_customer_date, o.order_purchase_timestamp) as shipping_days, avg(r.review_score) as avg_review_score
from olist_orders_dataset o
join olist_order_reviews_dataset r 
	on o.order_id = r.order_id
group by shipping_days;

select * from e_commerce.kpi_5;

#total_orders_year wise
create view total_orders as
select year(order_approved_at) as years, count(order_id) as total_orders
from 
olist_orders_dataset
group by year(order_purchase_timestamp);

select * from e_commerce.total_orders;

 #total profit year wise
drop procedure if exists total_profit_year_wise;
delimiter //
create procedure total_profit_year_wise(in _year int)
	begin
		select year(o.order_approved_at) as year, sum(p.payment_value) as total_payment
        from 
        olist_orders_dataset o
        join
        olist_order_payments_dataset p
        on o.order_id= p.order_id
        where year(o.order_approved_at) = _year;
			end//
delimiter ;

call e_commerce.total_profit_year_wise(2016);

#total_order_status by reviewscore
delimiter //
create procedure reviewscore_by_orderstatus (in _review_score int)
begin
    select r.review_score,o.order_status, count(o.order_status) as total 
    from olist_order_reviews_dataset r
    join olist_orders_dataset o
    on r.order_id = o.order_id
    #where r.review_score = 1 #and order_status = "delivered" and order_status="cancelled"
    where r.review_score = _review_score
    group by o.order_status;
end//
delimiter ;

call e_commerce.reviewscore_by_orderstatus(1);

#order_status
create view order_status as 
select order_status, count(order_status) as total
from olist_orders_dataset
group by order_status;

select * from e_commerce.order_status;

create view total_profit as
select sum(payment_value) as Total_Profit
from olist_order_payments_dataset;

#top 10 profit states
select o.customer_id , p.payment_value
from olist_orders_dataset o
join olist_order_payments_dataset p
on o.order_id=p.order_id
order by o.customer_id desc
limit 10; 