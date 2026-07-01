package com.myproject.service;

import com.myproject.entity.Result;
import lombok.Data;
import java.math.BigDecimal;

public interface TicketService {

    Result cancelOrder(Long orderId);

    @Data
    class TicketRequest {
        private Long scheduleId;
        private Long seatId;
        private Long carriageId;
        private Long fromStationId;
        private Long toStationId;
        private String passengerName;
        private String passengerIdNumber;
        private BigDecimal ticketPrice;
        private String seatType;
        private String scheduleDate;   // yyyy-MM-dd，从查车次结果中拿
    }

    Result buy(TicketRequest req);

    /**
     * 查询我的订单列表（分页）
     */
    Result getMyOrders(Long userId, Integer page, Integer size, Integer status);
}
