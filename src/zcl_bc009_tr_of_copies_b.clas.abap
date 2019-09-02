
*----------------------------------------------------------------------*
*       CLASS zcl_bc009_tr_of_copies_b DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_bc009_tr_of_copies_b DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_bc009_tr_of_copies.
    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_target_sys_info
            , rfcdest TYPE rfcdest
            , system TYPE char10
          , END OF ts_target_sys_info
          .

    CONSTANTS: BEGIN OF mc
                   , sign_include TYPE char1 VALUE 'I'
                   , option_equal TYPE char2 VALUE 'EQ'
                   , request_type_copy TYPE trfunction VALUE 'T'
                   , toc_text TYPE string VALUE `TOC: `
                   , underscore TYPE char1 VALUE '_'
                   , action_lock TYPE char1 VALUE '1'
                   , action_unlock TYPE char1 VALUE '2'
              , END OF mc
              .

    CONSTANTS: BEGIN OF mc_request_status
                  , modifiable TYPE trstatus VALUE 'D' " Изменяемо
                  , modifiable_protected TYPE trstatus VALUE 'L' " Изменяемо, защищено
                  , release_started TYPE trstatus VALUE 'L' " Деблокирование запущено
                  , released TYPE trstatus VALUE 'R' " Деблокировано
                  , released_with_protection TYPE trstatus VALUE 'N' " Released (with Import Protection for Repaired Objects)
            , END OF mc_request_status
            .

    DATA ms_target_system_info TYPE ts_target_sys_info.
    DATA mt_range_init_trkorr TYPE RANGE OF trkorr.

    METHODS fill_target_system_info.
    METHODS fill_korr_range
        IMPORTING !iv_trkorr TYPE trkorr
        RAISING zcx_bc009_request.

    METHODS read_transport_head_info
        EXPORTING et_070 TYPE tt_e070
        RAISING zcx_bc009_request.

    METHODS create_copy
      IMPORTING it_e070 TYPE tt_e070
      EXPORTING ev_toc_number TYPE trkorr
      RAISING zcx_bc009_request.

    METHODS put_objects2toc
       IMPORTING it_e070 TYPE tt_e070
                 iv_req_id TYPE trkorr
      RAISING zcx_bc009_request.

    METHODS release_toc_wo_version
      IMPORTING iv_req_id  TYPE trkorr
     RAISING zcx_bc009_request.

    METHODS do_lock_action
       IMPORTING iv_req_id  TYPE trkorr
                 iv_action TYPE char1 DEFAULT mc-action_lock
       RAISING zcx_bc009_request.

    METHODS transport_toc
       IMPORTING iv_req_id  TYPE trkorr
       RAISING zcx_bc009_request.

    METHODS tms_in_remote_sys
        IMPORTING is_e070 TYPE e070
        RAISING zcx_bc009_request.
ENDCLASS.



CLASS ZCL_BC009_TR_OF_COPIES_B IMPLEMENTATION.


  METHOD constructor.
    me->fill_target_system_info( ).
  ENDMETHOD.                    "constructor


  METHOD create_copy.
*      IMPORTING it_e070 TYPE tt_e070
*      EXPORTING ev_toc_number TYPE trkorr.
    DATA lv_text TYPE trexreqhd-text.

    DATA ls_req_header TYPE  trexreqhd.
    DATA ls_msg TYPE tr004-msgtext.
    DATA lv_exception TYPE tr007-exception.

    lv_text = mc-toc_text && sy-uname && mc-underscore && sy-datum && mc-underscore && sy-uzeit.

    CALL FUNCTION 'TR_EXT_CREATE_REQUEST'
      EXPORTING
        iv_request_type = 'T'    " Type of request; KTW are possible
        iv_target       = ms_target_system_info-system    " Only Type T: Transport target of a request
        iv_author       = sy-uname    " Owner of request
        iv_text         = lv_text    " Short text describing R/3 Repository objects
*       iv_req_attr     =     " Request attribute
*       iv_attr_ref     =     " Attribute value
      IMPORTING
        es_req_id       = ev_toc_number
        es_req_header   = ls_req_header
        es_msg          = ls_msg
        ev_exception    = lv_exception.     " Name of exception

    IF ev_toc_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_bc009_request.
    ENDIF.

  ENDMETHOD.                    "create_copy


  METHOD do_lock_action.

    DATA lv_func_lock TYPE rs38l_fnam VALUE 'CTS_LOCK_TRKORR'.
    DATA lv_func_unlock TYPE rs38l_fnam VALUE 'CTS_UNLOCK_TRKORR'.



    CASE iv_action.
      WHEN mc-action_unlock.
        CALL FUNCTION 'FUNCTION_EXISTS'
          EXPORTING
            funcname           = lv_func_lock    " Name of Function Module
*                      IMPORTING
*                        group              =     " Name of function group
*                        include            =     " Name of include
*                        namespace          =     " Namespace
*                        str_area           =     " Name of function group without namespace
          EXCEPTIONS
            function_not_exist = 1
            OTHERS             = 2
          .
        IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          RETURN.
        ENDIF.

        CALL FUNCTION lv_func_unlock
          EXPORTING
            iv_trkorr = iv_req_id
          EXCEPTIONS
            OTHERS    = 0.
      WHEN mc-action_lock.
        CALL FUNCTION 'FUNCTION_EXISTS'
        EXPORTING
          funcname           = lv_func_unlock    " Name of Function Module
*            IMPORTING
*              group              =     " Name of function group
*              include            =     " Name of include
*              namespace          =     " Namespace
*              str_area           =     " Name of function group without namespace
        EXCEPTIONS
          function_not_exist = 1
          OTHERS             = 2
        .
        IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          RETURN.
        ENDIF.

        CALL FUNCTION lv_func_lock        " eclipse compatible locking...
         EXPORTING
          iv_trkorr   = iv_req_id
         EXCEPTIONS
          OTHERS = 1.
        IF sy-subrc  =    1.
          RAISE EXCEPTION TYPE zcx_bc009_request.
        ENDIF.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_bc009_request.
    ENDCASE.
  ENDMETHOD.                    "do_lock_action


  METHOD fill_korr_range.
    FIELD-SYMBOLS <fs_range_korr> LIKE LINE OF mt_range_init_trkorr.

    CLEAR mt_range_init_trkorr.

    IF iv_trkorr IS INITIAL.
      RAISE EXCEPTION TYPE zcx_bc009_request.
    ENDIF.

    APPEND INITIAL LINE TO mt_range_init_trkorr ASSIGNING <fs_range_korr>.
    <fs_range_korr>-sign = mc-sign_include.
    <fs_range_korr>-option = mc-option_equal.
    <fs_range_korr>-low = iv_trkorr.
  ENDMETHOD.                    "fill_korr_range


  METHOD fill_target_system_info.
    DATA lo_target_sys TYPE REF TO zcl_bc009_target_sysinfo.
    CREATE OBJECT lo_target_sys.

    ms_target_system_info-rfcdest = lo_target_sys->get_target_rfc_name( ).
    ms_target_system_info-system = lo_target_sys->get_target_sys_name( ).
  ENDMETHOD.                    "fill_target_system_info


  METHOD put_objects2toc.
*       IMPORTING it_e070 TYPE tt_e070
*                 iv_req_id TYPE trkorr
*      RAISING zcx_bc009_request.

    DATA lt_objects TYPE STANDARD TABLE OF trexreqob.
    DATA ls_objects TYPE trexreqob.
    FIELD-SYMBOLS <fs_e070> TYPE e070.


    LOOP AT it_e070 ASSIGNING <fs_e070>.

      CALL FUNCTION 'TR_COPY_COMM'
        EXPORTING
          wi_dialog                = abap_true    " Flag, whether information messages sent
          wi_trkorr_from           = <fs_e070>-trkorr    " Initial correction number
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
        RAISE EXCEPTION TYPE zcx_bc009_request.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.                    "put_objects2request


  METHOD read_transport_head_info.
    IF mt_range_init_trkorr IS INITIAL.
      RAISE EXCEPTION TYPE zcx_bc009_request.
    ENDIF.

    SELECT * FROM e070
    INTO TABLE et_070
    WHERE trkorr IN mt_range_init_trkorr
    AND trstatus IN (mc_request_status-modifiable, mc_request_status-modifiable_protected, mc_request_status-released)
    ORDER BY PRIMARY KEY
    .
  ENDMETHOD.                    "read_transport_head_info


  METHOD release_toc_wo_version.
    DATA lv_as_background_job TYPE char1.
    DATA lv_success_message TYPE char1.
    DATA lv_without_locking TYPE char1 VALUE abap_true.
    DATA lv_without_objects_check TYPE char1 .
    DATA lv_display_export_log TYPE char1.
    DATA lt_messages               TYPE ctsgerrmsgs.
    DATA ls_message                TYPE ctsgerrmsg.



    do_lock_action(  EXPORTING iv_req_id = iv_req_id ).

    CALL FUNCTION 'Z_BC009_TRREQ_UPD'
      IN UPDATE TASK .

*---call trint_release_request------------------------------------------
    CLEAR lt_messages.
    CALL FUNCTION 'TRINT_RELEASE_REQUEST'
      EXPORTING
        iv_trkorr                   = iv_req_id
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

    IF sy-subrc NE 0.
      do_lock_action(  EXPORTING iv_req_id = iv_req_id
                                 iv_action = mc-action_unlock  ).
      RAISE EXCEPTION TYPE zcx_bc009_request.
    ENDIF.

*---dequeue request-----------------------------------------------------
    do_lock_action(  EXPORTING iv_req_id = iv_req_id
                                     iv_action = mc-action_unlock  ).



  ENDMETHOD.                    "release_toc_wo_version


  METHOD tms_in_remote_sys.
*       IMPORTING is_e070 TYPE e070
*       RAISING zcx_bc009_request.

    DATA lv_system_name TYPE  stpa-sysname.

    DATA lv_tp_ret_code TYPE trretcode.
    DATA lt_trreq TYPE STANDARD TABLE OF tprequest.

    lv_system_name = ms_target_system_info-system.
    CALL FUNCTION 'Z_BC009_TMS_TP_IMPORT'
      DESTINATION ms_target_system_info-rfcdest
      EXPORTING
        iv_system_name = lv_system_name
        iv_request     = is_e070-trkorr
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

*    zcl_bc009_html=>get_instance( )->add_para_val_ch(
*        iv_id    = 'ret_code'
*        iv_value = lv_tp_ret_code
*    )->add_tab_ch( it_tab = lt_trreq ).

  ENDMETHOD.                    "tms_in_remote_sys


  METHOD transport_toc.
*      IMPORTING iv_req_id  TYPE trkorr
*      RAISING zcx_bc009_request.

    DATA lt_e070 TYPE tt_e070.
    DATA ls_e070 TYPE e070.
    DATA lv_waiting_times TYPE syindex VALUE 100.

    FIELD-SYMBOLS <fs_e070> TYPE e070.

    DO lv_waiting_times TIMES.
      SELECT * FROM e070
        INTO TABLE lt_e070
        WHERE trkorr  = iv_req_id
          AND trstatus = mc_request_status-released.
      IF sy-subrc EQ 0.
        EXIT.
      ENDIF.
      WAIT UP TO 2 SECONDS.
    ENDDO.

    LOOP AT lt_e070 ASSIGNING <fs_e070>.
      tms_in_remote_sys( is_e070 = <fs_e070> ).
    ENDLOOP.

  ENDMETHOD.                    "transport_toc


  METHOD zif_bc009_tr_of_copies~create_toc_n_move2target.
    DATA lt_e070 TYPE tt_e070.
    DATA lv_toc_number TYPE  trkorr.

    fill_korr_range( iv_trkorr = iv_trkorr ).

    read_transport_head_info( IMPORTING et_070 = lt_e070 ).

    create_copy( EXPORTING it_e070       = lt_e070
                 IMPORTING ev_toc_number = lv_toc_number  ).

    put_objects2toc( EXPORTING it_e070   = lt_e070
                                   iv_req_id = lv_toc_number ).

    release_toc_wo_version( iv_req_id = lv_toc_number ).

    transport_toc( iv_req_id = lv_toc_number ).


  ENDMETHOD.                    "zif_bc009_tr_of_copies~create_toc_n_move2target
ENDCLASS.
