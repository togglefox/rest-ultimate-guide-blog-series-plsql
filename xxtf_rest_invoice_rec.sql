
create or replace type xxtf_rest_invoice_rec force is object (
  invoice_id number,
  invoice_num varchar2(50),
  invoice_date date,
  customer_num varchar2(50),
  lines xxtf_rest_invoice_line_tab)
/

show errors

