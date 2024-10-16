# Learning-SQL-with-1M-dataset
Apple Sales SQL Analysis
Project Overview

This project demonstrates my SQL skills using a dataset of 1 million sales records from a fictional Apple dataset. It includes various queries for business analysis, query optimization, and more advanced problems, showcasing techniques like indexing, window functions, and Common Table Expressions (CTEs). The goal is to solve real-world business problems by querying large datasets efficiently.
Datasets Used

The project makes use of four primary tables:

    1. category: Contains product category information.
    2. products: Contains product details, including price and category.
    3. sales: A 1 million row table of sales data, with details of products sold by various stores.
    4. warranty: Records of warranty claims on products sold.
    5. stores: Information about stores, including their locations and names.

Queries and Solutions
Simple Queries

    Data Exploration
        View all distinct warranty statuses.
        Total number of sales records (1M rows).
        Select and analyze key sales data.

Query Optimization

    Indexing: Added indexes to improve performance on columns frequently used in search queries (product_id, store_id, sale_date).
    Performance Improvement: Queries are optimized with EXPLAIN ANALYZE before and after indexing to highlight execution time improvements.

Business Problems Solved

    Store Count by Country: Count of total stores per country.
    Units Sold by Each Store: Aggregation of sales quantities by store.
    Sales in December 2023: Total sales for December 2023.
    Stores Without Warranty Claims: Identify stores with no warranty claims.
    Percentage of Warranty Void Claims: Calculate the percentage of claims marked as "Warranty Void."
    Top Selling Store (Last Year): Identify the store with the highest units sold in the last year.
    Unique Products Sold (Last Year): Count the unique products sold in the last year.
    Average Product Price by Category: Calculate the average price of products by category.
    Warranty Claims in 2020: Count of warranty claims filed in 2020.
    Best-Selling Day by Store: Identify the best-selling day of the week for each store.

Medium to Hard Queries

    Least Selling Product by Country and Year: For each country and year, identify the least sold product.
    Warranty Claims Filed Within 180 Days: Count of claims filed within 180 days of sale.
    Warranty Claims for Products Launched in Last Two Years: Identify claims for newly launched products.
    Months with Sales Exceeding 5000 Units in the USA: List the months in the last three years where sales exceeded 5000 units in the USA.
    Top Product Category by Warranty Claims: Identify the product category with the most warranty claims filed in the last two years.

Complex Analysis

    Warranty Claim Risk by Country: Determine the risk percentage of receiving warranty claims after each purchase.
    Yearly Growth Ratio by Store: Calculate year-over-year growth for each store.
    Correlation Between Product Price and Warranty Claims: Analyze warranty claims based on product price segments.
    Store with Highest Percentage of Paid Repairs: Find the store with the highest percentage of 'Paid Repaired' claims.

Key Skills Demonstrated

    SQL Performance Optimization: Usage of indexes to improve query execution times.
    Window Functions: For ranking and year-over-year growth analysis.
    CTEs (Common Table Expressions): Used for more complex queries like warranty claim analysis and growth ratios.
    Data Aggregation: Summarizing large datasets to extract meaningful insights.
