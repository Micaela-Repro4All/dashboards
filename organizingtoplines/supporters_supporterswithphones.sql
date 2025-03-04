SELECT
  COUNT(DISTINCT vanid) AS unique_vanid_count,
  CASE WHEN activistcodeid = 5114413 THEN 'Supporter'
  END AS ladder_step
FROM (
  SELECT DISTINCT
    vanid,
    activistcodeid
  FROM
      proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym a
)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b
USING (vanid)
WHERE activistcodeid IN (5114413)
AND b.state ='AZ'
GROUP BY ladder_step
ORDER BY unique_vanid_count desc;

-----

WITH ladder AS (
    SELECT 
        vanid, 
        CASE 
            WHEN activistcodeid = 5393615 THEN 'FEC Defined Member'
            WHEN activistcodeid = 5396060 THEN 'Hot Lead'
            WHEN activistcodeid = 5289137 THEN 'New Volunteer Lead'
            WHEN activistcodeid = 5297454 THEN 'Active Volunteer'
            WHEN activistcodeid = 5114413 THEN 'Supporter' 
            ELSE NULL 
        END AS ladder_of_engagement
    FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contactsactivistcodes_mym
    GROUP BY ladder_of_engagement, vanid
)

SELECT 
    COUNT(DISTINCT a.vanid) AS vanid_count,
    ladder_of_engagement
FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contacts_mym a 
LEFT JOIN ladder USING (vanid)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_phonesdelta_mym d USING (vanid)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b USING (vanid)
WHERE d.Phone IS NOT NULL
  AND ladder_of_engagement IS NOT NULL
  AND b.state = 'AZ'
  AND ladder_of_engagement IN ({{ladder_of_engagement_input | array}})
GROUP BY ladder_of_engagement

UNION ALL

SELECT 
    COUNT(DISTINCT a.vanid) AS vanid_count,
    'Total' AS ladder_of_engagement
FROM proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_contacts_mym a 
LEFT JOIN ladder USING (vanid)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_phonesdelta_mym d USING (vanid)
LEFT JOIN proj-tmc-mem-rffa.raw_everyaction__rffa_naral.av_naral_addressdelta_mym b USING (vanid)
WHERE d.phone IS NOT NULL
  AND ladder_of_engagement IS NOT NULL
  AND b.state = 'AZ'
  AND ladder_of_engagement IN ({{ladder_of_engagement_input | array}})
