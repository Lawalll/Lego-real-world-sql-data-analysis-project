CREATE DATABASE lego;
USE lego;

--Creating a view--
CREATE view[dbo].[analysis_main] as

SELECT s.set_num, s.name as set_name, s.year,s.theme_id, cast(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id, p.name as parent_theme_name,
CASE
   WHEN s.year between 1901 and 2000 then '20th _Century'
   WHEN s.year between 2001 and 2100 then '21st_Century'
   END
   AS Century
   FROM dbo.sets  s
   LEFT JOIN[dbo].[themes]  t
      ON s.theme_id = t.id
	  LEFT JOIN [dbo].[themes]p
	    ON t.parent_id = p.id
		GO



--what is the total number of parts per theme--
-- select * from dbo.analysis_main--

SELECT 
theme_name,
SUM (num_parts) AS total_number
FROM dbo.analysis_main 
GROUP BY theme_name
ORDER BY total_number DESC ;




---what is the total number of parts per year --
SELECT year, 
SUM(num_parts) AS counts
FROM dbo.analysis_main
GROUP BY year 
ORDER BY counts DESC;

--how many sets were created in each century--
SELECT Century,
COUNT (set_num) AS total_number_of_sets
FROM dbo.analysis_main
GROUP BY Century
ORDER BY total_number_of_sets DESC;


--what percentage of sets ever released in the 21st century were trains themed--
;with cte as
(
    SELECT Century , theme_name, count(set_num) total_set_num
	FROM dbo.analysis_main
	WHERE Century = '21st_Century'
	GROUP BY Century, theme_name
	)
	SELECT sum(total_set_num) , sum(percentage)
	FROM (
	      SELECT Century ,theme_name, total_set_num, sum(total_set_num) OVER() as total, cast(1.00 *total_set_num / sum(total_set_num) OVER() as decimal (5,4))*100 percentage
		  FROM cte
		  )m
		  WHERE theme_name like '%Star wars%'



----5----
----what was the popular theme by year in termsof sets released in the 21st century---

SELECT year, theme_name, total_set_num
FROM (
    SELECT year, theme_name, COUNT(set_num) total_set_num, ROW_NUMBER() OVER(partition by year order by COUNT(set_num) DESC)rn
	FROM analysis_main
	WHERE Century = '21st_Century'
	AND parent_theme_name IS NOT NULL
	GROUP BY year, theme_name
	) m
	WHERE rn =1 
	ORDER BY year DESC;




---what is the most produced color of lego ever in terms of quantity of parts ---

SELECT color_name , sum(quantity) as quantity_of_parts
FROM (
          SELECT 
		       inv.color_id, inv.inventory_id, inv.part_num, cast(inv.quantity as numeric) quantity, inv.is_spare, c.name as color_name, c.rgb, p.name as part_name, p.part_material, pc.name as category_name
				FROM inventory_parts inv
				INNER JOIN colors c
				      ON inv.color_id = c.id
					  INNER JOIN parts p
					        ON  inv.part_num = p.part_num
							INNER JOIN part_categories pc
							    ON part_cat_id = pc.id
       )main 

	   GROUP BY color_name
	   ORDER BY 2 DESC;