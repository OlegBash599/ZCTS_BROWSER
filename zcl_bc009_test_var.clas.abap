class ZCL_BC009_TEST_VAR definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BC009_TEST_VAR IMPLEMENTATION.


METHOD constructor.
*  TYPES: BEGIN OF ts_sort_tab_aka_java_final
*          , val TYPE char10
*        , END OF ts_sort_tab_aka_java_final
*        , tt_sort_tab_aka_java_final TYPE SORTED TABLE OF ts_sort_tab_aka_java_final
*            WITH UNIQUE KEY primary_key COMPONENTS val
*        .
*
*  DATA ls_aka_final_java TYPE ts_sort_tab_aka_java_final.
*  DATA lt_aka_final_java TYPE tt_sort_tab_aka_java_final.
*  DATA lr_aka_final_java TYPE REF TO ts_sort_tab_aka_java_final.
*
*  ls_aka_final_java-val = 'VAL1'.
*
*  INSERT ls_aka_final_java INTO TABLE lt_aka_final_java.
*
*  READ TABLE lt_aka_final_java REFERENCE INTO lr_aka_final_java INDEX 1.
*  IF sy-subrc EQ 0.
*    lr_aka_final_java->val = 'VAL2'.
*  ENDIF.

ENDMETHOD.
ENDCLASS.
