@echo off

SET /P inputid= Please enter an id:
REM Update
REM gmpublish.exe update -id %_inputid% -addon %~f1.gma -icon "menzek_workshop.jpg" -changes ""

REM gmpublish.exe update -id "860794236" -addon %~n1.gma -icon menzek_workshop.jpg -changes ""
cd G:\Games\Steam\steamapps\common\GarrysMod\bin
gmpublish.exe update -id %inputid% -addon %~n1.gma -icon menzek_workshop.jpg -changes ""
pause