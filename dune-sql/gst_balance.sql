/* 
GSTのdailyの入金・引き出しを集計するクエリ
https://dune.com/queries/604436
を参考に分析・加筆
*/

SELECT
    block_date,
    -- GST変化前後の大小によって、DepositとWithdrawalsを区別している
    SUM(CASE WHEN post_token_balance.amount - pre_token_balance.amount > 0 THEN post_token_balance.amount - pre_token_balance.amount ELSE 0 END) AS GST_Deposits,
    SUM(CASE WHEN post_token_balance.amount - pre_token_balance.amount < 0 THEN pre_token_balance.amount - post_token_balance.amount ELSE 0 END) AS GST_Withdrawals
FROM 
    solana.transactions
    LATERAL VIEW explode(account_keys) t1 AS account 
    LATERAL VIEW explode(pre_token_balances) t2 AS pre_token_balance 
    LATERAL VIEW explode(post_token_balances) t3 AS post_token_balance
WHERE
    -- 重いクエリになるので、1ヶ月から2ヶ月ずつの抽出を推奨
    block_date BETWEEN DATE('2022-10-01') AND DATE('2022-11-01')
    -- GSTトークンアカウント（HLS5Y68QSQgJP7wUbbbbCjEnMknVZrHXYDwwVaDcsdK7）
    AND account = 'HLS5Y68QSQgJP7wUbbbbCjEnMknVZrHXYDwwVaDcsdK7'
    -- GSTトークンアドレス（AFbX8oGjGpmVFywbVouvhQSRmiW2aR1mohfahi4Y2AdB）
    AND pre_token_balance.mint='AFbX8oGjGpmVFywbVouvhQSRmiW2aR1mohfahi4Y2AdB'
    AND post_token_balance.mint='AFbX8oGjGpmVFywbVouvhQSRmiW2aR1mohfahi4Y2AdB'
    -- GSTトークンアカウント（HLS5Y68QSQgJP7wUbbbbCjEnMknVZrHXYDwwVaDcsdK7）
    AND pre_token_balance.account = "HLS5Y68QSQgJP7wUbbbbCjEnMknVZrHXYDwwVaDcsdK7"
    AND post_token_balance.account = "HLS5Y68QSQgJP7wUbbbbCjEnMknVZrHXYDwwVaDcsdK7"
    AND error is NULL
GROUP BY 
    block_date
ORDER BY 
    block_date

