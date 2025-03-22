package com.acme.ems.logging;

import org.springframework.stereotype.Component;

@Component
public class EmployeeAuditLogger {
    public void log(String message) {
        System.out.println("AUDIT: " + message);
    }
}
