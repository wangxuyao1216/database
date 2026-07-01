package com.myproject.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.One;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface TicketMapper {

    /**
     * 购票 — 调用 sp_book_ticket 存储过程
     * 传入 params Map，OUT 参数 resultCode/resultMsg/orderId 会回填到同一个 Map 里
     */
    void bookTicket(Map<String, Object> params);

    /**
     * 退票 — 调用 sp_refund_ticket 存储过程
     * 传入 params Map，OUT 参数 p_result_code/p_result_msg 会回填到同一个 Map 里
     *
     * params 需要包含：
     *     IN p_ticket_id BIGINT,
     *     IN p_refund_reason VARCHAR(500),
     *     OUT p_result_code INT,结果码
     *     OUT p_result_msg VARCHAR(200),结果消息
     *     OUT p_refund_amount DECIMAL(10,2)退款金额
     */
    void cancelTicket(Map<String, Object> params);


    /**
     * 从ticket_order表里面找相应的数据构成Map给TicketServiceImpl下的退票方法cancerOder使用
     * @param id
     * @return
     */

    Map<String, Object> findById(@Param("orderId") Long id);

    /**
     * 查询我的订单 — 调用 sp_get_user_orders 存储过程
     */
    List<Map<String, Object>> getMyOrders(Map<String, Object> params);

    /**
     * 统计用户订单总数
     */
    int countMyOrders(@Param("userId") Long userId);
}
