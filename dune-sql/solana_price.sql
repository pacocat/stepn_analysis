/*
DEXデータセットを用いたSOLANA価格（USD）の集計
エンジンはsolana.transactionの時のDUNE Engine v2ではなく、Ethereumを選択する点に注意。
集計テーブルなのでクエリはとても軽い。
*/

SELECT 
    date_trunc('day', hour) as day,
    max(round(median_price::numeric,2)) as SOL_price
FROM
    dex."view_token_prices" d
    LEFT JOIN erc20.tokens e on d.contract_address = e.contract_address
WHERE 
    symbol = 'SOL'
    AND hour >= '2021-12-01'
    AND hour <= current_date
GROUP BY 1 

