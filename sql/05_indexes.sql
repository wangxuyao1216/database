-- ============================================
-- 火车售票管理系统 - 索引优化
-- 针对高频查询建立索引，并进行性能对比分析
-- ============================================

USE train_ticket_db;

-- ============================================
-- 复合索引优化
-- ============================================

-- 1. 订单高频查询索引：按用户+状态+时间查询
CREATE INDEX idx_order_user_status_time
ON ticket_order (user_id, ticket_status, created_at);


-- 2. 列车线路复合索引：按车次+站点序号查询
CREATE INDEX idx_route_train_station_order
ON train_route (train_id, station_order, station_id);

-- 3. 排班查询索引：按日期+状态
CREATE INDEX idx_schedule_date_status
ON train_schedule (schedule_date, status);

-- 4. 座位库存高效查询索引（区间售票核心）
CREATE INDEX idx_inventory_schedule_occupied_range
ON seat_inventory (train_schedule_id, is_occupied, from_station_order, to_station_order);

-- 5. 座位复合索引：按车厢+座位号
CREATE INDEX idx_seat_carriage_number
ON seat (carriage_id, seat_number);

-- 6. 审计日志时间范围查询索引
CREATE INDEX idx_audit_time_table
ON audit_log (operated_at, table_name);

-- 7. 退票记录查询索引
CREATE INDEX idx_refund_ticket
ON refund_record (ticket_id, refund_time);

-- 8. 用户查询优化索引
CREATE INDEX idx_user_realname
ON `user` (real_name);

-- ============================================
-- 唯一索引（已在建表时创建，此处说明）
-- uk_username: 用户名唯一 - user表
-- uk_phone: 手机号唯一 - user表
-- uk_station_code: 车站代码唯一 - station表
-- uk_train_number: 车次号唯一 - train表
-- uk_order_number: 订单号唯一 - ticket_order表
-- uk_carriage_seat: 车厢+座位号唯一 - seat表
-- ============================================

-- ============================================
-- 性能分析：使用EXPLAIN查看执行计划
-- ============================================

-- 示例1：查询某用户订单 (使用索引 idx_order_user_status_time)
-- EXPLAIN SELECT * FROM ticket_order
-- WHERE user_id = 1 AND ticket_status = 'VALID'
-- ORDER BY created_at DESC;

-- 示例2：查询可用座位 (使用复合索引)
-- EXPLAIN SELECT s.* FROM seat s
-- JOIN carriage c ON s.carriage_id = c.id
-- WHERE c.train_id = 1 AND s.status = 1;

-- 示例3：区间座位冲突检查 (使用 inventory 复合索引)
-- EXPLAIN SELECT COUNT(*) FROM seat_inventory
-- WHERE train_schedule_id = 1
--   AND is_occupied = 1
--   AND from_station_order < 5
--   AND to_station_order > 2;

-- ============================================
-- 索引维护
-- ============================================

-- 定期分析表，更新索引统计信息
-- ANALYZE TABLE ticket_order;
-- ANALYZE TABLE seat_inventory;
-- ANALYZE TABLE train_schedule;

-- 查看索引使用情况
-- SHOW INDEX FROM ticket_order;
-- SHOW INDEX FROM seat_inventory;
