package com.luv2code.ecommerce.member.entity;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonBackReference;
import java.time.LocalDate;

@Entity
@Table(name = "user_vip")
public class UserVip {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer vipId;

    @JsonBackReference
    @OneToOne
    @JoinColumn(name = "member_id")
    private User user;

    @Column(nullable = false)
    private Boolean isVip = true;

    private Integer vipLevel;

    @Column(nullable = false)
    private LocalDate startDate;

    private LocalDate endDate;

    private String vipPhoto;

    // Getters and Setters
    public Integer getVipId() {
        return vipId;
    }

    public void setVipId(Integer vipId) {
        this.vipId = vipId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Boolean getIsVip() {
        return isVip;
    }

    public void setIsVip(Boolean isVip) {
        this.isVip = isVip;
    }

    public Integer getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(Integer vipLevel) {
        this.vipLevel = vipLevel;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getVipPhoto() {
        return vipPhoto;
    }

    public void setVipPhoto(String vipPhoto) {
        this.vipPhoto = vipPhoto;
    }
}