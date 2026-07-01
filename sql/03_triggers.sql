-- ============================================
-- 火车售票管理系统 - 触发器
-- 审计日志: 用户增删改 + 订单购票退票
-- ============================================

USE train_ticket_db;

DELIMITER $$

-- ============================================
-- 1. 用户表审计触发器
-- ============================================

-- 用户注册
DROP TRIGGER IF EXISTS trg_user_audit_insert$$
CREATE TRIGGER trg_user_audit_insert
    AFTER INSERT ON `user` FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation_type, record_id, old_value, new_value, operated_by, operated_at, log_date)
    VALUES ('user', 'INSERT', NEW.id, NULL,
        JSON_OBJECT(
            'id', NEW.id, 'username', NEW.username, 'password', NEW.password,
            'real_name', NEW.real_name, 'id_number', NEW.id_number,
            'phone', NEW.phone, 'email', NEW.email,
            'user_type', NEW.user_type, 'status', NEW.status
        ),
        NEW.id, NOW(), CURDATE());
END$$

-- 用户修改信息
DROP TRIGGER IF EXISTS trg_user_audit_update$$
CREATE TRIGGER trg_user_audit_update
    AFTER UPDATE ON `user` FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation_type, record_id, old_value, new_value, operated_by, operated_at, log_date)
    VALUES ('user', 'UPDATE', NEW.id,
        JSON_OBJECT('username', OLD.username, 'real_name', OLD.real_name, 'user_type', OLD.user_type, 'status', OLD.status),
        JSON_OBJECT('username', NEW.username, 'real_name', NEW.real_name, 'user_type', NEW.user_type, 'status', NEW.status),
        COALESCE(@audit_operator, NEW.id), NOW(), CURDATE());
END$$

-- 用户注销
DROP TRIGGER IF EXISTS trg_user_audit_delete$$
CREATE TRIGGER trg_user_audit_delete
    AFTER DELETE ON `user` FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation_type, record_id, old_value, operated_by, operated_at, log_date)
    VALUES ('user', 'DELETE', OLD.id,
        JSON_OBJECT('username', OLD.username, 'real_name', OLD.real_name),
        COALESCE(@audit_operator, OLD.id), NOW(), CURDATE());
END$$

-- ============================================
-- 2. 订单表审计触发器
-- ============================================

-- 购票
DROP TRIGGER IF EXISTS trg_order_audit_insert$$
CREATE TRIGGER trg_order_audit_insert
    AFTER INSERT ON ticket_order FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation_type, record_id, old_value, new_value, operated_by, operated_at, log_date)
    VALUES ('ticket_order', 'INSERT', NEW.id, NULL,
        JSON_OBJECT(
            'order_number', NEW.order_number,
            'train_schedule_id', NEW.train_schedule_id,
            'passenger_name', NEW.passenger_name,
            'from_station_id', NEW.from_station_id,
            'to_station_id', NEW.to_station_id,
            'ticket_price', NEW.ticket_price,
            'seat_type', NEW.seat_type,
            'ticket_status', NEW.ticket_status,
            'schedule_date', NEW.schedule_date
        ),
        COALESCE(@audit_operator, NEW.user_id), NOW(), CURDATE());
END$$

-- 退票（状态变更）
DROP TRIGGER IF EXISTS trg_order_audit_update$$
CREATE TRIGGER trg_order_audit_update
    AFTER UPDATE ON ticket_order FOR EACH ROW
BEGIN
    IF OLD.ticket_status != NEW.ticket_status THEN
        INSERT INTO audit_log (table_name, operation_type, record_id, old_value, new_value, operated_by, operated_at, log_date)
        VALUES ('ticket_order', 'UPDATE', NEW.id,
            JSON_OBJECT('order_number', OLD.order_number, 'ticket_status', OLD.ticket_status),
            JSON_OBJECT('order_number', NEW.order_number, 'ticket_status', NEW.ticket_status),
            COALESCE(@audit_operator, NEW.user_id), NOW(), CURDATE());
    END IF;
END$$

DELIMITER ;
