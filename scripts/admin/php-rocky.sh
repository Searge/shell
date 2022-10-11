#!/usr/bin/env bash

# Install PHP 7.4 on Rocky Linux 8.4

dnf module enable php:7.4

dnf install php-{cli,common,curl,fpm,gd,json,ldap,mbstring,mysqlnd,opcache,pdo,soap,xml,zip}
