*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_CLS02
*&---------------------------------------------------------------------*

CLASS lcl_open_ext_obj DEFINITION.

  PUBLIC SECTION.
    METHODS open_view
      IMPORTING iv_view_name TYPE tabname.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS lcl_open_ext_obj IMPLEMENTATION.
  METHOD open_view.
    "      IMPORTING iv_view_name TYPE tabname.

    CONSTANTS: BEGIN OF lc_actions
                  , display TYPE char1 VALUE 'U'
                  , maintain TYPE char1 VALUE 'S'
                  , transport TYPE char1 VALUE 'T'
              , END OF lc_actions
              .

    data lv_target_action TYPE char1.

    lv_target_action = lc_actions-display.

    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action                       = lv_target_action " Action (Display/Maintain/Transport)
*       corr_number                  = '          '     " Correction Number for Changes Made
*       generate_maint_tool_if_missing = ' '              " Flag: Create Maint. Mods. if They do Not Exist
*       show_selection_popup         = ' '              " Flag: Display Selection Conditions Dialog Box
        view_name                    = iv_view_name                 " Name of the View/Table to be Edited
*       no_warning_for_clientindep   = ' '              " Flag: No Warning for Cross-Client Objects
*       rfc_destination_for_upgrade  = ' '              " RFC Dest. of System for Comparison/Adjustment
*       client_for_upgrade           = ' '              " Client for Comparison/Adjustment
*       variant_for_selection        = ' '              " Selection Conditions Variant
*       complex_selconds_used        = ' '              " Flag: DBA_SELLIST Contains Complex Selection Conditions
*       check_ddic_mainflag          = ' '              " Flag: Check Whether Maintenance is Allowed
*       suppress_wa_popup            = space            " Flag: Suppress "Specify Work Area" Dialog Box
*      TABLES
*       dba_sellist                  =                  " Database Access Selection Conditions
*       excl_cua_funct               =                  " GUI Functions to be Deactivated Dynamically
      EXCEPTIONS
        client_reference             = 1                " View is Chained to Another Client
        foreign_lock                 = 2                " View/Table is Locked by Another User
        invalid_action               = 3                " ACTION Contains Invalid Values
        no_clientindependent_auth    = 4                " No Authorization for Maintaining Cross-Client Tables/Views
        no_database_function         = 5                " No Data Capture/Disposal Function Module
        no_editor_function           = 6                " Editor Function Module Missing
        no_show_auth                 = 7                " No Display Authorization
        no_tvdir_entry               = 8                " View/Table is Not in TVDIR
        no_upd_auth                  = 9                " No Maintenance or Display Authorization
        only_show_allowed            = 10               " Display but Not Maintenance Authorization
        system_failure               = 11               " System lock error
        unknown_field_in_dba_sellist = 12               " Selection Table Contains Unknown Fields
        view_not_found               = 13               " View/Table Not Found in DDIC
        maintenance_prohibited       = 14               " View/Table Cannot be Maintained acc. to DDIC
        OTHERS                       = 15.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
