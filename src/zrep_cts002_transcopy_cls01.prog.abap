*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_CLS01
*&---------------------------------------------------------------------*


CLASS lcl_toc DEFINITION.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING is_scr TYPE ts_screen.

    METHODS sh
      RAISING zcx_cts002_data_error.

  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS: BEGIN OF mc_trstatus
            ,   modifiable TYPE trstatus VALUE 'D'
            ,   protected TYPE trstatus VALUE 'L'
            ,   release_started TYPE trstatus VALUE 'O'
            ,   released TYPE trstatus VALUE 'R'
            ,   released_with_protection TYPE trstatus VALUE 'N'
        , END OF mc_trstatus
        .

    DATA ms_scr TYPE REF TO ts_screen.
    DATA ms_target_sys TYPE ztcts002_destsys.

    METHODS fill_target_sys_info
      RAISING zcx_cts002_data_error.

    METHODS do_toc_n_send
      RAISING zcx_cts002_data_error.

    METHODS fill_e070
      CHANGING ct_e070 TYPE e070_t.


    METHODS create_copy
      IMPORTING it_e070 TYPE e070_t.

    METHODS get_text4copy_req
      IMPORTING it_e070       TYPE e070_t
      RETURNING VALUE(rv_val) TYPE string.


    METHODS put_objects2request
      IMPORTING it_e070   TYPE e070_t
                iv_req_id TYPE trkorr.


    METHODS release_request
      IMPORTING iv_req_id TYPE trkorr.

    METHODS transport_request
      IMPORTING iv_req_id TYPE trkorr.

    METHODS transport_via_tms
      IMPORTING is_e070 TYPE e070.

    METHODS tms_in_remote_sys
      IMPORTING is_e070 TYPE e070.

ENDCLASS.


CLASS lcl_toc IMPLEMENTATION.
  METHOD constructor.
    ms_scr = REF #( is_scr ).
  ENDMETHOD.

  METHOD sh.

    fill_target_sys_info( ).

    do_toc_n_send( ).

  ENDMETHOD.

  METHOD fill_target_sys_info.

    DATA lt_destsys TYPE STANDARD TABLE OF ztcts002_destsys.

    IF ms_scr->rfcdest IS INITIAL.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |No rfcdest is provided. Could not transport anything|.
    ENDIF.

    SELECT mandt rfcdest target_sys descr del_mark is_default
      FROM ztcts002_destsys
      INTO TABLE lt_destsys
      WHERE rfcdest = ms_scr->rfcdest
        AND del_mark = abap_false.

    DELETE lt_destsys WHERE rfcdest IS INITIAL OR target_sys IS INITIAL.

    IF lt_destsys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |Rfcdest { ms_scr->rfcdest } has no valid mapping in DestSys (tab ZTCTS002_DESTSYS) |.
    ENDIF.

    ms_target_sys = VALUE #( lt_destsys[ 1 ] OPTIONAL ).

  ENDMETHOD.

  METHOD do_toc_n_send.

    DATA lt_e070 TYPE STANDARD TABLE OF e070.
    FIELD-SYMBOLS <fs_e070> TYPE e070.

    IF ms_scr->s_trreqi[] IS INITIAL.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = |Field REQUEST should be filled |.
    ENDIF.

    IF ms_scr->s_trreqi[] IS NOT INITIAL.

      fill_e070( CHANGING ct_e070 = lt_e070 ).

      IF lt_e070 IS NOT INITIAL.
        create_copy( lt_e070 ).
      ELSE.
        RAISE EXCEPTION TYPE zcx_cts002_data_error
          EXPORTING
            descr = |No requests cou;d be transported |.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD fill_e070.

    IF ms_scr IS INITIAL.
      RETURN.
    ENDIF.

    CLEAR ct_e070.

    SELECT * FROM e070
    INTO TABLE ct_e070
    WHERE trkorr IN ms_scr->s_trreqi
    AND trstatus IN
        (mc_trstatus-modifiable, mc_trstatus-protected, mc_trstatus-released)
    ORDER BY PRIMARY KEY
    .

  ENDMETHOD.

  METHOD create_copy.

    DATA lv_text TYPE trexreqhd-text.

    DATA lv_req_type TYPE trfunction VALUE 'T'.
    DATA lv_req_id TYPE  trkorr.
    DATA ls_req_header TYPE  trexreqhd.
    DATA ls_msg TYPE tr004-msgtext.
    DATA lv_exception TYPE tr007-exception.

    lv_text = get_text4copy_req( it_e070 ).

    CALL FUNCTION 'TR_EXT_CREATE_REQUEST'
      EXPORTING
        iv_request_type = lv_req_type    " Type of request; KTW are possible
        iv_target       = ms_target_sys-target_sys " Only Type T: Transport target of a request
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

    IF ms_scr->toctrans EQ abap_true.
      transport_request( lv_req_id ).
    ENDIF.

  ENDMETHOD.

  METHOD get_text4copy_req.
    DATA lv_add_txt TYPE string.

    DATA lt_e07t TYPE STANDARD TABLE OF e07t.

    FIELD-SYMBOLS <fs_e07t> TYPE e07t.

    rv_val = `TOC:` && sy-uname && `_` && sy-uzeit.

    IF lines( it_e070 ) > 1.

      lv_add_txt = |:{ lines( it_e070 ) } orig.requests |.
    ELSE.

      SELECT trkorr langu as4text
      FROM e07t
      INTO TABLE lt_e07t
      FOR ALL ENTRIES IN it_e070
      WHERE trkorr EQ it_e070-trkorr
      .

      lv_add_txt = VALUE #( lt_e07t[ langu = sy-langu ]-as4text OPTIONAL ).
      IF lv_add_txt IS INITIAL.
        lv_add_txt = VALUE #( lt_e07t[ 1 ]-as4text OPTIONAL ).
      ENDIF.

    ENDIF.

    rv_val = rv_val && lv_add_txt.

  ENDMETHOD.


  METHOD put_objects2request.
*      IMPORTING it_e070 TYPE e070_t
*                iv_req_id TYPE trkorr.

    DATA lt_e071 TYPE STANDARD TABLE OF e071.
    DATA lt_objects TYPE STANDARD TABLE OF trexreqob.
    DATA ls_objects TYPE trexreqob.
    FIELD-SYMBOLS <fs_e071> TYPE e071.
**
    SELECT trkorr as4pos FROM e071
      INTO CORRESPONDING FIELDS OF TABLE lt_e071
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
  ENDMETHOD.


  METHOD release_request.
    "      IMPORTING iv_req_id  TYPE trkorr.

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


    CALL FUNCTION 'Z_CTS002_TRREQ_EXCL_VERGEN_UPD'
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
    "      IMPORTING iv_req_id TYPE trkorr.

    DATA lt_e070 TYPE STANDARD TABLE OF e070.
    DATA ls_e070 TYPE e070.
    DATA lv_request_release TYPE char1.
    FIELD-SYMBOLS <fs_e070> TYPE e070.

    WHILE lv_request_release EQ abap_false.
      SELECT * FROM e070
        INTO TABLE lt_e070
        WHERE trkorr  = iv_req_id
          AND trstatus = mc_trstatus-released.
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
  ENDMETHOD.

  METHOD transport_via_tms.
    "       IMPORTING is_e070 TYPE e070.

    tms_in_remote_sys( is_e070 = is_e070 ).

  ENDMETHOD.

  METHOD  tms_in_remote_sys.
    DATA lv_system_name TYPE  stpa-sysname.

    DATA lv_tp_ret_code TYPE trretcode.
    DATA lt_trreq TYPE STANDARD TABLE OF tprequest.

    "    lv_system_name = sy-sysid(3).
    lv_system_name = ms_target_sys-target_sys.
    CALL FUNCTION 'Z_CTS002_TMS_TP_IMPORT'
      DESTINATION ms_target_sys-rfcdest
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

    DATA lt_reqs TYPE tprequests.
    DATA ls_reqs TYPE tprequest.

    ls_reqs-trkorr = is_e070-trkorr.
    APPEND ls_reqs TO lt_reqs.

  ENDMETHOD.

ENDCLASS.
