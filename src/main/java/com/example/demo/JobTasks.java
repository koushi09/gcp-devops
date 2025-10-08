package com.example.demo;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import java.time.Instant;

@Component
public class JobTasks {

  // Run every 30 seconds for testing
  @Scheduled(fixedRate = 30000)
  public void jobOne() {
    System.out.println("JobOne run at " + Instant.now());
    // do DB ops via a service/repo
  }

  // Cron-style: every minute
  @Scheduled(cron = "0 * * * * *")
  public void jobTwo() {
    System.out.println("JobTwo run at " + Instant.now());
    // do DB ops via a service/repo
  }
}

