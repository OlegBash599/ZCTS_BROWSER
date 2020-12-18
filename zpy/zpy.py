import os
from pyrfc import Connection
import npl_login as npl_login


ABAP_TRUE = 'X'


def sh():
    do_ask4mode = True

    while do_ask4mode:
        run_ask_mode = ask_mode()
        if run_ask_mode == 'e' or run_ask_mode == 'exit':
            do_ask4mode = False
        if run_ask_mode == 'c' or run_ask_mode == 'current':
            move_current_variant()
        if run_ask_mode == 'l' or run_ask_mode == 'list':
            print_list()
        if run_ask_mode == 'r' or run_ask_mode == 'request':
            move_requests()
    print('Bye!')



def ask_mode():
    lv_val = 'e'
    #os.system('cls')
    print('e/exit; c/current; l/list; r/request; ')
    lv_val = str(input("Mode?    "))
    return lv_val


def move_current_variant():
    npl_login.set_target_sys('NPL_DEMO')
    conn = Connection(user=npl_login.get_user_name(),
                      passwd=npl_login.get_pass(),
                      ashost=npl_login.get_host(),
                      sysnr=npl_login.get_sap_num(),
                      client=npl_login.get_sap_mandant())
    result = conn.call('Z_BC009_PY_INPUT', IV_DO_CURRENT=ABAP_TRUE)
    return_msg = result.get('RC_TXT')
    print(return_msg)


def move_requests():
    req_line = ''
    req_line = str(input("TR1,TR2?    "))
    if req_line is None:
        return
    if req_line == 'e':
        return
    npl_login.set_target_sys('NPL_DEMO')
    conn = Connection(user=npl_login.get_user_name(),
                      passwd=npl_login.get_pass(),
                      ashost=npl_login.get_host(),
                      sysnr=npl_login.get_sap_num(),
                      client=npl_login.get_sap_mandant())
    result = conn.call('Z_BC009_PY_INPUT', IV_REQ_LIST=req_line)
    return_msg = result.get('RC_TXT')
    print(return_msg)


def print_list():
    npl_login.set_target_sys('NPL_DEMO')
    conn = Connection(user=npl_login.get_user_name(),
                      passwd=npl_login.get_pass(),
                      ashost=npl_login.get_host(),
                      sysnr=npl_login.get_sap_num(),
                      client=npl_login.get_sap_mandant())
    result = conn.call('Z_BC009_PY_INPUT', GET_MY_LIST=ABAP_TRUE)
    request_list = result.get('REQ_LIST')

    for request_info in request_list:
        print(f"{request_info.get('TRKORR')} | {request_info.get('AS4TEXT')}")

    return_msg = result.get('RC_TXT')
    print(return_msg)

