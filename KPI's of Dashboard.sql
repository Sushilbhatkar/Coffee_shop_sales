select * from coffee_shop_sales;
-- Total Sales-- 

select round(sum(unit_price*transaction_qty)) as total_sales
from coffee_shop_sales
WHERE 
MONTH(transaction_date) = 3; -- March Month

-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH-- 

Select
	month(transaction_date) As month,  -- Number OF Month
    Round(sum(unit_price * transaction_qty)) as total_sales, -- Total Sales Column
	(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1)-- Month Sales Difference
    over (order by month(transaction_date))) / lag(sum(unit_price * transaction_qty),1)--  Dividion by PM Sales
    over (order by month(transaction_date)) *100 as mom_increase_percentage -- Percentage
From
	coffee_shop_sales
Where
	month(transaction_date) In (4,5) -- for months of april (PM) and (CM)
Group by 
	month(transaction_date)
Order By
	month(transaction_date);


-- TOTAL ORDERS-- 

Select count(transaction_id) as Total_Orders
From coffee_shop_sales
where
Month(transaction_date) = 5; -- May Month 

-- TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH -- 

select
	Month(transaction_date) as Month,
    round(count(transaction_id)) as total_orders,
    (count(transaction_id) - LAG(count(transaction_id),1)
    Over (Order by Month(transaction_date))) / LAG(Count(transaction_id),1)
    Over (Order by Month(transaction_date)) * 100 as mom_increase_percentage
From
	coffee_shop_sales
Where 
	Month(transaction_date) IN (4,5) -- for April and May 
Group By 
	Month(transaction_date); 
    
    -- TOTAL QUANTITY SOLD-- 
    
select Sum(transaction_qty) As Total_Quantity_Sold
from coffee_shop_sales
Where
Month(transaction_date) = 5; -- May Month

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH -- 
select
	Month(transaction_date) as Month,
    round(Sum(transaction_qty)) As Total_Quntity_sold,
    (Sum(transaction_qty) - LAG(Sum(transaction_qty), 1)
    Over (order by Month(transaction_date))) / Lag(sum(transaction_qty),1)
    over (order by month(transaction_date)) * 100 as mom_increase_percentage
From
	coffee_shop_sales
where
	Month(transaction_date) In (4,5)  -- for April and May
group by
	month(transaction_date)
order by 
	Month(transaction_date);
    
--   CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS  -- 
Select 
	sum(unit_price*transaction_qty) As total_sales,
    sum(transaction_qty) as total_quantity_sold,
    count(transaction_id) as total_orders
from
	coffee_shop_sales
 where	
	transaction_date = '2023-05-18'; -- for 18 May 2023  
    
-- If you want to get exact Rounded off values then use below query to get the result:
Select
	concat(round(sum(unit_price*transaction_qty)/ 1000,1),'K') as total_sales,
    concat(round(count(transaction_id)/1000,1),'K') as total_orders,
    concat(Round(sum(transaction_qty)/1000,1),'K') as total_quantity_sold
From
	coffee_shop_sales
where
	transaction_date = '2023-05-18'; -- For 18 may2023
    
-- SALES TREND OVER PERIOD -- 
select 
	AVG(total_sales) as average_sales
from (
	select
        sum(unit_price * transaction_qty) as total_sales
	from
		coffee_shop_sales
        where 
        month (transaction_date) = 5 -- Filter for May
        group by
        transaction_date) as internal_query;
    
-- DAILY SALES FOR MONTH SELECTED-- 

Select
	day(transaction_date) as day_of_month,
    round(sum(unit_price*transaction_qty),1) as tota_sales
From
	coffee_shop_sales
where 
	month(transaction_date) = 5 -- Filter for may
group by
	day(transaction_date)
Order by 
	day(transaction_date);
    
--   COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

select
	day_of_month,
case
	when total_sales> avg_sales then 'Above Average'
    when total_sales<avg_sales then 'Below Average'
    else 'Average'
end as sales_status,
 total_sales
from(select
		day(transaction_date) as day_of_month,
        sum(unit_price * transaction_qty) as total_sales,
        avg(sum(unit_price * transaction_qty)) over () as avg_sales
	From 
		coffee_shop_sales
	where 
		month(transaction_date) = 5 -- Filter for may
	group by
		day(transaction_date)) as sales_data
	order by 
		day_of_month;
        
-- SALES BY WEEKDAY / WEEKEND

Select
	 case 
      when dayofweek(transaction_date) in (1,7) Then 'Weekends'
      Else 'Weekdays'
	End as day_types,
    round(sum(unit_price * transaction_qty),2) as total_sales
From
	coffee_shop_sales
where 
	Month(transaction_date) = 5  -- Fliter for may
group by
	case 
    when dayofweek(transaction_date) in (1,7) then 'Weekends'
    Else 'Weekdays'
    End	;
    
-- Sales BY Store Location --
Select 
	store_location,
    sum(unit_price * transaction_qty) as total_Sales
From 
	coffee_shop_sales
where 
	Month(transaction_date) = 5
group by
	store_location
order by
	Sum(unit_price *transaction_qty) desc;
    
-- SALES BY PRODUCT CATEGORY--

select 
	product_category,
    round(sum(unit_price * transaction_qty),1) as total_sales
from 
	coffee_shop_sales
where 
	month(transaction_date) = 5 
group by product_category
order by total_sales desc	;

-- SALES BY PRODUCTS (TOP 10)-- 
Select 
	 product_type,
     Round(Sum(unit_price * transaction_qty), 1) as total_sales
From 
	coffee_shop_sales
where 
	Month(transaction_date) = 5 
Group By 
	Product_type 
Order by 
	total_sales desc limit 10 ;
     
-- SALES BY DAY | HOUR--
Select 
	round(sum(unit_price*transaction_qty)) as total_sales,
    sum(transaction_qty) as total_quntity,
    count(*) as total_orders
from 
	coffee_shop_sales
where 
	dayofweek(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    and hour (transaction_time) = 8 -- Filter for hour number 8
    and Month (transaction_date) = 5 ; -- Filter for May (month number 5)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY  --   
Select 
    case  
		when dayofweek(transaction_date) = 2 Then 'Monday'
        when dayofweek(transaction_date) = 3 then 'Tuesday'
        when dayofweek(transaction_date) = 4 then  'Wednesday'
        when dayofweek(transaction_date) = 5 then  'Thursday'
        when dayofweek(transaction_date) = 6 then 'friday'
        when dayofweek(transaction_date) = 7 then 'Saturday'
        Else 'Sunday'
	end as day_of_week,
  round(sum(unit_price * transaction_qty)) as total_sales
from
	coffee_shop_sales
where 
	Month(transaction_date) = 5 -- Filter for may (month no 5)
Group by 
	day_of_week 
order by
	field(day_of_week,'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
	
-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY--
Select 
	Hour(transaction_time) as Hour_of_day,
    Round(Sum(unit_price * transaction_qty)) as Total_sales
From
	coffee_shop_sales
Where 
	Month(transaction_date) = 5 -- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
group by 
	hour(transaction_time)
order by
	hour(transaction_time);
     
        
    