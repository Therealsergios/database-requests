SELECT
       v.npp,
       v.dlv_id,
       d. dept_num,  
       v.objt_id,
       d.ust_name, 
       d.uch_name,
       v.t_ind,
       pt.full_name AS nko_type,
       v.fact_num,        
       o.fond_num,         
       m.pname AS nko_marka,   
       z.full_name AS manufact, 
       v.setting_mater,       
       v.s_date,             
          CASE
       WHEN v.ch_ar IS NULL
            THEN "N"
            ELSE "Y"
    	END fl_arx    
FROM v_nko v JOIN departments AS d ON (d.dlv_id = v.dlv_id)
    LEFT JOIN bux_fondobj AS o ON (o.fobj_id = v.fondobj_id)
    LEFT JOIN nko_mark    AS m ON (m.pmp_id = v.pmp_id)
    LEFT JOIN nko_types  AS pt ON (pt.type_id = v.type_id)
    LEFT JOIN spr_zavod   AS z ON (z.id = v.manufact_id)
    LEFT JOIN _tmp_pas_nko_documents AS tD ON (v.objt_id=tD.objt_id)       
WHERE d.dept_id NOT IN (SELECT
			dept_id
		     FROM
		     	depart_status
		     WHERE 
		     	ch_ar = 'Y')
ORDER BY dept_num, plant_name ,npp;