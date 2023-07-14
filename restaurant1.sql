-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurant
-- ------------------------------------------------------
-- Server version	8.0.33
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */
;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */
;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */
;
/*!50503 SET NAMES utf8 */
;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */
;
/*!40103 SET TIME_ZONE='+00:00' */
;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */
;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */
;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */
;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */
;
--
-- Table structure for table `menu_items`
--
DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */
;
/*!50503 SET character_set_client = utf8mb4 */
;
CREATE TABLE `menu_items` (
    `id` int NOT NULL AUTO_INCREMENT,
    `name` varchar(255) DEFAULT NULL,
    `price` decimal(10, 2) DEFAULT NULL,
    `description` text,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 13 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */
;
--
-- Dumping data for table `menu_items`
--
LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */
;
INSERT INTO `menu_items`
VALUES (6, '大闸蟹', 138.00, NULL),
    (7, '青岛啤酒', 6.00, NULL),
    (8, '帝王蟹', 6888.00, NULL),
    (9, '土豆炒肉', 52.00, NULL),
    (10, '雪花啤酒', 8.00, NULL),
    (11, '青椒土豆丝', 32.00, NULL),
    (12, '雪花牛肉', 188.00, NULL);
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */
;
UNLOCK TABLES;
--
-- Table structure for table `orders`
--
DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */
;
/*!50503 SET character_set_client = utf8mb4 */
;
CREATE TABLE `orders` (
    `id` int NOT NULL AUTO_INCREMENT,
    `user` varchar(100) NOT NULL,
    `timestamp` timestamp NOT NULL,
    `total` decimal(10, 2) NOT NULL,
    `items` text NOT NULL,
    `isSubmitted` tinyint(1) DEFAULT '0',
    `isConfirmed` tinyint(1) DEFAULT '0',
    `isCompleted` tinyint(1) DEFAULT '0',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 33 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */
;
--
-- Dumping data for table `orders`
--
LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */
;
INSERT INTO `orders`
VALUES (
        1,
        'customer',
        '2023-07-04 06:17:29',
        13972.00,
        '{\"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 2, \"price\": 6888}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6}, \"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138}}',
        0,
        0,
        0
    ),
    (
        2,
        'customer',
        '2023-07-04 06:24:39',
        13776.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 2, \"price\": 6888}}',
        0,
        0,
        0
    ),
    (
        3,
        'customer',
        '2023-07-04 06:29:30',
        6998.00,
        '{\"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 2, \"price\": 52}}',
        0,
        0,
        0
    ),
    (
        4,
        'customer',
        '2023-07-04 06:36:31',
        1380.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 10, \"price\": 138}}',
        0,
        0,
        0
    ),
    (
        5,
        'customer',
        '2023-07-04 06:40:21',
        68880.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 10, \"price\": 6888}}',
        0,
        0,
        0
    ),
    (
        6,
        'customer',
        '2023-07-04 06:42:15',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52}}',
        0,
        0,
        0
    ),
    (
        7,
        'customer',
        '2023-07-04 08:37:07',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        0,
        0
    ),
    (
        8,
        'customer',
        '2023-07-04 08:42:09',
        6.00,
        '{\"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}}',
        0,
        0,
        0
    ),
    (
        9,
        'customer',
        '2023-07-04 08:45:08',
        52.00,
        '{\"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        0,
        0
    ),
    (
        10,
        'customer',
        '2023-07-04 08:50:31',
        138.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}}',
        0,
        0,
        0
    ),
    (
        11,
        'customer',
        '2023-07-04 08:53:58',
        6.00,
        '{\"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        12,
        'customer',
        '2023-07-04 08:56:29',
        138.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        13,
        'customer',
        '2023-07-04 08:57:27',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        14,
        'customer',
        '2023-07-04 09:00:22',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        15,
        'customer',
        '2023-07-04 09:02:55',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        16,
        'customer',
        '2023-07-04 09:06:07',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        17,
        'customer',
        '2023-07-04 11:08:31',
        52.00,
        '{\"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        18,
        'customer',
        '2023-07-04 11:12:34',
        6888.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}}',
        0,
        1,
        1
    ),
    (
        19,
        'customer',
        '2023-07-04 11:22:36',
        6888.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true, \"status\": \"completed\"}}',
        1,
        1,
        1
    ),
    (
        20,
        'customer',
        '2023-07-04 11:25:23',
        6888.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        21,
        'customer',
        '2023-07-04 11:27:27',
        6.00,
        '{\"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        22,
        'customer',
        '2023-07-04 11:31:46',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true, \"status\": \"completed\"}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true, \"status\": \"completed\"}}',
        1,
        1,
        1
    ),
    (
        23,
        'customer',
        '2023-07-04 13:53:45',
        7246.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 2, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 5, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        24,
        'customer',
        '2023-07-05 01:53:38',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        25,
        'customer',
        '2023-07-05 02:06:23',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        26,
        'customer',
        '2023-07-05 02:17:26',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        27,
        'customer',
        '2023-07-05 02:23:07',
        7084.00,
        '{\"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        28,
        'customer',
        '2023-07-05 02:26:00',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        29,
        'customer',
        '2023-07-05 03:59:10',
        7084.00,
        '{\"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": true, \"isServed\": true}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": true}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": true}, \"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": true}}',
        1,
        1,
        1
    ),
    (
        30,
        'customer',
        '2023-07-05 04:04:54',
        7084.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}}',
        1,
        1,
        0
    ),
    (
        31,
        'customer',
        '2023-07-05 04:05:38',
        7124.00,
        '{\"\\u9752\\u6912\\u571f\\u8c46\\u4e1d\": {\"count\": 1, \"price\": 32, \"isPrepared\": false, \"isServed\": false}, \"\\u96ea\\u82b1\\u5564\\u9152\": {\"count\": 1, \"price\": 8, \"isPrepared\": false, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": false, \"isServed\": false}, \"\\u5e1d\\u738b\\u87f9\": {\"count\": 1, \"price\": 6888, \"isPrepared\": false, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": false, \"isServed\": false}, \"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": false, \"isServed\": false}}',
        1,
        1,
        0
    ),
    (
        32,
        'customer',
        '2023-07-05 04:21:02',
        236.00,
        '{\"\\u5927\\u95f8\\u87f9\": {\"count\": 1, \"price\": 138, \"isPrepared\": true, \"isServed\": false}, \"\\u9752\\u5c9b\\u5564\\u9152\": {\"count\": 1, \"price\": 6, \"isPrepared\": true, \"isServed\": false}, \"\\u571f\\u8c46\\u7092\\u8089\": {\"count\": 1, \"price\": 52, \"isPrepared\": true, \"isServed\": false}, \"\\u96ea\\u82b1\\u5564\\u9152\": {\"count\": 1, \"price\": 8, \"isPrepared\": true, \"isServed\": false}, \"\\u9752\\u6912\\u571f\\u8c46\\u4e1d\": {\"count\": 1, \"price\": 32, \"isPrepared\": true, \"isServed\": false}}',
        1,
        1,
        0
    );
/*!40000 ALTER TABLE `orders` ENABLE KEYS */
;
UNLOCK TABLES;
--
-- Table structure for table `users`
--
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */
;
/*!50503 SET character_set_client = utf8mb4 */
;
CREATE TABLE `users` (
    `id` int NOT NULL AUTO_INCREMENT,
    `username` varchar(50) NOT NULL,
    `password_hash` varchar(512) DEFAULT NULL,
    `identity` varchar(20) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`)
) ENGINE = InnoDB AUTO_INCREMENT = 7 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */
;
--
-- Dumping data for table `users`
--
LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */
;
INSERT INTO `users`
VALUES (
        1,
        '1号桌子',
        'pbkdf2:sha256:600000$A0CZJ7iqFitmexTf$4cd1e377bb8e146b0577fd708f196216acef6c7a689089e30c5aa3964fcfed6c',
        '顾客'
    ),
    (
        2,
        '小夏',
        'pbkdf2:sha256:600000$m54G5ZtPaiB3T2KC$e7179db45bd841fef3f4b2b1165c88ccad6b871ac876261b6362b0405a8c6248',
        '厨师'
    ),
    (
        3,
        '秋红',
        'pbkdf2:sha256:600000$I2Tr82PGKgMjdP67$65bba156e973d34dd5a5528d3649a33c778d70af48f9d06427ee810001db7c37',
        '老板'
    ),
    (
        4,
        '2号桌子',
        'pbkdf2:sha256:600000$aPngEWIUiEVbHdkq$1cf087a1b621dcc8f5117562553d5e0e21938650f06dff72603d573f64e7bf9a',
        '顾客'
    ),
    (
        5,
        '小梅',
        'pbkdf2:sha256:600000$yVCgqSIexpq4MRjC$19e834bedea6035cd7d707ec38de1fe91f816726542743e53112f87d5aef9f51',
        '服务员'
    ),
    (
        6,
        '4号桌子',
        'pbkdf2:sha256:600000$hH9bdIVCY04womX6$3478a8cb209ce851786c7ed9a58113b6b2559cfe5e36b30466f98976b83a1c10',
        '顾客'
    );
/*!40000 ALTER TABLE `users` ENABLE KEYS */
;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */
;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */
;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */
;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */
;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */
;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */
;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */
;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */
;
-- Dump completed on 2023-07-06  8:46:44