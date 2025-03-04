WITH interval_data AS (
  SELECT 
    'Total Messages' AS category,
    a.id,
    FORMAT_DATE('%Y-%m', TIMESTAMP(a.updated_at)) AS interval_start
  FROM proj-tmc-mem-rffa.raw_scaletowin_p2p__rffa_rffa.messages a
  left join proj-tmc-mem-rffa.raw_scaletowin_p2p__rffa_rffa.campaign_contacts b on a.contact_phone_number = b.phone_number
  WHERE JSON_VALUE(data, '$.state')= 'AZ'
  AND a.updated_at > '2025-01-01'
  AND a.direction = 'OUTBOUND'
  group by a.id, a.updated_at
),

texts_2025 AS (
  SELECT 
    '2025' AS year_key,
    COUNT(id) AS total_texts_2025
  FROM interval_data
),

texts_by_month AS (
  SELECT 
    interval_start,
    COUNT(id) AS texts_count
  FROM interval_data
  GROUP BY interval_start
),

date_reference AS (
  SELECT FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH)) AS current_month,
         FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH) - INTERVAL 1 MONTH) AS previous_month
)

SELECT 
  dr.previous_month,
  COALESCE(pm.texts_count, 0) AS texts_count_previous_month,
  dr.current_month,
  COALESCE(cm.texts_count, 0) AS texts_count_current_month,
  total.total_texts_2025
FROM date_reference dr
LEFT JOIN texts_by_month pm ON dr.previous_month = pm.interval_start
LEFT JOIN texts_by_month cm ON dr.current_month = cm.interval_start
LEFT JOIN texts_2025 total ON 1=1;
