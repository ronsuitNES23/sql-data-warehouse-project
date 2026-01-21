/* 
==================================================================
Create Database and Schema
==================================================================
Script Purpose:
	This script creates a new databse named 'DataWarehouse after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver' and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse database if it exists.
	All data in the database will be permamnently deleted. Proceed with caution and 
	ensure you have proper backups before running this script.
*/


-- Create Database 'DataWarehouse'

USE master;

-- The database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBAcK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO
 -- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

-- Using the DataWarehouse
USE DataWarehouse;

-- Creating the Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
