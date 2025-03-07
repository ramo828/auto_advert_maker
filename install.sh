#!/bin/bash

# Sistem yenilənir
echo "Sistem yenilənir..."
sudo apt-get update

# Lazımi asılılıqlar yüklənir
echo "Lazımi asılılıqlar yüklənir..."
sudo apt-get install -y python3 python3-pip python3-venv build-essential \
    python3-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev zlib1g-dev \
    libjpeg-dev libpng-dev libfreetype6-dev libblas-dev liblapack-dev \
    libatlas-base-dev gfortran libmysqlclient-dev libpq-dev \
    xvfb unzip curl wget git

# Google Chrome və ChromeDriver yüklənir
echo "Google Chrome yüklənir..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install -y google-chrome-stable

echo "ChromeDriver yüklənir..."
CHROME_DRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget -N https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/
unzip ~/chromedriver_linux64.zip -d ~/ 
sudo mv -f ~/chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
rm ~/chromedriver_linux64.zip

# Süni mühit (venv) varsa silinir
if [ -d "venv" ]; then
    echo "Süni mühit mövcuddur, silinir..."
    rm -rf venv
fi

# dist qovluğu varsa silinir
if [ -d "dist" ]; then
    echo "dist qovluğu mövcuddur, silinir..."
    rm -rf dist
fi

# build qovluğu varsa silinir
if [ -d "build" ]; then
    echo "build qovluğu mövcuddur, silinir..."
    rm -rf build
fi

# Süni mühit (venv) yaradılır
echo "Süni mühit yaradılır..."
python3 -m venv venv

# Süni mühit aktiv edilir
echo "Süni mühit aktiv edilir..."
source venv/bin/activate
echo "PIP versiyası yenilənir..."
pip install --upgrade pip

# Asılılıqlar yüklənir
echo "Asılılıqlar yüklənir..."
pip install -r requirements.txt

# setup.py faylı tərtib edilir
echo "Cython modulları tərtib edilir..."
python setup.py build_ext --inplace

# PyInstaller ilə icra edilə bilən fayl yaradılır
echo "PyInstaller ilə icra edilə bilən fayl yaradılır..."

# Fayl yolları toplanır və hər biri --add-data formatına salınır
DATA_FILES=""
if [ -d "module" ]; then
    for file in $(find module -type f); do
        DATA_FILES="$DATA_FILES --add-data $file:module"
    done
else
    echo "module qovluğu tapılmadı."
fi

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

# Süni mühit deaktiv edilir
echo "Süni mühit deaktiv edilir..."
deactivate

echo "Quraşdırma tamamlandı!"
