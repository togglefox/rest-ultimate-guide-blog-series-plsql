CREATE OR REPLACE PACKAGE XXTF_REST_INVOICE_PKG AS
  /* $Header: $ */
  /*#
  * APIs to provide CRUD support for tables XXTF_REST_INVOICES and XXTF_REST_INVOICE_LINES.
  * @rep:scope public
  * @rep:product XXTF
  * @rep:displayname XXTF_REST_INVOICE_PKG
  * @rep:category BUSINESS_ENTITY XXTF_REST_INVOICES
  * @rep:compatibility S
  * @rep:lifecycle active
  */

/******************************************************************************

  Copyright 2020 togglefox.

  For details see www.togglefox.com/blogs/create_plsql_rest_service_demo

  Ver   When    Who             What
  ----- ------- --------------- -------------------------
  1.0   05Feb20 Michael Carroll Initial creation.

******************************************************************************/

/*#
 * Creates a new invoice
 * @param invoice Invoice Record
 * @return New Invoice Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create a new invoice
 * @rep:compatibility S
 */
  function create_invoice(invoice in xxtf_rest_invoice_rec) return number;

  procedure create_invoice_lines(p_invoice_id in number, p_tab in xxtf_rest_invoice_line_tab);

/*#
 * Retrieves an invoice
 * @param invoice_id Invoice Id
 * @return Invoice Record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve an invoice for an invoice id
 * @rep:compatibility S
 */
  function get_invoice(invoice_id in number) return xxtf_rest_invoice_rec;

  function get_invoice_lines(p_invoice_id in number) return xxtf_rest_invoice_line_tab;

/*#
 * Retrieves invoices based on query criteria
 * @param invoice_num Invoice Number Mask
 * @param invoice_date_from Invoice Start Date
 * @param invoice_date_to Invoice End Date
 * @param customer_num Customer Number Mask
 * @return Invoice Records
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve invoices based on query criteria
 * @rep:compatibility S
 */
  function get_invoices(
    invoice_num in varchar2,
    invoice_date_from in date,
    invoice_date_to in date,
    customer_num in varchar2) return xxtf_rest_invoice_tab;

/*#
 * Updates an existing invoice
 * @param invoice Invoice Record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update an existing invoice
 * @rep:compatibility S
 */
  procedure update_invoice(invoice in xxtf_rest_invoice_rec);

  procedure update_invoice_lines(p_line_tab in xxtf_rest_invoice_line_tab);

/*#
 * Deletes an invoice
 * @param invoice_id Invoice Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete an invoice for an invoice id
 * @rep:compatibility S
 */
  procedure delete_invoice(invoice_id in number);

  procedure seed_invoices(
    p_user_id in number,
    p_resp_id in number,
    p_resp_appl_id in number);

/*#
 * Creates a new invoice 2
 * @param invoice Invoice Record
 * @param invoice_id Invoice Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create a new invoice 2
 * @rep:compatibility S
 */
  procedure create_invoice_id(invoice in xxtf_rest_invoice_rec, invoice_id out number);

/*#
 * get invoice 2
 * @param invoice_id Invoice Id
 * @param invoice_num Invoice Num
 * @param invoice_date Invoice Date
 * @param customer_num Customer Num
 * @param lines Lines
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get invoice 2
 * @rep:compatibility S
 */
  procedure get_invoice2(
    invoice_id in number,
    invoice_num out xxtf_rest_invoices.invoice_num%type,
    invoice_date out xxtf_rest_invoices.invoice_date%type,
    customer_num out xxtf_rest_invoices.customer_num%type,
    lines out xxtf_rest_invoice_line_tab);

/*#
 * get invoice 3
 * @param invoice_id Invoice Id
 * @param invoice Invoice
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get invoice 3
 * @rep:compatibility S
 */
  procedure get_invoice3(
    invoice_id in number,
    invoice out xxtf_rest_invoice_rec);

/*#
 * get invoice with status
 * @param invoice_id Invoice Id
 * @param invoice Invoice
 * @param result_status Status
 * @param result_message message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get invoice with status
 * @rep:compatibility S
 */
  procedure get_invoice_with_status(
    invoice_id in number,
    invoice out xxtf_rest_invoice_rec,
    result_status out varchar2,
    result_message out varchar2);

END XXTF_REST_INVOICE_PKG;
/

