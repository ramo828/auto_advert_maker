#!/bin/bash

# Sanal mühit (venv) varsa silinir
if [ -d "venv" ]; then
    echo "Sanal mühit mevcut, siliniyor..."
    rm -rf venv
fi

# dist klasörü varsa silinir
if [ -d "dist" ]; then
    echo "dist klasörü mevcut, siliniyor..."
    rm -rf dist
fi

# build klasörü varsa silinir
if [ -d "build" ]; then
    echo "build klasörü mevcut, siliniyor..."
    rm -rf build
fi

# Sanal mühit (venv) yaradılır
echo "Sanal mühit yaradılır..."
python -m venv venv

# Sanal mühiti aktivləşdirir
echo "Sanal mühit aktivləşdirilir..."
source venv/bin/activate
echo "PIP verisyasını yeniləyirəm.."
pip install --upgrade pip

# Asılılıqları yükləyir
echo "Asılılıqları yükləyirəm..."
pip install -r requirements.txt

# setup.py faylını tərtib et
echo "Cython modullarını tərtib edirəm..."
python setup.py build_ext --inplace

# PyInstaller ilə icra edilə bilən fayl yaradır
echo "PyInstaller ilə EXE faylı yaradılır..."

# Dosya yollarını toplar ve her birini --add-data formatında işler
DATA_FILES=""
# "module" dizini gerçekten var mı kontrol et
if [ -d "module" ]; then
    for file in $(find module -type f); do
        DATA_FILES="$DATA_FILES --add-data $file:module"
    done
else
    echo "module dizini bulunamadı."
fi

# Flask modülünü gizli olarak ekleriz
# Flask, selenium, waitress gibi modülleri --hidden-import ile dahil ederiz
# Burada doğru dosya adını kullanın, örneğin 'main.py' olarak değiştirdim
pyinstaller --onefile $DATA_FILES \
    --add-data "templates:templates" \
    --add-data "static:static" \
    --add-data "data:data" \
    --add-data "settings.json:." \
    --hidden-import=flask \
    --hidden-import=waitress \
    --hidden-import=selenium \
    --hidden-import=selenium.webdriver.chrome \
    --hidden-import=requests \
    --hidden-import=selenium.webdriver.support.ui \
    --hidden-import=selenium.webdriver.support.expected_conditions \
    --hidden-import=webdriver_manager \
    --hidden-import=webdriver_manager.chrome \
    --icon=static/icons/app_icon.ico \
    main.py
# Sanal mühiti deaktivləşdirir
echo "Sanal mühit deaktivləşdirilir..."
deactivate

echo "Quraşdırma tamamlandı!"
