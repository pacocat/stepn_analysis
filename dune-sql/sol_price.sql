SELECT 
    date_trunc('day', hour) as day,
    max(round(median_price::numeric,3)) as SOL_price
FROM
    dex."view_token_prices" d
    LEFT JOIN erc20.tokens e 
    ON d.contract_address = e.contract_address
WHERE
    symbol = 'SOL'
    AND hour >= '2021-12-01'
    AND hour <= current_date
GROUP BY 1 

