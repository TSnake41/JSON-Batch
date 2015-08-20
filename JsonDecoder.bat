:: The MIT License (MIT)
:: 
:: Copyright (c) 2015 TSnake41
:: 
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
:: 
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
:: 
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
:: THE SOFTWARE.

@Echo off
setlocal EnableDelayedExpansion EnableExtensions
:: Test du LpL
set test={"TestString":"Value",}

:: Variables de sortie
REM Le prefix des variables générées.
set Prefix=root.
REM Le délimiteur de variable
set VarDelim=.
REM Exemple (Prefix:root., VarDelim:.) fera pour la variable b dans a: 
REM * root.a.b

:: Internal
REM Nombre d'appels de variables sur la pile.
REM Sert de pointeur pour les noms de variables.
set /a StackCount=0

REM Liste des états de lecture:
REM 0: Lecture de rien,
REM 1: Lecture d'un nom de variable,
REM 2: Lecture de la valeur d'une variable
set /a ReadingState=0

set IsReadString=0

REM Buffer de lecture
REM Permet de créer une valeur avec une série de lettres (LpL).
set ReadBuffer=

set VarLabel=
set VarValue=
set CurretStack=

:: Partie de code LpL
for /L %%A in (0,1,4096) do (
    echo !test:~%%A,1!
    REM Permet de quitter la boucle si on est a la fin du fichier.
    if "!test:~%%A,1!" == "" goto:End
    REM Partie JSON
    if "!test:~%%A,1!" == "{" (
        REM '}' permet d'ouvrir un objet (utilisation de stack)
        echo Objet trouve: %CurretVarName%
        set /a StackCount+=1
        set ReadingState=1
        REM TODO: Add object to stack.
    ) 
    if "!test:~%%A,1!" == "}" (
        REM '}' permet de fermer un objet (utilisation de stack)
        echo Objet ferme.
        set /a StackCount-=1
        
        echo Changement de variable
        set VarValue=%ReadBuffer%
        set "ReadBuffer="
        echo %Prefix%%VarLabel% aloué avec la valeur: %VarValue%
        set %Prefix%%VarLabel%=%VarValue%
        set VarLabel=
        set VarValue=
        set ReadingState=1
        REM TODO: Add object update.
    ) 
    if "!test:~%%A,1!" == ":" (
        REM ':' permet de définir la variable
        echo En attente de lecture d'une variable
        set  VarLabel=%ReadBuffer%
        set "ReadBuffer="
        set  ReadingState=2
    ) 
    if "!test:~%%A,1!" == "," (
        echo Changement de variable
        set VarValue=%ReadBuffer%
        set "ReadBuffer="
        echo %Prefix%%VarLabel% aloué avec la valeur: %VarValue%
        set %Prefix%%VarLabel%=%VarValue%
        set VarLabel=
        set VarValue=
        set ReadingState=1
        REM ArrayIndex+=1
    )
    REM Probleme ICI
    if "!test:~%%A,1!"=="""" (
	   echo Double quote found
       if %IsReadString% EQU 0 (
          set IsReadString=1
       ) else (
          set IsReadString=0
       )
    )
    
    if ReadingState NEQ 0 ( 
            if IsReadString EQU 1 (
        set ReadBuffer=%ReadBuffer%!test:~%%A,1!
        echo %ReadBuffer%
    ) else (
         set ReadBuffer=%ReadBuffer%!test:~%%A,1!
        )
    )

)
:End
pause
set
set Read
pause
exit /b
