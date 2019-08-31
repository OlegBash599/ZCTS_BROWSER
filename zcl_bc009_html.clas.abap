class ZCL_BC009_HTML definition
  public
  final
  create private .

public section.

  types:
    BEGIN OF ts_index_str " определяем структуру " определяем структуру " определяем структуру " определяем структуру " определяем структуру " определяем структуру " определяем структуру " определяем структуру " определяем структуру
          , index TYPE syindex
          , line TYPE string
      , END OF ts_index_str .
  types:                         " определяем структуру
    tt_index_str TYPE STANDARD TABLE OF ts_index_str
        WITH DEFAULT KEY .

  events HTML_ACTION
    exporting
      value(EV_ACTION) type STRING .


  class-methods GET_INSTANCE
    importing
      !IV_TITLE type C optional
    returning
      value(RO_OBJ) type ref to ZCL_BC009_HTML .
  methods CONSTRUCTOR
    importing
      !IV_TITLE type C .
  methods ADD_PARA_VAL
    importing
      !IV_ID type C
      !IV_VALUE type C .
  methods ADD_TAB
    importing
      !IT_TAB type TABLE .
  methods ADD_PARA_VAL_CH
    importing
      !IV_ID type C
      !IV_VALUE type C
    returning
      value(RO_OBJ) type ref to ZCL_BC009_HTML .
  methods ADD_TAB_CH
    importing
      !IT_TAB type TABLE
    returning
      value(RO_OBJ) type ref to ZCL_BC009_HTML .
  methods SHOW .
  methods SHOW_XML
    importing
      !IV_XML type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ts_html_part
            , tag_str TYPE text20
            , content TYPE tt_index_str
        , END OF ts_html_part
        .

    DATA mt_head TYPE tt_index_str.
    DATA mt_body TYPE tt_index_str.
    DATA mv_title_win TYPE cl_abap_browser=>title.

    CONSTANTS: c_step_index TYPE syindex VALUE 10.

    CLASS-DATA mo_html TYPE REF TO ZCL_BC009_HTML .



    METHODS fill_default_head
      IMPORTING iv_title TYPE c .

    METHODS add_index
      CHANGING cv_index TYPE syindex.

    METHODS add_html_line
      CHANGING ct_block TYPE tt_index_str
               cs_line TYPE ts_index_str.

    METHODS get_html_tab
      RETURNING value(rt_val) TYPE cl_abap_browser=>html_table.

    METHODS add_head_line
      IMPORTING iv_line TYPE c.

    METHODS add_body_line
      IMPORTING iv_line TYPE c.

    METHODS add_html_menu.

    METHODS on_html_sapevent
      FOR EVENT sapevent
      OF cl_abap_browser
      IMPORTING action.
ENDCLASS.



CLASS ZCL_BC009_HTML IMPLEMENTATION.


  METHOD ADD_BODY_LINE.
    DATA ls_body_line TYPE ts_index_str.

    ls_body_line-line = iv_line.
    ls_body_line-index = lines( mt_body ) * c_step_index.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).
  ENDMETHOD.                    "ADD_BODY_LINE


  METHOD ADD_HEAD_LINE.
    DATA ls_head_line TYPE ts_index_str.

    ls_head_line-line = iv_line.
    ls_head_line-index = lines( mt_head ) * c_step_index.
    add_index( CHANGING cv_index = ls_head_line-index ).
    add_html_line( CHANGING ct_block = mt_head cs_line = ls_head_line ).
  ENDMETHOD.                    "ADD_HEAD_LINE


  METHOD ADD_HTML_LINE.
    APPEND cs_line TO ct_block.
  ENDMETHOD.                    "ADD_HTML_LINE


  METHOD ADD_HTML_MENU.
    add_body_line( iv_line = '<span>' ).
    add_body_line( iv_line = '<A HREF=SAPEVENT:F1>Action#1</A>' ).
    add_body_line( iv_line = '</span>' ).
    add_body_line( iv_line = '<span>' ).
    add_body_line( iv_line = '<A HREF=SAPEVENT:F2>Action#2</A>' ).
    add_body_line( iv_line = '</span>' ).
    add_body_line( iv_line = '<span>' ).
    add_body_line( iv_line = '<A HREF=SAPEVENT:F3>Action#3</A>' ).
    add_body_line( iv_line = '</span>' ).
  ENDMETHOD.                    "ADD_HTML_MENU


  METHOD ADD_INDEX.
    cv_index = cv_index + c_step_index.
  ENDMETHOD.                    "ADD_INDEX


  METHOD ADD_PARA_VAL.
    DATA ls_body_line TYPE ts_index_str.


    ls_body_line-line = ` <div> <p> `.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

    ls_body_line-line = `<strong>` && iv_id && `: </strong>`.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

    ls_body_line-line = `<em>` && iv_value && `</em>`.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

    ls_body_line-line = ` </p></div>`.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

  ENDMETHOD.                    "ADD_PARA_VAL


  METHOD ADD_PARA_VAL_CH.
    DATA lv_id TYPE text20.
    DATA lv_value TYPE text200.

    lv_id = iv_id.
    lv_value = iv_value.

    me->add_para_val(
      EXPORTING
        iv_id    = lv_id
        iv_value = lv_value
    ).

    ro_obj = me.

  ENDMETHOD.                    "ADD_PARA_VAL_CH


  METHOD ADD_TAB.

    DATA ls_body_line TYPE ts_index_str.

    DATA lo_desc_table    TYPE REF TO cl_abap_tabledescr.
    DATA lo_desc_struc    TYPE REF TO cl_abap_structdescr.
    DATA lv_text255 TYPE text255.


    FIELD-SYMBOLS <fs_component> TYPE abap_compdescr.
    FIELD-SYMBOLS <fs_itab> TYPE any.
    FIELD-SYMBOLS <fs_field> TYPE any.


    lo_desc_table ?= cl_abap_tabledescr=>describe_by_data( it_tab ).
    lo_desc_struc ?= lo_desc_table->get_table_line_type( ).


    ls_body_line-line = ` <div> <table id="table_id" class="display"> `.
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

    " добавляем заголовок
    ls_body_line-line = `<thead> <tr>` .
    add_index( CHANGING cv_index = ls_body_line-index ).
    add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).
    LOOP AT lo_desc_struc->components ASSIGNING <fs_component>.
*      ls_body_line-line = `<th>` .
*      add_index( CHANGING cv_index = ls_body_line-index ).
*      add_html_line( CHANGING ct_block = mt_body cs_line = ls_body_line ).

      add_body_line( iv_line = '<th>' ).
      add_body_line( iv_line =  <fs_component>-name ).
      add_body_line( iv_line = '</th>' ).

    ENDLOOP.

    add_body_line( iv_line = '<tbody>' ).



    LOOP AT it_tab ASSIGNING <fs_itab>.
      add_body_line( iv_line = '<tr>' ).
      LOOP AT lo_desc_struc->components ASSIGNING <fs_component>.
        add_body_line( iv_line = '<td>' ).
        ASSIGN COMPONENT <fs_component>-name OF STRUCTURE <fs_itab> TO <fs_field>.
        IF sy-subrc EQ 0.
          lv_text255 = <fs_field>.
          add_body_line( iv_line = lv_text255 ).
        ENDIF.
        add_body_line( iv_line = '</td>' ).
      ENDLOOP.
      add_body_line( iv_line = '</tr>' ).
    ENDLOOP.
    add_body_line( iv_line = '</tbody>' ).
    add_body_line( iv_line = '</table>' ).
    add_body_line( iv_line = '</div>' ).


  ENDMETHOD.                    "ADD_TAB


  METHOD ADD_TAB_CH.
    me->add_tab( it_tab = it_tab ).
    ro_obj = me.

  ENDMETHOD.                    "ADD_TAB_CH


  METHOD CONSTRUCTOR.
    me->mv_title_win = iv_title.
    fill_default_head( iv_title = iv_title ).
    CLEAR mt_body.
    add_html_menu( ).
  ENDMETHOD.                    "CONSTRUCTOR


  METHOD FILL_DEFAULT_HEAD.
    DATA ls_head TYPE ts_index_str.

    CLEAR mt_head.

    ls_head-index = 10.
    ls_head-line = '<!DOCTYPE html><html lang="ru">'.
    add_html_line( CHANGING ct_block = mt_head cs_line = ls_head ).
    add_index( CHANGING cv_index = ls_head-index ).
    ls_head-line = '<head>'.
    add_html_line( CHANGING ct_block = mt_head cs_line = ls_head ).
    add_index( CHANGING cv_index = ls_head-index ).
    ls_head-line = `<title>` && iv_title && `</title>`.
    add_html_line( CHANGING ct_block = mt_head cs_line = ls_head ).
    add_index( CHANGING cv_index = ls_head-index ).

*    add_head_line( iv_line = '<link rel="stylesheet" type="text/css"' ).
*    add_head_line( iv_line = 'href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.css">' ).
*    add_head_line( iv_line = '<script type="text/javascript" charset="utf8" ' ).
*    add_head_line( iv_line = 'src="https://code.jquery.com/jquery-3.3.1.js"></script>' ).
*    add_head_line( iv_line = '<script type="text/javascript" charset="utf8" ' ).
*    add_head_line( iv_line = 'src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.js"></script>' ).
    add_head_line( iv_line = '<style>' ).
    add_head_line( iv_line = 'table, th, td {').
    add_head_line( iv_line = 'border: 1px solid black;' ).
    add_head_line( iv_line = '}' ).
    add_head_line( iv_line = '</style>' ).
    add_head_line( iv_line = '</head>' ).

  ENDMETHOD.                    "FILL_DEFAULT_HEAD


  METHOD GET_HTML_TAB.
    DATA ls_html_line TYPE cl_abap_browser=>html_line.
    FIELD-SYMBOLS <fs_line> LIKE LINE OF mt_head.

    CLEAR rt_val[].
    LOOP AT mt_head ASSIGNING <fs_line>.
      CLEAR ls_html_line.
      ls_html_line = <fs_line>-line.
      APPEND ls_html_line TO rt_val.
    ENDLOOP.

    APPEND '<body>' TO rt_val.



    LOOP AT mt_body ASSIGNING <fs_line>.
      CLEAR ls_html_line.
      ls_html_line = <fs_line>-line.
      APPEND ls_html_line TO rt_val.
    ENDLOOP.

    APPEND '</body>' TO rt_val.
    APPEND '</html>' TO rt_val.

  ENDMETHOD.                    "GET_HTML_TAB


  METHOD GET_INSTANCE.
    IF mo_html IS BOUND.
    ELSE.
      " lazy initialization
      " то есть не при загрузке класса
      " а в момент первого обращения
      CREATE OBJECT mo_html
        EXPORTING
          iv_title = iv_title.
    ENDIF.
    ro_obj = mo_html.
  ENDMETHOD.                    "GET_INSTANCE


  METHOD ON_HTML_SAPEVENT.
    RAISE EVENT html_action EXPORTING ev_action = action.
  ENDMETHOD.                    "ON_HTML_SAPEVENT


  METHOD SHOW.
    DATA lt_html_errors TYPE STANDARD TABLE OF text255.

    SET HANDLER on_html_sapevent.


    cl_abap_browser=>show_html(
      EXPORTING
        html         =  me->get_html_tab( )  " HTML Table, Line Width 255 Characters
        title        =  me->mv_title_win   " Window Title
*        size         = CL_ABAP_BROWSER=>MEDIUM    " Size (S,M.L,XL)
        modal        = abap_true    " Display as Modal Dialog Box
*        html_string  =     " HTML String
*        printing     = ABAP_FALSE
         buttons      = cl_abap_browser=>navigate_html
*        format       = CL_ABAP_BROWSER=>LANDSCAPE    " Landscape/portrait format
*        position     = CL_ABAP_BROWSER=>TOPLEFT    " Position
*        data_table   =     " External data
*        anchor       =     " Goto Point
*        context_menu = ABAP_FALSE    " Display context menu in browser
*        html_xstring =     " HTML Binary String
*        check_html   = ABAP_TRUE    " Test of HTML File
*        container    =
      IMPORTING
        html_errors  = lt_html_errors    " Error List from Test
    ).
  ENDMETHOD.                    "SHOW


  METHOD SHOW_XML.
    DATA lt_html_errors TYPE STANDARD TABLE OF text255.

    SET HANDLER on_html_sapevent.


    cl_abap_browser=>show_xml(
      EXPORTING
        xml_string   =   IV_XML  " XML in String
*        xml_xstring  =     " XML in XString
*        title        =     " Window Title
*        size         = CL_ABAP_BROWSER=>MEDIUM    " Size (S,M.L,XL)
*        modal        = ABAP_TRUE    " Display as Modal Dialog Box
*        printing     = ABAP_FALSE
*        buttons      = NAVIGATE_OFF    " Navigation Keys navigate_...
*        format       = CL_ABAP_BROWSER=>LANDSCAPE    " Landscape/portrait format
*        position     = CL_ABAP_BROWSER=>TOPLEFT    " Position
*        context_menu = ABAP_FALSE    " Display context menu in browser
*        container    =
    ).
  ENDMETHOD.                    "SHOW
ENDCLASS.
