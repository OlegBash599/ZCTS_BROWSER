
*----------------------------------------------------------------------*
*       CLASS lcl_u DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_u DEFINITION.
  PUBLIC SECTION.

    METHODS constructor.
    METHODS main.
    METHODS output.

    METHODS at_sel_scr
      IMPORTING
        iv_ucomm TYPE syucomm
        is_scr   TYPE ts_screen.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_target_sys_info
            , rfcdest TYPE rfcdest
            , system TYPE char10
          , END OF ts_target_sys_info
          .

    DATA ms_target_system_info TYPE ts_target_sys_info.
    DATA ms_scr TYPE ts_screen.


    METHODS fill_e070
      IMPORTING iv_mode TYPE char1 DEFAULT 'A' " A - normal (not TOC), B - TOC (transport of copies)
      CHANGING  ct_e070 TYPE e070_t.

    METHODS transport_via_tms
      IMPORTING is_e070 TYPE e070.


    METHODS tms_in_local_sys
      IMPORTING is_e070 TYPE e070.


    METHODS tms_in_remote_sys
      IMPORTING is_e070 TYPE e070.

    METHODS create_copy
      IMPORTING it_e070 TYPE e070_t.

    METHODS put_objects2request
      IMPORTING it_e070   TYPE e070_t
                iv_req_id TYPE trkorr.


    METHODS release_request
      IMPORTING iv_req_id TYPE trkorr.

    METHODS transport_request
      IMPORTING iv_req_id TYPE trkorr.

    METHODS fill_target_system_info.

ENDCLASS.                    "lcl_u DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_u IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_u IMPLEMENTATION.
  METHOD constructor.
    fill_target_system_info( ).
  ENDMETHOD.                    "constructor

  METHOD fill_target_system_info.
    DATA lo_target_sys TYPE REF TO zcl_bc009_target_sysinfo.
    CREATE OBJECT lo_target_sys.

    ms_target_system_info-rfcdest = lo_target_sys->get_target_rfc_name( ).
    ms_target_system_info-system = lo_target_sys->get_target_sys_name( ).

  ENDMETHOD.                    "fill_target_system_info

  METHOD main.

    DATA lt_e070 TYPE STANDARD TABLE OF e070.
    FIELD-SYMBOLS <fs_e070> TYPE e070.

    IF ms_scr-s_trreq[] IS NOT INITIAL.
      fill_e070( CHANGING ct_e070 = lt_e070 ).

      LOOP AT lt_e070 ASSIGNING <fs_e070>.
        transport_via_tms( EXPORTING is_e070 = <fs_e070> ).
      ENDLOOP.
    ENDIF.

    IF ms_scr-s_trreqi[] IS NOT INITIAL.

      fill_e070( EXPORTING iv_mode = 'B'
                 CHANGING ct_e070 = lt_e070 ).

      IF lt_e070 IS NOT INITIAL.
        create_copy( lt_e070 ).
      ENDIF.

    ENDIF.





  ENDMETHOD.                    "main

  METHOD create_copy.

    DATA lv_text TYPE trexreqhd-text.

    DATA lv_req_id TYPE  trkorr.
    DATA ls_req_header TYPE  trexreqhd.
    DATA ls_msg TYPE tr004-msgtext.
    DATA lv_exception TYPE tr007-exception.

    lv_text = `TOC: ` && sy-uname && `_`
                      && sy-datum && `_`
                      && sy-uzeit.

    CALL FUNCTION 'TR_EXT_CREATE_REQUEST'
      EXPORTING
        iv_request_type = 'T'    " Type of request; KTW are possible
        iv_target       = ms_target_system_info-system    " Only Type T: Transport target of a request
        iv_author       = sy-uname    " Owner of request
        iv_text         = lv_text    " Short text describing R/3 Repository objects
*       iv_req_attr     =     " Request attribute
*       iv_attr_ref     =     " Attribute value
      IMPORTING
        es_req_id       = lv_req_id
        es_req_header   = ls_req_header
        es_msg          = ls_msg
        ev_exception    = lv_exception.     " Name of exception

    put_objects2request( EXPORTING it_e070 = it_e070
                                   iv_req_id = lv_req_id ).

    release_request( lv_req_id ).

    transport_request( lv_req_id ).

  ENDMETHOD.                    "create_copy

  METHOD output.
    IF no_dis EQ abap_true.

    ELSE.
      IF sy-calld EQ abap_true and sy-MODNO is INITIAL.
      ELSE.
        zcl_bc009_html=>get_instance( )->show( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "output

  METHOD at_sel_scr.
    ms_scr = is_scr.
  ENDMETHOD.                    "at_sel_scr

  METHOD fill_e070.
    "CHANGING ct_e070 TYPE e070_t.

    IF ms_scr IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR ct_e070.

    CASE iv_mode.
      WHEN 'A'.

        SELECT * FROM e070
  INTO TABLE ct_e070
  WHERE trkorr IN ms_scr-s_trreq
 AND trstatus EQ 'R'
  ORDER BY PRIMARY KEY
  .

      WHEN 'B'.

        SELECT * FROM e070
  INTO TABLE ct_e070
  WHERE trkorr IN ms_scr-s_trreqi
  AND trstatus IN ('D', 'L', 'R')
  ORDER BY PRIMARY KEY
  .

      WHEN OTHERS.
    ENDCASE.


    IF sy-subrc EQ 0.
      " DELETE  ct_e070 WHERE strkorr IS INITIAL.
    ENDIF.

  ENDMETHOD.                    "at_sel_scr

  METHOD transport_via_tms.
    "       IMPORTING is_e070 TYPE e070.

    IF ms_scr-remote EQ abap_true.

      tms_in_remote_sys( is_e070 = is_e070 ).

    ELSE.

      tms_in_local_sys( is_e070 = is_e070 ).

    ENDIF.


  ENDMETHOD.                    "transport_via_tms

  METHOD tms_in_local_sys.
    DATA lv_system_name TYPE  stpa-sysname.

    DATA lv_tp_ret_code TYPE trretcode.
    DATA lt_trreq TYPE STANDARD TABLE OF tprequest.


    DATA lt_request TYPE STANDARD TABLE OF  tprequest .
    DATA lt_project TYPE STANDARD TABLE OF  tpproject .
    DATA lt_client TYPE STANDARD TABLE OF  t000 .
    DATA lt_stdout TYPE STANDARD TABLE OF tpstdout .
    DATA lt_logptr TYPE STANDARD TABLE OF tplogptr .

    "lv_system_name = sy-sysid(3).
    lv_system_name = ms_target_system_info-system.

    CALL FUNCTION 'Z_BC009_TMS_TP_IMPORT'
      EXPORTING
        iv_system_name = lv_system_name
        iv_request     = is_e070-trkorr
        iv_vers_ignore = vers_ign
      IMPORTING
*       EV_TP_CMD_STRG =
        ev_tp_ret_code = lv_tp_ret_code
*       EV_TP_MESSAGE  =
*       EV_TP_VERSION  =
*       EV_TP_ALOG     =
*       EV_TP_SLOG     =
*       EV_TP_PID      =
*       EV_TPSTAT_KEY  =
      TABLES
        tt_request     = lt_trreq
        tt_project     = lt_request
        tt_client      = lt_client
        tt_stdout      = lt_stdout
        tt_logptr      = lt_logptr.


*    zcl_bc009_html=>get_instance( )->add_para_val_ch(
*        iv_id    = 'ret_code'
*        iv_value = lv_tp_ret_code
*    )->add_tab_ch( it_tab = lt_trreq
*    )->add_tab_ch( it_tab = lt_request
*    )->add_tab_ch( it_tab = lt_client
*    )->add_tab_ch( it_tab = lt_stdout
*    )->add_tab_ch( it_tab = lt_logptr ).

  ENDMETHOD.                    "tms_in_local_sys

  METHOD  tms_in_remote_sys.
    DATA lv_system_name TYPE  stpa-sysname.

    DATA lv_tp_ret_code TYPE trretcode.
    DATA lt_trreq TYPE STANDARD TABLE OF tprequest.

    "    lv_system_name = sy-sysid(3).
    lv_system_name = ms_target_system_info-system.
    CALL FUNCTION 'Z_BC009_TMS_TP_IMPORT'
      DESTINATION ms_target_system_info-rfcdest
      EXPORTING
        iv_system_name = lv_system_name
        iv_request     = is_e070-trkorr
        iv_vers_ignore = vers_ign
      IMPORTING
*       EV_TP_CMD_STRG =
        ev_tp_ret_code = lv_tp_ret_code
*       EV_TP_MESSAGE  =
*       EV_TP_VERSION  =
*       EV_TP_ALOG     =
*       EV_TP_SLOG     =
*       EV_TP_PID      =
*       EV_TPSTAT_KEY  =
      TABLES
        tt_request     = lt_trreq
*       TT_PROJECT     =
*       TT_CLIENT      =
*       TT_STDOUT      =
*       TT_LOGPTR      =
      .

    data lt_reqs TYPE tprequests.
    data ls_reqs TYPE TPREQUEST.

    ls_reqs-trkorr = is_e070-trkorr.
    append ls_reqs to lt_reqs.

    zcl_bc009_html=>get_instance( )->add_para_val_ch(
        iv_id    = 'ret_code'
        iv_value = lv_tp_ret_code
   " )->add_tab_ch( it_tab = VALUE tprequests( ( trkorr = is_e070-trkorr ) )
    )->add_tab_ch( it_tab = lt_reqs
    )->add_tab_ch( it_tab = lt_trreq ).
  ENDMETHOD.                    " tms_in_remote_sys

  METHOD put_objects2request.
*      IMPORTING it_e070 TYPE e070_t
*                iv_req_id TYPE trkorr.

    DATA lt_e071 TYPE STANDARD TABLE OF e071.
    DATA lt_objects TYPE STANDARD TABLE OF trexreqob.
    DATA ls_objects TYPE trexreqob.
    FIELD-SYMBOLS <fs_e071> TYPE e071.
**
    SELECT * FROM e071
      INTO TABLE lt_e071
      FOR ALL ENTRIES IN it_e070
      WHERE trkorr EQ it_e070-trkorr
      ORDER BY PRIMARY KEY.

    DELETE ADJACENT DUPLICATES FROM lt_e071 COMPARING trkorr.


    LOOP AT lt_e071 ASSIGNING <fs_e071>.

      CALL FUNCTION 'TR_COPY_COMM'
        EXPORTING
          wi_dialog                = 'X'    " Flag, whether information messages sent
          wi_trkorr_from           = <fs_e071>-trkorr    " Initial correction number
          wi_trkorr_to             = iv_req_id    " Target correction number
          wi_without_documentation = abap_false    " Flag, documentation is not to be copied
        EXCEPTIONS
          db_access_error          = 1
          trkorr_from_not_exist    = 2
          trkorr_to_is_repair      = 3
          trkorr_to_locked         = 4
          trkorr_to_not_exist      = 5
          trkorr_to_released       = 6
          user_not_owner           = 7
          no_authorization         = 8
          wrong_client             = 9
          wrong_category           = 10
          object_not_patchable     = 11
          OTHERS                   = 12.
      IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.                    "put_objects2request
  METHOD release_request.
    "      IMPORTING iv_req_id  TYPE trkorr.

*****    CALL FUNCTION 'TR_RELEASE_REQUEST'
*****      EXPORTING
*****        iv_trkorr                  = iv_req_id    " Request/Task
*****       iv_dialog                  = abap_false
******      iv_as_background_job       = ' '
******      iv_success_message         = 'X'
******      iv_display_export_log      = 'X'    " Boolean
******    IMPORTING
******      es_request                 =
******      et_deleted_tasks           =
*****      EXCEPTIONS
*****        cts_initialization_failure = 1
*****        enqueue_failed             = 2
*****        no_authorization           = 3
*****        invalid_request            = 4
*****        request_already_released   = 5
*****        repeat_too_early           = 6
*****        error_in_export_methods    = 7
*****        object_check_error         = 8
*****        docu_missing               = 9
*****        db_access_error            = 10
*****        action_aborted_by_user     = 11
*****        export_failed              = 12
*****        OTHERS                     = 13
*****      .
*****    IF sy-subrc <> 0.
******   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
******              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*****    ENDIF.

    DATA lv_as_background_job TYPE char1.
    DATA lv_success_message TYPE char1.
    DATA lv_without_locking TYPE char1 VALUE abap_true.
    DATA lv_without_objects_check TYPE char1 .
    DATA lv_display_export_log TYPE char1.
    DATA lt_messages               TYPE ctsgerrmsgs.
    DATA ls_message                TYPE ctsgerrmsg.

*"     REFERENCE(ES_REQUEST) TYPE  TRWBO_REQUEST
*"     REFERENCE(ET_DELETED_TASKS) TYPE  TRWBO_T_E070
*"     REFERENCE(ET_MESSAGES) TYPE  CTSGERRMSGS


    CALL FUNCTION 'CTS_LOCK_TRKORR'        " eclipse compatible locking...
      EXPORTING
        iv_trkorr = iv_req_id
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc  =    1.
      RETURN.
    ENDIF.

    "  lv_as_background_job = abap_true. " ????


    CALL FUNCTION 'Z_BC009_TRREQ_UPD'
      IN UPDATE TASK.

*---call trint_release_request------------------------------------------
    CLEAR lt_messages.
    CALL FUNCTION 'TRINT_RELEASE_REQUEST'
      EXPORTING
        iv_trkorr                   = iv_req_id
  "     iv_dialog                   = abap_true
        iv_dialog                   = abap_false
        iv_as_background_job        = lv_as_background_job
        iv_success_message          = lv_success_message
        iv_without_objects_check    = lv_without_objects_check
        iv_without_locking          = lv_without_locking
        iv_display_export_log       = lv_display_export_log
      IMPORTING
*       es_request                  = es_request
*       et_deleted_tasks            = et_deleted_tasks
        et_messages                 = lt_messages
      EXCEPTIONS
        cts_initialization_failure  = 1
        enqueue_failed              = 2
        no_authorization            = 3
        invalid_request             = 4
        request_already_released    = 5
        repeat_too_early            = 6
        object_lock_error           = 7
        object_check_error          = 8
        docu_missing                = 9
        db_access_error             = 10
        action_aborted_by_user      = 11
        export_failed               = 12
        execute_objects_check       = 13
        release_in_bg_mode          = 14
        release_in_bg_mode_w_objchk = 15
        error_in_export_methods     = 16
        object_lang_error           = 17.

    "lv_subrc = sy-subrc.

*---dequeue request-----------------------------------------------------
    CALL FUNCTION 'CTS_UNLOCK_TRKORR'
      EXPORTING
        iv_trkorr = iv_req_id
      EXCEPTIONS
        OTHERS    = 0.


  ENDMETHOD.                    "release_request
  METHOD transport_request.
    "      IMPORTING iv_req_id  TYPE trkorr.

    DATA lt_e070 TYPE STANDARD TABLE OF e070.
    DATA ls_e070 TYPE e070.
    DATA lv_request_release TYPE char1.
    FIELD-SYMBOLS <fs_e070> TYPE e070.

    WHILE lv_request_release EQ abap_false.
      SELECT * FROM e070
        INTO TABLE lt_e070
        WHERE trkorr  = iv_req_id
          AND trstatus = 'R'.
      IF sy-subrc EQ 0.
        lv_request_release = abap_true.
      ELSE.
        lv_request_release = abap_false.
      ENDIF.
      WAIT UP TO 1 SECONDS.
    ENDWHILE.

    LOOP AT lt_e070 ASSIGNING <fs_e070>.
      transport_via_tms( EXPORTING is_e070 = <fs_e070> ).
    ENDLOOP.
  ENDMETHOD.                    "transport_request
ENDCLASS.                    "lcl_u IMPLEMENTATION
