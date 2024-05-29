package com.example.capstone.api.repository;

import com.example.capstone.api.model.Route;
import com.example.capstone.member.model.Member;
import com.example.capstone.member.repository.MemberRepository;
import jakarta.persistence.EntityManager;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.cassandra.DataCassandraTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import javax.swing.text.html.parser.Entity;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
class RouteRepositoryTest {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private EntityManager em;

    @Test
    void assert_notNull() {
        assertNotNull(memberRepository);
        assertNotNull(routeRepository);
    }

    @Test
    void assert_findByMemberUuid() {
        Member member = new Member();
        member.setUuid("정회창");
        memberRepository.save(member);
        Route route = new Route();
        route.setMember(member);
        route.setPointIndex(68L);
        routeRepository.save(route);
        em.flush();
        em.clear();
        System.out.println("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
        List<Route> byMemberUuid = routeRepository.findByMemberUuid(
                member.getUuid()
        );
        em.flush();
        em.clear();
        System.out.println("ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ");
        routeRepository.findByMember(member);

        System.out.println();
    }
}