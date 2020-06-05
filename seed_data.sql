begin
  XXTF_REST_INVOICE_PKG.seed_invoices(&1,&2,0);
end;
/

select * from xxtf_rest_invoices
/

select * from xxtf_rest_invoice_lines
/

