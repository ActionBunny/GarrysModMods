@echo off

REM Create
cd G:\Games\Steam\steamapps\common\GarrysMod\bin
gmpublish.exe create -addon %~n1.gma -icon "menzek_workshop.jpg"
pause
