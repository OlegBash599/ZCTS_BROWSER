*----------------------------------------------------------------------*
*       CLASS zcl_bc009_target_sysinfo DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS zcl_bc009_target_sysinfo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor.
    METHODS get_target_sys_name
        RETURNING value(rv_val) TYPE char10.
    METHODS get_target_rfc_name
        RETURNING value(rv_val) TYPE rfcdest.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_target_sys_info
            , rfcdest TYPE rfcdest
            , system TYPE char10
          , END OF ts_target_sys_info
          .

    DATA ms_target_system_info TYPE ts_target_sys_info.

ENDCLASS.



CLASS ZCL_BC009_TARGET_SYSINFO IMPLEMENTATION.


  METHOD constructor.
    " could be retrieved from z-table - up to you :-)

" help: -  с помощью этих параметров нужно добиться
        " 1) создания транспорта в корректную целевую систему === system
        " 2) отсутствия ввода пароля при переносе через STMS === rfcdest
        " справка в интернете (которая может навести на правильную мысль,
        " но до конца проблемы конкретной системы не решает)

        " https://answers.sap.com/questions/8163615/index.html
        " https://launchpad.support.sap.com/#/notes/761637
        " https://answers.sap.com/questions/11370395/stms-logon-screen.html
        " https://wiki.scn.sap.com/wiki/display/SMAUTH/S_CTS_ADMI
        " https://answers.sap.com/questions/10461597/password-popup-while-transporting-request.html
"

    " эти значения нужно поменять на RFC-адрес в целевую (тестовую систему)
    " и на имя системы для переносов -
*    "ms_target_system_info-rfcdest = 'RFC2SYS'.
*    ms_target_system_info-rfcdest = 'NONE'.
*    "ms_target_system_info-system = 'SYS'.
*    ms_target_system_info-system = 'NPL'.
    ms_target_system_info-rfcdest = 'UTSCLNT740'.
    ms_target_system_info-system = 'UTS'.

" вынести в отдельный класс
*    IF ms_target_system_info-rfcdest eq 'RFC2SYS'.
*    " if runtime error - you need to substitute errors
*      " если этот дамп произошел - то нужно менять значения выше на корректные
*      " если базис адекватный - то запросить у базиса
*      MESSAGE x000(cl).
*    ENDIF.

  ENDMETHOD.                    "constructor


  METHOD get_target_rfc_name.
    rv_val = ms_target_system_info-rfcdest.
  ENDMETHOD.                    "get_target_rfc_name


  METHOD get_target_sys_name.
    rv_val = ms_target_system_info-system.
  ENDMETHOD.                    "get_target_sys_name
ENDCLASS.
