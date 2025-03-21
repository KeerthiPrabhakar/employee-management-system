package com.acme.ems.model;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;


public class TempEmployeeDetails {

    @Id
    @GeneratedValue
    private Long id;
    private String name;

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}