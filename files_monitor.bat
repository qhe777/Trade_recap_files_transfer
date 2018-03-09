@echo off
setlocal ENABLEDELAYEDEXPANSION
set mypath=C:\mypath
set readfilebat=%mypath%\pull.txt
set ftpdir=%mypath%\filesinfo.txt
set mydate=%date:~10,4%.%date:~4,2%.%date:~7,2%
set datapath=%mypath%\%mydate%

echo "%date%, %time%">> C:\C:\mypath\pulllog.log

set /A brokernumber=1

set brokeruniverse[1]=mybroker
set hostuniverse[1]=myhost
set loginuniverse[1]=mylogin
set pwuniverse[1]=mypassword
set portuniverse[1]=22
set remotepath[1]=/

set month=%date:~4,2%
set myday=%date:~7,2%
if %month%==01 set mymonth=Jan
if %month%==02 set mymonth=Feb
if %month%==03 set mymonth=Mar
if %month%==04 set mymonth=Apr
if %month%==05 set mymonth=May
if %month%==06 set mymonth=Jun
if %month%==07 set mymonth=Jul
if %month%==08 set mymonth=Aug
if %month%==09 set mymonth=Sep
if %month%==10 set mymonth=Oct
if %month%==11 set mymonth=Nov
if %month%==12 set mymonth=Dec
for /L %%i in (1,1,%brokernumber%) do (
  echo dir !remotepath[%%i]!> %readfilebat%
  echo quit>> %readfilebat%
  

  set myhost=!hostuniverse[%%i]!
  set mylogin=!loginuniverse[%%i]!
  set mypassword=!pwuniverse[%%i]!
  set myport=!portuniverse[%%i]!

  set /A filesnum=0
  for /F "skip=4 tokens=6-9 delims= " %%a in ('psftp -b %readfilebat% -pw !mypassword! -P !myport! !mylogin!@!myhost!') do (    
    REM ----------------------------
    if %%a==Jan (
      if %%b==17 (
        set /A filesnum+=1
        set output[!filesnum!]=%%d
      )
    )
    REM ----------------------------
  )
  echo !output[1]!
  echo !filesnum!>> C:\C:\mypath\pulllog.log
  if not !filesnum!==0 (
    set datafile=%datapath%_%brokeruniverse[%%i]%
    md %datafile%
    echo lcd %datafile%> %readfilebat%
    for /L %%n in (1,1,!filesnum!) do (
      echo get !remotepath[%%i]!/!output[%%n]!>> %readfilebat%
      set output[%%n]=
    )
    echo quit>> %readfilebat%
    psftp -b %readfilebat% -pw !mypassword! -P !myport! !mylogin!@!myhost!
    start /w matlab -r "cd('C:\mypath\trade_recap.m');try;get_recap_2;catch Me;disp(['Error: ', Me.message]);end;exit"
  )
  del %readfilebat%

)

