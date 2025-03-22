package com.acme.ems.util;

public class EmployeeUtils {
    public static String sanitize(String input) {
        return input == null ? "" : input.trim();
    }
}
