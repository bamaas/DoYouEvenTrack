--liquibase formatted sql
--changeset test:1
CREATE SCHEMA xyz;
DROP SCHEMA xyz CASCADE;