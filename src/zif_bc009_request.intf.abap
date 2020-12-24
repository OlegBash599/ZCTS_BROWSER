interface ZIF_BC009_REQUEST
  public .


  constants MC_N type SEOCLSNAME value 'ZIF_BC009_REQUEST'. "#EC NOTEXT

  methods MOVE_AS_COPY
    importing
      !IV_TRKORR type TRKORR
    raising
      resumable(ZCX_BC009_REQUEST) .
  methods SET_TARGET
    importing
      !IV_TRG_SYS type SYSYSID .
endinterface.
