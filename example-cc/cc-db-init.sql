-- MySQL Distrib 10.2.15-MariaDB, for Linux (x86_64)
-- Host: localhost    Database: cultural_centre

CREATE USER 'ccsetter'@'localhost' IDENTIFIED BY 'setter_pass';
CREATE USER 'ccgetter'@'localhost' IDENTIFIED BY 'getter_pass';

CREATE DATABASE cultural_centre;
USE cultural_centre;

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
    start_datetime DATETIME NOT NULL,
    duration TIME,
    longitude DOUBLE NOT NULL,
    latitude DOUBLE NOT NULL,
    location VARCHAR(200) NOT NULL,
    a_type VARCHAR(20) NOT NULL,
    reservation VARCHAR(20) NOT NULL,
    introduction TEXT NOT NULL,
    CONSTRAINT chk_itude CHECK (longitude<180 AND longitude>-180 AND latitude<90 AND latitude>-90)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

GRANT ALL ON cultural_centre.activities TO 'ccsetter'@'localhost';
GRANT SELECT ON cultural_centre.activities TO 'ccgetter'@'localhost';

-- Tests temp items
INSERT INTO activities (
    priority, title, author, a_host, contact, submission_datetime, start_datetime, duration, longitude, latitude, location, a_type, reservation, introduction) values (
    1, '活动名称1', 'sh', '嘉兴文化馆', '电话123456', '2018-07-12 12:12:12', '2018-07-26 10:00:00', '2:00:00', 120.75964, 30.73644, '五星路88号', '教学', '免预约', 'intro'), (
    2, '活动名称2', 'sh', '嘉兴图书馆', '电话1啊啊23456', '2018-07-12 12:12:12', '2018-07-26 10:00:00', '2:00:00', 120.76442, 30.74467, '五星路88号', '演讲', '免预约', 'intro'), (
    1, '活动名称3', 'sh', '嘉兴文化馆', '电话x123456', '2018-07-12 12:12:12', '2018-07-25 10:00:00', '2:00:00', 120.75964, 30.73644, '五星路88号', '演讲', '免预约', 'intro'), (
    1, '活动名称4', 'sh', '嘉兴文化馆', '电话x123333456', '2018-07-12 12:12:12', '2018-08-25 10:00:00', '2:00:00', 120.75964, 30.73644, '五星路88号', '演讲', '免预约', 'intro'), (
    1, '活动名称6', 'sh', '嘉兴文化馆', '电话123456', '2018-07-12 12:12:12', '2018-07-20 10:00:00', '2:00:00', 120.75964, 30.73644, '五星路88号', '教学', '免预约', 'intro'), (
    2, '活动名称7', 'sh', '嘉兴图书馆', '电话123456', '2018-07-12 12:12:12', '2018-07-28 10:00:00', '2:00:00', 120.76442, 30.74467, '五星路88号', '演讲', '免预约', '中国古代，玉是沟通天地的灵媒和祭祀鬼神的重器。它既是权势和地位的象征，又是士人君子洁身明志的佩饰，更是丧葬中保护死者的圣物。山西古玉，温润，美丽，典雅，厚重，是中国玉文化的最灿烂的组成部分。'), (
    1, '活动名称8', 'sh', '嘉兴文化馆', '电话x123456', '2018-07-12 12:12:12', '2018-07-31 10:00:00', '2:00:00', 120.75964, 30.73644, '五星路88号', '演讲', '免预约', 'intro');
