-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurant
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `description` text,
  `category` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES (18,'海鲜小咖',588.00,NULL,NULL),(19,'海鲜中咖',888.00,NULL,NULL),(20,'海鲜大咖',1288.00,NULL,NULL),(21,'粉丝扇贝',68.00,NULL,NULL),(22,'粉丝生蚝',88.00,NULL,NULL),(23,'蒜香花甲',48.00,NULL,NULL),(24,'香辣花甲',48.00,NULL,NULL),(25,'海鲜全家福',168.00,NULL,NULL),(26,'小炒肉',58.00,NULL,NULL),(27,'蒜苗回锅肉',58.00,NULL,NULL),(28,'辣子鸡',78.00,NULL,NULL),(29,'水煮肉片',68.00,NULL,NULL),(30,'家常豆腐',30.00,NULL,NULL),(31,'麻婆豆腐',25.00,NULL,NULL),(32,'豆角茄子',28.00,NULL,NULL),(33,'梅菜扣肉',58.00,NULL,NULL),(34,'干锅花菜',32.00,NULL,NULL),(35,'手撕包菜',28.00,NULL,NULL),(36,'蒜蓉地瓜叶',28.00,NULL,NULL),(37,'酸辣土豆丝',28.00,NULL,NULL),(38,'干锅土豆片',35.00,NULL,NULL),(39,'蒜蓉油麦菜',28.00,NULL,NULL),(40,'芙蓉蒸蛋',28.00,NULL,NULL),(41,'西红柿炒蛋',28.00,NULL,NULL),(42,'凉拌牛肉',88.00,NULL,NULL),(43,'川香酥肉',38.00,NULL,NULL),(44,'醋椒小黄瓜',20.00,NULL,NULL),(45,'油酥花生米',20.00,NULL,NULL),(46,'白切鸡',68.00,NULL,NULL),(47,'芝麻饼',28.00,NULL,NULL),(48,'手撕风干鸡',58.00,NULL,NULL),(49,'招牌牛杂',128.00,NULL,NULL),(50,'米椒鸡',68.00,NULL,NULL),(51,'米椒鸭',68.00,NULL,NULL),(52,'香辣鱿鱼',78.00,NULL,NULL),(53,'三鲜汤',35.00,NULL,NULL),(54,'青菜豆腐汤',22.00,NULL,NULL),(55,'海贝冬瓜汤',28.00,NULL,NULL),(56,'西红柿煎蛋汤',28.00,NULL,NULL),(57,'酸菜鱼',68.00,NULL,NULL),(58,'虾兵蟹将',268.00,NULL,NULL),(59,'酸汤肥牛',78.00,NULL,NULL),(60,'水煮牛肉',88.00,NULL,NULL),(61,'小炒黄牛肉',88.00,NULL,NULL),(62,'椰子鸡',128.00,NULL,NULL),(63,'椰子饭',38.00,NULL,NULL),(64,'海南四角豆',32.00,NULL,NULL),(65,'革命野菜',28.00,NULL,NULL),(66,'盐焗鸡半只',48.00,NULL,NULL),(67,'鲍鱼捞饭',28.00,NULL,NULL),(68,'海鲜炒饭',32.00,NULL,NULL),(69,'菠萝炒饭',28.00,NULL,NULL),(70,'海鲜面',38.00,NULL,NULL),(71,'蛋炒饭',20.00,NULL,NULL),(72,'麻辣小面',28.00,NULL,NULL),(73,'西红柿鸡蛋面',28.00,NULL,NULL),(74,'白米饭一个人',3.00,NULL,NULL),(75,'打包盒一个',1.00,NULL,NULL),(76,'美团218',218.00,NULL,NULL),(77,'美团298',298.00,NULL,NULL),(78,'美团304',304.00,NULL,NULL),(79,'美团498.4',498.00,NULL,NULL),(80,'百威',15.00,NULL,NULL),(81,'王老吉',5.00,NULL,NULL),(82,'红牛',8.00,NULL,NULL),(83,'酸豆王',8.00,NULL,NULL),(84,'雪碧',5.00,NULL,NULL),(85,'可乐',5.00,NULL,NULL),(86,'宾得宝',30.00,NULL,NULL),(87,'元气森林',8.00,NULL,NULL),(88,'毛铺大',168.00,NULL,NULL),(89,'毛铺小',25.00,NULL,NULL),(90,'白熊',25.00,NULL,NULL),(91,'1664',25.00,NULL,NULL),(92,'青岛经典',10.00,NULL,NULL),(93,'乌苏',18.00,NULL,NULL),(94,'东星斑一斤',268.00,NULL,NULL),(95,'鲍鱼一斤',188.00,NULL,NULL),(96,'皮皮虾一斤',188.00,NULL,NULL),(97,'波士顿龙虾一斤',238.00,NULL,NULL),(98,'白灼虾一份',88.00,NULL,NULL),(99,'蟹一斤',188.00,NULL,NULL),(100,'象拔蚌 水蚌一个',238.00,NULL,NULL),(101,'象拔蚌 肉蚌一斤',238.00,NULL,NULL),(102,'石斑鱼每条',148.00,NULL,NULL),(103,'白灼加工1斤',30.00,NULL,NULL),(104,'辣炒加工1斤',40.00,NULL,NULL),(105,'纸巾',1.00,NULL,NULL),(106,'奶椰',12.00,NULL,NULL);
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user` varchar(100) NOT NULL,
  `timestamp` timestamp NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `items` text NOT NULL,
  `isSubmitted` tinyint(1) DEFAULT '0',
  `isConfirmed` tinyint(1) DEFAULT '0',
  `isCompleted` tinyint(1) DEFAULT '0',
  `isPaid` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (85,'外6@2023-07-10T17:16:35.066','2023-07-10 17:19:40',65.00,'{\"\\u6d77\\u9c9c\\u7092\\u996d\": {\"count\": 1, \"price\": 32, \"isPrepared\": true, \"isServed\": true}, \"\\u96ea\\u78a7\": {\"count\": 1, \"price\": 5, \"isPrepared\": true, \"isServed\": true}, \"\\u6d77\\u8d1d\\u51ac\\u74dc\\u6c64\": {\"count\": 1, \"price\": 28, \"isPrepared\": true, \"isServed\": true}}',1,1,1,0),(87,'外2@2023-07-10T18:11:55.397','2023-07-10 18:12:26',69.00,'{\"\\u9c8d\\u9c7c\\u635e\\u996d\": {\"count\": 1, \"price\": 28, \"isPrepared\": true, \"isServed\": true}, \"\\u8fa3\\u7092\\u52a0\\u5de51\\u65a4\": {\"count\": 1, \"price\": 40, \"isPrepared\": true, \"isServed\": true}, \"\\u7eb8\\u5dfe\": {\"count\": 1, \"price\": 1, \"isPrepared\": true, \"isServed\": true}}',1,1,1,0),(88,'外2@2023-07-10T18:20:39.999','2023-07-10 18:20:51',12.00,'{\"\\u5976\\u6930\": {\"count\": 1, \"price\": 12, \"isPrepared\": true, \"isServed\": true}}',1,1,1,0),(89,'外4@2023-07-10T18:55:44.022','2023-07-10 19:04:32',498.00,'{\"\\u7f8e\\u56e2498.4\": {\"count\": 1, \"price\": 498, \"isPrepared\": false, \"isServed\": false}}',1,0,0,0);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(512) DEFAULT NULL,
  `identity` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (13,'秋红','pbkdf2:sha256:600000$R0it7d2WtnBFULVq$7866e36c76f639d759ef0eec2f5a4140d9e20b77e9eb3f0d07fe716030aa1614','老板'),(14,'外1','pbkdf2:sha256:600000$q3ptgm781HWdUnui$28d580d63755c1544bce47ee099b4f798c01d66b3c4cc12f2200ca0a75f7cb1f','顾客'),(15,'外2','pbkdf2:sha256:600000$Uwe1Y3twhVFGHHuG$69ca3b7634ddfd69b3c1121bd3aae6e0ecd31426e08de7611f49b13f48c40f3a','顾客'),(16,'外3','pbkdf2:sha256:600000$QMHHTvSXbLrMeDMV$795522e67c44116fb26909d81c464673acfc387d7d012c487d6dbb151f16cd13','顾客'),(17,'外4','pbkdf2:sha256:600000$2hYEhuNcDtYRnJG4$5efd75cb3c255574d93cf0c3443428ccf3c5f33aeaa4b9523a42601b61f19190','顾客'),(18,'外5','pbkdf2:sha256:600000$Ubs91czJtSwwM0tg$c273fa06b376e3d5b042803fd947ed05cda870e74c5f573c11c82e92688dc8e0','顾客'),(19,'外6','pbkdf2:sha256:600000$UxFbw5VOH40tloM8$eaa1afccfb6df3f8c3fd190d31b456be0dc549f5bc3d03c8d5bc5f31a6ff7e1c','顾客'),(20,'外7','pbkdf2:sha256:600000$FvH6LSR4GjhVhHNg$9177dd9efac7fb2210b896252e274ccd00f417a7f56041fa4fb1a83f46317d67','顾客'),(21,'内1','pbkdf2:sha256:600000$DKLWDpija28L1wF6$3ea4da235e90985f2b5780764ef72bb383af5c546f056b9c375eca40ddf2716d','顾客'),(22,'内2','pbkdf2:sha256:600000$V5UtMaN6ztXXOhOm$04e40f1d28028816ba9a8cd2af29eef8027932924a3770f1e0d9c95b24480e02','顾客'),(23,'内3','pbkdf2:sha256:600000$Z9Ij0LOOlW5HotTX$789a37fa782d8d4dbce4667e819e598b014a8aadae8090429d3fae512c7ffd63','顾客'),(24,'内4','pbkdf2:sha256:600000$QXR8wY2YCjQCImDf$237913f0c32ea1895cb81c93d6fe22585a68173a726b1a8075a273cfcd8c0503','顾客'),(25,'内5','pbkdf2:sha256:600000$FqYWRgiTyuiMeknm$8c9328cc9adbb9b8cee2a829d116b5216f65b013ab92d2b25754ecb1ab35e81b','顾客'),(26,'打包','pbkdf2:sha256:600000$YaR2TdWI4DXEtkGM$9c0caa14cd48b16cdd6401c95b8ef090620af7cea81ce9cb8d53747645f6d9a0','顾客'),(27,'小梅','pbkdf2:sha256:600000$YYfiefRf3hakzo5P$249e58f284883b813e1e965bca96b409878e19d1389ad825a70ebe7f5b5097d8','服务员'),(28,'小夏','pbkdf2:sha256:600000$ymUkREaiQOvzCehw$f17bca8326defce26a46986a7a9f0db410575a27eb4dd6b2cb08ca9ef2783404','厨师');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-07-10 23:07:32
