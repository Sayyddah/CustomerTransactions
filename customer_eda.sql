--Create "customers" table

CREATE TABLE customers(
    id INT NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    age INT,
    gender VARCHAR(255),
    PRIMARY KEY (id)
);

--Load data into customers table from .csv file

LOAD DATA INFILE 'customer_transactions\CustomersMerged.csv' 
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--Create "transactions" table

CREATE TABLE transactions (
    transaction_id INT NOT NULL,
    customer_id INT NOT NULL,
    transaction_amount TEXT NOT NULL,
    transaction_location VARCHAR(255) NOT NULL,
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

--Load data into transactions table from .csv file

LOAD DATA INFILE 'customer_transactions\TransactionsMerged.csv' 
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

--update the transactions_amount column to remove dollar sign

UPDATE transactions
SET transaction_amount = replace(transaction_amount,"$",'');

-- Find total spent on transaction by each gender

SELECT gender
	  ,SUM(transaction_amount) AS TotalSpent
FROM customers
LEFT join transactions
ON customers.id = transactions.customer_id 
group by customers.gender;

--List the top 5 customers who have the highest number of transactions.

SELECT 
    customers.id AS CustID,
    customers.first_name AS FirstName,
    customers.last_name AS LastName,
    COUNT(DISTINCT transaction_id) AS NumofTransactions
FROM
    customers
        LEFT JOIN
    transactions ON customers.id = transactions.customer_id
GROUP BY CustID
ORDER BY NumofTransactions DESC
LIMIT 5;

-- List the top 3 spenders.

SELECT 
	     customers.id AS CustID
	    ,customers.first_name AS FirstName
      ,customers.last_name AS LastName
	    ,SUM(transaction_amount) AS TotalSpent
FROM customers
LEFT join transactions
ON customers.id = transactions.customer_id
group by CustID
ORDER BY TotalSpent DESC
LIMIT 3;

-- List the top 3 customers with the highest average transaction amount.

SELECT 
    customers.id AS CustID,
    customers.first_name AS FirstName,
    customers.last_name AS LastName,
    AVG(transaction_amount) AS AverageSpent
FROM
    customers
        LEFT JOIN
    transactions ON customers.id = transactions.customer_id
GROUP BY CustID
ORDER BY AverageSpent DESC
LIMIT 3;

-- List the top 5 transaction locations with the lowest average transaction amount.

SELECT 
	   transaction_location AS Location
	  ,AVG(transaction_amount) AS AverageSpent
FROM transactions
group by Location
ORDER BY AverageSpent ASC
LIMIT 5;

-- Display count of the occurence of same first name and same last name with all the records from the customer table

FROM
    customers
        LEFT JOIN
    (SELECT 
        first_name, COUNT(first_name) AS FirstCount
    FROM
        customers
    GROUP BY first_name) FirstNameCount ON customers.first_name = FirstNameCount.first_name
        LEFT JOIN
    (SELECT 
        last_name, COUNT(last_name) AS LastCount
    FROM
        customers
    GROUP BY last_name) LastNameCount ON customers.last_name = LastNameCount.last_name
ORDER BY customers.first_name , customers.last_name ASC;

-- List customer transaction amounts and transaction id for the highest spender including a total row at the end.
    
SELECT 
    CASE
        WHEN GROUPING(transaction_id) = 0 THEN transaction_id
        ELSE 'Total_Transactions_Amount'
    END AS transaction_id,
    SUM(transaction_amount) AS Transaction_Amount
FROM
    transactions
WHERE
    customer_id = (SELECT 
            customer_id
        FROM
            transactions
        GROUP BY customer_id
        ORDER BY SUM(transaction_amount) DESC
        LIMIT 1)
GROUP BY transaction_id WITH ROLLUP
;
        
