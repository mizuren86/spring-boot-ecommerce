package com.luv2code.ecommerce.member.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.luv2code.ecommerce.member.entity.UserVipHistory;

@Repository
public interface UserVipHistoryRepository extends JpaRepository<UserVipHistory, Integer> {
}