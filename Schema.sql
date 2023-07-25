DROP DATABASE IF EXISTS olympics_data;

-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema olympics_data
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema olympics_data
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `olympics_data` DEFAULT CHARACTER SET utf8 ;
USE `olympics_data` ;

-- -----------------------------------------------------
-- Table `olympics_data`.`athletes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `olympics_data`.`athletes` (
  `athlete_id` INT NOT NULL AUTO_INCREMENT,
  `athlete_name` VARCHAR(120) NOT NULL,
  `sex` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`athlete_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `olympics_data`.`games`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `olympics_data`.`games` (
  `games_id` INT NOT NULL AUTO_INCREMENT,
  `year` INT NOT NULL,
  `season` ENUM('Summer', 'Winter') NOT NULL,
  `host` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`games_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `olympics_data`.`events`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `olympics_data`.`events` (
  `event_id` INT NOT NULL AUTO_INCREMENT,
  `sport` VARCHAR(100) NOT NULL,
  `gender` VARCHAR(10) NOT NULL,
  `category` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`event_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `olympics_data`.`committees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `olympics_data`.`committees` (
  `committee_code` CHAR(3) NOT NULL,
  `region` VARCHAR(100) NOT NULL,
  `historical` TINYINT NOT NULL,
  PRIMARY KEY (`committee_code`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `olympics_data`.`results`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `olympics_data`.`results` (
  `athlete_id` INT NOT NULL,
  `games_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `age` INT NULL,
  `committee_code` CHAR(3) NOT NULL,
  `medal` INT NOT NULL,
  `result_id` INT NOT NULL AUTO_INCREMENT,
  INDEX `fk_results_events1_idx` (`event_id` ASC) VISIBLE,
  INDEX `fk_results_games1_idx` (`games_id` ASC) VISIBLE,
  INDEX `fk_results_committees1_idx` (`committee_code` ASC) VISIBLE,
  PRIMARY KEY (`result_id`),
  CONSTRAINT `fk_results_athletes`
    FOREIGN KEY (`athlete_id`)
    REFERENCES `olympics_data`.`athletes` (`athlete_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_results_events1`
    FOREIGN KEY (`event_id`)
    REFERENCES `olympics_data`.`events` (`event_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_results_games1`
    FOREIGN KEY (`games_id`)
    REFERENCES `olympics_data`.`games` (`games_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_results_committees1`
    FOREIGN KEY (`committee_code`)
    REFERENCES `olympics_data`.`committees` (`committee_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
