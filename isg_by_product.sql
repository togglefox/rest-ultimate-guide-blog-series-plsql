select display_product_name,count(*)
from (
select nvl(b.product_name,a.product_code) as display_product_name
from   fnd_irep_all_interfaces a,
       ad_pm_product_info b
where  a.product_code = b.product_abbreviation(+)
and    a.lifecycle_mode = 'ACTIVE')
group by display_product_name
order by count(*) desc
/
