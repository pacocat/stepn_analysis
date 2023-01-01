WITH

gmt_usdc_orca_pool AS (
SELECT
    block_date,
    post_token_balance.mint AS token_address,
    SUM(post_token_balance.amount) AS token_size,
    IF (post_token_balance.mint ='EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', -- USDC contract
        SUM(post_token_balance.amount), 1/SUM(post_token_balance.amount)) AS tmp
FROM
    solana.transactions LATERAL VIEW EXPLODE(post_token_balances) t3 AS post_token_balance
WHERE 
    --block_date >= (CURRENT_DATE - '360 days'::INTERVAL)
    -- GMTデータは2022-03-31より
    block_date BETWEEN DATE('2022-03-31') AND DATE('2022-11-05')
    AND ARRAY_CONTAINS(account_keys, "3HGGVGTXbqT49PG3L8JQYH4jCeP5CNBG6CpJniZ434an") --usdc/gmt pool
    AND (
        (post_token_balance.mint = "7i5KKsX2weiTkry7jA4ZwSuXGhs5eJBEjY8vVxR4pfRx" -- GMT contract
            AND post_token_balance.account = "BTpvbpTArnekGgbXRqjfSvp7gENtHXvZCAwuUKQNYMeN")
        OR (post_token_balance.mint = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v" -- USDC mint 
            AND post_token_balance.account = "DdBTJuiAXQQ7gLVXBXNPbVEG8g1avRxiJXhH5LhBytYW") -- USDC contract
        )
GROUP BY 
    block_date,
    post_token_balance.mint
)

-- gmt_price
SELECT 
    block_date,
    -- dailyの取引価格の幾何平均を計算
    round(EXP(SUM(LOG(tmp))), 2) AS gmt_price
FROM 
    gmt_usdc_orca_pool
GROUP BY 
    block_date
