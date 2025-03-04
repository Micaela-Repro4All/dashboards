WITH organizer_mapping AS (
  SELECT DISTINCT 
    CASE 
      WHEN eventname LIKE '%Jamila%' THEN 'Jamila'
      WHEN eventname LIKE '%Yazmin%' THEN 'Yazmin'
    END AS organizer
  FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_events
  WHERE eventname LIKE '%Jamila%' OR eventname LIKE '%Yazmin%'
),

filtered_events AS (
  SELECT 
    FORMAT_DATE('%Y-%m', DATE(a.DateCreated)) AS interval_start,
    om.organizer
  FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_events a
  LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_eventsignups USING (eventid)
  LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_eventsignupsstatuses USING (eventsignupid)
  JOIN organizer_mapping om ON 
    (eventname LIKE '%Jamila%' AND om.organizer = 'Jamila') OR 
    (eventname LIKE '%Yazmin%' AND om.organizer = 'Yazmin')
  WHERE om.organizer IN ({{organizer | array }}) -- Filtering by name
    AND EventStatusName = 'Completed'
    AND a.DateCreated >= DATE('2025-01-01')
),

aggregated_data AS (
  SELECT 
    interval_start,
    COUNT(*) AS one_on_one_count
  FROM filtered_events
  GROUP BY interval_start
),

date_reference AS (
  SELECT 
    FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH)) AS current_month,
    FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH) - INTERVAL 1 MONTH) AS previous_month
),

final_counts AS (
  SELECT 
    SUM(one_on_one_count) AS total_one_on_ones_2025
  FROM aggregated_data
)

SELECT 
  dr.previous_month,
  COALESCE(pm.one_on_one_count, 0) AS one_on_one_count_previous_month,
  dr.current_month,
  COALESCE(cm.one_on_one_count, 0) AS one_on_one_count_current_month,
  total.total_one_on_ones_2025
FROM date_reference dr
LEFT JOIN aggregated_data pm ON dr.previous_month = pm.interval_start
LEFT JOIN aggregated_data cm ON dr.current_month = cm.interval_start
CROSS JOIN final_counts total;
