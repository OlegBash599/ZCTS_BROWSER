
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_trreq FOR gs_e070-trkorr ,
  s_trreqi FOR gs_e070-trkorr MATCHCODE OBJECT ZSHBC_009_ZVBC009_E070
  .

PARAMETERS:   remote TYPE char1 AS CHECKBOX DEFAULT 'X'
            , no_dis TYPE char1 DEFAULT '' NO-DISPLAY
            .

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" see comment in TMS_TP_IMPORT
PARAMETERS: VERS_IGN TYPE ZEBC009_VERS_IGNORE DEFAULT 'Y'
  .
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

SELECTION-SCREEN END OF BLOCK b01.
