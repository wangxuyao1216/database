-- ============================================
-- 火车售票管理系统 - 测试数据脚本
-- 运行此脚本后即可测试所有接口
-- 执行方式: Navicat/IDEA 连接 train_ticket_db 后全选运行
-- 注意: 用户请通过 POST /register 接口注册（AES加密由Java处理）
--       测试用户: admin/123456 (已存在)
-- ============================================

USE train_ticket_db;

-- ============================================
-- 0. 清理旧数据
-- ============================================
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM audit_log;
DELETE FROM refund_record;
DELETE FROM seat_inventory;
DELETE FROM ticket_order;
DELETE FROM train_schedule;
DELETE FROM train_route;
DELETE FROM seat;
DELETE FROM carriage;
DELETE FROM train;
DELETE FROM station;
DELETE FROM passenger;
SET FOREIGN_KEY_CHECKS = 1;

-- 重置自增
ALTER TABLE station AUTO_INCREMENT = 1;
ALTER TABLE train AUTO_INCREMENT = 1;
ALTER TABLE carriage AUTO_INCREMENT = 1;
ALTER TABLE seat AUTO_INCREMENT = 1;
ALTER TABLE train_schedule AUTO_INCREMENT = 1;

-- ============================================
-- 1. 车站表 — 10个站，覆盖京沪/京广线
-- ============================================
INSERT INTO station (station_name, station_code, city, province, sort_order) VALUES
('北京南',   'BJN', '北京', '北京', 1),
('天津西',   'TJX', '天津', '天津', 2),
('济南西',   'JNX', '济南', '山东', 3),
('南京南',   'NJN', '南京', '江苏', 4),
('上海虹桥', 'SHH', '上海', '上海', 5),
('杭州东',   'HZD', '杭州', '浙江', 6),
('广州南',   'GZN', '广州', '广东', 7),
('深圳北',   'SZB', '深圳', '广东', 8),
('武汉',     'WHN', '武汉', '湖北', 9),
('郑州东',   'ZZD', '郑州', '河南', 10);

-- ============================================
-- 2. 列车表 — G高铁/D动车/T特快/K快速
-- ============================================
INSERT INTO train (train_number, train_type, train_name) VALUES
('G101', 'G', '京沪高铁'),
('D301', 'D', '京沪动车'),
('T110', 'T', '京广特快'),
('K508', 'K', '京广快速');

-- ============================================
-- 3. 列车线路表 — 每趟车的经停站
-- ============================================
-- G101: 北京南→济南西→南京南→上海虹桥 (4站)
INSERT INTO train_route (train_id, station_id, station_order, arrival_time, departure_time, stay_minutes, distance_km, price_per_km) VALUES
(1, 1, 1, NULL,        '06:00:00', 0,    0,   0.5),
(1, 3, 2, '07:30:00', '07:35:00', 5,  400,  0.5),
(1, 4, 3, '09:00:00', '09:05:00', 5,  800,  0.5),
(1, 5, 4, '10:30:00', NULL,       0, 1200,  0.5);

-- D301: 北京南→天津西→济南西→南京南→上海虹桥→杭州东 (6站)
INSERT INTO train_route (train_id, station_id, station_order, arrival_time, departure_time, stay_minutes, distance_km, price_per_km) VALUES
(2, 1, 1, NULL,        '08:00:00', 0,    0,   0.4),
(2, 2, 2, '08:30:00', '08:33:00', 3,  120,  0.4),
(2, 3, 3, '09:30:00', '09:35:00', 5,  400,  0.4),
(2, 4, 4, '11:00:00', '11:05:00', 5,  800,  0.4),
(2, 5, 5, '12:30:00', '12:35:00', 5, 1200,  0.4),
(2, 6, 6, '13:30:00', NULL,       0, 1400,  0.4);

-- T110: 北京南→郑州东→武汉→广州南→深圳北 (5站)
INSERT INTO train_route (train_id, station_id, station_order, arrival_time, departure_time, stay_minutes, distance_km, price_per_km) VALUES
(3, 1,  1, NULL,        '20:00:00',  0,    0,  0.3),
(3, 10, 2, '23:00:00', '23:10:00', 10,  500,  0.3),
(3, 9,  3, '03:30:00', '03:40:00', 10, 1000,  0.3),
(3, 7,  4, '07:00:00', '07:10:00', 10, 1800,  0.3),
(3, 8,  5, '09:00:00', NULL,        0, 2000,  0.3);

-- K508: 广州南→武汉→郑州东→北京南 (4站)
INSERT INTO train_route (train_id, station_id, station_order, arrival_time, departure_time, stay_minutes, distance_km, price_per_km) VALUES
(4, 7, 1, NULL,        '18:00:00',  0,    0,  0.2),
(4, 9, 2, '23:00:00', '23:15:00', 15,  800,  0.2),
(4,10, 3, '03:00:00', '03:10:00', 10, 1300,  0.2),
(4, 1, 4, '08:00:00', NULL,        0, 2000,  0.2);

-- ============================================
-- 4. 车厢表
-- ============================================
-- G101: BUS + 2×SECOND
INSERT INTO carriage (train_id, carriage_number, carriage_type, seat_capacity, row_count) VALUES
(1,1,'BUSINESS',  8,2), (1,2,'SECOND',12,3), (1,3,'SECOND',12,3);
-- D301: FIRST + SECOND + SOFT_SLEEPER
INSERT INTO carriage (train_id, carriage_number, carriage_type, seat_capacity, row_count) VALUES
(2,1,'FIRST',8,2), (2,2,'SECOND',12,3), (2,3,'SOFT_SLEEPER',4,2);
-- T110: HARD_SLEEPER + HARD_SEAT
INSERT INTO carriage (train_id, carriage_number, carriage_type, seat_capacity, row_count) VALUES
(3,1,'HARD_SLEEPER',6,3), (3,2,'HARD_SEAT',16,4);
-- K508: HARD_SLEEPER + HARD_SEAT + SOFT_SLEEPER
INSERT INTO carriage (train_id, carriage_number, carriage_type, seat_capacity, row_count) VALUES
(4,1,'HARD_SLEEPER',6,3), (4,2,'HARD_SEAT',16,4), (4,3,'SOFT_SLEEPER',4,2);

-- ============================================
-- 5. 座位表
-- ============================================
-- G101 商务座(车厢1): 2排×4座=8座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(1,'01A','WINDOW',1),(1,'01C','AISLE',1),(1,'01D','AISLE',1),(1,'01F','WINDOW',1),
(1,'02A','WINDOW',1),(1,'02C','AISLE',1),(1,'02D','AISLE',1),(1,'02F','WINDOW',1);

-- G101 二等座(车厢2): 3排×5座=15座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(2,'01A','WINDOW',1),(2,'01B','MIDDLE',1),(2,'01C','AISLE',1),(2,'01D','AISLE',1),(2,'01F','WINDOW',1),
(2,'02A','WINDOW',1),(2,'02B','MIDDLE',1),(2,'02C','AISLE',1),(2,'02D','AISLE',1),(2,'02F','WINDOW',1),
(2,'03A','WINDOW',1),(2,'03B','MIDDLE',1),(2,'03C','AISLE',1),(2,'03D','AISLE',1),(2,'03F','WINDOW',1);

-- G101 二等座(车厢3): 3排×5座=15座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(3,'01A','WINDOW',1),(3,'01B','MIDDLE',1),(3,'01C','AISLE',1),(3,'01D','AISLE',1),(3,'01F','WINDOW',1),
(3,'02A','WINDOW',1),(3,'02B','MIDDLE',1),(3,'02C','AISLE',1),(3,'02D','AISLE',1),(3,'02F','WINDOW',1);

-- D301 一等座(车厢4): 2排×4座=8座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(4,'01A','WINDOW',1),(4,'01C','AISLE',1),(4,'01D','AISLE',1),(4,'01F','WINDOW',1),
(4,'02A','WINDOW',1),(4,'02C','AISLE',1),(4,'02D','AISLE',1),(4,'02F','WINDOW',1);

-- D301 二等座(车厢5): 2排×5座=10座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(5,'01A','WINDOW',1),(5,'01B','MIDDLE',1),(5,'01C','AISLE',1),(5,'01D','AISLE',1),(5,'01F','WINDOW',1),
(5,'02A','WINDOW',1),(5,'02B','MIDDLE',1),(5,'02C','AISLE',1),(5,'02D','AISLE',1),(5,'02F','WINDOW',1);

-- D301 软卧(车厢6): 4座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(6,'01A','WINDOW',1),(6,'01B','MIDDLE',1),(6,'01C','AISLE',1),(6,'01D','AISLE',1);

-- T110 硬卧(车厢7): 2排×3座=6座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(7,'01A','WINDOW',1),(7,'01B','MIDDLE',1),(7,'01C','AISLE',1),
(7,'02A','WINDOW',1),(7,'02B','MIDDLE',1),(7,'02C','AISLE',1);

-- T110 硬座(车厢8): 4排×5座=20座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(8,'01A','WINDOW',1),(8,'01B','MIDDLE',1),(8,'01C','AISLE',1),(8,'01D','AISLE',1),(8,'01F','WINDOW',1),
(8,'02A','WINDOW',1),(8,'02B','MIDDLE',1),(8,'02C','AISLE',1),(8,'02D','AISLE',1),(8,'02F','WINDOW',1),
(8,'03A','WINDOW',1),(8,'03B','MIDDLE',1),(8,'03C','AISLE',1),(8,'03D','AISLE',1),(8,'03F','WINDOW',1),
(8,'04A','WINDOW',1),(8,'04B','MIDDLE',1),(8,'04C','AISLE',1),(8,'04D','AISLE',1),(8,'04F','WINDOW',1);

-- K508 硬卧(车厢9): 2排×3座=6座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(9,'01A','WINDOW',1),(9,'01B','MIDDLE',1),(9,'01C','AISLE',1),
(9,'02A','WINDOW',1),(9,'02B','MIDDLE',1),(9,'02C','AISLE',1);

-- K508 硬座(车厢10): 2排×5座=10座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(10,'01A','WINDOW',1),(10,'01B','MIDDLE',1),(10,'01C','AISLE',1),(10,'01D','AISLE',1),(10,'01F','WINDOW',1),
(10,'02A','WINDOW',1),(10,'02B','MIDDLE',1),(10,'02C','AISLE',1),(10,'02D','AISLE',1),(10,'02F','WINDOW',1);

-- K508 软卧(车厢11): 4座
INSERT INTO seat (carriage_id, seat_number, seat_type, status) VALUES
(11,'01A','WINDOW',1),(11,'01B','MIDDLE',1),(11,'01C','AISLE',1),(11,'01D','AISLE',1);

-- ============================================
-- 6. 列车排班表 — 未来7天
-- =============================================
INSERT INTO train_schedule (train_id, schedule_date, status)
SELECT t.id, DATE_ADD(CURDATE(), INTERVAL d.day DAY), 'SCHEDULED'
FROM train t
CROSS JOIN (SELECT 1 AS day UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) d;

-- ============================================
-- 7. 座位库存 — 为每个排班初始化全区段库存
-- ============================================
INSERT INTO seat_inventory (train_schedule_id, carriage_id, seat_id, from_station_order, to_station_order, is_occupied, schedule_date)
SELECT ts.id, c.id, s.id, 1,
    (SELECT MAX(tr.station_order) FROM train_route tr WHERE tr.train_id = ts.train_id),
    0, ts.schedule_date
FROM train_schedule ts
JOIN carriage c ON c.train_id = ts.train_id
JOIN seat s ON s.carriage_id = c.id;

-- 更新排班的座位数
UPDATE train_schedule ts SET
    total_seats = (SELECT COUNT(*) FROM seat s JOIN carriage c ON s.carriage_id=c.id WHERE c.train_id=ts.train_id),
    available_seats = (SELECT COUNT(*) FROM seat s JOIN carriage c ON s.carriage_id=c.id WHERE c.train_id=ts.train_id);

-- ============================================
-- 验证
-- ============================================
SELECT 'station' AS tbl, COUNT(*) FROM station UNION ALL
SELECT 'train', COUNT(*) FROM train UNION ALL
SELECT 'train_route', COUNT(*) FROM train_route UNION ALL
SELECT 'carriage', COUNT(*) FROM carriage UNION ALL
SELECT 'seat', COUNT(*) FROM seat UNION ALL
SELECT 'train_schedule', COUNT(*) FROM train_schedule UNION ALL
SELECT 'seat_inventory', COUNT(*) FROM seat_inventory;

SELECT '=== 未来一周排班 ===' AS info;
SELECT ts.id, t.train_number, ts.schedule_date, ts.available_seats, ts.total_seats
FROM train_schedule ts JOIN train t ON ts.train_id=t.id
WHERE ts.schedule_date >= CURDATE()
ORDER BY ts.schedule_date, t.train_number;
