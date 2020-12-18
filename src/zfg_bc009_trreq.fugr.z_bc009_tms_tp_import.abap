FUNCTION z_bc009_tms_tp_import.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SYSTEM_NAME) TYPE  STPA-SYSNAME
*"     VALUE(IV_REQUEST) TYPE  STPA-TRKORR
*"     VALUE(IV_VERS_IGNORE) TYPE  TRPARFLAG DEFAULT 'Y'
*"  EXPORTING
*"     VALUE(EV_TP_CMD_STRG) LIKE  STPA-CMDSTRING
*"     VALUE(EV_TP_RET_CODE) LIKE  STPA-RETCODE
*"     VALUE(EV_TP_MESSAGE) LIKE  STPA-MESSAGE
*"     VALUE(EV_TP_VERSION) LIKE  STPA-VERSION
*"     VALUE(EV_TP_ALOG) LIKE  STPA-FILE
*"     VALUE(EV_TP_SLOG) LIKE  STPA-FILE
*"     VALUE(EV_TP_PID) LIKE  STPA-PID
*"     VALUE(EV_TPSTAT_KEY) LIKE  STPA-TIMESTAMP
*"  TABLES
*"      TT_REQUEST STRUCTURE  TPREQUEST OPTIONAL
*"      TT_PROJECT STRUCTURE  TPPROJECT OPTIONAL
*"      TT_CLIENT STRUCTURE  T000 OPTIONAL
*"      TT_STDOUT STRUCTURE  TPSTDOUT OPTIONAL
*"      TT_LOGPTR STRUCTURE  TPLOGPTR OPTIONAL
*"----------------------------------------------------------------------
  DATA lv_symandt TYPE symandt.

  """"""""""""""""""""""""""""""""""""""""""""'
  DATA lv_vers_ignore TYPE trparflag VALUE 'Y'.
  DATA lv_rc152 TYPE trparflag VALUE 'X'.
  """"""""""""""""""""""""""""""""""""""""""""'

  lv_symandt = sy-mandt.

  IF iv_vers_ignore IS SUPPLIED.
    lv_vers_ignore = iv_vers_ignore.
  ENDIF.


  CALL FUNCTION 'TMS_TP_IMPORT'
    EXPORTING
      iv_system_name     = iv_system_name
      iv_request         = iv_request
      iv_client          = lv_symandt
*     IV_CTC_UI          =
*     IV_CTC_ACTIVE      =
*     IV_UMODES          =
*     IV_TP_OPTIONS      =
*     IV_IGN_PREDEC      =
      iv_ign_cvers       = lv_vers_ignore
      iv_ign_rc152       = lv_rc152
*     IV_OFFLINE         =
*     IV_FEEDBACK        =
*     IV_PRID_TEXT       =
*     IV_PRID_MIN        = 0
*     IV_PRID_MAX        = 100
*     IV_TEST_IMPORT     =
*     IV_CMD_IMPORT      =
*     IV_NO_DELIVERY     =
*     IV_OWN_REQUEST     =
*     IV_SUBSET          =
*     IV_SIMULATE        = GC_CI_SIMU_OFF
*     IV_BATCHID         =
*     IT_TRPROJECT       =
*     IT_SUCCESSOR       =
*     IT_TARFILTER       =
    IMPORTING
      ev_tp_cmd_strg     = ev_tp_cmd_strg
      ev_tp_ret_code     = ev_tp_ret_code
      ev_tp_message      = ev_tp_message
      ev_tp_version      = ev_tp_version
      ev_tp_alog         = ev_tp_alog
      ev_tp_slog         = ev_tp_slog
      ev_tp_pid          = ev_tp_pid
      ev_tpstat_key      = ev_tpstat_key
    TABLES
      tt_request         = tt_request
      tt_project         = tt_project
      tt_client          = tt_client
      tt_stdout          = tt_stdout
      tt_logptr          = tt_logptr
    EXCEPTIONS
      permission_denied  = 1
      import_not_allowed = 2
      enqueue_failed     = 3
      tp_call_failed     = 4
      tp_interface_error = 5
      tp_reported_error  = 6
      tp_reported_info   = 7
      OTHERS             = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.




ENDFUNCTION.
