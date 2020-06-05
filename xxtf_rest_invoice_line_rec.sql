

create or replace type xxtf_rest_invoice_line_rec force is object (
  invoice_line_id number,
  invoice_id number,
  line_num number,
  description varchar2(100),
  quantity number,
  price number,
  line_amount number)
/

show errors

