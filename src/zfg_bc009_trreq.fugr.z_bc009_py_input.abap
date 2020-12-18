FUNCTION Z_BC009_PY_INPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DO_CURRENT) TYPE  CHAR1 DEFAULT ' '
*"     VALUE(IV_REQ_LIST) TYPE  TEXT1024 DEFAULT ' '
*"     VALUE(GET_MY_LIST) TYPE  CHAR1 DEFAULT ' '
*"  EXPORTING
*"     VALUE(RC_TXT) TYPE  TEXT1024
*"  TABLES
*"      REQ_LIST STRUCTURE  ZSBC009_E070_REQ_LIST OPTIONAL
*"----------------------------------------------------------------------

  DATA lo_py_input TYPE REF TO zcl_bc009_py_input.
  CREATE OBJECT lo_py_input.

  lo_py_input->set_params(
  EXPORTING
    iv_do_current = iv_do_current
    iv_req_list = iv_req_list
    get_my_list = get_my_list
  ).

  lo_py_input->sh(  ).

  lo_py_input->get_my_list( IMPORTING et_req_list = req_list[] ).
  lo_py_input->get_rc_txt( IMPORTING rc_txt = rc_txt ).


ENDFUNCTION.
