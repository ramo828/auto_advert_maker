@echo off

:: Süni mühit (venv) varsa silinir
if exist "venv" (
    echo Süni mühit mevcut, siliniyor...
    rmdir /s /q venv
)

:: dist klasörü varsa silinir
if exist "dist" (
    echo dist klasörü mevcut, siliniyor...
    rmdir /s /q dist
)

:: build klasörü varsa silinir
if exist "build" (
    echo build klasörü mevcut, siliniyor...
    rmdir /s /q build
)

:: Süni mühit (venv) yaradılır
echo Süni mühit yaradılır...
python -m venv venv

:: Süni mühiti aktivləşdirir
echo Süni mühit aktivləşdirilir...
call venv\Scripts\activate.bat
echo PIP versiyonunu güncelliyorum...
pip install --upgrade pip

:: Bağımlılıkları yüklüyor
echo Bağımlılıkları yüklüyorum...
pip install -r requirements.txt

:: setup.py dosyasını derler
echo Cython modüllerini derliyorum...
python setup.py build_ext --inplace

:: PyInstaller ile çalıştırılabilir dosya oluşturuyor
echo PyInstaller ile EXE dosyası oluşturuluyor...

:: Dosya yollarını toplar ve her birini --add-data formatında işler
set DATA_FILES=
if exist "module" (
    for /r %%f in (module\*) do (
        set DATA_FILES=!DATA_FILES! --add-data "%%f:module"
    )
) else (
    echo "module dizini bulunamadı."
)

:: Flask ve diğer modülleri gizli olarak ekleriz
pyinstaller --onefile %DATA_FILES% ^
    --add-data "templates:templates" ^
    --add-data "static:static" ^
    --add-data "data:data" ^
    --add-data "settings.json:." ^
    --hidden-import=flask ^
    --hidden-import=waitress ^
    --hidden-import=selenium ^
    --hidden-import=selenium.webdriver.chrome ^
    --hidden-import=requests ^
    --hidden-import=selenium.webdriver.support.ui ^
    --hidden-import=selenium.webdriver.support.expected_conditions ^
    --hidden-import=webdriver_manager ^
    --hidden-import=webdriver_manager.chrome ^
    --icon=static\icons\app_icon.ico ^
    main.py

:: Süni mühiti devre dışı bırakır
echo Süni mühit devre dışı bırakılıyor...
deactivate

echo Kurulum tamamlandı!
pause
