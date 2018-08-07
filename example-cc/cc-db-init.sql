-- MySQL Distrib 10.2.15-MariaDB, for Linux (x86_64)
-- Host: localhost    Database: cultural_centre

CREATE DATABASE cultural_centre;
USE cultural_centre;

--
-- Table structure for `submitter`
--

CREATE TABLE IF NOT EXISTS `submitter` (
    sid INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    passwd VARCHAR(100) NOT NULL,
    salt VARCHAR(100) NOT NULL,
    sgroup TINYINT UNSIGNED NOT NULL DEFAULT 1,
    employer VARCHAR(50) NOT NULL,
    access_token VARCHAR(100) NOT NULL,
    reserve VARCHAR(100) NOT NULL,
    CONSTRAINT chk_grp CHECK (sgroup<2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for `citizen`
--

CREATE TABLE IF NOT EXISTS `citizen` (
    cid INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    wx_openid VARCHAR(100) UNIQUE NOT NULL,
    wx_session_key VARCHAR(100) NOT NULL,
    access_token VARCHAR(100) NOT NULL,
    reserve VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for `activity`
-- priority, 0:off, 1:on
-- author, name in table `submitter`
-- a_type, 类别: 电影 展览 培训 演出 讲座 其他
-- reservation, 预约: 个人 摇号 团体 免预约 其他
--

CREATE TABLE IF NOT EXISTS `activity` (
    aid INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    priority TINYINT UNSIGNED NOT NULL DEFAULT 1,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    a_host VARCHAR(100) NOT NULL,
    contact VARCHAR(100) NOT NULL,
    submission_datetime DATETIME NOT NULL,
    start_datetime DATETIME NOT NULL,
    duration TIME NOT NULL,
    longitude DOUBLE NOT NULL,
    latitude DOUBLE NOT NULL,
    location VARCHAR(200) NOT NULL,
    a_type VARCHAR(20) NOT NULL,
    reservation VARCHAR(20) NOT NULL,
    introduction TEXT NOT NULL,
    reserve VARCHAR(200) NOT NULL,
    CONSTRAINT fk_author FOREIGN KEY(author) REFERENCES submitter(name) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_itude CHECK (longitude<180 AND longitude>-180 AND latitude<90 AND latitude>-90)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for `favorite`
-- citizen <-> activity
--

CREATE TABLE IF NOT EXISTS `favorite` (
    cid INT UNSIGNED,
    aid INT UNSIGNED,
    CONSTRAINT pk_ca PRIMARY KEY(cid, aid),
    CONSTRAINT fk_citizen FOREIGN KEY(cid) REFERENCES citizen(cid) ON DELETE CASCADE,
    CONSTRAINT fk_activity FOREIGN KEY(aid) REFERENCES activity(aid) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- USER
--

CREATE USER 'ccadmin'@'localhost' IDENTIFIED BY 'ccadmin_pass';
GRANT ALL ON cultural_centre.* TO 'ccadmin'@'localhost';

CREATE USER 'ccsetter'@'localhost' IDENTIFIED BY 'ccsetter_pass';
GRANT ALL ON cultural_centre.activity TO 'ccsetter'@'localhost';
GRANT SELECT, UPDATE ON cultural_centre.submitter TO 'ccsetter'@'localhost';

CREATE USER 'ccgetter'@'localhost' IDENTIFIED BY 'ccgetter_pass';
GRANT ALL ON cultural_centre.citizen TO 'ccgetter'@'localhost';
GRANT SELECT ON cultural_centre.activity TO 'ccgetter'@'localhost';
GRANT ALL ON cultural_centre.favorite TO 'ccgetter'@'localhost';
