@echo off
REM Sanal mühit (venv) yaradılır
echo Sanal mühit yaradılır...
python -m venv venv

REM Sanal mühiti aktivləşdirir
echo Sanal mühit aktivləşdirilir...
call venv\Scripts\activate

REM Asılılıqları yükləyir
echo Asılılıqları yükləyirəm...
pip install -r requirements.txt

REM setup.py faylını tərtib et
echo Cython modullarını tərtib edirəm...
python setup.py build_ext --inplace

REM PyInstaller ilə icra edilə bilən fayl yaradır
echo PyInstaller ilə EXE faylı yaradılır...
pyinstaller --onefile --add-data "module\\screenshot.pyx;module" --add-data "module\\server.pyx;module" main.py

REM Sanal mühiti deaktivləşdirir
echo Sanal mühit deaktivləşdirilir...
deactivate

echo Quraşdırma tamamlandı!
pause
