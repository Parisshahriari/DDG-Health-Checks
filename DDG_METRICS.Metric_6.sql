use DT_1NCMREM_2018
IF OBJECT_ID('DDG_METRICS.Metric_6','U') IS NOT NULL DROP TABLE DDG_METRICS.Metric_6

-- Create Table for metric 6 
select * into DDG_METRICS.Metric_6 from 
(SELECT 
a.SR_Name, 
a.effectivity, 
a.SR_Revision, 
a.SR_ID,
b.parent_type, 
b.dataset_type, 
b.dataset_name, 
b.original_file_name,
CASE WHEN parent_ID IS NOT NULL then 'aligned'
	 ELSE 'misaligned' end as alignment_flag
 
FROM		DDG_STAGING.SR_Base_Table		a 

LEFT JOIN	DDG_STAGING.Associated_Dataset	b 
ON a.SR_ID			= b.parent_ID
and a.SR_Revision	= b.parent_Revision

where Effectivity in ('1082PB','1090PB'))z


-- Metric Result 
SELECT COUNT(alignment_flag) Results, effectivity, alignment_flag FROM DDG_METRICS.Metric_6 GROUP BY effectivity, alignment_flag ORDER BY effectivity;

--Misalignments (no results as there arent any)
SELECT * from DDG_Metrics.Metric_6 where alignment_flag = 'misaligned'

--Insight (no SR has more than 1 dataset, previous multiple datasets may be due to not joining on Revision)
select SR_ID, SR_Revision, Effectivity, COUNT(SR_ID) from DDG_Metrics.Metric_6 group by SR_ID, SR_Revision, Effectivity having COUNT(SR_ID) != 1

--Data sheet
SELECT * FROM DDG_METRICS.Metric_6