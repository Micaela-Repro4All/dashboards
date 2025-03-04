WITH interval_data AS (
  -- Create monthly intervals starting from January 2025
  SELECT 
    vanid,
    FORMAT_DATE('%Y-%m', DATE(a.datecreated)) AS interval_start
  FROM 
    proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym a
left join proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b using (vanid)
  WHERE 
    activistcodeid = 5393615 --'FEC Defined Member'
    AND a.datecreated >= DATETIME('2025-01-01') -- Only data from 2025 onward
    AND b.state ='AZ'

)
SELECT 
  interval_start,
  COUNT(DISTINCT vanid) AS new_fec_member_count
FROM interval_data
GROUP BY interval_start
ORDER BY interval_start;

----

WITH interval_data AS (
  -- Create monthly intervals starting from January 2025
  SELECT 
    vanid,
    FORMAT_DATE('%Y-%m', DATE(a.datecreated)) AS interval_start
  FROM 
    proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym a
left join proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b using (vanid)
  WHERE 
    activistcodeid = 5114413 --'Supporter'
    AND a.datecreated >= DATETIME('2025-01-01') -- Only data from 2025 onward
    AND b.state ='AZ'

)
SELECT 
  interval_start,
  COUNT(DISTINCT vanid) AS new_supporter_count
FROM interval_data
GROUP BY interval_start
ORDER BY interval_start;
