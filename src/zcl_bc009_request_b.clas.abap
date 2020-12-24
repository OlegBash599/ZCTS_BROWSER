*----------------------------------------------------------------------*
*       CLASS ZCL_BC009_REQUEST_B DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class ZCL_BC009_REQUEST_B definition
  public
  final
  create public .

public section.

  interfaces ZIF_BC009_REQUEST .

  data MV_TARGET_SYS type SYSYSID .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BC009_REQUEST_B IMPLEMENTATION.


  METHOD zif_bc009_request~move_as_copy.

*    DATA lt_range_korr TYPE RANGE OF trkorr.
*    FIELD-SYMBOLS <fs_range_korr> LIKE LINE OF lt_range_korr.

*    APPEND INITIAL LINE TO lt_range_korr ASSIGNING <fs_range_korr>.
*    <fs_range_korr>-sign = 'I'.
*    <fs_range_korr>-option = 'EQ'.
*    <fs_range_korr>-low = iv_trkorr.
*
*
*    SUBMIT zbc_009rep_transport
*      WITH s_trreqi IN lt_range_korr
*      WITH no_dis EQ abap_true
*      AND RETURN.

    DATA lo_transport_of_copies TYPE REF TO zif_bc009_tr_of_copies.
    DATA lv_clsname TYPE seoclsname VALUE 'ZCL_BC009_TR_OF_COPIES_B'.
    DATA lx_bc009 TYPE REF TO zcx_bc009_request.

    TRY.
        CREATE OBJECT lo_transport_of_copies TYPE (lv_clsname).
        lo_transport_of_copies->create_toc_n_move2target( iv_trkorr = iv_trkorr ).

      CATCH zcx_bc009_request INTO lx_bc009.

    ENDTRY.

  ENDMETHOD.                    "zif_bc009_request~move_as_copy


method ZIF_BC009_REQUEST~SET_TARGET.
  MV_TARGET_SYS = iv_trg_sys.
endmethod.
ENDCLASS.
