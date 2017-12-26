@ECHO OFF
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