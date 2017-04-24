-- Create or connect to database


CREATE DATABASE "E:\SQL\Test\Database_for_Beer_Warehouse.fdb" page_size 8192
user 'sysdba' password 'masterkey'

CONNECT "E:\SQL\Test\Database_for_Beer_Warehouse.fdb"
user 'sysdba' password 'masterkey'



-- Creating tables 

CREATE TABLE Sale (
Sale_ID int NOT NULL PRIMARY KEY,
Employee_ID int NOT NULL,
Customer_name varchar(255) NOT NULL,
Invoice_ID int NOT NULL,
Sale_date timestamp,
Operation_status int default 0);


CREATE TABLE Invoice_headers (
Invoice_ID int NOT NULL PRIMARY KEY,
Customer_name varchar(255) NOT NULL,
Payment varchar(30) NOT NULL,
Discount int,
Invoice_datetime timestamp,
Invoice_value DECIMAL(18, 4) NOT NULL);


CREATE TABLE Invoice_items (
Invoice_items_ID int NOT NULL PRIMARY KEY,
Invoice_ID int NOT NULL,
Product_name varchar(255) NOT NULL,
Unit_price int NOT NULL CHECK (Unit_price>0),
Amount numeric(9,2) NOT NULL,
Unit_of_measurement varchar(50) NOT NULL,
Serial_number varchar(255) NOT NULL);



CREATE TABLE Employees (
Employee_ID int NOT NULL PRIMARY KEY, 
Em_LOGIN varchar (50) NOT NULL,
Job_title varchar(255) NOT NULL,
Em_Name varchar(255) NOT NULL,
Em_Surname varchar(255) NOT NULL);



CREATE TABLE Customers (
Customer_ID int PRIMARY KEY,
Customer_name varchar(255) UNIQUE,
NIP varchar(20) UNIQUE,
City varchar(255),
C_Address varchar(255),
Postal_code varchar(50),
Telephone varchar(50),
Email varchar(255),
WWW varchar(255),
Cus_Type varchar(50));


CREATE TABLE Cus_Types (
Cus_Type varchar(50) NOT NULL PRIMARY KEY, 
Discount int DEFAULT 0 CHECK (Discount >= 0));


CREATE TABLE Products (
Product_name varchar(255) NOT NULL Primary KEY,
Brewery varchar(255) NOT NULL, 
Distributor varchar(255),
Price int NOT NULL,
P_type varchar(50) NOT NULL,
Amount int CHECK (Amount>=0),
Unit_of_measurement varchar(50) NOT NULL);


CREATE TABLE Products_Types (
Product_type_ID int NOT NULL PRIMARY KEY,
P_Type_Name varchar(50) NOT NULL UNIQUE);


CREATE TABLE Expiration_dates(
Product_name varchar(255) NOT NULL,
Serial_number varchar(255) PRIMARY KEY,
Expiration_date timestamp NOT NULL);


CREATE TABLE Distributors (
Dis_name varchar(255) NOT NULL PRIMARY KEY,
Dis_Location varchar(255) NOT NULL,
Adress varchar (255) NOT NULL,
Postal_code varchar(50) NOT NULL,
Telephone varchar (50) NOT NULL,
Email varchar(255) NOT NULL,
WWW varchar(255) NOT NULL);


CREATE TABLE Breweries (
Br_name varchar(255) NOT NULL PRIMARY KEY,
Br_Location varchar(255) NOT NULL,
Adress varchar (255) NOT NULL,
Postal_code varchar(50) NOT NULL,
Telephone varchar(50) NOT NULL,
Email varchar(255) NOT NULL,
WWW varchar(255) NOT NULL);

-- Creating generators

CREATE GENERATOR gen_sale_id;
SET GENERATOR gen_sale_id TO 0;

CREATE GENERATOR gen_invoice_headers_ID;
SET GENERATOR gen_invoice_headers_ID TO 0;

CREATE GENERATOR gen_products_types_ID;
SET GENERATOR gen_products_types_ID TO 0;

CREATE GENERATOR gen_customers_ID;
SET gen_customers_ID TO 0;

CREATE GENERATOR gen_employyes_ID;
SET GENERATOR gen_employyes_ID TO 0;

CREATE GENERATOR gen_invoice_items_ID;
SET GENERATOR gen_invoice_items_ID TO 0;

-- Creating triggers

SET TERM !!;

CREATE TRIGGER TR_Sale_ID FOR Sale
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Sale_ID IS NULL) THEN NEW.Sale_ID = GEN_ID(gen_sale_id, 1);
END !!

CREATE TRIGGER TR_invoice_headers_ID FOR Invoice_headers
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Invoice_ID IS NULL) THEN NEW.Invoice_ID = GEN_ID(gen_invoice_headers_ID, 1);
END !!

CREATE TRIGGER TR_products_types_ID FOR Products_Types
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Product_type_ID IS NULL) THEN NEW.Product_type_ID = GEN_ID(gen_products_types_ID, 1);
END !!

CREATE TRIGGER TR_customers_ID FOR Customers
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Customer_ID IS NULL) THEN NEW.Customer_ID = GEN_ID(gen_customers_ID, 1);
END !!

CREATE TRIGGER TR_employees_ID FOR Employees
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Employee_ID IS NULL) THEN NEW.Employee_ID = GEN_ID(gen_employyes_ID, 1);
END !!

CREATE TRIGGER TR_invoice_items_ID FOR Invoice_items
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
IF (NEW.Invoice_items_ID IS NULL) THEN NEW.Invoice_items_ID = GEN_ID(gen_invoice_items_ID, 1);
END !!

CREATE TRIGGER TR_GET_DATETIME_SALE FOR Sale
AFTER INSERT
AS
BEGIN
UPDATE Sale
SET Sale_date = (select cast('NOW' as timestamp) from rdb$database)
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
END
!!

CREATE TRIGGER TR_SET_OPERATION_STATUS FOR Sale
AFTER INSERT
AS
BEGIN
UPDATE Sale
SET Operation_Status = 1
WHERE Sale_ID = (SELECT MAX(Sale_ID) FROM Sale);
END
!!

CREATE TRIGGER TR_GET_DATETIME_INVOICE_HEADERS FOR Invoice_headers
AFTER INSERT
AS
BEGIN
UPDATE Invoice_headers
SET Invoice_datetime = (select cast('NOW' as timestamp) from rdb$database)
WHERE Invoice_ID = (SELECT MAX(Invoice_ID) FROM Invoice_headers);
END
!!

SET TERM ;!!



-- This part is adding foreign keys


ALTER TABLE Expiration_dates  ADD CONSTRAINT FK_Product_name FOREIGN KEY (Product_name)
REFERENCES Products(Product_name)
ON DELETE CASCADE;

ALTER TABLE Sale ADD  CONSTRAINT FK_Sale_Employee FOREIGN KEY(Employee_ID)
REFERENCES Employees (Employee_ID)
ON DELETE CASCADE;

ALTER TABLE Sale  ADD  CONSTRAINT FK_Sale_Invoice_Headers FOREIGN KEY(Invoice_ID)
REFERENCES Invoice_headers (Invoice_ID)
ON DELETE CASCADE;

ALTER TABLE Sale ADD  CONSTRAINT FK_Sale_Customers FOREIGN KEY(Customer_name)
REFERENCES Customers (Customer_name)
ON DELETE CASCADE;

ALTER TABLE Invoice_headers ADD  CONSTRAINT FK_Invoice_Headers_Customer FOREIGN KEY(Customer_name)
REFERENCES Customers (Customer_name)
ON DELETE NO ACTION;

ALTER TABLE Invoice_items ADD  CONSTRAINT FK_Invoice_Headers_ID FOREIGN KEY(Invoice_ID)
REFERENCES Invoice_headers (Invoice_ID)
ON DELETE CASCADE;

ALTER TABLE Invoice_items ADD  CONSTRAINT FK_Invoice_items_Product_name FOREIGN KEY(Product_name)
REFERENCES Products (Product_name)
ON DELETE NO ACTION;

ALTER TABLE Products ADD  CONSTRAINT FK_Products_P_type FOREIGN KEY(P_type)
REFERENCES Products_Types (P_Type_Name)
ON DELETE NO ACTION;

ALTER TABLE Products ADD  CONSTRAINT FK_Products_Distributor FOREIGN KEY(Distributor)
REFERENCES Distributors (Dis_name)
ON DELETE CASCADE;

ALTER TABLE Products ADD CONSTRAINT FK_Products_Brewery FOREIGN KEY(Brewery)
REFERENCES Breweries (Br_name)
ON DELETE CASCADE;

ALTER TABLE Customers ADD  CONSTRAINT FK_Customers FOREIGN KEY(Cus_Type)
REFERENCES Cus_Types (Cus_Type)
ON DELETE CASCADE;


-- Creating logins, users and grant them roles 


CREATE ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Products TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Sale TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Invoice_headers TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Invoice_items TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Customers TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Breweries TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Distributors TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Expiration_dates TO ROLE cashier;
GRANT SELECT, UPDATE, INSERT ON Products_Types TO ROLE cashier;

CREATE ROLE warehouseman;
GRANT SELECT, UPDATE, INSERT, DELETE ON Products TO ROLE warehouseman;
GRANT SELECT, UPDATE, INSERT, DELETE ON Products_Types TO ROLE warehouseman;
GRANT SELECT, UPDATE, INSERT, DELETE ON Expiration_dates TO ROLE warehouseman;
GRANT SELECT, UPDATE, INSERT, DELETE ON Breweries TO ROLE warehouseman;
GRANT SELECT, UPDATE, INSERT, DELETE ON Distributors TO ROLE warehouseman;

CREATE ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Products TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Sale TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Invoice_headers TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Invoice_items TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Customers TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Cus_Types TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Breweries TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Distributors TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Expiration_dates TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Products_Types TO ROLE w_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON Employees TO ROLE w_admin;

CREATE USER cashier1 PASSWORD 'cashier1' FIRSTNAME 'John' LASTNAME 'Walker';
GRANT cashier to cashier1;

CREATE USER cashier2 PASSWORD 'cashier2' FIRSTNAME 'Juan' LASTNAME 'Moore';
GRANT cashier to cashier2;

CREATE USER cashier3 PASSWORD 'cashier3' FIRSTNAME 'Richard' LASTNAME 'Perez';
GRANT cashier to cashier3;

CREATE USER warehouseman1 PASSWORD 'warehouseman1' FIRSTNAME 'Jeremy' LASTNAME 'Mitchell';
GRANT warehouseman to warehouseman1;

CREATE USER warehouseman2 PASSWORD 'warehouseman2' FIRSTNAME 'David' LASTNAME 'Scott';
GRANT warehouseman to warehouseman2;

CREATE USER boss PASSWORD 'boss1' FIRSTNAME 'Peter' LASTNAME 'Anderson' GRANT ADMIN ROLE;
GRANT w_admin to boss;
-- granty na specjalne tabele

-- dodaæ u¿ytkowników po ich imionach
-- dodaæ role: warehouseman i boss


--Example content for database

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('cashier1', 'cashier', 'John', 'Walker');

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('cashier2', 'cashier', 'Juan', 'Moore');

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('cashier3', 'cashier', 'Richard', 'Perez');

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('warehouseman1', 'warehouseman', 'Jeremy', 'Mitchell');

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('warehouseman2', 'warehouseman', 'David', 'Scott');

INSERT INTO Employees (Em_LOGIN, Job_title, Em_Name, Em_Surname)
VALUES ('boss', 'boss', 'Peter', 'Anderson');

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Lager');

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Porter');

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Wheat beer');

INSERT INTO Products_Types (P_Type_Name)
VALUES ('Stout');

INSERT INTO Products_Types (P_Type_Name)
VALUES ('RIS');

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('We love beer', 'Sosnowiec', 'ul. Zielona 2', '15-232', '123456789', 'we_love_beer@beer.pl', 'www.welovebeer.pl');

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Beer masters', 'Wroc³aw', 'ul. Czerwona 99', '50-531', '321654987', 'beer_masters@beer.pl', 'www.beermasters.pl');

INSERT INTO Distributors (Dis_name, Dis_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Darkest beers', 'Kraków', 'ul. Niebieska 745', '15-232', '741852963', 'darkest_beers@beer.pl', 'www.darkestbeers.pl');

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Hops', 'Wroc³aw', 'ul. Ciemna 12', '50-634', '123654897', 'hops@beer.pl', 'www.hops.pl');

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('For The Sun', 'Kostom³oty', 'ul. Sucha 2', '80-532', '365854795', 'For_The_Sun@beer.pl', 'www.forthesun.pl');

INSERT INTO Breweries (Br_name, Br_Location, Adress, Postal_code, Telephone, Email, WWW)
VALUES ('Green_Hops', 'Ko³o', 'ul. Mokra 64', '70-564', '123654897', 'green_hops@beer.pl', 'www.greenhops.pl');

INSERT INTO Products (Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Kazimierskie', 'For The Sun', 9, 'Lager', 100020, '0.5l');

INSERT INTO Products (Product_name, Brewery, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Wroc³awskie', 'For The Sun', 12, 'Porter', 4340, '0.5l');

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Hip-Hops', 'Hops', 'We love beer', 10, 'Wheat beer', 7890, '0.5l');

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Dark Hoops', 'Hops', 'We love beer', 9, 'Porter', 5000, '0.5l');

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Black Leaf', 'Green_Hops', 'Beer masters', 22, 'RIS', 3900, '0.3l');

INSERT INTO Products (Product_name, Brewery, Distributor, Price, P_type, Amount, Unit_of_measurement)
VALUES ('Coin', 'Green_Hops', 'Beer masters', 11, 'Stout', 6920, '0.5l');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Kazimierskie', '2016/08/12/T23', '2017-05-02 11:11:11');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Wroc³awskie', '2016/11/21/T43', '2017-10-12 20:11:11');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/01/R213', '2017-02-12 19:20:00');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/02/R214', '2017-02-12 20:20:00');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Hip-Hops', '2016/12/03/R215', '2017-02-12 12:50:01');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/11/S32', '2017-04-05 07:31:12');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Dark Hoops', '2016/10/12/S33', '2017-04-06 08:10:45');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Black Leaf', '2016/12/12/W31', '2017-06-12 11:11:01');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/12/8213', '2017-07-14 09:43:21');

INSERT INTO Expiration_dates (Product_name, Serial_number, Expiration_date)
VALUES ( 'Coin', '2016/12/13/8214', '2017-07-15 19:13:21');

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('DETAL', 0);

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('HURT', 5);

INSERT INTO Cus_Types (Cus_Type, Discount)
VALUES ('VIP', 10);

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('GRAF', '8992683494', 'Wroc³aw', 'ul. Gajowa 22', '50-289', '745896523', 'graf@beer.com', 'www.graf.com', 'VIP');

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Semafor', '8997849878', 'Oleœnica', 'ul. Cebulowa 16', '40-239', '741852965', 'semafor@beer.com', 'www.semafor.com', 'HURT');

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Ma³pka', '8889652121', 'Wroc³aw', 'ul. Hutnicza 2', '50-001', '854125652', 'malpka@beer.com', 'www.malpka.com', 'HURT');

INSERT INTO Customers (Customer_name, NIP, City, C_Address, Postal_code, Telephone, Email, WWW, Cus_Type)
VALUES ('Kropka', '6527896598', 'Wroc³aw', 'ul. Wiejska 74', '50-031', '745985125', 'kropka@beer.com', 'www.kropka.com', 'VIP');

INSERT INTO Invoice_headers (Customer_name, Payment, Discount, Invoice_datetime, Invoice_value)
VALUES ('GRAF', 'CASH', 10, '2017-02-23 11:11:21', 1100);

INSERT INTO Invoice_headers (Customer_name, Payment, Discount, Invoice_datetime, Invoice_value)
VALUES ('Semafor', 'CREDIT CARD', 5, '2017-01-01 16:00:22', 1800);

INSERT INTO Invoice_headers (Customer_name, Payment, Discount, Invoice_datetime, Invoice_value)
VALUES ('Ma³pka', 'TRANSFER', 5, '2017-01-13 07:57:04', 10000);

INSERT INTO Invoice_items (Invoice_ID, Product_name, Unit_price, Amount, Unit_of_measurement, Serial_number)
VALUES ( 1, 'Coin', 11, 100, '0.5l', '2016/12/23/P09');

INSERT INTO Invoice_items (Invoice_ID, Product_name, Unit_price, Amount, Unit_of_measurement, Serial_number)
VALUES (2, 'Dark Hoops', 9, 200, '0.3l', '2016/12/30/R423');

INSERT INTO Invoice_items (Invoice_ID, Product_name, Unit_price, Amount, Unit_of_measurement, Serial_number)
VALUES (3, 'Hip-Hops', 10, 1000, '0.5l', '2017/01/23/G543');

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (1, 'GRAF', 1, '2017-02-23');

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (2, 'Semafor', 2, '2017-01-01');

INSERT INTO SALE (Employee_ID, Customer_name, Invoice_ID, Sale_date)
VALUES (3, 'Ma³pka', 3, '2017-01-13');


COMMIT;