@ECHO OFF
SET simps=%cd%
DEL /F /q %simps%\bkp_manutancao

ECHO ***********************************************************
ECHO *                                                         *
ECHO *           ANTES DE PROSEGUIR COM A MANUTENCAO           *
ECHO * CERTIFIQUE-SE QUE TODOS OS USUARIOS ESTAO FORA DO SIMPS *
ECHO *  E QUE O AGENDADOR E SUAS INTERFACES FORAM FINALIZADOS  *
ECHO *                                                         *
ECHO ***********************************************************

SET /P "confirma=Digite '1' para CONTINUAR ou '0' para CANCELAR: "
if [%confirma%]==[1] (goto inicio) else (exit)

:inicio
if NOT exist "%simps%\simps.fdb" (
CLS
ECHO *****************************************
ECHO *                                       *   
ECHO *   ARQUIVO SIMPS.FDB NAO ENCONTRADO    *
ECHO *          FAVOR VERIFICAR!             *
ECHO *                                       * 
ECHO *****************************************
PAUSE
EXIT
) ELSE (goto existe)


:existe
CLS
ECHO *********************
ECHO *                   *
ECHO * EFETUANDO BACKUP  *
ECHO *     AGUARDE...    *
ECHO *                   *
ECHO ********************* 
net stop "FirebirdServerDefaultInstance"
taskkill /f /im fb_inet_server.exe

REN simps.fdb _simps.fdb

ROBOCOPY %simps% %simps%\bkp_manutancao _simps.fdb
CD %simps%\bkp_manutancao
REN _simps.fdb bkp_simps-%date:/=.%.fdb
CD %simps%

if NOT exist "%simps%\bkp_manutancao\bkp_simps-%date:/=.%.fdb" (
CLS
ECHO *******************************
ECHO *                             * 
ECHO *  ERRO AO REALIZAR O BACKUP  *
ECHO *                             *
ECHO *******************************
) else (goto continuar)

:continuar
CLS
ECHO *****************************************
ECHO *                                       *   
ECHO *   VERIFICAR SE FOI GERADO O ARQUIVO   *
ECHO *    # bkp_simps-%date:/=.%.fdb #       *
ECHO *             NA PASTA                  * 
ECHO -----------------------------------------
ECHO  %simps%\bkp_manutancao
ECHO -----------------------------------------
ECHO *  E O .FDB TEM TAMANHO IGUAL AO BANCO  * 
ECHO *                                       * 
ECHO *****************************************
SET /P "confirma=Se tudo estiver ok digite 'okay' para proseguir: "
if [%confirma%]==[okay] (goto manut) else (exit)

:manut
CLS
ECHO *****************************
ECHO *                           * 
ECHO *  INICIANDO A MANUTENCAO   *
ECHO *                           *
ECHO *****************************
net start "FirebirdServerDefaultInstance"
SET ISC_USER=SYSDBA
SET ISC_PASSWORD=masterkey
@ECHO ON
gfix -v -full _simps.fdb
gfix -mend -full -ignore _simps.fdb
gbak -backup -v -ignore -garbage _simps.fdb simps.fbk
@ECHO OFF
if NOT ["%errorlevel%"]==["0"] (goto erro)
@ECHO ON
gbak -create -v -use_all_space simps.fbk SIMPSNOVO.fdb
@ECHO OFF
if NOT ["%errorlevel%"]==["0"] (goto erro)
@ECHO ON
gfix -v -full SIMPSNOVO.fdb
@ECHO OFF
if NOT ["%errorlevel%"]==["0"] (goto erro)  else (goto final)

:erro
@ECHO OFF
ECHO *****************************************
ECHO *                                       * 
ECHO *  OCORERAM ERROS DURANTE A MANUTENCAO  *
ECHO *          FAVOR VERIFICAR!             *
ECHO *                                       *
ECHO *****************************************
pause
exit


:final
net stop "FirebirdServerDefaultInstance"
taskkill /f /im fb_inet_server.exe
DEL /F simps.fbk
DEL /F _simps.fdb
REN SIMPSNOVO.fdb SIMPS.FDB
net start "FirebirdServerDefaultInstance"
ECHO ***************************
ECHO *                         * 
ECHO *  MANUTENCAO CONCLUIDA,  *
ECHO *  FAVOR TESTAR O SIMPS!  *
ECHO *                         *
ECHO ***************************
PAUSE
EXIT
