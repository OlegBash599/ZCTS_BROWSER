*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_DATA
*&---------------------------------------------------------------------*


TYPES: BEGIN OF ts_screen
*        , s_trreq TYPE RANGE OF trkorr
        , s_trreqi TYPE RANGE OF trkorr
*        , remote TYPE char1
        , rfcdest TYPE rfcdest
        , version_ignore TYPE char1
        , toctrans TYPE char1
      , END OF ts_screen
      .

DATA gs_scr TYPE ts_screen.

TABLES sscrfields.

CLASS lcl_app DEFINITION DEFERRED.
DATA lo_app TYPE REF TO lcl_app.
