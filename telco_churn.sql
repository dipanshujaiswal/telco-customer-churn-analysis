
CREATE DATABASE telco_churn


SELECT * FROM telco

-- 1.Customer Segmentation:

-- How many customers belong to each gender category?
SELECT Gender, COUNT(CustomerID) AS Num_Customers
FROM telco
GROUP BY Gender;

-- What is the average tenure of customers by contract type?
SELECT Contract, AVG(Tenure_Months) AS Avg_Tenure
FROM telco
GROUP BY Contract;

-- Which geographic region (e.g., state or city) has the highest churn rate?
SELECT State, City, COUNT(CustomerID) AS Total_Customers, 
       SUM(CASE WHEN Churn_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
       (SUM(CASE WHEN Churn_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(CustomerID)) AS Churn_Rate
FROM telco
GROUP BY State, City
ORDER BY Churn_Rate DESC;


-- 2. Churn Analysis:

-- What is the overall churn rate of the company?
SELECT COUNT(CustomerID) AS Total_Customers,
       SUM(CASE WHEN Churn_Label = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers,
       (SUM(CASE WHEN Churn_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(CustomerID)) AS Churn_Rate
FROM telco;

-- Among customers who churned, what is the distribution of churn reasons?
SELECT Churn_Reason, COUNT(CustomerID) AS Num_Customers
FROM telco
WHERE Churn_Label = 'Yes'
GROUP BY Churn_Reason;

-- Are there any significant differences in average monthly charges between churned and non-churned customers?
SELECT Churn_Label, AVG(Monthly_Charges) AS Avg_Monthly_Charges
FROM telco
GROUP BY Churn_Label;


-- 3. Lifetime Value Analysis:

-- What is the distribution of customer lifetime value (CLTV) among different tenure groups?
SELECT NTILE(4) OVER (ORDER BY Tenure_Months) AS Tenure_Group,
       MIN(Tenure_Months) AS Min_Tenure,
       MAX(Tenure_Months) AS Max_Tenure,
       AVG(CLTV) AS Avg_CLTV
FROM telco
GROUP BY NTILE(4);

-- How does CLTV vary across different payment methods?
SELECT Payment_Method, AVG(CLTV) AS Avg_CLTV
FROM telco
GROUP BY Payment_Method;

-- Can you identify any patterns in CLTV for customers with different service combinations (e.g., internet service, streaming services)?
SELECT Internet_Service, Streaming_TV, Streaming_Movies,
       AVG(CLTV) AS Avg_CLTV
FROM telco
GROUP BY Internet_Service, Streaming_TV, Streaming_Movies;


-- 4. Predictive Modeling Preparation:

-- Are there any correlations between customer attributes (e.g., gender, age, tenure) and churn likelihood?
SELECT Gender, AVG(CAST(Churn_Value AS INT)) AS Avg_Churn_Likelihood
FROM telco
GROUP BY Gender;

-- What is the distribution of churn scores among churned and non-churned customers?
SELECT Churn_Label, AVG(Churn_Score) AS Avg_Churn_Score
FROM telco
GROUP BY Churn_Label;

-- How do churn scores differ between customers with different contract types?
SELECT Contract, AVG(Churn_Score) AS Avg_Churn_Score
FROM telco
GROUP BY Contract;


-- 5. Advanced Joins and Subqueries:

-- Calculate the average monthly charges for customers who have both internet service and streaming TV service
SELECT AVG(Monthly_Charges) AS Avg_Monthly_Charges
FROM telco
WHERE Internet_Service = 'Yes' AND Streaming_TV = 'Yes';

-- Identify customers who have churned and whose monthly charges exceed the average monthly charges of all customers
SELECT *
FROM telco
WHERE Churn_Label = 'Yes' AND Monthly_Charges > (SELECT AVG(Monthly_Charges) FROM telco);



-- 6. Window Functions and Ranking: (Assuming the database supports window functions like ROW_NUMBER() or NTILE())

-- Rank customers based on their tenure months and identify the top 10 longest-tenured customers
SELECT CustomerID, Tenure_Months,
       ROW_NUMBER() OVER (ORDER BY Tenure_Months DESC) AS Tenure_Rank
FROM telco
WHERE Tenure_Months IS NOT NULL
ORDER BY Tenure_Rank
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Calculate the cumulative sum of monthly charges for each customer, ordered by tenure months

SELECT CustomerID, Tenure_Months, Monthly_Charges,
       SUM(Monthly_Charges) OVER (ORDER BY Tenure_Months) AS Cumulative_Monthly_Charges
FROM telco
ORDER BY Tenure_Months;
