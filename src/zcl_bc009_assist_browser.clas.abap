class ZCL_BC009_ASSIST_BROWSER definition
  public
  inheriting from CL_WD_COMPONENT_ASSISTANCE
  create public .

public section.

*"* public components of class ZCL_BC009_ASSIST_BROWSER
*"* do not include other source files here!!!
  constants CON_SAP_CTS_PROJECT type TRATTR value 'SAP_CTS_PROJECT'. "#EC NOTEXT
  constants CON_PARAMETER_CLIENT type STRING value 'CLIENT'. "#EC NOTEXT
  constants CON_PARAMETER_SERVER type STRING value 'SERVER'. "#EC NOTEXT
  constants CON_PARAMETER_CLIENT_ONLY type STRING value 'CLIENT_ONLY'. "#EC NOTEXT
  constants CON_PARAMETER_SERVER_ONLY type STRING value 'SERVER_ONLY'. "#EC NOTEXT
  constants CON_FILE_OBJECT type STRING value 'FILE'. "#EC NOTEXT
  constants CON_X type FLAG value 'X'. "#EC NOTEXT
  constants CON_CLIENT type STRING value 'CLIENT'. "#EC NOTEXT
  constants CON_SERVER type STRING value 'SERVER'. "#EC NOTEXT
  constants CON_XI_REPOSITORY type STRING value '1'. "#EC NOTEXT
  constants CON_XI_DIRECTORY type STRING value '2'. "#EC NOTEXT
  constants CON_RQSTAT_RELEASED type STRING value 'RELEASED'. "#EC NOTEXT
  constants CON_RQSTAT_MODIFIED type STRING value 'MODIFIED'. "#EC NOTEXT
  constants CON_OTHERS type STRING value '3'. "#EC NOTEXT
  constants CON_REQ_MODIFIABLE type STRING value 'DO'. "#EC NOTEXT
  constants CON_REQ_RELEASED type STRING value 'LORN'. "#EC NOTEXT
  constants CON_TAB_PROPERTIES type STRING value 'TAB_PROPERTIES'. "#EC NOTEXT
  constants CON_TAB_OBJECTS type STRING value 'TAB_OBJECTS'. "#EC NOTEXT
  constants CON_TAB_PROTOCOL_LIST type STRING value 'TAB_PROTOCOL_LIST'. "#EC NOTEXT
  constants CON_TAB_ATTRIBUTES type STRING value 'TAB_ATTRIBUTES'. "#EC NOTEXT
  constants CON_TAB_TEAM type STRING value 'TAB_TEAM'. "#EC NOTEXT

  methods UPDATE_SERVER_FILE
    importing
      !I_FILE_LOCATION type STRING
      !I_FILE_CONTENT type CTS_WD_FILE_ATTACHMENT-FILECONTENT
    returning
      value(R_ERROR_TEXT) type STRING .
  methods GET_ALL_PROJECTS
    importing
      !IV_SRCSYSTEM type FROMSYSTEM
      !IV_SRCCLIENT type TRCLIENT
    returning
      value(RT_PROJECTS) type CTS_PROJECT_TAB .
  methods SELECT_TRSTATUS
    importing
      !IV_TRKORR type TRKORR
    exporting
      !EV_TRSTATUS type TRSTATUS .
  methods SELECT_FILE_ATTRIBUTE
    importing
      !IV_ID type TROBJ_NAME
    exporting
      !EV_APPLICATION type SI_RQ_FILECNTRL-ATTRIBUTE_VALUE .
  methods SELECT_PHYSICAL_FILENAME
    importing
      !IV_ID type TROBJ_NAME
    exporting
      !EV_FILENAME type CTS_FILENAME .
  methods SELECT_ALL_APPLICATION_TYPES
    exporting
      !ET_APPLICATIONS type CTS_WD_APPLICATION_TYPES .
  methods CHECK_PROJECT_FOR_TRKORR
    importing
      !IV_TRKORR type TRKORR
    exporting
      !EV_SUBRC type SY-SUBRC .
*"* protected components of class ZCL_BC009_ASSIST_BROWSER
*"* do not include other source files here!!!
protected section.
private section.
*"* private components of class ZCL_BC009_ASSIST_BROWSER
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_BC009_ASSIST_BROWSER IMPLEMENTATION.


method CHECK_PROJECT_FOR_TRKORR.
data: l_trkorr_p TYPE trkorr_p.

*--- check if project is allowed.
    SELECT trkorr INTO l_trkorr_p
           FROM  ctsprjc_f4
           WHERE  trkorr  = iv_trkorr.
    ENDSELECT.
    ev_subrc = sy-subrc.
endmethod.


method GET_ALL_PROJECTS.
* data lt_ctsprjc_f4      type standard table of ctsprjc_f4.
  data lt_projects           type cts_project_tab.
  data lr_project            type ref to cts_project_str. "note 1555656
  data lv_description_length type i.                      "note 1583346

*--- get all the projects
  select trkorr externalid as description into table lt_projects "#EC CI_NOWHERE
            from  ctsprjc_f4                                     "#EC CI_NOWHERE
            where srcsystem IN (iv_srcsystem, sy-sysid) "note 1521843
            and   srcclient = iv_srcclient.             "note 1449540

  loop at lt_projects reference into lr_project. "begin of note 1555656
    clear lv_description_length.                               "begin of note 1583346
    lv_description_length = strlen( lr_project->description ).
    if lv_description_length <= 3.
      continue.
    endif.                                                     "end of note 1583346

    if lr_project->description+3(1) = '/'. " OTO - non-ABAP systems
      if lr_project->description(3) = iv_srcsystem.
        shift lr_project->description by 4 places left.
      else.
        delete lt_projects index sy-tabix.
      endif.
    endif.
  endloop.                                       "end of note 1555656

  SORT lt_projects BY trkorr ASCENDING.                         "note 1521843
  DELETE ADJACENT DUPLICATES FROM lt_projects COMPARING trkorr. "note 1521843

  rt_projects = lt_projects.

endmethod.


METHOD SELECT_ALL_APPLICATION_TYPES.
*---- Get all the application types
  SELECT appl~application text~description
                INTO TABLE et_applications
                FROM
                     ( cts_rq_applid AS appl
                       INNER JOIN cts_rq_applidt AS text
                       ON  text~application  = appl~application
                       AND language = sy-langu )
                       .

*--- if the descriptions are not available in the logon language switch to the
*--- english
  IF sy-subrc <> 0.
    SELECT appl~application text~description
                  INTO TABLE et_applications
                  FROM
                       ( cts_rq_applid AS appl
                         INNER JOIN cts_rq_applidt AS text
                         ON  text~application  = appl~application
                         AND language = 'EN' )
                         .
*--- English should always available...
  ENDIF.

* add 'generic' application types [hdf, 09/09]
  DATA: ls_applications   TYPE cts_wd_application_type,
        ls_cts_appltypet  TYPE cts_appltypet,
        lt_cts_appltypet  TYPE TABLE OF cts_appltypet.
  CALL FUNCTION 'TMS_READ_APPLTYPES'
    EXPORTING
      iv_with_text     = 'X'
    IMPORTING
      et_cts_appltypet = lt_cts_appltypet.
  LOOP AT lt_cts_appltypet INTO ls_cts_appltypet.
    ls_applications-application = ls_cts_appltypet-appl_type.
    ls_applications-description = ls_cts_appltypet-description.
    APPEND ls_applications TO et_applications.
  ENDLOOP.
  SORT et_applications.

ENDMETHOD.


method SELECT_FILE_ATTRIBUTE.

*--- Get the application...
      SELECT SINGLE attribute_value INTO ev_application "#EC *
             FROM   si_rq_filecntrl
             WHERE  id              = iv_id
             AND    attribute_name  = 'APPLICATION'.  "ctsc_file_attrib_application.

endmethod.


method SELECT_PHYSICAL_FILENAME.
* File name
      SELECT SINGLE  physname INTO ev_filename
                     FROM  si_rq_content
                     WHERE  id  = iv_id.

endmethod.


method SELECT_TRSTATUS.
*--- get the status of the request
    select single trstatus into ev_trstatus from  e070"#EC - number is not used in the table
           where  trkorr    = iv_trkorr.

endmethod.


method UPDATE_SERVER_FILE.
    data:
       l_string           type string
      ,l_server_filename  type string
*--- exception handling
      ,lf_cx_root           type ref to cx_root.


  l_server_filename = i_file_location.

  try.
*--- open for read.
      clear l_string.
      open dataset l_server_filename for output in binary mode. "We want to write string
      if sy-subrc <> 0.
*--- normal error handling
        l_string = if_wd_component_assistance~get_text( '033' ).
        exit.
      endif.

*--- catch...
    catch cx_sy_file_open into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

    catch cx_sy_codepage_converter_init into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

    catch cx_sy_conversion_codepage into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

    catch cx_sy_file_authority  into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

    catch cx_sy_pipes_not_supported  into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

    catch cx_sy_too_many_files   into lf_cx_root.
      l_string = lf_cx_root->get_text( ).

  endtry.

*--- if there was no error....
  if l_string is initial.
*--- write a temporary file
    transfer i_file_content to l_server_filename.
*--- and close it
    try.
        clear l_string.
        close dataset l_server_filename.
*---
      catch cx_sy_file_close     into lf_cx_root.
        l_string = lf_cx_root->get_text( ).
    endtry.
  endif.

  r_error_text = l_string.
endmethod.
ENDCLASS.
