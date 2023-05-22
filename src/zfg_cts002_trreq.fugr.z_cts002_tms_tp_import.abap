FUNCTION z_cts002_tms_tp_import.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SYSTEM_NAME) TYPE  STPA-SYSNAME
*"     VALUE(IV_REQUEST) TYPE  STPA-TRKORR
*"     VALUE(IV_VERS_IGNORE) TYPE  TRPARFLAG DEFAULT 'Y'
*"     VALUE(IV_IMPORT_MODE) TYPE  INT1 DEFAULT 2
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  STRING
*"----------------------------------------------------------------------

  " TMS_MGR_IMPORT_TR_REQUEST
  DATA lc_tr_imp_dir TYPE int1 VALUE 1.
  DATA lc_tr_imp_with_file_check TYPE int1 VALUE 2.
  DATA lx TYPE REF TO zcx_cts002_data_error.

  CASE iv_import_mode.
    WHEN lc_tr_imp_dir.
      TRY .
          NEW zcl_cts002_trans_imp( iv_system_name = iv_system_name
                                  iv_request = iv_request
                                  iv_vers_ignore = iv_vers_ignore )->sh( ).
        CATCH zcx_cts002_data_error INTO lx.
          ev_error = lx->descr.
      ENDTRY.

    WHEN lc_tr_imp_with_file_check.
      TRY .
          NEW zcl_cts002_tr_imp_dtfile(
            iv_system_name = iv_system_name
            iv_request = iv_request
            iv_vers_ignore = iv_vers_ignore )->sh( ).
        CATCH zcx_cts002_data_error INTO lx.
          ev_error = lx->descr.
      ENDTRY.
    WHEN OTHERS.

  ENDCASE.




ENDFUNCTION.
