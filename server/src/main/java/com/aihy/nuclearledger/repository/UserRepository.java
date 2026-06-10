package com.aihy.nuclearledger.repository;

import com.aihy.nuclearledger.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsernameAndAppId(String username, Long appId);

    boolean existsByUsernameAndAppId(String username, Long appId);

}
