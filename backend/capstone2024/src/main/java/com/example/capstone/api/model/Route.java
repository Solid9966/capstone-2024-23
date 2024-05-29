package com.example.capstone.api.model;

import com.example.capstone.member.model.Member;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.sql.SQLTransactionRollbackException;

@Getter
@Setter
@Entity
@NoArgsConstructor
public class Route {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long pointIndex;

    private String lat;

    private String lon;

    private String description;

    @ManyToOne
    @JoinColumn(name = "member_uuid")
    private Member member;

}
