package com.acme.ems.job;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ArchivedEmployeeCleanupJob {

    @Scheduled(cron = "0 0 * * * ?")
    public void cleanup() {
        System.out.println("Archived employee cleanup executed.");
    }
}
