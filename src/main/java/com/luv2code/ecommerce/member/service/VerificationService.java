package com.luv2code.ecommerce.member.service;

import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.HashMap;
import java.util.Random;
import java.time.LocalDateTime;

@Service
public class VerificationService {
    private Map<String, VerificationData> verificationCodes = new HashMap<>();

    private static class VerificationData {
        String code;
        LocalDateTime expireTime;

        VerificationData(String code) {
            this.code = code;
            this.expireTime = LocalDateTime.now().plusMinutes(5); // 5分鐘有效期
        }
    }

    public String generateCode(String contact) {
        String code = String.format("%06d", new Random().nextInt(999999));
        verificationCodes.put(contact, new VerificationData(code));
        return code;
    }

    public boolean verifyCode(String contact, String code) {
        VerificationData data = verificationCodes.get(contact);
        if (data == null) {
            return false;
        }

        boolean isValid = data.code.equals(code) &&
                LocalDateTime.now().isBefore(data.expireTime);

        if (isValid) {
            verificationCodes.remove(contact); // 使用後刪除驗證碼
        }

        return isValid;
    }
}