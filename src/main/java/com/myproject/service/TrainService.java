package com.myproject.service;

import com.myproject.entity.SeatInfo;
import com.myproject.entity.TrainSearchInfo;

import java.util.List;
import java.util.Map;

public interface TrainService {
    List<TrainSearchInfo> search(Long fromStationId, Long toStationId, String date, String trainType);

    List<SeatInfo> findSeats(Long scheduleId, Long fromStationId, Long toStationId);

    /**
     * 查经停站
     */
    List<Map<String, Object>> findRoute(Long trainId);
}
