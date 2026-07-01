package com.myproject.mapper;

import org.apache.ibatis.annotations.Mapper;
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
     * 退票 — 调用 sp_cancel_ticket 存储过程
     * 传入 params Map，OUT 参数 p_result_code/p_result_msg 会回填到同一个 Map 里
     * 
     * params 需要包含：
     *   - p_order_id: 订单ID (IN)
     *   - p_refund_amount: 退款金额 (IN)
     *   - p_user_id: 用户ID (IN)
     *   - p_result_code: 结果码 (OUT)
     *   - p_result_msg: 结果消息 (OUT)
     */
    void cancelTicket(Map<String, Object> params);

    /**
     * 根据订单ID查询车票
     */
    @Select("SELECT * FROM ticket WHERE order_id = #{orderId}")
    List<Map<String, Object>> findByOrderId(@Param("orderId") Long orderId);

    /**
     * 根据订单ID更新车票状态
     */
    @Select("UPDATE ticket SET status = #{status} WHERE order_id = #{orderId}")
    void updateStatusByOrderId(@Param("orderId") Long orderId, @Param("status") Integer status);
}
