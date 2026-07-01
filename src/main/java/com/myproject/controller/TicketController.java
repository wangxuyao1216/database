package com.myproject.controller;

import com.myproject.entity.Result;
import com.myproject.service.TicketService;
import com.myproject.util.CurrentHolder;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    @Autowired
    private TicketService ticketService;

    /**
     * 1. 购票
     */
    @PostMapping
    public Result buy(@Valid @RequestBody TicketService.TicketRequest req) {
        Long userId = CurrentHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        req.setUserId(userId);
        log.info("购票请求: userId={}, scheduleId={}, seatId={}", 
                 userId, req.getScheduleId(), req.getSeatId());
        return ticketService.buy(req);
    }

    /**
     * 2. 退票
     * 
     * 退票规则：
     * - 仅支持退还未出发的车票
     * - 距离开车时间不足2小时，收取20%退票费
     * - 距离开车时间不足24小时，收取10%退票费
     * - 距离开车时间超过24小时，免费退票
     * 
     * @param orderId 订单ID
     * @return 退票结果
     */
    @DeleteMapping("/{orderId}")
    public Result cancelOrder(@PathVariable Long orderId) {
        Long userId = CurrentHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        log.info("退票请求: orderId={}, userId={}", orderId, userId);
        return ticketService.cancelOrder(orderId, userId);
    }

    /**
     * 3. 查询我的订单列表
     */
    @GetMapping("/my-orders")
    public Result getMyOrders(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer size,
            @RequestParam(required = false) Integer status) {
        Long userId = CurrentHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        log.info("查询订单列表: userId={}, page={}, size={}, status={}", 
                 userId, page, size, status);
        return ticketService.getMyOrders(userId, page, size, status);
    }

    /**
     * 4. 查询订单详情
     */
    @GetMapping("/{orderId}")
    public Result getOrderDetail(@PathVariable Long orderId) {
        Long userId = CurrentHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        log.info("查询订单详情: orderId={}, userId={}", orderId, userId);
        return ticketService.getOrderDetail(orderId, userId);
    }
}
