CLASS zcl_cts002_tr_imp_dtfile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING iv_system_name TYPE stpa-sysname
                iv_request     TYPE  stpa-trkorr
                iv_vers_ignore TYPE  trparflag DEFAULT 'Y'.
    METHODS sh
      RAISING zcx_cts002_data_error.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_system_name TYPE sysysid.
    DATA mv_request TYPE  stpa-trkorr.
    DATA mv_vers_ignore TYPE  trparflag.

    METHODS check_n_import_data_file
      RAISING zcx_cts002_data_error.

    METHODS import_tr
      RAISING zcx_cts002_data_error.

    METHODS read_tms_buffer
      EXPORTING et_tmsbuff TYPE tmsbuffers.

    METHODS read_trans_queue
      RAISING zcx_cts002_data_error.

    METHODS read_with_no_data_files
      EXPORTING et_tmsbuff TYPE tmsbuffers.

    METHODS import_data_files
      IMPORTING it_tmsbuff TYPE tmsbuffers
      RAISING   zcx_cts002_data_error.
ENDCLASS.



CLASS zcl_cts002_tr_imp_dtfile IMPLEMENTATION.
  METHOD constructor.
    mv_system_name = iv_system_name.
    mv_request = iv_request.
    mv_vers_ignore = iv_vers_ignore.
  ENDMETHOD.

  METHOD sh.

    check_n_import_data_file( ).

    import_tr(  ).

  ENDMETHOD.

  METHOD check_n_import_data_file.
    DATA lt_tmsbuffer TYPE tmsbuffers.
    FIELD-SYMBOLS <fs_tmsbuffer> TYPE tmsbuffer.

    read_trans_queue(  ).

    read_with_no_data_files( IMPORTING et_tmsbuff = lt_tmsbuffer ).

    import_data_files( EXPORTING it_tmsbuff = lt_tmsbuffer ).

  ENDMETHOD.

  METHOD read_tms_buffer.

    SELECT
     domnam sysnam bufpos buflvl trkorr umodes impflg maxrc
        tarcli project trfunc actflg preflg nodataflg
    FROM tmsbuffer
    INTO CORRESPONDING FIELDS OF TABLE et_tmsbuff
    WHERE trkorr = mv_request
    .

  ENDMETHOD.

  METHOD read_trans_queue.
    DATA lv_err TYPE string.

    DATA lt_tmsbuffer TYPE tmsbuffers.
    data lv_tmssysnam TYPE TMSSYSNAM.

    read_tms_buffer( IMPORTING et_tmsbuff = lt_tmsbuffer ).

    IF lt_tmsbuffer IS INITIAL.

      lv_tmssysnam = sy-sysid.

      CALL FUNCTION 'TMS_MGR_READ_TRANSPORT_QUEUE'
        EXPORTING
          iv_system          = lv_tmssysnam
*         iv_domain          = space
          iv_collect_data    = abap_true
*         iv_count_only      =
          iv_read_shadow     = abap_true
*         iv_maxrc_only      = 'X'
*         iv_read_locks      = 'X'
*         iv_clear_locks     = 'X'
*         iv_use_data_files  =
*         iv_update_cache    = 'X'
*         iv_monitor         = 'X'
*         iv_progress_min    = 1
*         iv_progress_max    = 100
*         iv_verbose         =
*         iv_expiration_date =
*         iv_allow_expired   =
*         it_systems         =
*      IMPORTING
*         ev_collect_date    =
*         ev_collect_time    =
*         ev_collect_flag    =
*         es_exception       =
*      TABLES
*         tt_buffer          =
*         tt_counter         =
*         tt_project         =
*         tt_domain          =
*         tt_system          =
*         tt_group           =
        EXCEPTIONS
          read_config_failed = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_err.
        RAISE EXCEPTION TYPE zcx_cts002_data_error
          EXPORTING
            descr = | { lv_err } |.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD read_with_no_data_files.
    DATA lt_tmsbuffer TYPE tmsbuffers.

    read_tms_buffer( IMPORTING et_tmsbuff = lt_tmsbuffer ).

    DELETE lt_tmsbuffer WHERE nodataflg = abap_false.

    et_tmsbuff = lt_tmsbuffer.

  ENDMETHOD.

  METHOD import_data_files.
    DATA lv_err TYPE string.
    DATA ls_tmsbuffer TYPE tmsbuffer.
    DATA ls_tp_trque            TYPE stms_tp_trque.
*    FIELD-SYMBOLS <fs_tmsbuffer> TYPE tmsbuffer.

    ls_tmsbuffer = VALUE #( it_tmsbuff[ 1 ] OPTIONAL ).

    IF ls_tmsbuffer IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'TMS_MGR_TRANSMIT_TR_QUEUE'
      EXPORTING
        iv_tar_sys                = ls_tmsbuffer-sysnam
        iv_tar_dom                = ls_tmsbuffer-domnam
*       iv_src_sys                =
*       iv_src_grp                =
*       iv_src_dom                =
*       iv_loc_grp                = 'X'
*       iv_ext_grp                = 'X'
        iv_read_only              = abap_false
*       iv_use_list               =
*       iv_ignore_lock            =
*       iv_without_ftp            =
*       iv_ftp_only               =
*       iv_monitor                = 'X'
*       iv_verbose                =
        it_requests               = it_tmsbuff
*       it_projects               =
*      IMPORTING
*       es_tp_dirtsts             =
      CHANGING
        cs_tp_trque               = ls_tp_trque
      EXCEPTIONS
        read_config_failed        = 1
        system_not_found          = 2
        group_not_found           = 3
        no_source_systems_found   = 4
        feature_not_available     = 5
        identical_groups          = 6
        check_group_config_failed = 7
        invalid_group_config      = 8
        OTHERS                    = 9.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_err.
      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
          descr = | { lv_err } |.
    ENDIF.

  ENDMETHOD.

  METHOD import_tr.

    DATA lv_error TYPE string.
    DATA lt_request_in TYPE tmsbuffers.
    DATA lt_request_out TYPE stms_wbo_requests.

    DATA lv_sys_name TYPE tmscsys-sysnam.
    "    lv_sys_name = mv_system_name.
    lv_sys_name = sy-sysid.



    CALL FUNCTION 'TMS_MGR_IMPORT_TR_REQUEST'
      EXPORTING
        iv_system                  = lv_sys_name
*       iv_domain                  =
        iv_request                 = mv_request
*       iv_client                  =
*       iv_ctc_active              =
*       iv_overtake                =
*       iv_import_again            =
*       iv_ignore_originality      =
*       iv_ignore_repairs          =
*       iv_ignore_transtype        =
*       iv_ignore_tabletype        =
*       iv_ignore_qaflag           =
*       iv_ignore_predec           =
        iv_ignore_cvers            = mv_vers_ignore
*       iv_ignore_spam             =
*       iv_test_import             =
*       iv_cmd_import              =
*       iv_no_delivery             =
*       iv_subset                  =
*       iv_offline                 =
*       iv_feedback                =
*       iv_monitor                 = 'X'
*       iv_force                   =
*       iv_verbose                 =
*       is_batch                   =
*       it_requests                =
*       it_clients                 =
*      IMPORTING
*       ev_tp_ret_code             =
*       ev_tp_alog                 =
*       ev_tp_slog                 =
*       ev_tp_pid                  =
*       ev_tpstat_key              =
*       es_exception               =
*       et_tp_imports              =
*      TABLES
*       tt_logptr                  =
*       tt_stdout                  =
      EXCEPTIONS
        read_config_failed         = 1
        table_of_requests_is_empty = 2
        OTHERS                     = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_error.

      RAISE EXCEPTION TYPE zcx_cts002_data_error
        EXPORTING
*         textid   =
*         previous =
          descr = | { lv_error } |.

    ENDIF.


*    CALL FUNCTION 'TMS_MGR_READ_TRANSPORT_REQUEST'
*      EXPORTING
*        iv_request                 = mv_request
*        iv_target_system           = lv_sys_name
**       iv_docu_only               =
**       iv_header_only             =
**       iv_monitor                 = 'X'
**       iv_verbose                 =
**       is_queue                   =
**        it_requests                = lt
*      IMPORTING
*        et_request_infos           = lt_request_out
*      EXCEPTIONS
*        read_config_failed         = 1
*        table_of_requests_is_empty = 2
*        system_not_available       = 3
*        OTHERS                     = 4.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_error.
*
*      RAISE EXCEPTION TYPE zcx_cts002_data_error
*        EXPORTING
**         textid   =
**         previous =
*          descr = | { lv_error } |.
*
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
