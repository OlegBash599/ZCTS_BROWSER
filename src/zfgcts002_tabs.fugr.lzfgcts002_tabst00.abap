*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTCTS002_DESTSYS................................*
DATA:  BEGIN OF STATUS_ZTCTS002_DESTSYS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTCTS002_DESTSYS              .
CONTROLS: TCTRL_ZTCTS002_DESTSYS
            TYPE TABLEVIEW USING SCREEN '4000'.
*.........table declarations:.................................*
TABLES: *ZTCTS002_DESTSYS              .
TABLES: ZTCTS002_DESTSYS               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
