
TYPES: BEGIN OF ts_screen
        , s_trreq TYPE RANGE OF trkorr
        , s_trreqi TYPE RANGE OF trkorr
        , remote TYPE char1
      , END OF ts_screen
      .

DATA gs_e070 TYPE e070.


DATA gs_scr TYPE ts_screen.

CLASS lcl_u DEFINITION DEFERRED.
DATA go_u TYPE REF TO lcl_u.
