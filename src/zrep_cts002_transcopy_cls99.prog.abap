*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_CLS99
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS start_of_sel.
    METHODS at_sel_screen.
    METHODS at_sel_screen_output.
    METHODS end_of_sel.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA ms_scr TYPE ts_screen.
    METHODS fill_from_screen.
    METHODS output_end.
    METHODS fill_toolbar_func1.

ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    fill_toolbar_func1( ).
  ENDMETHOD.

  METHOD start_of_sel.

    DATA lx TYPE REF TO zcx_cts002_data_error.

    TRY .
        fill_from_screen( ).
        NEW lcl_toc( ms_scr )->sh( ).
        output_end( ).
      CATCH zcx_cts002_data_error INTO lx.
        MESSAGE s001(cl) WITH lx->descr.
    ENDTRY.

  ENDMETHOD.

  METHOD end_of_sel.
    " output_end( ).
  ENDMETHOD.

  METHOD output_end.
    MESSAGE s000(cl) WITH '...something is done...'.
  ENDMETHOD.

  METHOD fill_from_screen.

    "    ms_scr-s_trreq = s_trreq[].
    ms_scr-s_trreqi = s_trreqi[].
*    ms_scr-remote = remote.
    ms_scr-rfcdest = rfcdest.
    ms_scr-version_ignore = vers_ign.
    ms_scr-toctrans = toctrans.


  ENDMETHOD.

  METHOD at_sel_screen.

    CASE sscrfields-ucomm.
      WHEN'FC01'.
        NEW lcl_open_ext_obj( )->open_view( 'ZTCTS002_DESTSYS' ).
      WHEN 'FC02'.
        " no action
    ENDCASE.

  ENDMETHOD.

  METHOD at_sel_screen_output.
    LOOP AT SCREEN.
      IF screen-name = 'RFCDEST'.
        screen-required = '2'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD fill_toolbar_func1.
    sscrfields-functxt_01 = 'TargetSys (ZTCTS002_DESTSYS)'.
  ENDMETHOD.
ENDCLASS.
