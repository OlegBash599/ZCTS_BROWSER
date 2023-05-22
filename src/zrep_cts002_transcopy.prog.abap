*&---------------------------------------------------------------------*
*& Report ZREP_CTS002_TRANSCOPY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZREP_CTS002_TRANSCOPY.

INCLUDE ZREP_CTS002_TRANSCOPY_data IF FOUND.
INCLUDE ZREP_CTS002_TRANSCOPY_scrn IF FOUND.


INCLUDE ZREP_CTS002_TRANSCOPY_cls01 IF FOUND. " do transport copy
INCLUDE ZREP_CTS002_TRANSCOPY_cls02 IF FOUND. " viem maintain
INCLUDE ZREP_CTS002_TRANSCOPY_cls99 IF FOUND. " app central in

INCLUDE ZREP_CTS002_TRANSCOPY_evnt IF FOUND.
