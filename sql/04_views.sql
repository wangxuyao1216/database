-- ============================================
-- 火车售票管理系统 - 视图
-- ============================================

USE train_ticket_db;

-- ============================================
-- 1. 订单完整信息视图 
-- ============================================
CREATE OR REPLACE VIEW v_order_detail AS
SELECT
    tro.id AS order_id,
    tro.order_number,
    tro.user_id,
    tro.ticket_price,
    tro.seat_type,
    tro.ticket_status,
    tro.passenger_name,
    tro.payment_time,
    tro.created_at AS order_time,
    t.train_number,
    t.train_type,
    t.train_name,
    ts.schedule_date AS departure_date,
    fs.station_name AS from_station,
    ts2.station_name AS to_station,
    fs.city AS from_city,
    ts2.city AS to_city,
    c.carriage_number,
    s.seat_number,
    s.seat_type AS seat_location,
    fr.departure_time,
    tr2.arrival_time
FROM ticket_order tro
JOIN train_schedule ts ON tro.train_schedule_id = ts.id
JOIN train t ON ts.train_id = t.id
JOIN station fs ON tro.from_station_id = fs.id
JOIN station ts2 ON tro.to_station_id = ts2.id
JOIN carriage c ON tro.carriage_id = c.id
JOIN seat s ON tro.seat_id = s.id
JOIN train_route fr ON t.id = fr.train_id AND fr.station_id = fs.id
JOIN train_route tr2 ON t.id = tr2.train_id AND tr2.station_id = ts2.id;

-- ============================================
-- 2. 车次时刻表视图
-- ============================================
CREATE OR REPLACE VIEW v_train_schedule_detail AS
SELECT
    t.id AS train_id,
    t.train_number,
    t.train_type,
    t.train_name,
    tr.station_order,
    s.station_name,
    s.station_code,
    s.city,
    s.province,
    tr.arrival_time,
    tr.departure_time,
    tr.stay_minutes,
    tr.distance_km
FROM train t
JOIN train_route tr ON t.id = tr.train_id
JOIN station s ON tr.station_id = s.id
ORDER BY t.id, tr.station_order;

-- ============================================
-- 3. 运营日车次视图
-- ============================================
CREATE OR REPLACE VIEW v_daily_trains AS
SELECT
    ts.id AS schedule_id,
    ts.schedule_date,
    ts.status,
    ts.available_seats,
    ts.total_seats,
    t.train_number,
    t.train_type,
    t.train_name,
    fr.station_name AS from_station_name,
    fr2.station_name AS to_station_name,
    tr.departure_time,
    tr2.arrival_time,
    fr.city AS from_city,
    fr2.city AS to_city
FROM train_schedule ts
JOIN train t ON ts.train_id = t.id
JOIN train_route tr ON t.id = tr.train_id
JOIN train_route tr2 ON t.id = tr2.train_id
JOIN station fr ON tr.station_id = fr.id
JOIN station fr2 ON tr2.station_id = fr2.id
WHERE tr.station_order = 1
  AND tr2.station_order = (
      SELECT MAX(tr3.station_order) FROM train_route tr3 WHERE tr3.train_id = t.id
  );

-- ============================================
-- 4. 用户信息脱敏视图
-- ============================================
CREATE OR REPLACE VIEW v_user_public AS
SELECT
    id,
    username,
    CASE
        WHEN CHAR_LENGTH(real_name) <= 1 THEN real_name
        ELSE CONCAT(LEFT(real_name, 1), REPEAT('*', CHAR_LENGTH(real_name) - 1))
    END AS real_name_masked,
    CONCAT(LEFT(phone, 3), '****', RIGHT(phone, 4)) AS phone_masked,
    user_type,
    status,
    created_at
FROM `user`;

-- ============================================
-- 5. 销售汇总视图 
-- ============================================
CREATE OR REPLACE VIEW v_daily_sales_summary AS
SELECT
    DATE(created_at) AS sale_date,
    COUNT(id) AS total_tickets,
    SUM(ticket_price) AS total_revenue,
    ROUND(AVG(ticket_price), 2) AS avg_price,
    COUNT(DISTINCT user_id) AS unique_users
FROM ticket_order
WHERE ticket_status IN ('VALID', 'USED')
GROUP BY DATE(created_at)
ORDER BY sale_date DESC;

-- ============================================
-- 6. 列车满载率视图
-- ============================================
CREATE OR REPLACE VIEW v_train_occupancy AS
SELECT
    ts.id AS schedule_id,
    t.train_number,
    t.train_type,
    ts.schedule_date,
    ts.total_seats,
    (ts.total_seats - ts.available_seats) AS occupied_seats,
    ROUND((ts.total_seats - ts.available_seats) * 100.0 / NULLIF(ts.total_seats, 0), 2) AS occupancy_rate,
    ts.status
FROM train_schedule ts
JOIN train t ON ts.train_id = t.id
ORDER BY ts.schedule_date DESC, occupancy_rate DESC;

-- ============================================
-- 7. 用户消费统计视图 
-- ============================================
CREATE OR REPLACE VIEW v_user_consumption AS
SELECT
    u.id AS user_id,
    u.username,
    COUNT(tro.id) AS ticket_count,
    SUM(tro.ticket_price) AS total_spent,
    MAX(tro.created_at) AS last_order_time,
    ROUND(AVG(tro.ticket_price), 2) AS avg_ticket_price
FROM `user` u
LEFT JOIN ticket_order tro ON u.id = tro.user_id AND tro.ticket_status IN ('VALID', 'USED')
GROUP BY u.id, u.username;
