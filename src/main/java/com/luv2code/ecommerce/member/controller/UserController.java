package com.luv2code.ecommerce.member.controller;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.luv2code.ecommerce.member.dto.LoginDTO;
import com.luv2code.ecommerce.member.dto.RegisterDTO;
import com.luv2code.ecommerce.member.dto.UserDTO;
import com.luv2code.ecommerce.member.dto.UserVipDTO;
import com.luv2code.ecommerce.member.entity.User;
import com.luv2code.ecommerce.member.service.JwtService;
import com.luv2code.ecommerce.member.service.UserService;
import com.luv2code.ecommerce.member.service.VerificationService;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "http://localhost:8091", allowCredentials = "true")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private VerificationService verificationService;

    @Autowired
    private JwtService jwtService;

    // 註冊新用戶
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody UserDTO userDTO) {
        try {
            User user = userService.createUser(userDTO);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 用戶登入
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginDTO loginDTO) {
        try {
            User user = userService.validateLogin(loginDTO.getUsername(), loginDTO.getPassword());

            // 生成 JWT token
            String token = jwtService.generateToken(user.getUsername());

            // 創建 HTTP-only cookie
            ResponseCookie cookie = ResponseCookie.from("jwt", token)
                    .httpOnly(true)
                    .secure(false) // 在生產環境中應該設為 true
                    .path("/")
                    .maxAge(24 * 60 * 60) // 24 小時
                    .sameSite("Strict")
                    .build();

            // 構建響應
            Map<String, Object> response = new HashMap<>();
            response.put("username", user.getUsername());
            response.put("fullName", user.getFullName());
            response.put("email", user.getEmail());

            return ResponseEntity.ok()
                    .header(HttpHeaders.SET_COOKIE, cookie.toString())
                    .body(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 獲取當前登入用戶
    @GetMapping("/current")
    public ResponseEntity<?> getCurrentUser(@CookieValue(name = "jwt", required = false) String token) {
        if (token == null) {
            return ResponseEntity.badRequest().body("未登入");
        }

        try {
            String username = jwtService.extractUsername(token);
            User user = userService.findByUsername(username);

            if (user != null && jwtService.isTokenValid(token, username)) {
                return ResponseEntity.ok(user);
            }

            return ResponseEntity.badRequest().body("未登入");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("未登入");
        }
    }

    // 用戶登出
    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        ResponseCookie cookie = ResponseCookie.from("jwt", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0)
                .sameSite("Strict")
                .build();

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .body("登出成功");
    }

    // 更新用戶資料
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Integer id, @RequestBody UserDTO userDTO) {
        try {
            User updatedUser = userService.updateUser(id, userDTO);
            return ResponseEntity.ok(updatedUser);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 刪除用戶
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Integer id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok("用戶已刪除");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 獲取所有用戶
    @GetMapping("/all")
    public ResponseEntity<?> getAllUsers() {
        try {
            List<User> users = userService.getAllUsers();
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 獲取用戶表格數據
    @GetMapping("/tables")
    public ResponseEntity<?> getTableData() {
        try {
            List<User> users = userService.getAllUsers();
            Map<String, Object> response = new HashMap<>();

            // 用戶表數據 - 基本信息
            List<Map<String, Object>> usersTable = users.stream().map(user -> {
                Map<String, Object> userData = new HashMap<>();
                userData.put("memberId", user.getMemberId());
                userData.put("username", user.getUsername());
                userData.put("email", user.getEmail());
                userData.put("fullName", user.getFullName());
                userData.put("phone", user.getPhone());
                userData.put("address", user.getAddress());
                return userData;
            }).distinct().collect(Collectors.toList());
            response.put("usersTable", usersTable);

            // VIP表數據 - 只包含有VIP的用戶
            List<Map<String, Object>> vipTable = users.stream()
                    .filter(user -> user.getUserVip() != null)
                    .map(user -> {
                        Map<String, Object> vipData = new HashMap<>();
                        vipData.put("vipId", user.getUserVip().getVipId());
                        vipData.put("memberId", user.getMemberId());
                        vipData.put("isVip", user.getUserVip().getIsVip());
                        vipData.put("vipLevel", user.getUserVip().getVipLevel());
                        vipData.put("startDate", user.getUserVip().getStartDate());
                        vipData.put("endDate", user.getUserVip().getEndDate());
                        vipData.put("vipPhoto", user.getUserVip().getVipPhoto());
                        return vipData;
                    }).distinct().collect(Collectors.toList());
            response.put("vipTable", vipTable);

            // VIP歷史表數據 - 確保每條歷史記錄只出現一次
            List<Map<String, Object>> historyTable = users.stream()
                    .flatMap(user -> user.getVipHistories().stream())
                    .map(history -> {
                        Map<String, Object> historyData = new HashMap<>();
                        historyData.put("historyId", history.getHistoryId());
                        historyData.put("memberId", history.getUser().getMemberId());
                        historyData.put("vipLevel", history.getVipLevel());
                        historyData.put("startDate", history.getStartDate());
                        historyData.put("endDate", history.getEndDate());
                        historyData.put("vipPhoto", history.getVipPhoto());
                        return historyData;
                    }).distinct().collect(Collectors.toList());
            response.put("historyTable", historyTable);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 創建帶VIP信息的用戶
    @PostMapping("/with-vip")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> createUserWithVip(@RequestBody Map<String, Object> request) {
        try {
            UserDTO userDTO = new UserDTO();
            // 設置用戶信息
            Map<String, Object> userData = (Map<String, Object>) request.get("user");
            userDTO.setUsername((String) userData.get("username"));
            userDTO.setPassword((String) userData.get("password"));
            userDTO.setEmail((String) userData.get("email"));
            userDTO.setFullName((String) userData.get("fullName"));
            userDTO.setPhone((String) userData.get("phone"));
            userDTO.setAddress((String) userData.get("address"));

            // 設置VIP信息
            UserVipDTO vipDTO = null;
            if (request.containsKey("vip")) {
                Map<String, Object> vipData = (Map<String, Object>) request.get("vip");
                vipDTO = new UserVipDTO();
                vipDTO.setIsVip((Boolean) vipData.get("isVip"));
                vipDTO.setVipLevel((Integer) vipData.get("vipLevel"));
                vipDTO.setStartDate(LocalDate.parse((String) vipData.get("startDate")));
                vipDTO.setEndDate(LocalDate.parse((String) vipData.get("endDate")));
                vipDTO.setVipPhoto((String) vipData.get("vipPhoto"));
            }

            User user = userService.createUserWithVip(userDTO, vipDTO);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 批次更新所有用戶密碼為加密格式
    @PostMapping("/batch-encrypt-passwords")
    public ResponseEntity<?> batchEncryptPasswords(@RequestBody Map<String, String> request) {
        try {
            String adminKey = request.get("adminKey");
            // 簡單的管理員驗證，實際應用中應該使用更安全的方式
            if (!"your-admin-key".equals(adminKey)) {
                return ResponseEntity.badRequest().body("管理員密鑰錯誤");
            }

            List<Map<String, Object>> results = userService.batchUpdatePasswords();
            Map<String, Object> response = new HashMap<>();
            response.put("totalProcessed", results.size());
            response.put("results", results);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("批次更新密碼時發生錯誤: " + e.getMessage());
            return ResponseEntity.badRequest().body(Map.of(
                    "status", "error",
                    "message", "批次更新密碼時發生錯誤: " + e.getMessage()));
        }
    }

    // 發送驗證碼
    @PostMapping("/send-verification")
    public ResponseEntity<?> sendVerification(@RequestBody Map<String, String> request) {
        try {
            String contact = request.get("email");
            if (contact == null) {
                contact = request.get("phone");
            }

            if (contact == null) {
                return ResponseEntity.badRequest().body("需要提供email或手機號碼");
            }

            // 生成驗證碼
            String code = verificationService.generateCode(contact);

            // TODO: 實際發送驗證碼（這裡先模擬）
            System.out.println("驗證碼已發送到 " + contact + ": " + code);

            return ResponseEntity.ok("驗證碼已發送");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 驗證並註冊
    @PostMapping("/register-with-verification")
    public ResponseEntity<?> registerWithVerification(@RequestBody RegisterDTO registerDTO) {
        try {
            // 驗證碼檢查
            String contact = registerDTO.getEmail() != null ? registerDTO.getEmail() : registerDTO.getPhone();

            if (!verificationService.verifyCode(contact, registerDTO.getVerificationCode())) {
                return ResponseEntity.badRequest().body("驗證碼無效或已過期");
            }

            // 創建用戶
            UserDTO userDTO = new UserDTO();
            userDTO.setUsername(registerDTO.getUsername());
            userDTO.setPassword(registerDTO.getPassword());
            userDTO.setEmail(registerDTO.getEmail());
            userDTO.setPhone(registerDTO.getPhone());
            userDTO.setFullName(registerDTO.getFullName());

            User user = userService.createUser(userDTO);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}