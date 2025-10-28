-- Migration: Add PHONE field to USERS table
-- Run this if you already have the database set up

USE professional_network;

-- Add PHONE column to USERS table
ALTER TABLE USERS 
ADD COLUMN PHONE VARCHAR(20) AFTER L_NAME;

-- Verify the change
DESCRIBE USERS;
