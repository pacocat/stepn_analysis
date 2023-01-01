WITH

gst_usdc_orca_pool AS (
SELECT 
    block_date,
    post_token_balance.mint AS token_address,
    SUM(post_token_balance.amount) AS token_size,
    IF (post_token_balance.mint ='EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', -- USDC contract
        SUM(post_token_balance.amount), 1/SUM(post_token_balance.amount)) AS tmp
FROM
    solana.transactions LATERAL VIEW EXPLODE(post_token_balances) t3 AS post_token_balance
WHERE 
    -- GSTデータは2021-12-27より
    block_date BETWEEN DATE('2021-12-27') AND DATE('2022-11-01')
    AND ARRAY_CONTAINS(account_keys, "CwwMfXPXfRT5H5JUatpBctASRGhKW2SqLWWGU3eX5Zgo") --usdc/gst pool
    AND ((post_token_balance.mint = "AFbX8oGjGpmVFywbVouvhQSRmiW2aR1mohfahi4Y2AdB" -- GST contract
        AND post_token_balance.account = "9r39vqrJuubgafaJ5aQyDWYAUQVJeyZyveBXeRqp7xev")
            OR (post_token_balance.mint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v" -- USDC contract
        AND post_token_balance.account = "7LFnr5YgUyEgPMCLGNQ9N7wM5MFRNqCuRawLZTe5q4c7"))-- USDC mint
GROUP BY
    block_date,
    post_token_balance.mint
)

SELECT
    block_date,
    -- dailyの取引価格の幾何平均を計算
    round(EXP(SUM(LOG(tmp))), 3) AS gst_price
FROM
    gst_usdc_orca_pool
GROUP BY
    block_date
ORDER BY
    block_date
