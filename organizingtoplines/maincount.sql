SELECT
  COUNT(DISTINCT vanid) AS unique_vanid_count,
  CASE
    WHEN activistcodeid = 5393615 THEN 'FEC Defined Member'
    WHEN activistcodeid = 5396060 THEN 'Hot Lead'
    WHEN activistcodeid = 5289137 THEN 'New Volunteer Lead'
    WHEN activistcodeid = 5297454 THEN 'Active Volunteer'
  END AS ladder_step
FROM (
  SELECT DISTINCT
    vanid,
    activistcodeid
  FROM
      proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym
)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b
USING (vanid)
WHERE activistcodeid IN (5393615, 5396060, 5289137, 5297454)
AND b.state ='AZ'
GROUP BY ladder_step
ORDER BY unique_vanid_count desc;
