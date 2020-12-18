TARGET_SYS = ''
USER_NAME = 'USER'
PASSWORD = 'Password'
HOST_SAP_SYS = 'ip_address'
NUM_SAP_SYS = '00'
SYS_CLIENT = '400'


def set_target_sys(iv_sys_alias):
    TARGET_SYS = iv_sys_alias


def get_user_name():
    return USER_NAME


def get_pass():
    return PASSWORD


def get_host():
    return HOST_SAP_SYS


def get_sap_num():
    return NUM_SAP_SYS


def get_sap_mandant():
    return SYS_CLIENT