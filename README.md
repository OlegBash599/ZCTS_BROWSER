# ZCTS_BROWSER: NetWeaver Object Transporting
ZCTS_BROWSER for Object Transporting with TOC (transport of copies)
Latest version: ZCTS002
<h2>Characteristics: </h2>
<ol type="1">
  <li>transport of copies without version generation</li>
  <li>transport of copies for both customizing and workbench requests</li>
  <li>get list of transports via search help</li>
  <li>working via simple report ZREP_CTS002_TRANSCOPY </li>
</ol>
=========================================================== <BR>
=========================================================== <BR>
<h2>Prerequisites: </h2>
<ol type="1">
  <li>Just import package into the source system and target system</li>
  <li>RFC-connection between source and target systems should be created</li>
  <li>RFC-connection information should be added into the report **ZREP_CTS002_TRANSCOPY** with help of button _TargetSys (ZTCTS002_DESTSYS)_ which is on the toolbar near launch button</li>
  <li>You should have authorization to launch report and access to target system</li>
  <li>No web dynpro</li>
  <li>Launch ZREP_CTS002_TRANSCOPY, do TOC, and enjoy yourself with saving time :-)</li>
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
  <li>Импортируйте пакет ZCTS002 в исходную систему и в целевую систему.</li>
  <li>Между исходной и целевой системой должно быть настроено RFC-соединение</li>
  <li>В исходной системе RFC-соединение должно быть добавлено в таблицу ZTCTS002_DESTSYS: доступно в программе **ZREP_CTS002_TRANSCOPY** с помощью кнопки _TargetSys (ZTCTS002_DESTSYS)_</li>
  <li>У пользователя должны быть полномочия на перенос запрос из исходной системы; а в целевой системе должны быть полномочия на импорт (у того пользователя, под которым открывается RFC-соединение)</li>
  <li>Web Dynpro-доступность удалена для легковестности активации и переноса между системами</li>
  <li>Запустите отчет ZREP_CTS002_TRANSCOPY, перенести TOC в один клик, и будьте довольны и счастливы :-)</li>
</ol>  


<h4>Что улучшено по сравнению с версией1 (ZBC009) ( is here: https://github.com/OlegBash599/ZCTS_BROWSER_v1 ): </h4>
  <ol type="1">
  <li>Модуль PyRFC больше не требуется; работа через отчет **ZREP_CTS002_TRANSCOPY** </li>
  <li>Функциональность webDynpro исключена</li>
  <li>Старые ФМы (TMS*) были заменены на новые ФМы (TMS_MGR* ) (именно так сделал стандарт в своем функционале, поэтому пришлось соответствовать; в старых ФМах проблем не было)</li>
  <li>Добавлена возможность кастомизации</li>
  <li>Неиспользуемый код/комментарии были удалены</li>
  <li>Опция **либо создать только TOC** or **либо создать TOC и импортировать в целевую систему** добавлена на селекционный экран</li>
  <li>Список открытых транспортных запросов можно получить через средство поиска. Для проверки номера запроса с описанием не нужно ходить в другие транзакции.</li>
</ol> 
  

 Support via email: F1base@olegbash.ru
  
