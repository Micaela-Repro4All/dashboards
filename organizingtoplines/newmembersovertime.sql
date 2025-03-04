WITH interval_data AS (
  SELECT 
    a.vanid,  -- Keep VANID to ensure unique individuals
    CASE 
      WHEN a.activistcodeid = 5393615 THEN 'FEC Defined Member'
      WHEN a.activistcodeid = 5396060 THEN 'Hot Lead'
      WHEN a.activistcodeid = 5289137 THEN 'New Volunteer Lead'
      WHEN a.activistcodeid = 5297454 THEN 'Active Volunteer'
      WHEN a.activistcodeid = 5114413 THEN 'Supporter'
    END AS ladder_step,
    FORMAT_DATE('%Y-%m', DATE(a.datecreated)) AS interval_start
  FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym a
  LEFT JOIN (
      SELECT vanid, state
      FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym
      QUALIFY ROW_NUMBER() OVER (PARTITION BY vanid ORDER BY datecreated DESC) = 1
  ) b ON a.vanid = b.vanid
  WHERE 
    a.activistcodeid IN (5393615, 5396060, 5289137, 5297454, 5114413)
    AND a.datecreated >= '2025-01-01'
    AND b.state = 'AZ'
),

members_by_month AS (
  SELECT 
    interval_start,
    ladder_step,
    COUNT(DISTINCT vanid) AS members_count
  FROM interval_data
  WHERE ladder_step IN ({{ladder_of_engagement_input | array}})
  GROUP BY interval_start, ladder_step
),

members_2025 AS (
  SELECT 
    ladder_step,
    COUNT(DISTINCT vanid) AS total_members_2025
  FROM interval_data
  WHERE ladder_step IN ({{ladder_of_engagement_input | array}})
  GROUP BY ladder_step
),

date_reference AS (
  SELECT 
    FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH)) AS current_month,
    FORMAT_DATE('%Y-%m', DATE_TRUNC(CURRENT_DATE(), MONTH) - INTERVAL 1 MONTH) AS previous_month
)

SELECT 
  dr.previous_month,
  pm.ladder_step,
  COALESCE(pm.members_count, 0) AS members_count_previous_month,
  dr.current_month,
  COALESCE(cm.members_count, 0) AS members_count_current_month,
  COALESCE(total.total_members_2025, 0) AS total_members_2025
FROM date_reference dr
LEFT JOIN members_by_month pm ON dr.previous_month = pm.interval_start
LEFT JOIN members_by_month cm ON dr.current_month = cm.interval_start AND pm.ladder_step = cm.ladder_step
LEFT JOIN members_2025 total ON pm.ladder_step = total.ladder_step
WHERE pm.ladder_step IN ({{ladder_of_engagement_input | array}})
ORDER BY pm.ladder_step;
