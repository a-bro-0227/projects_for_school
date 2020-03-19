
select ks1.category, ks1.count_successful, ks2.count_total, round(ks1.count_successful::numeric/ks2.count_total::numeric, 2) as pct_successful
from 
	(
	select category, count(*) as count_successful from ksprojects
	where state = 'successful' group by category
	) as ks1
inner join 
	(
	select category, count(*) as count_total from ksprojects
	group by category
	) as ks2
on ks1.category = ks2.category;