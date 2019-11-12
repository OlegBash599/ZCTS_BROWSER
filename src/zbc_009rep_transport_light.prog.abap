*&---------------------------------------------------------------------*
*& Report  ZBC_009REP_TRANSPORT_LIGHT
*&
*&---------------------------------------------------------------------*
*& Light version of calling ZCTS browser to check customizing
*&
*&---------------------------------------------------------------------*

REPORT zbc_009rep_transport_light.


" номер НЕДЕБЛОКИРОВАННОЙ задачи в запросе, а не номер запроса
PARAMETERS: p_trinit TYPE trkorr OBLIGATORY.

START-OF-SELECTION.
  DATA lo_transport_of_copies TYPE REF TO zif_bc009_tr_of_copies.
  DATA lv_clsname TYPE seoclsname VALUE 'ZCL_BC009_TR_OF_COPIES_B'.
  DATA lx_bc009 TYPE REF TO zcx_bc009_request.

  TRY.
      CREATE OBJECT lo_transport_of_copies TYPE (lv_clsname).
      lo_transport_of_copies->create_toc_n_move2target( iv_trkorr = p_trinit ).

    CATCH zcx_bc009_request INTO lx_bc009.

  ENDTRY.

END-OF-SELECTION.
