*"* use this source file for your ABAP unit test classes

CLASS ltc_aka_java_final DEFINITION FOR TESTING
                          RISK LEVEL HARMLESS
                          DURATION SHORT
  INHERITING FROM cl_aunit_assert.

  PUBLIC SECTION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS setup.
    METHODS ltc_aka_java_final FOR TESTING.

    METHODs final_var
      IMPORTING iv_var type char10 OPTIONAL.

ENDCLASS.                    "ltc_aka_java_final DEFINITION


*----------------------------------------------------------------------*
*       CLASS ltc_aka_java_final IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ltc_aka_java_final IMPLEMENTATION.
  METHOD setup.

  ENDMETHOD.                    "setup

  METHOD ltc_aka_java_final.
*    TYPES: BEGIN OF ts_sort_tab_aka_java_final
*        , val TYPE char10
*      , END OF ts_sort_tab_aka_java_final
*      , tt_sort_tab_aka_java_final TYPE SORTED TABLE OF ts_sort_tab_aka_java_final
*          WITH UNIQUE KEY primary_key COMPONENTS val
*      .
*
*    DATA ls_aka_final_java TYPE ts_sort_tab_aka_java_final.
*    DATA lt_aka_final_java TYPE tt_sort_tab_aka_java_final.
*    DATA lr_aka_final_java TYPE REF TO ts_sort_tab_aka_java_final.
*
*    ls_aka_final_java-val = 'VAL1'.
*
*    INSERT ls_aka_final_java INTO TABLE lt_aka_final_java.
*
*    READ TABLE lt_aka_final_java REFERENCE INTO lr_aka_final_java INDEX 1.
*    IF sy-subrc EQ 0.
*      lr_aka_final_java->val = 'VAL2'.
*    ENDIF.
  ENDMETHOD.                    "ltc_aka_java_final

  METHOD final_var.
*    data lv_var type char10.
*    IF iv_var is SUPPLIED.
*      " do calculation
*      iv_var = iv_var + 1.
*      else.
*       lv_var = get_var( ).
*       final_var( lv_var ).
*    ENDIF.
  ENDMETHOD.

ENDCLASS.                    "ltc_aka_java_final IMPLEMENTATION
