FUNCTION Z_CTS002_TRREQ_EXCL_VERGEN_UPD.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_AVOID_VER_GEN) TYPE  ABAP_BOOL DEFAULT ABAP_TRUE
*"----------------------------------------------------------------------

  DATA lv_control_active TYPE string VALUE '(SAPLSVRY)VERSION_CONTROL_ACTIVE'.

  FIELD-SYMBOLS <fs_ver_active> TYPE char1.

  PERFORM some_never_exist_form IN PROGRAM saplsvry
  IF FOUND.

  ASSIGN (lv_control_active) TO <fs_ver_active>.
  IF sy-subrc EQ 0.
    CLEAR <fs_ver_active>.
  ENDIF.



ENDFUNCTION.
