/* 
現在から{interval days}日遡った初アクセスログを取得。
NUUと異なり、任意の変数値を選べる。
*/

SELECT
    block_date as date,
    COUNT(distinct signer) as user_id
FROM
    solana.transactions
WHERE
    block_date >= (CURRENT_DATE - '{{interval days}} days'::INTERVAL)
    AND block_date < CURRENT_DATE
    -- アドレスの指定は以下を推奨。Account Keysのリスト内にSTEPNメインアドレスが含まれるかを検証。
    AND array_contains(account_keys, 'STEPNq2UGeGSzCyGVr2nMQAzf8xuejwqebd84wcksCK')
    -- 以下2行はDuneのダッシュボードでたまに見る条件だがここでは推奨しない（ただ、差分は軽微）
    --AND account_keys[1] = "STEPNq2UGeGSzCyGVr2nMQAzf8xuejwqebd84wcksCK"
    --AND size(account_keys) = 3
    AND error is NULL
GROUP BY
    block_date
ORDER BY
    block_date
