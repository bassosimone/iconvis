-- MySQL dump 10.13  Distrib 5.1.34, for Win32 (ia32)
--
-- Host: localhost    Database: iconvis
-- ------------------------------------------------------
-- Server version	5.1.34-community

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `id_document` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path_document` varchar(100) NOT NULL,
  `subject_document` varchar(100) NOT NULL,
  `title_document` varchar(100) NOT NULL,
  PRIMARY KEY (`id_document`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,'/usr/local/iconvizDB_data/breeds.pdf','beagle','Breeds: beagle'),(2,'/usr/local/iconvizDB_data/breeds.pdf','golden retriever','Breeds: golden retriever'),(3,'/usr/local/iconvizDB_data/breeds.pdf','collie','Breeds: collie'),(4,'/usr/local/iconvizDB_data/breeds.pdf','Spinone Italiano','Breeds: spinone italiano'),(5,'/usr/local/iconvizDB_data/breeds.pdf','great dane','Breads: great dane'),(6,'/usr/local/iconvizDB_data/breeds.pdf','German Shepherd','Breeds: german shepherd'),(7,'/usr/local/iconvizDB_data/breeds.pdf','Doberman Pinscher','Breeds: dobermann');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id_image` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path_image` varchar(100) NOT NULL,
  `subject_image` varchar(100) NOT NULL,
  `title_image` varchar(100) NOT NULL,
  PRIMARY KEY (`id_image`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES (1,'/usr/local/iconvizDB_data/BEAGLE.jpg','beagle','Beagle standard'),(2,'/usr/local/iconvizDB_data/beagle_3.jpg','beagle','Beagle in a competition'),(3,'/usr/local/iconvizDB_data/beagle-cucciolo.jpg','beagle','Beagle pups'),(4,'/usr/local/iconvizDB_data/Img1-45363.jpg','beagle','Beagle pups'),(5,'/usr/local/iconvizDB_data/B7764.jpg','golden retriever','Golden retriever outdoor'),(6,'/usr/local/iconvizDB_data/gold_big.jpg','golden retriever','Golden retrievers'),(7,'/usr/local/iconvizDB_data/Golden-Retriever-2266.jpg','golden retriever','Golden retriever pup'),(8,'/usr/local/iconvizDB_data/il-golden-retriever.jpg','golden retriever','Golden retriever standard'),(9,'/usr/local/iconvizDB_data/SPINONE.jpg','Spinone Italiano','Spinone outdoor'),(10,'/usr/local/iconvizDB_data/Spinone_italiano_Daisy.JPG','Spinone Italiano','Spinone standard'),(11,'/usr/local/iconvizDB_data/collie.jpg','collie','Collie during a competition'),(12,'/usr/local/iconvizDB_data/collie_weis.jpg','collie','Collie in a movie'),(13,'/usr/local/iconvizDB_data/rough_collie.jpg','collie','Collie outdoor'),(14,'/usr/local/iconvizDB_data/pastore_tedesco.jpg','German Shepherd','German shepherd standard'),(15,'/usr/local/iconvizDB_data/pastore_tedesco_2.jpg','German Shepherd','German shepherd indoor'),(16,'/usr/local/iconvizDB_data/ptedesco.jpg','German Shepherd','German shepherd during a competition'),(17,'/usr/local/iconvizDB_data/SpinoneItalianonunzio2-6-18-05.JPG','Spinone Italiano','Spinone italiano'),(18,'/usr/local/iconvizDB_data/PASTORE-TEDESCO-CUCCIOLO-CLINICA-VETERINARIA-GAIA-ANCONA.jpg','German Shepherd','German shepherd pup'),(19,'/usr/local/iconvizDB_data/dobermann.jpg','Doberman Pinscher','Dobermann standard'),(20,'/usr/local/iconvizDB_data/Dobermann1.jpg','Doberman Pinscher','Dobermann ears'),(21,'/usr/local/iconvizDB_data/dobermann-03.jpg','Doberman Pinscher','Dobermann pup'),(22,'/usr/local/iconvizDB_data/dobermann(1).jpg','Doberman Pinscher','Dobermann outdoor'),(23,'/usr/local/iconvizDB_data/282px-Alano.jpg','great dane','Greate dane outdoor '),(24,'/usr/local/iconvizDB_data/alano.jpg','great dane','White and black dane'),(25,'/usr/local/iconvizDB_data/Alano-4.jpg','great dane','Black greate done');
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videos`
--

DROP TABLE IF EXISTS `videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videos` (
  `id_video` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path_video` varchar(100) NOT NULL,
  `subject_video` varchar(100) NOT NULL,
  `title_video` varchar(100) NOT NULL,
  PRIMARY KEY (`id_video`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videos`
--

LOCK TABLES `videos` WRITE;
/*!40000 ALTER TABLE `videos` DISABLE KEYS */;
INSERT INTO `videos` VALUES (1,'/usr/local/iconvizDB_data/history.flv','beagle','History of dogs - beagle'),(2,'/usr/local/iconvizDB_data/history.flv','golden retriever','History  of dogs - golden retriever'),(3,'/usr/local/iconvizDB_data/history.flv','Spinone Italiano','History  of dogs - spinone italiano'),(4,'/usr/local/iconvizDB_data/history.flv','collie','History  of dogs - collie'),(5,'/usr/local/iconvizDB_data/history.flv','German Shepherd','History of dogs - german shepherd'),(6,'/usr/local/iconvizDB_data/history.flv','Doberman Pinscher','History of dogs - dobermann'),(7,'/usr/local/iconvizDB_data/history.flv','great dane','History of dogs - great dane');
/*!40000 ALTER TABLE `videos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-10-15 15:43:25
