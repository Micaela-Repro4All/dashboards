SELECT 
  'Completed' AS Category,
  (SUM(CASE
    WHEN (status LIKE 'Sched%') AND (final_status = 'Completed' OR final_status = 'Walk In') THEN 1
    ELSE 0
  END) / NULLIF(SUM(CASE
    WHEN status LIKE 'Sched%' THEN 1
    ELSE 0
  END), 0)) * 100 AS Percentage
FROM proj-tmc-mem-rffa.everyaction_enhanced.enh_everyaction__events
left join proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b using (vanid)
WHERE b.state ='AZ'

UNION ALL

SELECT 
  'Flaked' AS Category,
  (SUM(CASE
    WHEN status LIKE 'Sched%' THEN 1
    ELSE 0
  END) - SUM(CASE
    WHEN (status LIKE 'Sched%') AND (final_status = 'Completed' OR final_status = 'Walk In') THEN 1
    ELSE 0
  END)) / NULLIF(SUM(CASE
    WHEN status LIKE 'Sched%' THEN 1
    ELSE 0
  END), 0) * 100 AS Percentage
FROM proj-tmc-mem-rffa.everyaction_enhanced.enh_everyaction__events
left join proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b using (vanid)
WHERE b.state ='AZ'
