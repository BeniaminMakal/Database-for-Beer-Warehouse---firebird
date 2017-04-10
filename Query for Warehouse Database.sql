
/* Script to create database*/

USE [master]
GO

CREATE DATABASE [Warehouse]
GO
USE [Warehouse]
GO

CREATE TABLE [dbo].[Sale] (
Sale_ID int identity(1,1) NOT NULL,
Employee_ID int NOT NULL,
Customer_name varchar(255) NOT NULL,
Invoice_ID int NOT NULL,
Sale_date datetime,
Operation_status int CHECK (Operation_status = 0 OR Operation_status = 1) DEFAULT (0),
CONSTRAINT PK_Sale PRIMARY KEY CLUSTERED (Sale_ID) 
)
GO

CREATE TABLE [dbo].[Invoice_headers] (
Invoice_ID int identity(1,1) NOT NULL,
Customer_ID int NOT NULL,
Payment varchar(30) NOT NULL,
Discount int,
Date_time datetime,
Invoice_value float NOT NULL
CONSTRAINT PK_Invoice_header PRIMARY KEY CLUSTERED (Invoice_ID))
GO

CREATE TABLE [dbo].[Invoice_items] (
ID int NOT NULL identity(1,1),
Invoice_ID int NOT NULL,
Product_name varchar(255) NOT NULL,
Unit_price int NOT NULL CHECK (Unit_price>0),
Amount float NOT NULL,
Unit_of_measurement varchar(50) NOT NULL,
Serial_number varchar(255) NOT NULL, 
CONSTRAINT PK_Invoice_items PRIMARY KEY CLUSTERED (ID))
GO

CREATE TABLE [dbo].[Employees] (
Employee_ID int identity(1,1) NOT NULL, 
Em_LOGIN varchar (50) NOT NULL,
Position varchar(255) NOT NULL,
Em_Name varchar(255) NOT NULL,
Surname varchar(255) NOT NULL
CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (Employee_ID))
GO

CREATE TABLE [dbo].[Customers] (
Customer_ID int identity(1,1) NOT NULL,
Customer_name varchar(255) UNIQUE,
NIP varchar(20) UNIQUE,
City varchar(255),
C_Address varchar(255),
Postal_code varchar(50),
Telephone varchar(50),
Email varchar(255),
WWW varchar(255),
Cus_Type varchar(50),
CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED (Customer_ID))
GO

CREATE TABLE [dbo].[Cus_Types] (
Cus_Type varchar(50) NOT NULL, 
Discount int CHECK (Discount >= 0) DEFAULT (0)
CONSTRAINT PK_Cus_Type PRIMARY KEY CLUSTERED (Cus_Type))
GO

CREATE TABLE [dbo].[Products] (
ID int identity(1,1) NOT NULL,
Product_name varchar(255) NOT NULL UNIQUE,
Brewery varchar(255) NOT NULL, 
Distributor varchar(255),
Price int NOT NULL,
P_type varchar(50) NOT NULL,
Amount int CHECK (Amount>=0),
Unit_of_measurement varchar(50) NOT NULL,
CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ID))
GO

CREATE TABLE [dbo].[Products_Types] (
ID int identity (1,1) NOT NULL,
P_Type_Name varchar(50) NOT NULL UNIQUE,
CONSTRAINT PK_Product_Type PRIMARY KEY CLUSTERED (ID))
GO

CREATE TABLE [dbo].[Expiration_dates](
ID int identity (1,1) NOT NULL,
Product_name varchar(255) NOT NULL,
Serial_number varchar(255) NOT NULL,
Expiration_date datetime NOT NULL,
CONSTRAINT PK_Expiration_dates PRIMARY KEY CLUSTERED (ID)
)
GO

CREATE TABLE [dbo].[Distributors] (
ID int identity(1,1) NOT NULL,
Dis_name varchar(255) NOT NULL UNIQUE,
Dis_Location varchar(255) NOT NULL,
Adress varchar (255) NOT NULL,
Postal_code varchar(50) NOT NULL,
Telephone varchar (50) NOT NULL,
Email varchar(255) NOT NULL,
WWW varchar(255) NOT NULL
CONSTRAINT PK_Distributor PRIMARY KEY CLUSTERED (ID))
GO

CREATE TABLE [dbo].[Breweries] (
ID int identity(1,1) NOT NULL,
Br_name varchar(255) NOT NULL UNIQUE,
Br_Location varchar(255) NOT NULL,
Adress varchar (255) NOT NULL,
Postal_code varchar(50) NOT NULL,
Telephone varchar(50) NOT NULL,
Email varchar(255) NOT NULL,
WWW varchar(255) NOT NULL
CONSTRAINT PK_Brewerys PRIMARY KEY CLUSTERED (ID))
GO

/* This part is adding foreign keys */

ALTER TABLE [dbo].[Expiration_dates] WITH NOCHECK ADD CONSTRAINT [FK_Product_name] FOREIGN KEY ([Product_name])
REFERENCES [dbo].[Products]([Product_name])
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_Employee] FOREIGN KEY([Employee_ID])
REFERENCES [dbo].[Employees] ([Employee_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_Invoice_Headers] FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[Invoice_headers] ([Invoice_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Sale]  WITH NOCHECK ADD  CONSTRAINT [FK_Sale_Customers] FOREIGN KEY([Customer_name])
REFERENCES [dbo].[Customers] ([Customer_name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Invoice_headers]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_Headers_Customer] FOREIGN KEY([Customer_ID])
REFERENCES [dbo].[Customers] ([Customer_ID])
ON DELETE NO ACTION
GO

ALTER TABLE [dbo].[Invoice_items]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_Headers_ID] FOREIGN KEY([Invoice_ID])
REFERENCES [dbo].[Invoice_headers] ([Invoice_ID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Invoice_items]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_items_ID] FOREIGN KEY([Product_name])
REFERENCES [dbo].[Products] ([Product_name])
GO

ALTER TABLE [dbo].[Invoice_items]  WITH NOCHECK ADD  CONSTRAINT [FK_Invoice_items_Product_name] FOREIGN KEY([Product_name])
REFERENCES [dbo].[Products] ([Product_name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_P_type] FOREIGN KEY([P_type])
REFERENCES [dbo].[Products_Types] ([P_Type_Name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Distributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[Distributors] ([Dis_name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Products]  WITH NOCHECK ADD  CONSTRAINT [FK_Products_Brewery] FOREIGN KEY([Brewery])
REFERENCES [dbo].[Breweries] ([Br_name])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Customers]  WITH NOCHECK ADD  CONSTRAINT [FK_Customers] FOREIGN KEY([Cus_Type])
REFERENCES [dbo].[Cus_Types] ([Cus_Type])
ON DELETE CASCADE
GO

/*TRIGGERS*/

CREATE TRIGGER TR_GET_DATETIME_SALE ON Sale
AFTER INSERT
AS
UPDATE Sale
SET Sale_date = GETDATE()
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
GO

CREATE TRIGGER TR_GET_DATETIME_INVOICE_H ON Sale
AFTER INSERT
AS
UPDATE Invoice_headers
SET Date_time = GETDATE()
WHERE Invoice_ID = (SELECT MAX(Invoice_ID) FROM Invoice_headers);
GO


CREATE TRIGGER TR_SET_OPERATION_STATUS ON Sale
AFTER INSERT
AS
UPDATE Sale
SET Operation_Status = 1
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
GO


/*Creating logins, users and grant them roles */

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier1')
BEGIN 
CREATE LOGIN cashier1 WITH PASSWORD = 'cashier1'
END
CREATE USER cashier1 FOR LOGIN cashier1
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier2')
BEGIN 
CREATE LOGIN cashier2 WITH PASSWORD = 'cashier2'
END
CREATE USER cashier2 FOR LOGIN cashier2
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier3')
BEGIN 
CREATE LOGIN cashier3 WITH PASSWORD = 'cashier3'
END
CREATE USER cashier3 FOR LOGIN cashier3
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier4')
BEGIN 
CREATE LOGIN cashier4 WITH PASSWORD = 'cashier4'
END
CREATE USER cashier4 FOR LOGIN cashier4
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier5')
BEGIN 
CREATE LOGIN cashier5 WITH PASSWORD = 'cashier5'
END
CREATE USER cashier5 FOR LOGIN cashier5
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier6')
BEGIN 
CREATE LOGIN cashier6 WITH PASSWORD = 'cashier6'
END
CREATE USER cashier6 FOR LOGIN cashier6
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'cashier7')
BEGIN 
CREATE LOGIN cashier7 WITH PASSWORD = 'cashier7'
END
CREATE USER cashier7 FOR LOGIN cashier7
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'warehouseman1')
BEGIN 
CREATE LOGIN warehouseman1 WITH PASSWORD = 'warehouseman1'
END
CREATE USER warehouseman1 FOR LOGIN warehouseman1
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'warehouseman2')
BEGIN 
CREATE LOGIN warehouseman2 WITH PASSWORD = 'warehouseman2'
END
CREATE USER warehouseman2 FOR LOGIN warehouseman2
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'boss')
BEGIN 
CREATE LOGIN boss WITH PASSWORD = 'boss'
END
CREATE USER boss FOR LOGIN boss
GO

IF NOT EXISTS (SELECT name FROM sys.sql_logins WHERE name = 'w_admin')
BEGIN 
CREATE LOGIN w_admin WITH PASSWORD = 'admin'
END
CREATE USER w_admin FOR LOGIN w_admin
GO

ALTER ROLE db_datawriter ADD MEMBER cashier1
GO 
ALTER ROLE db_datareader ADD MEMBER cashier1
GO

ALTER ROLE db_datawriter ADD MEMBER cashier2
GO 
ALTER ROLE db_datareader ADD MEMBER cashier2
GO

ALTER ROLE db_datawriter ADD MEMBER cashier3
GO 
ALTER ROLE db_datareader ADD MEMBER cashier3
GO

ALTER ROLE db_datawriter ADD MEMBER cashier4
GO 
ALTER ROLE db_datareader ADD MEMBER cashier4
GO

ALTER ROLE db_datawriter ADD MEMBER cashier5
GO 
ALTER ROLE db_datareader ADD MEMBER cashier5
GO

ALTER ROLE db_datawriter ADD MEMBER cashier6
GO 
ALTER ROLE db_datareader ADD MEMBER cashier6
GO

ALTER ROLE db_datawriter ADD MEMBER cashier7
GO
ALTER ROLE db_datareader ADD MEMBER cashier7
GO 

ALTER ROLE db_datawriter ADD MEMBER warehouseman1
GO 
ALTER ROLE db_datareader ADD MEMBER warehouseman1
GO

ALTER ROLE db_datawriter ADD MEMBER warehouseman2
GO 
ALTER ROLE db_datareader ADD MEMBER warehouseman2
GO

ALTER ROLE db_datawriter ADD MEMBER boss
GO 
ALTER ROLE db_datareader ADD MEMBER boss
GO
ALTER ROLE db_securityadmin ADD MEMBER boss
GO
ALTER ROLE db_accessadmin ADD MEMBER boss
GO

ALTER ROLE db_datawriter ADD MEMBER w_admin
GO 
ALTER ROLE db_datareader ADD MEMBER w_admin
GO
ALTER ROLE db_securityadmin ADD MEMBER w_admin
GO
ALTER ROLE db_accessadmin ADD MEMBER w_admin
GO
ALTER ROLE db_backupoperator ADD MEMBER w_admin
GO
ALTER ROLE db_ddladmin ADD MEMBER w_admin
GO
ALTER ROLE db_owner ADD MEMBER w_admin


/*Example content for database*/

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier1', 'John', 'Walker')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier2', 'Juan', 'Moore')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier3', 'Richard', 'Perez')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier4', 'Dennis', 'Wood')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier5', 'Paul', 'Collins')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier6', 'Christopher', 'Edwards')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('cashier', 'cashier7', 'Jason', 'Stewart')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('warehouseman', 'warehouseman1', 'Jeremy', 'Mitchell')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('warehouseman', 'warehouseman2', 'David', 'Scott')

INSERT INTO Employees (Position, Em_LOGIN, Em_Name, Surname)
VALUES ('boss', 'boss', 'Peter', 'Anderson')

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Lager')

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Porter')

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Wheat beer')

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Stout')

INSERT INTO Products_Types (P_Type_Name)
VALUES ('RIS')

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('We love beer', 'Sosnowiec', 'ul. Zielona 2', '15-232', '123456789', 'we_love_beer@beer.pl', 'www.welovebeer.pl')

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Beer masters', 'Wroc�aw', 'ul. Czerwona 99', '50-531', '321654987', 'beer_masters@beer.pl', 'www.beermasters.pl')

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Darkest beers', 'Krak�w', 'ul. Niebieska 745', '15-232', '741852963', 'darkest_beers@beer.pl', 'www.darkestbeers.pl')

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Hops', 'Wroc�aw', 'ul. Ciemna 12', '50-634', '123654897', 'hops@beer.pl', 'www.hops.pl')

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('For The Sun', 'Kostom�oty', 'ul. Sucha 2', '80-532', '365854795', 'For_The_Sun@beer.pl', 'www.forthesun.pl')

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Green_Hops', 'Ko�o', 'ul. Mokra 64', '70-564', '123654897', 'green_hops@beer.pl', 'www.greenhops.pl')

INSERT INTO Products (Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Kazimierskie', 'For The Sun', 9, 'Lager', 100020, '0.5l')

INSERT INTO Products (Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Wroc�awskie', 'For The Sun', 12, 'Porter', 4340, '0.5l')

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Hip-Hops', 'Hops', 'We love beer', 10, 'Wheat beer', 7890, '0.5l')

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Dark Hoops', 'Hops', 'We love beer', 9, 'Porter', 5000, '0.5l')

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Black Leaf', 'Green_Hops', 'Beer masters', 22, 'RIS', 3900, '0.3l')

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Coin', 'Green_Hops', 'Beer masters', 11, 'Stout', 6920, '0.5l')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Kazimierskie', '2016/08/12/T23', '2017-05-02 11:11:11')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Wroc�awskie', '2016/11/21/T43', '2017-10-12 20:11:11')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/01/R213', '2017-02-12 19:20:00')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/02/R214', '2017-02-12 20:20:00')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/03/R215', '2017-02-12 12:50:01')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/11/S32', '2017-04-05 07:31:12')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/12/S33', '2017-04-06 08:10:45')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Black Leaf', '2016/12/12/W31', '2017-06-12 11:11:01')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/12/8213', '2017-07-14 09:43:21')

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/13/8214', '2017-07-15 19:13:21')

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('DETAL', 0)

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('HURT', 5)

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('VIP', 10)

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('GRAF', '8992683494', 'Wroc�aw', 'ul. Gajowa 22', '50-289', '745896523', 'graf@beer.com', 'www.graf.com', 'VIP')

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Semafor', '8997849878', 'Ole�nica', 'ul. Cebulowa 16', '40-239', '741852965', 'semafor@beer.com', 'www.semafor.com', 'HURT')

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Ma�pka', '8889652121', 'Wroc�aw', 'ul. Hutnicza 2', '50-001', '854125652', 'malpka@beer.com', 'www.malpka.com', 'HURT')

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Kropka', '6527896598', 'Wroc�aw', 'ul. Wiejska 74', '50-031', '745985125', 'kropka@beer.com', 'www.kropka.com', 'VIP')

INSERT INTO Invoice_headers (Customer_ID, Invoice_value, Payment, Discount, Date_time)
VALUES (1, 1100, 'CASH', 10, '2017-02-23 11:11:21')

INSERT INTO Invoice_headers (Customer_ID, Invoice_value, Payment, Discount, Date_time)
VALUES (2, 1800, 'CREDIT CARD', 5, '2017-01-01 16:00:22')

INSERT INTO Invoice_headers (Customer_ID, Invoice_value, Payment, Discount, Date_time)
VALUES (3, 10000, 'TRANSFER', 5, '2017-01-13 07:57:04')

INSERT INTO Invoice_items (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number)
VALUES ('Coin', 1, 100, 11, '0.5l', '2016/12/23/P09')

INSERT INTO Invoice_items (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number)
VALUES ('Dark Hoops', 2, 200, 9, '0.3l', '2016/12/30/R423')

INSERT INTO Invoice_items (Product_name, Invoice_ID, Amount, Unit_price, Unit_of_measurement, Serial_number)
VALUES ('Hip-Hops', 3, 1000, 10, '0.5l', '2017/01/23/G543')

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (1, 'GRAF', 1, '2017-02-23 11:11:21')

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (2, 'Semafor', 2, '2017-01-01 16:00:22')

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (3, 'Ma�pka', 3, '2017-01-13 07:57:04')

