package com.myproject.service.impl;

import com.myproject.annotation.Log;
import com.myproject.entity.OperationType;
import com.myproject.entity.Result;
import com.myproject.mapper.TicketMapper;
import com.myproject.service.TicketService;
import com.myproject.util.AESUtil;
import com.myproject.util.CurreetHolder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class TicketServiceImpl implements TicketService {

    @Autowired
    private TicketMapper ticketMapper;

    // ==================== 退票（新增） ====================

    @Override
    @Transactional
    @Log(TableName = "ticket_order", operationType = OperationType.UPDATE)
    public Result cancelOrder(Long orderId) {
        Long userId = CurreetHolder.getCurrentId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        // 1. 查询订单，注意！这里我改了一下，不是之前的orderMapper调用findById(因为项目中没有这个orderMapper类，你的提交也没有这个类)
        Map<String, Object> order = ticketMapper.findById(orderId);
        if (order == null || order.isEmpty()) {
            return Result.error("订单不存在");
        }

        // 2. 检查权限（只能退自己的票）
        Long orderUserId = (Long) order.get("userId");
        if (!orderUserId.equals(userId)) {
            log.warn("用户 {} 尝试退他人的订单 {}", userId, orderId);
            return Result.error("无权操作此订单");
        }

        // 3. 检查订单状态
        String status = order.get("ticketStatus").toString();
        if (status.equals("REFUNDED")) {
            return Result.error("该订单已退票");
        }
        if (status.equals("CANCELLED")) {
            return Result.error("该订单已取消，无法退票");
        }
        if (status.equals("USED")) {
            return Result.error("该车票已使用，无法退票");
        }

        // 4. 检查是否已发车（scheduleDate 已在 findById 中查出）
        Date scheduleDate = (Date) order.get("scheduleDate");
        Date today = Date.valueOf(LocalDateTime.now().toLocalDate());
        if (scheduleDate.before(today)) {
            return Result.error("列车已发车，无法退票");
        }


        // 5. 计算退票手续费,注意！！！！！！这里不要手动计算了！因为数据库设计的同学已经帮我们写好了存储过程sp_refund_ticket了
//        BigDecimal ticketPrice = (BigDecimal) order.get("ticketPrice");
//        BigDecimal refundAmount = calculateRefundAmountByDate(departureDate, ticketPrice);

        // 6. 调用存储过程退票
        Map<String, Object> params = new HashMap<>();
        params.put("p_ticket_id", orderId);
        params.put("p_refund_reason", "暂无");
        //下面三项是回填项
        params.put("p_result_code", null);
        params.put("p_result_msg", null);
        params.put("p_refund_amount", null);

        ticketMapper.cancelTicket(params);

        int resultCode = (int) params.get("p_result_code");
        String resultMsg = (String) params.get("p_result_msg");

        if (resultCode != 0) {
            return Result.error(resultMsg);
        }

        log.info("退票成功: orderId={}, userId={}",
                orderId, userId);

        Map<String, Object> data = new HashMap<>();
        data.put("orderId", orderId);
        data.put("refundAmount", params.get("p_refund_amount"));  // 把退款金额返回给前端
        data.put("refundTime", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return Result.success(data);
    }

    // ==================== 我的订单 ====================

    @Override
    public Result getMyOrders(Long userId, Integer page, Integer size, Integer status) {
        if (page == null || page < 1) page = 1;
        if (size == null || size < 1) size = 10;

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("page", page);
        params.put("size", size);

        List<Map<String, Object>> orders = ticketMapper.getMyOrders(params);
        int total = ticketMapper.countMyOrders(userId);

        Map<String, Object> data = new HashMap<>();
        data.put("list", orders);
        data.put("total", total);
        data.put("page", page);
        data.put("size", size);
        data.put("totalPages", (total + size - 1) / size);

        return Result.success(data);
    }


    @Log(TableName = "ticket_order", operationType = OperationType.INSERT)
    @Override
    public Result buy(TicketRequest req) {
        Long userId = CurreetHolder.getCurrentId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        // 身份证加密入库
        String encryptedIdNumber = AESUtil.encrypt(req.getPassengerIdNumber());

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("scheduleId", req.getScheduleId());
        params.put("passengerName", req.getPassengerName());
        params.put("passengerIdNumber", encryptedIdNumber);
        params.put("carriageId", req.getCarriageId());
        params.put("seatId", req.getSeatId());
        params.put("fromStationId", req.getFromStationId());
        params.put("toStationId", req.getToStationId());
        params.put("ticketPrice", req.getTicketPrice());
        params.put("seatType", req.getSeatType());
        params.put("scheduleDate", java.sql.Date.valueOf(req.getScheduleDate()));

        ticketMapper.bookTicket(params);

        int resultCode = (int) params.get("resultCode");
        String resultMsg = (String) params.get("resultMsg");

        if (resultCode != 0) {
            return Result.error(resultMsg);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("orderId", params.get("orderId"));
        data.put("resultMsg", resultMsg);
        return Result.success(data);
    }
}
