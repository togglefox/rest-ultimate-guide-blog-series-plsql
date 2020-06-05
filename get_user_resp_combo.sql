select a.user_id,
       b.responsibility_id,
       b.application_id,
       b.responsibility_name
from   fnd_user_resp_groups a,
       fnd_responsibility_vl b,
       fnd_user c
where  c.user_name='&1'
and    a.responsibility_id=b.responsibility_id
and    a.user_id=c.user_id
and    sysdate between nvl(a.start_date,sysdate) and nvl(b.end_date,sysdate)
/
