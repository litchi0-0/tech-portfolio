package com.aihy.nuclearledger.repository;

import com.aihy.nuclearledger.entity.App;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AppRepository extends JpaRepository<App, Long> {

    Optional<App> findByAppKey(String appKey);

}
