
INITIALIZATION.
  CREATE OBJECT go_u.


AT SELECTION-SCREEN.
  gs_scr-s_trreq[] = s_trreq[].
  gs_scr-s_trreqi[] = s_trreqi[].
  gs_scr-remote = remote.

  go_u->at_sel_scr( EXPORTING
        iv_ucomm = sy-ucomm
        is_scr = gs_scr ).

START-OF-SELECTION.
  go_u->main( ).



END-OF-SELECTION.
  go_u->output( ).
