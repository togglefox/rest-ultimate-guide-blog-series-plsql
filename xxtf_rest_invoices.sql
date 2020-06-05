
drop table xxtf_rest_invoices;

create table xxtf_rest_invoices(
invoice_id number not null,
invoice_num varchar2(50) not null,
invoice_date date not null,
customer_num varchar2(50) not null,
CREATED_BY            NUMBER(15) not null,
CREATION_DATE         DATE not null,
LAST_UPDATED_BY       NUMBER(15) not null,
LAST_UPDATE_DATE      DATE not null,
LAST_UPDATE_LOGIN     NUMBER(15) not null);

drop sequence xxtf_rest_invoices_s;

create sequence xxtf_rest_invoices_s start with 1 nocache;


