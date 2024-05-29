package com.example.capstone.api.repository;

import com.example.capstone.api.model.Route;
import com.example.capstone.member.model.Member;
import org.springframework.data.domain.Example;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.FluentQuery;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.function.Function;

public interface RouteRepository extends JpaRepository<Route, Long> {

    List<Route> findByMemberUuid(final String uuid);
    List<Route> findByMember(final Member member);
    @Transactional(rollbackFor = Exception.class)
    void deleteAllByMemberUuid(String uuid);
}
