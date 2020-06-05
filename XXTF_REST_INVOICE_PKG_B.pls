
CREATE OR REPLACE PACKAGE BODY XXTF_REST_INVOICE_PKG AS

/******************************************************************************

  Copyright 2020 togglefox.

  For details see www.togglefox.com/blogs/create_plsql_rest_service_demo

  Ver   When    Who             What
  ----- ------- --------------- -------------------------
  1.0   05Feb20 Michael Carroll Initial creation.

******************************************************************************/

  function create_invoice(invoice in xxtf_rest_invoice_rec) return number is
    v_invoice_id number;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start create_invoice');
    XXTF_SIMPLE_LOG_PKG.log('invoice_num='||invoice.invoice_num);
    XXTF_SIMPLE_LOG_PKG.log('invoice_date='||invoice.invoice_date);
    XXTF_SIMPLE_LOG_PKG.log('customer_num='||invoice.customer_num);

    XXTF_SIMPLE_LOG_PKG.log('customer_num2='||invoice.customer_num);

    v_invoice_id := xxtf_rest_invoices_s.nextval;
    XXTF_SIMPLE_LOG_PKG.log('v_invoice_id='||v_invoice_id);

    insert into xxtf_rest_invoices (
      invoice_id,
      invoice_num,
      invoice_date,
      customer_num,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    values (
      v_invoice_id,
      invoice.invoice_num,
      invoice.invoice_date,
      invoice.customer_num,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.login_id);

    create_invoice_lines(v_invoice_id,invoice.lines);

    XXTF_SIMPLE_LOG_PKG.log('end create_invoice invoice_id='||v_invoice_id);
    return v_invoice_id;
  end create_invoice;


  procedure create_invoice_lines(p_invoice_id in number, p_tab in xxtf_rest_invoice_line_tab) is
    v_invoice_line_id number;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start create_invoice_lines');
    XXTF_SIMPLE_LOG_PKG.log('p_invoice_id='||p_invoice_id);
    XXTF_SIMPLE_LOG_PKG.log('p_tab.count='||p_tab.count);

    for a in p_tab.first..p_tab.last loop
      v_invoice_line_id := xxtf_rest_invoice_lines_s.nextval;
      XXTF_SIMPLE_LOG_PKG.log('v_invoice_line_id='||v_invoice_line_id);
      XXTF_SIMPLE_LOG_PKG.log('line_num='||p_tab(a).line_num);
      XXTF_SIMPLE_LOG_PKG.log('description='||p_tab(a).description);
      XXTF_SIMPLE_LOG_PKG.log('quantity='||p_tab(a).quantity);
      XXTF_SIMPLE_LOG_PKG.log('price='||p_tab(a).price);
      XXTF_SIMPLE_LOG_PKG.log('line_amount='||p_tab(a).line_amount);

      insert into xxtf_rest_invoice_lines (
        invoice_line_id,
        invoice_id,
        line_num,
        description,
        quantity,
        price,
        line_amount,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      values (
        v_invoice_line_id,
        p_invoice_id,
        p_tab(a).line_num,
        p_tab(a).description,
        p_tab(a).quantity,
        p_tab(a).price,
        p_tab(a).line_amount,
        FND_GLOBAL.user_id,
        sysdate,
        FND_GLOBAL.user_id,
        sysdate,
        FND_GLOBAL.login_id);
    end loop;

    XXTF_SIMPLE_LOG_PKG.log('end create_invoice_lines');
  end create_invoice_lines;


  function get_invoice(invoice_id in number) return xxtf_rest_invoice_rec is
    v_invoice_rec xxtf_rest_invoice_rec;
    v_invoice_num xxtf_rest_invoices.invoice_num%type;
    v_invoice_date xxtf_rest_invoices.invoice_date%type;
    v_customer_num xxtf_rest_invoices.customer_num%type;
    v_invoice_id number := invoice_id; -- avoid name class in sql
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoice');
    XXTF_SIMPLE_LOG_PKG.log('v_invoice_id='||v_invoice_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.user_id='||FND_GLOBAL.user_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.user_name='||FND_GLOBAL.user_name);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.resp_id='||FND_GLOBAL.resp_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.resp_appl_id='||FND_GLOBAL.resp_appl_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.resp_name='||FND_GLOBAL.resp_name);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.security_group_id='||FND_GLOBAL.security_group_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.nls_language='||FND_GLOBAL.nls_language);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.org_id='||FND_GLOBAL.org_id);
    XXTF_SIMPLE_LOG_PKG.log('FND_GLOBAL.org_name='||FND_GLOBAL.org_name);

    begin
      select invoice_num,
             invoice_date,
             customer_num
      into   v_invoice_num,
             v_invoice_date,
             v_customer_num
      from   xxtf_rest_invoices
      where  invoice_id = v_invoice_id;

    exception
      when no_data_found then
        XXTF_SIMPLE_LOG_PKG.log('got no_data_found exception');
        raise_application_error(-20001,'Invalid invoice id: '||v_invoice_id);
      when others then
        XXTF_SIMPLE_LOG_PKG.log('got exception sqlerrm='||sqlerrm);
        raise;
    end;

    v_invoice_rec := xxtf_rest_invoice_rec(
      v_invoice_id,
      v_invoice_num,
      v_invoice_date,
      v_customer_num,
      get_invoice_lines(v_invoice_id));

    XXTF_SIMPLE_LOG_PKG.log('end get_invoice');
    return v_invoice_rec;
  end get_invoice;


  function get_invoice_lines(p_invoice_id in number) return xxtf_rest_invoice_line_tab is
    v_line_tab xxtf_rest_invoice_line_tab := xxtf_rest_invoice_line_tab();
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoice_lines');
    XXTF_SIMPLE_LOG_PKG.log('p_invoice_id='||p_invoice_id);

    for a in (
      select invoice_line_id,
             line_num,
             description,
             quantity,
             price,
             line_amount
      from   xxtf_rest_invoice_lines
      where  invoice_id = p_invoice_id
      order by line_num) loop

      XXTF_SIMPLE_LOG_PKG.log('invoice_line_id='||a.invoice_line_id);
      XXTF_SIMPLE_LOG_PKG.log('line_num='||a.line_num);
      XXTF_SIMPLE_LOG_PKG.log('description='||a.description);
      XXTF_SIMPLE_LOG_PKG.log('quantity='||a.quantity);
      XXTF_SIMPLE_LOG_PKG.log('price='||a.price);
      XXTF_SIMPLE_LOG_PKG.log('line_amount='||a.line_amount);

      v_line_tab.extend;
      v_line_tab(v_line_tab.count) :=
        xxtf_rest_invoice_line_rec(
          a.invoice_line_id,
          p_invoice_id,
          a.line_num,
          a.description,
          a.quantity,
          a.price,
          a.line_amount);

    end loop;
    XXTF_SIMPLE_LOG_PKG.log('end get_invoice_lines');
    return v_line_tab;
  end get_invoice_lines;


  function get_invoices(
    invoice_num in varchar2,
    invoice_date_from in date,
    invoice_date_to in date,
    customer_num in varchar2) return xxtf_rest_invoice_tab is

    v_invoice_tab xxtf_rest_invoice_tab := xxtf_rest_invoice_tab();
    -- avoid name clashes in sql
    v_invoice_num xxtf_rest_invoices.invoice_num%type := invoice_num;
    v_customer_num xxtf_rest_invoices.customer_num%type := customer_num;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoices');
    XXTF_SIMPLE_LOG_PKG.log('invoice_num='||invoice_num);
    XXTF_SIMPLE_LOG_PKG.log('invoice_date_from='||invoice_date_from);
    XXTF_SIMPLE_LOG_PKG.log('invoice_date_to='||invoice_date_to);
    XXTF_SIMPLE_LOG_PKG.log('customer_num='||customer_num);

    for a in (
      select invoice_id,
             invoice_num,
             invoice_date,
             customer_num
      from   xxtf_rest_invoices
      where (invoice_num like v_invoice_num or v_invoice_num is null)
      and   (invoice_date >= invoice_date_from or invoice_date_from is null)
      and   (invoice_date <= invoice_date_to or invoice_date_to is null)
      and   (customer_num like v_customer_num or v_customer_num is null)
      order by invoice_id) loop

      XXTF_SIMPLE_LOG_PKG.log('invoice_id='||a.invoice_id);
      XXTF_SIMPLE_LOG_PKG.log('invoice_num='||a.invoice_num);
      XXTF_SIMPLE_LOG_PKG.log('invoice_date='||a.invoice_date);
      XXTF_SIMPLE_LOG_PKG.log('customer_num='||a.customer_num);

      v_invoice_tab.extend;
      v_invoice_tab(v_invoice_tab.count) :=
        xxtf_rest_invoice_rec(
          a.invoice_id,
          a.invoice_num,
          a.invoice_date,
          a.customer_num,
          get_invoice_lines(a.invoice_id));

    end loop;

    XXTF_SIMPLE_LOG_PKG.log('end get_invoices');
    return v_invoice_tab;
  end get_invoices;


  procedure update_invoice(invoice in xxtf_rest_invoice_rec) is
    v_invoice_rec xxtf_rest_invoice_rec;
    v_invoice_num xxtf_rest_invoices.invoice_num%type;
    v_invoice_date xxtf_rest_invoices.invoice_date%type;
    v_customer_num xxtf_rest_invoices.customer_num%type;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start update_invoice');
    XXTF_SIMPLE_LOG_PKG.log('invoice_id='||invoice.invoice_id);
    XXTF_SIMPLE_LOG_PKG.log('invoice_num='||invoice.invoice_num);
    XXTF_SIMPLE_LOG_PKG.log('invoice_date='||invoice.invoice_date);
    XXTF_SIMPLE_LOG_PKG.log('customer_num='||invoice.customer_num);

    update xxtf_rest_invoices
    set    invoice_num = invoice.invoice_num,
           invoice_date = invoice.invoice_date,
           customer_num = invoice.customer_num
    where  invoice_id = invoice.invoice_id;

    if sql%rowcount = 0 then
      XXTF_SIMPLE_LOG_PKG.log('got rowcount = 0');
      raise_application_error(-20001,'Invalid invoice id: '||invoice.invoice_id);
    end if;

    update_invoice_lines(invoice.lines);

    XXTF_SIMPLE_LOG_PKG.log('end update_invoice');
  end update_invoice;


  procedure update_invoice_lines(p_line_tab in xxtf_rest_invoice_line_tab) is
  begin
    XXTF_SIMPLE_LOG_PKG.log('start update_invoice_lines');
    XXTF_SIMPLE_LOG_PKG.log('p_line_tab.count='||p_line_tab.count);

    for a in 1..p_line_tab.count loop
      XXTF_SIMPLE_LOG_PKG.log('in loop pos='||a);
      XXTF_SIMPLE_LOG_PKG.log('invoice_line_id='||p_line_tab(a).invoice_line_id);
      XXTF_SIMPLE_LOG_PKG.log('line_num='||p_line_tab(a).line_num);
      XXTF_SIMPLE_LOG_PKG.log('description='||p_line_tab(a).description);
      XXTF_SIMPLE_LOG_PKG.log('quantity='||p_line_tab(a).quantity);
      XXTF_SIMPLE_LOG_PKG.log('price='||p_line_tab(a).price);
      XXTF_SIMPLE_LOG_PKG.log('line_amount='||p_line_tab(a).line_amount);

      update xxtf_rest_invoice_lines
      set    line_num = p_line_tab(a).line_num,
             description = p_line_tab(a).description,
             quantity = p_line_tab(a).quantity,
             price = p_line_tab(a).price,
             line_amount = p_line_tab(a).line_amount
      where  invoice_line_id = p_line_tab(a).invoice_line_id;

      if sql%rowcount = 0 then
        XXTF_SIMPLE_LOG_PKG.log('got rowcount = 0');
        raise_application_error(-20001,'Invalid invoice line id: '||p_line_tab(a).invoice_line_id);
      end if;
    end loop;

    XXTF_SIMPLE_LOG_PKG.log('end update_invoice_lines');
  end update_invoice_lines;


  procedure delete_invoice(invoice_id in number) is
    -- avoid name clash in sql
    v_invoice_id number := invoice_id;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start delete_invoice');
    XXTF_SIMPLE_LOG_PKG.log('invoice_id='||invoice_id);

    delete
    from   xxtf_rest_invoices
    where  invoice_id = v_invoice_id;

    if sql%rowcount = 0 then
      XXTF_SIMPLE_LOG_PKG.log('got rowcount = 0');
      raise_application_error(-20001,'Invalid invoice id: '||v_invoice_id);
    end if;

    delete
    from   xxtf_rest_invoice_lines
    where  invoice_id = v_invoice_id;

    XXTF_SIMPLE_LOG_PKG.log('lines deleted='||sql%rowcount);

    XXTF_SIMPLE_LOG_PKG.log('end delete_invoice');
  end delete_invoice;


  procedure seed_invoices(
    p_user_id in number,
    p_resp_id in number,
    p_resp_appl_id in number) is

    v_invoice_rec xxtf_rest_invoice_rec;
    v_line_tab xxtf_rest_invoice_line_tab;
    v_invoice_id number;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start seed_invoices');
    XXTF_SIMPLE_LOG_PKG.log('p_user_id='||p_user_id);
    XXTF_SIMPLE_LOG_PKG.log('p_resp_id='||p_resp_id);
    XXTF_SIMPLE_LOG_PKG.log('p_resp_appl_id='||p_resp_appl_id);

    FND_GLOBAL.apps_initialize(
      user_id => p_user_id,
      resp_id => p_resp_id,
      resp_appl_id => p_resp_appl_id);

    delete from xxtf_rest_invoices;
    delete from xxtf_rest_invoice_lines;

    v_line_tab := xxtf_rest_invoice_line_tab();
    v_line_tab.extend;
    v_line_tab(v_line_tab.count) := xxtf_rest_invoice_line_rec(
      null,
      null,
      1,
      'Description of line 1',
      10,
      15.99,
      159.9);

    v_line_tab.extend;
    v_line_tab(v_line_tab.count) := xxtf_rest_invoice_line_rec(
      null,
      null,
      2,
      'Description of line 2',
      5,
      25,
      125);

    v_invoice_rec := xxtf_rest_invoice_rec(
      null,
      '1004',
      trunc(sysdate)-20,
      '81773',
      v_line_tab);

    v_invoice_id := create_invoice(v_invoice_rec);

    v_line_tab := xxtf_rest_invoice_line_tab();
    v_line_tab.extend;
    v_line_tab(v_line_tab.count) := xxtf_rest_invoice_line_rec(
      null,
      null,
      1,
      'Another invoice line description 1',
      4,
      100,
      400);

    v_line_tab.extend;
    v_line_tab(v_line_tab.count) := xxtf_rest_invoice_line_rec(
      null,
      null,
      2,
      'And another invoice line description 2',
      1,
      129.99,
      129.99);

    v_line_tab.extend;
    v_line_tab(v_line_tab.count) := xxtf_rest_invoice_line_rec(
      null,
      null,
      3,
      'And another invoice line description 3',
      2,
      15,
      30);

    v_invoice_rec := xxtf_rest_invoice_rec(
      null,
      '1005',
      trunc(sysdate)-18,
      '81773',
      v_line_tab);

    v_invoice_id := create_invoice(v_invoice_rec);

    XXTF_SIMPLE_LOG_PKG.log('end seed_invoices');
  end seed_invoices;


  procedure create_invoice_id(invoice in xxtf_rest_invoice_rec, invoice_id out number) is
  begin
    XXTF_SIMPLE_LOG_PKG.log('start create_invoice_id');
    invoice_id := create_invoice(invoice);

    XXTF_SIMPLE_LOG_PKG.log('end create_invoice_id invoice_id='||invoice_id);
  end create_invoice_id;


  procedure get_invoice2(
    invoice_id in number,
    invoice_num out xxtf_rest_invoices.invoice_num%type,
    invoice_date out xxtf_rest_invoices.invoice_date%type,
    customer_num out xxtf_rest_invoices.customer_num%type,
    lines out xxtf_rest_invoice_line_tab) is

    v_invoice_rec xxtf_rest_invoice_rec;
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoice2');
    XXTF_SIMPLE_LOG_PKG.log('invoice_id='||invoice_id);

    v_invoice_rec := get_invoice(invoice_id);
    invoice_num := v_invoice_rec.invoice_num;
    invoice_date := v_invoice_rec.invoice_date;
    customer_num := v_invoice_rec.customer_num;
    lines := v_invoice_rec.lines;

    XXTF_SIMPLE_LOG_PKG.log('end get_invoice2');
  end get_invoice2;


  procedure get_invoice3(
    invoice_id in number,
    invoice out xxtf_rest_invoice_rec) is
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoice3');
    XXTF_SIMPLE_LOG_PKG.log('invoice_id='||invoice_id);

    invoice := get_invoice(invoice_id);

    XXTF_SIMPLE_LOG_PKG.log('end get_invoice3');
  end get_invoice3;


  procedure get_invoice_with_status(
    invoice_id in number,
    invoice out xxtf_rest_invoice_rec,
    result_status out varchar2,
    result_message out varchar2) is
  begin
    XXTF_SIMPLE_LOG_PKG.log('start get_invoice_with_status');
    XXTF_SIMPLE_LOG_PKG.log('invoice_id='||invoice_id);

    result_status := 'S';
    begin
      invoice := get_invoice(invoice_id);
    exception when others then
      result_status := 'E';
      result_message := SQLERRM;
    end;

    XXTF_SIMPLE_LOG_PKG.log('result_status='||result_status);
    XXTF_SIMPLE_LOG_PKG.log('result_message='||result_message);
    XXTF_SIMPLE_LOG_PKG.log('end create_invoice_with_status invoice_id='||invoice_id);
  end get_invoice_with_status;


END XXTF_REST_INVOICE_PKG;
/

show errors

