# ZCTS_BROWSER: ABAP / Python / webDynPro 
ZCTS_BROWSER for Object Transporting
<h2>Characteristics: </h2>
<ol type="1">
  <li>transport of copies without version generation</li>
  <li>transport of copies for both customizing and workbench requests</li>
  <li>get list of transports and start import via Python console with pynwrfc</li>
</ol>
=========================================================== <BR>
=========================================================== <BR>
<h2>prerequisites: </h2>
<ol type="1">
  <li>WebDynpro is supported</li>
  <li>Function <b>Z_BC009_TMS_TP_IMPORT</b> should be tranposrted into test/target system;  RFC-connection should exist with the system. User which is transporting the request should have authorization  <b>S_TRANSPRT</b> </li>
  <li>in class <b>ZCL_BC009_TARGET_SYSINFO</b> it is necessary to specify: name and RFC-connection.</li>
  <li>for initial testing purposes the report exists <b>ZBC_009REP_TRANSPORT_LIGHT</b>. After that web version could be used with no problems</li>
</ol>  

<h2>prerequisites for ZPY-function </h2>
<ol type="1">
  <li>Python is installed</li>
  <li>pynwrfc is installed. It is described  https://sap.github.io/PyRFC/install.html </li>
</ol> 

==========================RUSSIAN DESCRIPTION=================================
<h2>Функции: </h2>
<ol type="1">
  <li>перенос копий запросов без генерации версии</li>
  <li>включение транспортных запросов не только инструментальных, но и запросов настройки</li>
  <li>получение списка транспортов и запуск импорта в тест через Python-console</li>
</ol>
=========================================================== <BR>
=========================================================== <BR>
<h2>Требования и предпосылки: </h2>
<ol type="1">
  <li>Компоненты WebDynPro должны поддерживаться системой</li>
  <li>Функциональный модуль <b>Z_BC009_TMS_TP_IMPORT</b> должен быть донесен до теста (или до системы, в которую нужно переносить транспортный запрос); также должно быть создано RFC-соединение с этой системой. У пользователя, под которым делается перенос должен быть объект полномочий  <b>S_TRANSPRT</b> </li>
  <li>в классе <b>ZCL_BC009_TARGET_SYSINFO</b> нужно прописать настройки целевой системы: имя и RFC-соединение.</li>
  <li>первые запуски делать на программе <b>ZBC_009REP_TRANSPORT_LIGHT</b> - если при прогоне этой программы запросы-копии создаются и переносятся до целевой системы, то можно считать, что настройка произведена успешно. если нет - то необходимо успешно настроить все и только потом переходить к использованию web-версии.</li>
</ol>  

<h2>Для работы части ZPY </h2>
<ol type="1">
  <li>Python3 (чем выше, тем лучше) установлен на рабочей машине </li>
  <li> Библиотека pynwrfc установлена как описано тут https://sap.github.io/PyRFC/install.html </li>
</ol> 
