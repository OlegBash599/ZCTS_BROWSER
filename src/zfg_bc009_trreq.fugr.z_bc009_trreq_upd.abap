FUNCTION z_bc009_trreq_upd.
*"----------------------------------------------------------------------
*"*"Функциональный модуль обновления:
*"
*"*"Локальный интерфейс:
*"  IMPORTING
*"     VALUE(IV_AVOID) TYPE  CHAR1 DEFAULT ABAP_TRUE
*"----------------------------------------------------------------------

  DATA lv_control_active TYPE string VALUE '(SAPLSVRY)VERSION_CONTROL_ACTIVE'.

  FIELD-SYMBOLS <fs_ver_active> TYPE char1.

  PERFORM zbc009_never_exist_form IN PROGRAM saplsvry
  IF FOUND.

  ASSIGN (lv_control_active) TO <fs_ver_active>.
  IF sy-subrc EQ 0.
    CLEAR <fs_ver_active>.
  ENDIF.

ENDFUNCTION.
