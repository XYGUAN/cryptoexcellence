/* 
    Description: This script is the SQL for Flipside Crypto interview to generate the metrics from data warehouse
    Author: Xiuyang Guan
    Version: 0.0.1
    Email: xiuyangguan@gmail.com
    Status: Done
*/

-- Q1: Compute these two metrics: sum of transactions per day, and count of distinct addresses that 
-- initiated a transaction (i.e. the “from” side).

-- Here the grammer is based on MYSQL, as different database might have alight different query grammer
-- My understanding is that this metric is day metric, the query result is (1) how many transactions per day and (2) how many unique address_from per day
SELECT 
    DATE_FORMAT(block_timestamp, "%Y-%m-%d") AS block_date,
    COUNT(tx_hash) AS n_transactions, 
    COUNT(DISTINCT address_from) AS n_uniq_address_from
FROM ethereum_transactions
GROUP BY DATE_FORMAT(block_timestamp, "%Y-%m-%d")

-- Q2: Compute the sum of transactions per day by label type.

-- Here my assumptions are:
    -- 1. label type means the label, not the lable category
    -- 2. the definition for the transaction label is using address_from, not address_to
    -- 3. All the address_from can be found in address_labels table, otherwise we need to implement another step to turn the NULL to some values
-- If these assumptions are not correct, we can adjust the query based on the correct understanding of the requirements

SELECT 
    DATE_FORMAT(a.block_timestamp, "%Y-%m-%d") AS block_date,
    b.label AS label_type,
    COUNT(tx_hash) AS n_transactions
FROM ethereum_transactions a
LEFT JOIN (
    SELECT address, label FROM address_labels
) b
ON a.address_from = b.address
GROUP BY DATE_FORMAT(a.block_timestamp, "%Y-%m-%d"), b.label

-- Q3: Compute the USD denominated volume on Ethereum per day.
-- Here I made the following assumptions as I am not quite sure what the real data looks like, assumptions are:
    -- 1. amount is the amount of ETH sent, the description used "volume", which is a little confusing
    -- 2. price_close is the minute price benchmark to calculate the volume for this minute
    -- 3. the timestamp in minute_price_candles table is uniquely per minute, so I didn't clean it further more

SELECT 
    DATE_FORMAT(a.block_timestamp, "%Y-%m-%d") AS block_date,
    SUM(CAST(a.amount AS DECIMAL(10,2) * b.price_close) AS volume_usd, 
FROM ethereum_transactions a
LEFT JOIN (
    SELECT 
        timestamp,
        price_close
    FROM minute_price_candles
) b
ON DATE_FORMAT(a.block_timestamp, "%Y-%m-%d %H:%i") = DATE_FORMAT(b.timestamp, "%Y-%m-%d %H:%i")
GROUP BY DATE_FORMAT(a.block_timestamp, "%Y-%m-%d")

-- Q4: Identify the top 10 addresses per day ranked by transaction count.
SELECT 
    block_date,
    address_from,
    n_transactions
FROM (
    SELECT 
        block_date,
        address_from,
        n_transactions,
        ROW_NUMBER() OVER (PARTITION BY block_date ORDER BY n_transactions DESC) AS row_number
    FROM (
        SELECT 
            DATE_FORMAT(block_timestamp, "%Y-%m-%d") AS block_date,
            address_from,
            COUNT(tx_hash) AS n_transactions
        FROM ethereum_transactions
        GROUP BY DATE_FORMAT(block_timestamp, "%Y-%m-%d"), address_from
    )
)
WHERE row_number <= 10
ORDER BY block_date ASC, n_transactions DESC