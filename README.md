# ZCTS_BROWSER: ZCTS002 version
ZCTS_BROWSER for Object Transporting
<h2>Characteristics: </h2>
<ol type="1">
  <li>transport of copies without version generation</li>
  <li>transport of copies for both customizing and workbench requests</li>
  <li>get list of transports via search help</li>
  <li>working via simple report</li>
</ol>
=========================================================== <BR>
=========================================================== <BR>
<h2>prerequisites: </h2>
<ol type="1">
  <li>Just import package into the source system and target system</li>
  <li>RFC-connection between source and target systems should be created</li>
  <li>RFC-connection information should be added into the report **ZREP_CTS002_TRANSCOPY** with help of button _TargetSys (ZTCTS002_DESTSYS)_ which is on the toolbar near launch button</li>
  <li>You should have authorization to launch report and access to target system</li>
  <li>No web dynpro</li>
</ol>  

<h4>What was optimized/improved compared to version1 ( is here: https://github.com/OlegBash599/ZCTS_BROWSER_v1 ): </h4>
  <ol type="1">
  <li>No more PyRFC is needed</li>
  <li>No more webDynpro is needed </li>
  <li>Some old functions (TMS*) was replaced by new functions (TMS_MGR* )</li>
  <li>Customizing options are added</li>
  <li>Old unused code is removed</li>
  <li>Option to **create TOC only** or **create and transport TOC** are on the selection screen for now</li>
  <li>List of opened transports could be read via search help. No need to go anywhere else for reading.</li>
</ol> 


==========================RUSSIAN DESCRIPTION=================================
<h2>Функции: </h2>
<ol type="1">
  <li>перенос копий запросов без генерации версии: весь функционал через программу **ZREP_CTS002_TRANSCOPY**</li>
  <li>перенос запросов как для запросов customizing так и для запросов workbench</li>
  <li>получение списка запросов через средство поиска прямо в отчете</li>
  <li>минималистский/легкий дизайн</li>
</ol>
=========================================================== <BR>
=========================================================== <BR>
<h2>Требования и предпосылки: </h2>
<ol type="1">
  <li>Между исходной и целевой системой должно быть настроено RFC-соединение</li>
  <li>RFC соединение должно быть добавлено в таблицу ZTCTS002_DESTSYS: доступно в программе **ZREP_CTS002_TRANSCOPY** с помощью кнопки _TargetSys (ZTCTS002_DESTSYS)_</li>
  <li>У пользователя должны быть полномочия на перенос запрос из исходной системы; а в целевой системе должны быть полномочия на импорт (у того пользователя, под которым открывается RFC-соединение)</li>
  <li>Web Dynpro-доступность удалена для легковестности активации и переноса между системами</li>
</ol>  

