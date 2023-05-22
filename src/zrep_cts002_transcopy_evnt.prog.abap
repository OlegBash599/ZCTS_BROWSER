*&---------------------------------------------------------------------*
*& Include          ZREP_CTS002_TRANSCOPY_EVNT
*&---------------------------------------------------------------------*

INITIALIZATION.
  lo_app = new #( ).

at SELECTION-SCREEN.
  lo_app->at_sel_screen( ).

at SELECTION-SCREEN OUTPUT.
  lo_app->at_sel_screen_output( ).

START-OF-SELECTION.
  lo_app->start_of_sel( ).

end-OF-SELECTION.
  lo_app->end_of_sel( ).
