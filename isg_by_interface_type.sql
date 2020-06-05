select display_interface_type,count(*)
from (
select decode(a.open_interface_flag,'Y','Open Interface',b.meaning) as display_interface_type
from   fnd_irep_all_interfaces a,
       fnd_lookups b
where  b.lookup_code = a.class_type
and    b.lookup_type = 'FND_REP_OBJECT_TYPE'
and    b.enabled_flag = 'Y'
and    a.lifecycle_mode = 'ACTIVE')
group by display_interface_type
order by count(*) desc
/
