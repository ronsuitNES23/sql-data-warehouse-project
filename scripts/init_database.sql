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
GO

-- Creating the Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
