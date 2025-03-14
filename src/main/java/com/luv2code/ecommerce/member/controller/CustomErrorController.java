package com.luv2code.ecommerce.member.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.ResponseEntity;
import java.util.Map;

@RestController
public class CustomErrorController implements ErrorController {

    @GetMapping("/error")
    public ResponseEntity<Map<String, Object>> handleError() {
        Map<String, Object> body = Map.of(
                "status", "error",
                "message", "發生錯誤，請檢查日誌",
                "timestamp", new java.util.Date());
        return ResponseEntity.internalServerError().body(body);
    }
}