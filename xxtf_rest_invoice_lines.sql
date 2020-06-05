
drop table xxtf_rest_invoice_lines;

create table xxtf_rest_invoice_lines(
invoice_line_id number not null,
invoice_id number not null,
line_num number not null,
description varchar2(100) not null,
quantity number not null,
price number not null,
line_amount number not null,
CREATED_BY            NUMBER(15) not null,
CREATION_DATE         DATE not null,
LAST_UPDATED_BY       NUMBER(15) not null,
LAST_UPDATE_DATE      DATE not null,
LAST_UPDATE_LOGIN     NUMBER(15) not null);

drop sequence xxtf_rest_invoice_lines_s;

create sequence xxtf_rest_invoice_lines_s start with 1 nocache;


