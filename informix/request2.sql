SELECT
	sparetypesonketegorii.kat_id,  -- id категории
	markontypesinkategory.kati_id,  -- id подкатегории
	sparetypesonketegorii.vid,  -- вид ЗИП
	sparetypesonketegorii.podvid_or_vid,  -- подвид ЗИП
	sparetypesonketegorii.type_or_podvid_or_vid,  -- тип ЗИП
	markontypesinkategory.pmp_id,  -- id марки
	t4.pname AS nko_mark  -- наименование марки
FROM spr_norma_nko_item_mark markontypesinkategory,
	OUTER nko_mark t4, (
		SELECT 
			t1.kati_id,
			t1.kat_id,
			t1.spare_type_id,
			sparetypetable.vid,
			sparetypetable.podvid_or_vid,
			sparetypetable.type_or_podvid_or_vid
		FROM 
			spr_norma_nko_item
			t1,
			(
		SELECT 
			t.type_id,
			PV.vid,
			PV.podvid_or_vid,
			t.caption AS type_or_podvid_or_vid,
			t.kind
		FROM nko_spare_types AS T, 
	OUTER (
		SELECT 
			v.caption AS vid,
			P.type_id,
			p.caption AS podvid_or_vid,
			p.kind			 
		FROM	nko_spare_types AS P, 
	OUTER (
		SELECT* 
		FROM nko_spare_types 
		) AS V					
	WHERE V.type_id=P.parent_id 
	      AND V.kind<>"T" 
	      AND P.kind<>"T"  
		) AS PV
	WHERE T.parent_id=PV.type_id
		) AS sparetypetable
	WHERE (sparetypetable.type_id=t1.spare_type_id) 
		) AS sparetypesonketegorii
WHERE markontypesinkategory.pmp_id = t4.pmp_id 
      AND sparetypesonketegorii.kati_id=markontypesinkategory.kati_id