WITH organizer_mapping AS (
  SELECT DISTINCT 
    canvassedby,
    CASE 
      WHEN canvassedby = 2545603 THEN 'Jamila'
      WHEN canvassedby = 2545602 THEN 'Yazmin'
    END AS organizer
  FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactscontacts_mym
  WHERE canvassedby IN (2545603, 2545602)
),

interval_data AS (
    SELECT 
    a.contactscontactid,
    FORMAT_DATE('%Y-%m', TIMESTAMP(a.datecanvassed)) AS interval_start,
    om.organizer
  FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactscontacts_mym a
  JOIN organizer_mapping om ON a.canvassedby = om.canvassedby
  WHERE om.organizer IN ({{organizer | array }})  -- Filtering by name
    AND a.datecanvassed >= DATE('2025-01-01')
),

phonecalls_2025 AS (
  SELECT 
    '2025' AS year_key,
    COUNT(contactscontactid) AS total_phonecalls_2025
  FROM interval_data
),

phonecalls_by_month AS (
  SELECT 
    interval_start,
    COUNT(contactscontactid) AS phonecalls_count
  FROM interval_data
  GROUP BY interval_start
),

date_reference AS (
  SELECT FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH)) AS current_month,
         FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH) - INTERVAL 1 MONTH) AS previous_month
)

SELECT 
  dr.previous_month,
  COALESCE(pm.phonecalls_count, 0) AS phonecalls_count_previous_month,
  dr.current_month,
  COALESCE(cm.phonecalls_count, 0) AS phonecalls_count_current_month,
  total.total_phonecalls_2025
FROM date_reference dr
LEFT JOIN phonecalls_by_month pm ON dr.previous_month = pm.interval_start
LEFT JOIN phonecalls_by_month cm ON dr.current_month = cm.interval_start
LEFT JOIN phonecalls_2025 total ON 1=1;
