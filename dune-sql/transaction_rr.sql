WITH

daily_transaction_table AS (
SELECT
    DISTINCT
    signer as user_id,
    --MIN(block_date) as first_access_date
    block_date as transaction_date
FROM
    solana.transactions
WHERE
    -- 重いクエリで全期間指定ができないので、2021-12-20から期間を区切りながら実行する
    -- 初期に初トランザクションを経験したユーザーが対象期間に取引した場合に重複する不正確さはあるが、
    -- 28daysを超えた継続トランザクションは小さいと仮定して許容する。
    block_date BETWEEN DATE('2021-03-01') AND DATE('2022-05-01')
    -- ここでの「継続」はトランザクション継続。メインアカウントのみを指定しているが、
    -- 知りたい継続のスコープによって適宜アカウントを追加する必要がある
    AND array_contains(account_keys, 'STEPNq2UGeGSzCyGVr2nMQAzf8xuejwqebd84wcksCK')
    AND error is NULL
)

-- 対象期間中の初トランザクション（計測起点）の集計
, first_transaction_table AS (
SELECT
    user_id, 
    MIN(transaction_date) as first_transaction_date 
FROM 
    daily_transaction_table 
GROUP BY 
    user_id
)

-- 初トランザクション以降のトランザクションが何日目のものか計測
, elapsed_days_table AS (
SELECT
    t.*,
    f.first_transaction_date,
    DATEDIFF(t.transaction_date, f.first_transaction_date) as elapsed_days
FROM
    daily_transaction_table as t
    LEFT JOIN first_transaction_table as f 
    ON t.user_id = f.user_id
)

-- トランザクション継続の集計（クエリが重いのでデータ加工はSpreadsheetなどでやる）
SELECT
    first_transaction_date,
    elapsed_days,
    COUNT(distinct user_id) as uu
FROM
    elapsed_days_table
WHERE
    -- Nday継続率のNを任意に指定。ただ、28days以降は集計期間が伸びてTimeoutになりやすいため非推奨
    elapsed_days IN (0, 1, 7, 28)
GROUP BY
    first_transaction_date, elapsed_days
ORDER BY
    first_transaction_date, elapsed_days

    
    
    
