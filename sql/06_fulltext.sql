-- ============================================
-- 火车售票管理系统 - 全文检索
-- 使用MySQL原生FULLTEXT索引实现高效文本搜索
-- 对比LIKE查询和全文检索的性能差异
-- ============================================

USE train_ticket_db;

-- ============================================
-- 1. 全文索引已在建表时创建:
-- station表: FULLTEXT KEY `ft_station_name` (`station_name`, `city`, `province`)
-- ============================================

-- ============================================
-- 2. 添加更多全文索引
-- ============================================

-- 列车表全文索引 (车次号、列车名称搜索)
ALTER TABLE train ADD FULLTEXT INDEX ft_train_number_name (train_number, train_name);

-- ============================================
-- 3. 全文检索查询示例
-- ============================================

-- 自然语言模式搜索车站:
-- SELECT station_name, city, province,
--        MATCH(station_name, city, province) AGAINST('北京' IN NATURAL LANGUAGE MODE) AS relevance
-- FROM station
-- WHERE MATCH(station_name, city, province) AGAINST('北京' IN NATURAL LANGUAGE MODE)
-- ORDER BY relevance DESC;

-- 布尔模式搜索 (支持 +必须包含 -必须排除):
-- SELECT * FROM station
-- WHERE MATCH(station_name, city, province) AGAINST('+北京 -西' IN BOOLEAN MODE);

-- 搜索列车:
-- SELECT train_number, train_name,
--        MATCH(train_number, train_name) AGAINST('G101' IN NATURAL LANGUAGE MODE) AS score
-- FROM train
-- WHERE MATCH(train_number, train_name) AGAINST('G101' IN NATURAL LANGUAGE MODE);

-- ============================================
-- 4. 全文检索存储过程
-- ============================================
DELIMITER //

CREATE PROCEDURE sp_fulltext_search_station(
    IN p_keyword VARCHAR(100)
)
BEGIN
    -- 使用全文检索搜索车站
    SELECT
        station_name,
        station_code,
        city,
        province,
        MATCH(station_name, city, province) AGAINST(p_keyword IN NATURAL LANGUAGE MODE) AS relevance
    FROM station
    WHERE MATCH(station_name, city, province) AGAINST(p_keyword IN NATURAL LANGUAGE MODE)
    ORDER BY relevance DESC
    LIMIT 20;
END //

CREATE PROCEDURE sp_fulltext_search_train(
    IN p_keyword VARCHAR(100)
)
BEGIN
    SELECT
        t.train_number,
        t.train_name,
        t.train_type,
        MATCH(t.train_number, t.train_name) AGAINST(p_keyword IN NATURAL LANGUAGE MODE) AS relevance
    FROM train t
    WHERE MATCH(t.train_number, t.train_name) AGAINST(p_keyword IN NATURAL LANGUAGE MODE)
    ORDER BY relevance DESC
    LIMIT 20;
END //

DELIMITER ;

-- ============================================
-- 5. 性能对比: FULLTEXT vs LIKE
-- ============================================

-- LIKE方式 (全表扫描，性能差):
-- EXPLAIN SELECT * FROM station WHERE station_name LIKE '%北京%';

-- 全文检索方式 (使用索引，性能好):
-- EXPLAIN SELECT * FROM station
-- WHERE MATCH(station_name, city, province) AGAINST('北京' IN NATURAL LANGUAGE MODE);

-- 结论: 在大数据量下，全文检索相比LIKE '%keyword%'有显著性能提升
-- FULLTEXT索引利用倒排索引技术，避免了全表扫描
-- 特别是在中文分词场景下，建议配合ngram解析器使用
-- ALTER TABLE station ADD FULLTEXT INDEX ft_station_ngram (station_name) WITH PARSER ngram;

-- ============================================
-- 6. 授予全文检索存储过程执行权限
-- ============================================
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_station TO 'train_app'@'localhost';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_station TO 'train_app'@'%';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_train TO 'train_app'@'localhost';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_train TO 'train_app'@'%';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_station TO 'train_staff'@'localhost';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_station TO 'train_staff'@'%';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_train TO 'train_staff'@'localhost';
GRANT EXECUTE ON PROCEDURE train_ticket_db.sp_fulltext_search_train TO 'train_staff'@'%';
