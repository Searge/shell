#!/bin/env bash

sudo dnf module enable php:7.4

sudo dnf install php-{cli,common,curl,fpm,gd,json,ldap,mbstring,mysqlnd,opcache,pdo,soap,xml,zip}
