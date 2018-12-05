use DT_1NCMREM_2018
IF OBJECT_ID('DDG_METRICS_XX','U') IS NOT NULL DROP TABLE DDG_METRICS.Metric_24

-- CREATE DATA TABLE FOR METRIC
SELECT * INTO DDG_METRICS.Metric_24 FROM 
(SELECT DISTINCT
a.SR_ID,
a.SR_Name,
a.SR_Mnemonic,
a.SR_Revision,
a.Effectivity,
a.SR_Description,
a.d5_productSystem,
a.d5_ActivityCause,
a.d5_ActivityType,
a.d5_maintenanceLevel,
a.d5_MRC,
a.d5_ElapsedHours,
COUNT(b.child_id)						AS Trigger_total,
dbo.GROUP_CONCAT(distinct b.child_id)	AS Trigger_frequency_list
FROM		[DDG_STAGING].[SR_Base_Table]			a 

LEFT JOIN	[DDG_STAGING].[SR_Process_Occurrences]	b
ON  a.SR_ID			= b.SR_id 
AND a.SR_Revision	= b.SR_revision

LEFT JOIN	[DDG_STAGING].[Frequency_Base_Table]	c 
ON b.child_id = c.item_id

WHERE a.Effectivity IN ('1082PB','1090PB') 
AND b.child_id LIKE 'FR%'

GROUP BY a.SR_ID,a.SR_Name,SR_Mnemonic,a.SR_Revision,a.Effectivity,a.SR_Description,
a.d5_productSystem,a.d5_ActivityCause,a.d5_ActivityType,a.d5_maintenanceLevel,a.d5_MRC, a.d5_ElapsedHours)z


-- Metric Results (note that because there is no checklist field, we devide the total by 4)
SELECT Effectivity,
SUM((CASE WHEN Trigger_total > 0 THEN 1 ELSE 0 END))																											AS Triggers_no,
FORMAT(SUM(CASE WHEN Trigger_total > 0 THEN 1 ELSE 0 END)*100/COUNT(SR_ID), 'N1')																				AS Triggers_Pc,
((COUNT(d5_MRC)+COUNT(SR_Name)+COUNT(d5_productSystem)+COUNT(d5_ActivityCause)+COUNT(d5_ActivityType)+COUNT(d5_maintenanceLevel)+COUNT(SR_Mnemonic))/7)			AS mandatory_fields,
format((COUNT(SR_Name)+COUNT(d5_productSystem)+
COUNT(d5_ActivityCause)+COUNT(d5_ActivityType)+COUNT(d5_maintenanceLevel)+COUNT(d5_MRC)+COUNT(SR_Mnemonic))/7*100.0/COUNT(SR_ID), 'N1')							AS mandatory_fields_pc,
COUNT(d5_ElapsedHours)																																			AS Elapsed_hours,
(COUNT(d5_ElapsedHours) / COUNT(SR_ID))*100.0																													AS Elapsed_hours_pc,
(COUNT(SR_ID))																																					AS Total,
(((SUM(CASE WHEN Trigger_total > 0 THEN 1 ELSE 0 END)))+
((COUNT(d5_MRC)+COUNT(SR_Name)+COUNT(d5_productSystem)+COUNT(d5_ActivityCause)+COUNT(d5_ActivityType)+COUNT(d5_maintenanceLevel)+COUNT(SR_Mnemonic))/7)+
COUNT(d5_ElapsedHours))/4																																		AS Total_Average,
(((SUM(CASE WHEN Trigger_total > 0 THEN 1 ELSE 0 END)))+
((COUNT(d5_MRC)+COUNT(SR_Name)+COUNT(d5_productSystem)+COUNT(d5_ActivityCause)+COUNT(d5_ActivityType)+COUNT(d5_maintenanceLevel)+COUNT(SR_Mnemonic))/7)+
COUNT(d5_ElapsedHours))/4*100.0/COUNT(SR_ID)																													AS Total_Average_pc
FROM DDG_METRICS.Metric_24
GROUP BY Effectivity;

-- Data Sheet
SELECT * FROM DDG_METRICS.Metric_24;




