
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_trreq FOR gs_e070-trkorr,
  s_trreqi FOR gs_e070-trkorr
  .

PARAMETERS:   remote TYPE char1 AS CHECKBOX DEFAULT 'X'
            , no_dis TYPE char1 DEFAULT '' NO-DISPLAY
            .

SELECTION-SCREEN END OF BLOCK b01.
