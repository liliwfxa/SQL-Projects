SELECT * FROM taobao;

ALTER TABLE `taobao` CHANGE COLUMN `date` `specific_date` DATETIME;

-- A. User behavior analysis
-- 1. Daily page view(PV) and Unique visitor(UV)
select date(specific_date), count(*) as DailyPV, count(distinct user_id) as DailyUV
from taobao
group by date(specific_date);

-- A. User behavior analysis
-- 2. Hourly PV and UV
select hour, count(*) as HourlyPV, count(distinct user_id) as HourlyUV
from taobao
group by hour;

-- A. User behavior analysis
-- 3. Hourly PV analysis among different type of user behavoir
select behavior_type, hour, count(*) as TypeHourlyPV
from taobao
group by behavior_type, hour
order by behavior_type, hour;


-- B. The consumpation behavior of user analysis
-- 1. The analysis of average times in this period of comsumpation per user including who has not comsumpt
SELECT 
    (SELECT SUM(consumptions_times)
     FROM (
         SELECT user_id, COUNT(*) AS consumptions_times
         FROM taobao
         WHERE behavior_type = '4'
         GROUP BY user_id
     ) AS ConsumptionData
    ) / (SELECT COUNT(DISTINCT user_id) FROM taobao) AS AvgConsumptionTimes;


-- 2. The times distribution of consumpation of users in this period
select consumpationtime, count(*)
from 
(
select user_id, count(*) as consumpationtime
from taobao
where behavior_type = '4'
group by user_id
) as consumpationtimes
group by consumpationtime;

-- 3.Rebuy rate, namely purchasing more than 2 times divide by all purchasing number
SELECT 
    (SELECT COUNT(*) FROM (
        SELECT user_id
        FROM taobao
        WHERE behavior_type = '4'
        GROUP BY user_id
        HAVING COUNT(DISTINCT DATE(time)) >= 2
    ) AS rebuy_users) / 
    (SELECT COUNT(DISTINCT user_id) FROM taobao WHERE behavior_type = '4') AS Rebuy_rate;

-- 4. daily_pay_rate， daily consumpation number divided by daily unique visitors number
select c.date, c.consumption_number / u.unique_visitior as daily_pay_rate
from (
select date(time) as date, count(*) as consumption_number
from taobao
where behavior_type = '4'
group by date(time)
) as c
Join
(
select date(time) as date, count(distinct user_id) as unique_visitior
from taobao
group by date(time)
) as u
on c.date = u.date
order by c.date;


-- Time intervals between user purchases and analyze the distribution of these intervals

WITH RankedPurchases AS (
    SELECT 
        user_id, 
        DATE(time) AS purchase_date, 
        LAG(DATE(time)) OVER (PARTITION BY user_id ORDER BY DATE(time)) AS prev_purchase_date
    FROM taobao
    WHERE behavior_type = 4
),
PurchaseGaps AS (
    SELECT 
        user_id, 
        purchase_date, 
        prev_purchase_date, 
        DATEDIFF(purchase_date, prev_purchase_date) AS gap_days
    FROM RankedPurchases
    WHERE prev_purchase_date IS NOT NULL
)
SELECT 
    gap_days, 
    COUNT(*) AS frequency
FROM PurchaseGaps
WHERE gap_days > 0
GROUP BY gap_days
ORDER BY gap_days;



-- C #浏览，点击、收藏、加购物车、支付 lost rate
-- 1. pV to click lost rate
SELECT 
    (COUNT(*) - SUM(CASE WHEN behavior_type = 1 THEN 1 ELSE 0 END)) / COUNT(*) AS pv_click_lostrate
FROM 
    taobao;
    
    
-- 2. Click to shopcart lost rate
select (SUM(CASE WHEN behavior_type = 1 THEN 1 ELSE 0 END) - SUM(CASE WHEN behavior_type = 3 THEN 1 ELSE 0 END)) /  SUM(CASE WHEN behavior_type = 1 THEN 1 ELSE 0 END)
as click_shopcart_lostrate
from taobao;

-- 3. Shopcart to Favorite lost rate
select (SUM(CASE WHEN behavior_type = 3 THEN 1 ELSE 0 END) - SUM(CASE WHEN behavior_type = 2 THEN 1 ELSE 0 END)) /  SUM(CASE WHEN behavior_type = 3 THEN 1 ELSE 0 END)
as shopbag_favorite_lostrate
from taobao;

-- 4.Favorite to buy lost rate
select (SUM(CASE WHEN behavior_type = 2 THEN 1 ELSE 0 END) - SUM(CASE WHEN behavior_type = 4 THEN 1 ELSE 0 END)) /  SUM(CASE WHEN behavior_type = 2 THEN 1 ELSE 0 END)
as favorite_buy_lostrate
from taobao;



-- 2. 计算三种行为后加购转化率

WITH ClickToBuy AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 1 AND item_id IN (SELECT item_id FROM taobao WHERE behavior_type = 4)
),
TotalClicks AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 1
),
FavoriteToBuy AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 2 AND item_id IN (SELECT item_id FROM taobao WHERE behavior_type = 4)
),
TotalFavorites AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 2
),
CartToBuy AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 3 AND item_id IN (SELECT item_id FROM taobao WHERE behavior_type = 4)
),
TotalCarts AS (
    SELECT COUNT(*) AS total
    FROM taobao
    WHERE behavior_type = 3
)
SELECT
    (SELECT total FROM ClickToBuy) / (SELECT total FROM TotalClicks) AS click_conversion_rate,
    (SELECT total FROM FavoriteToBuy) / (SELECT total FROM TotalFavorites) AS favorite_conversion_rate,
    (SELECT total FROM CartToBuy) / (SELECT total FROM TotalCarts) AS cart_conversion_rate
FROM dual;










