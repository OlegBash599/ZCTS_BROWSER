CLASS zcl_bc009_py_input DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor .
    METHODS set_params
      IMPORTING
        !iv_do_current TYPE abap_bool OPTIONAL
        !iv_req_list   TYPE text1024 OPTIONAL
        !get_my_list   TYPE abap_bool OPTIONAL .

    METHODS sh.

    METHODS get_my_list
      EXPORTING
        !et_req_list TYPE zttbc009_e070_req_list .
    METHODS get_rc_txt
      EXPORTING
        !rc_txt TYPE text1024 .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS mc_prefix TYPE trkorr VALUE 'NPL%'.

    DATA mv_do_current TYPE abap_bool .
    DATA mv_req_list TYPE text1024 .
    DATA mv_get_my_list TYPE abap_bool  .

    DATA mv_rc_txt TYPE string.
    DATA mv_current_def TYPE char30 VALUE 'CURRENT'.
    METHODS submit_current_sel.
    METHODS submit_with_list.

ENDCLASS.



CLASS zcl_bc009_py_input IMPLEMENTATION.


  METHOD constructor.
    "
  ENDMETHOD.


  METHOD get_my_list.
    DATA lt_ve070 TYPE STANDARD TABLE OF zvbc009_e070.
    DATA lr_ve070 TYPE REF TO zvbc009_e070.
    FIELD-SYMBOLS <fs_list_line> TYPE zsbc009_e070_req_list.


    IF mv_get_my_list EQ abap_true.
      SELECT * FROM zvbc009_e070
      INTO TABLE lt_ve070
      WHERE trkorr LIKE mc_prefix
        AND trfunction = 'S'
        AND trstatus = 'D'
        AND as4user = sy-uname.

      LOOP AT lt_ve070 REFERENCE INTO lr_ve070.
        APPEND INITIAL LINE TO et_req_list ASSIGNING <fs_list_line>.
        MOVE-CORRESPONDING lr_ve070->* TO <fs_list_line>.
      ENDLOOP.

    ENDIF.



  ENDMETHOD.


  METHOD get_rc_txt.
    DATA lv_date10 TYPE char10.
    DATA lv_time10 TYPE char10.
    WRITE sy-datum TO lv_date10.
    WRITE sy-uzeit TO lv_time10.

    IF mv_rc_txt IS INITIAL.
      rc_txt = 'Output is done'.
    ELSE.
      mv_rc_txt = |{  mv_rc_txt } ### END: Date { lv_date10 } time { lv_time10 }|.
      rc_txt = mv_rc_txt.
    ENDIF.

  ENDMETHOD.


  METHOD set_params.
    mv_do_current = iv_do_current.
    mv_req_list = iv_req_list.
    mv_get_my_list = get_my_list.
  ENDMETHOD.


  METHOD sh.
    DATA lv_date10 TYPE char10.
    DATA lv_time10 TYPE char10.
    WRITE sy-datum TO lv_date10.
    WRITE sy-uzeit TO lv_time10.

    CLEAR mv_rc_txt.

    mv_rc_txt = |BEG: Date { lv_date10 } time { lv_time10 }|.
    IF mv_do_current EQ abap_true.
      submit_current_sel(  ).
    ENDIF.

    IF mv_req_list IS NOT INITIAL.
      submit_with_list(  ).
    ENDIF.

  ENDMETHOD.


  METHOD submit_current_sel.


    SUBMIT zbc_009rep_transport
     USING SELECTION-SET mv_current_def
     AND RETURN.

  ENDMETHOD.

  METHOD submit_with_list.
    DATA lt_str_lines TYPE STANDARD TABLE OF string.
    DATA lv_tr_in_line TYPE string.

    DATA ls_e070 TYPE e070.
    DATA lt_e070 TYPE STANDARD TABLE OF e070.
    DATA lt_e070_db TYPE STANDARD TABLE OF e070.

    FIELD-SYMBOLS <fs_str_tr> LIKE LINE OF lt_str_lines.

    lv_tr_in_line = mv_req_list.
    CONDENSE lv_tr_in_line NO-GAPS.

    SPLIT lv_tr_in_line AT ',' INTO TABLE lt_str_lines.

    CLEAR ls_e070.
    CLEAR lt_e070.
    LOOP AT lt_str_lines ASSIGNING <fs_str_tr>.
      CLEAR ls_e070.
      ls_e070-trkorr = <fs_str_tr>.
      APPEND ls_e070 TO lt_e070.
    ENDLOOP.

    IF lt_e070 IS INITIAL.
      mv_rc_txt = mv_rc_txt && ' no request supplied '.
      RETURN.
    ENDIF.

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lt_ve070 TYPE STANDARD TABLE OF zvbc009_e070.
    DATA lr_ve070 TYPE REF TO zvbc009_e070.
    FIELD-SYMBOLS <fs_list_line> TYPE zsbc009_e070_req_list.


    SELECT * FROM zvbc009_e070
     INTO TABLE lt_ve070
     FOR ALL ENTRIES IN lt_e070
     WHERE trkorr EQ lt_e070-trkorr
       AND trfunction = 'S'
       AND trstatus = 'D'
       .

    IF lt_ve070 IS INITIAL.
      mv_rc_txt = mv_rc_txt && ' no request found '.
      RETURN.
    ELSE.
      SORT lt_ve070 BY trkorr.
      DELETE ADJACENT DUPLICATES FROM lt_ve070 COMPARING trkorr.
    ENDIF.


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA lt_range_trkorr TYPE RANGE OF trkorr.
    FIELD-SYMBOLS <fs_range_trkorr> LIKE LINE OF lt_range_trkorr.

    LOOP AT lt_ve070 REFERENCE INTO lr_ve070.
      APPEND INITIAL LINE TO lt_range_trkorr ASSIGNING <fs_range_trkorr>.
      <fs_range_trkorr> = 'IEQ'.
      <fs_range_trkorr>-low = lr_ve070->trkorr.
    ENDLOOP.

    IF lt_range_trkorr IS INITIAL.

      RETURN.
    ENDIF.

    SUBMIT zbc_009rep_transport
            WITH s_trreqi IN lt_range_trkorr
            AND RETURN.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ENDMETHOD.

ENDCLASS.
