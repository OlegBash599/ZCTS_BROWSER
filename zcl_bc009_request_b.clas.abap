class ZCL_BC009_REQUEST_B definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC009_REQUEST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BC009_REQUEST_B IMPLEMENTATION.


METHOD zif_bc009_request~move_as_copy.

  DATA lt_range_korr TYPE RANGE OF trkorr.
  FIELD-SYMBOLS <fs_range_korr> LIKE LINE OF lt_range_korr.

  APPEND INITIAL LINE TO lt_range_korr ASSIGNING <fs_range_korr>.
  <fs_range_korr>-sign = 'I'.
  <fs_range_korr>-option = 'EQ'.
  <fs_range_korr>-low = iv_trkorr.


  SUBMIT zewm_049_transport
    WITH s_trreqi IN lt_range_korr
    with no_dis eq abap_true
    AND RETURN.

ENDMETHOD.
ENDCLASS.
