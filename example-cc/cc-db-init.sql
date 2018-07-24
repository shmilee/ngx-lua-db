-- MySQL Distrib 10.2.15-MariaDB, for Linux (x86_64)
-- Host: localhost    Database: cultural_centre

CREATE USER 'ccadmin'@'localhost' IDENTIFIED BY 'admin_pass';
CREATE USER 'ccsetter'@'localhost' IDENTIFIED BY 'setter_pass';
CREATE USER 'ccgetter'@'localhost' IDENTIFIED BY 'getter_pass';

CREATE DATABASE cultural_centre;
USE cultural_centre;

--
-- Table structure for table `users`
-- u_group(user_group) TINYINT, 0:admin, 1:author
--

CREATE TABLE IF NOT EXISTS `users` (
    u_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    passwd VARCHAR(100) NOT NULL,
    u_group TINYINT UNSIGNED NOT NULL DEFAULT 1,
    employer VARCHAR(50) NOT NULL,
    CONSTRAINT chk_grp CHECK (u_group<2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `activities`
-- priority TINYINT, -1:pass, 0:off, 1:on
-- author VARCHAR, name in user table
-- a_type VARCHAR, 类别: 电影 展览 培训 演出 讲座 其他
-- reservation VARCHAR, 预约: 个人 摇号 团体 免预约 其他
--

CREATE TABLE IF NOT EXISTS activities (
    a_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    priority TINYINT NOT NULL DEFAULT 1,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    a_host VARCHAR(100) NOT NULL,
    contact VARCHAR(100) NOT NULL,
    submission_datetime DATETIME NOT NULL,
    start_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    location VARCHAR(200) NOT NULL,
    a_type VARCHAR(20) NOT NULL,
    reservation VARCHAR(20) NOT NULL,
    introduction TEXT NOT NULL,
    CONSTRAINT chk_itude CHECK (longitude<90 AND longitude>-90 AND latitude<180 AND latitude>-180)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GRANT ALL ON cultural_centre.users TO 'ccadmin'@'localhost';
GRANT ALL ON cultural_centre.activities TO 'ccsetter'@'localhost';
GRANT SELECT ON cultural_centre.activities TO 'ccgetter'@'localhost';
