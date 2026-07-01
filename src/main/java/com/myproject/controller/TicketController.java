package com.myproject.controller;

import com.myproject.entity.Result;
import com.myproject.service.TicketService;
import com.myproject.util.CurreetHolder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
@Slf4j
@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    @Autowired
    private TicketService ticketService;

    @PostMapping
    public Result buy(@RequestBody TicketService.TicketRequest req) {
        return ticketService.buy(req);
    }

    /**
     * 2. 退票
     * @param orderId 订单ID
     * @return 退票结果
     */
    @DeleteMapping("/{orderId}")
    public Result cancelOrder(@PathVariable Long orderId) {
        Long userId = CurreetHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        log.info("退票请求: orderId={}, userId={}", orderId, userId);
        return ticketService.cancelOrder(orderId);
    }

    /**
     * 3. 查询我的订单列表
     */
    @GetMapping("/my-orders")
    public Result getMyOrders(
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "10") Integer size,
            @RequestParam(required = false) Integer status) {
        Long userId = CurreetHolder.getCurrentId();
        if (userId == null) {
            return Result.error("请先登录");
        }
        log.info("查询订单列表: userId={}, page={}, size={}, status={}",
                userId, page, size, status);
        return ticketService.getMyOrders(userId, page, size, status);
    }
}
