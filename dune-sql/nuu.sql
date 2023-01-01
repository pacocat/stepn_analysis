WITH

/* 
現在から{interval days}日遡った初アクセスログを取得。以下に注意。
対象期間以前に起動したユーザーは期間初日（CURRENT_DATE - {inreval days}）のNUUとして扱われる可能性がある。
そのため、純粋なNUUの推移を知りたい場合はサービス開始（2021年12月のパブリックβ開始）まで遡る必要がありそう。
*/
first_access_table AS (
SELECT
    signer as user_id,
    MIN(block_date) as first_access_date
FROM
    solana.transactions
WHERE
    block_date >= (CURRENT_DATE - '{{interval days}} days'::INTERVAL)
    AND block_date < CURRENT_DATE
    -- STEPNのaccount key (ref. https://solscan.io/account/STEPNq2UGeGSzCyGVr2nMQAzf8xuejwqebd84wcksCK)
    AND account_keys[1] = "STEPNq2UGeGSzCyGVr2nMQAzf8xuejwqebd84wcksCK"
    -- 配列要素が３つのものに絞る（意図は確認できていないが、当該account keyを含むものは全てsize=3であることを確認済）
    AND size(account_keys) = 3
    -- 成功したトランザクションのみに絞る（2022-11-06のデータでは0.1%ほどerrorが発生している）
    AND error is NULL
GROUP BY
    signer
)

SELECT
    first_access_date,
    COUNT(distinct user_id) as nuu
FROM
    first_access_table
GROUP BY first_access_date
ORDER BY first_access_date
