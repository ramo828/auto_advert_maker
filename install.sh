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
echo "Google Chrome versiyası yoxlanılır..."
INSTALLED_CHROME_VERSION=$(google-chrome-stable --version 2>/dev/null)

if [ -z "$INSTALLED_CHROME_VERSION" ]; then
    echo "Google Chrome quraşdırılmayıb, quraşdırılır..."
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
else
    echo "Google Chrome artıq quraşdırılıb: $INSTALLED_CHROME_VERSION"
fi

# Yüklü ChromeDriver-ı yoxlayaq
if command -v chromedriver &> /dev/null; then
    INSTALLED_VERSION=$(chromedriver --version | awk '{print $2}')
    CHROME_DRIVER_VERSION=$(curl -sS https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)

    if [ "$INSTALLED_VERSION" == "$CHROME_DRIVER_VERSION" ]; then
        echo "Ən son versiyada ChromeDriver artıq yüklüdür. Yenidən yükləməyə ehtiyac yoxdur."
    else
        echo "Yüklü ChromeDriver versiyası $INSTALLED_VERSION, amma ən son versiya $CHROME_DRIVER_VERSION-dir. Yenidən yüklənir..."
        # ChromeDriver-i məcburi olaraq yenidən yükləyirik
        CHROMEDRIVER_ZIP="chromedriver-linux64.zip"
        CHROMEDRIVER_DIR="chromedriver-linux64"

        # Əvvəlki ZIP faylını silirik ki, problem olmasın
        rm -f ~/$CHROMEDRIVER_ZIP

        wget -O ~/$CHROMEDRIVER_ZIP "https://storage.googleapis.com/chrome-for-testing-public/$CHROME_DRIVER_VERSION/linux64/$CHROMEDRIVER_ZIP"

        # ZIP faylın düzgün yüklənib-yüklənmədiyini yoxlayaq
        if [ ! -f ~/$CHROMEDRIVER_ZIP ]; then
            echo "ChromeDriver ZIP faylı yüklənmədi! Çıxılır..."
            exit 1
        fi

        # ZIP faylını açırıq
        unzip ~/$CHROMEDRIVER_ZIP -d ~/

        # ChromeDriver-in düzgün mövcud olub-olmadığını yoxlayaq
        if [ ! -f ~/$CHROMEDRIVER_DIR/chromedriver ]; then
            echo "ChromeDriver faylı tapılmadı! Çıxılır..."
            exit 1
        fi

        # ChromeDriver-i sistemə yerləşdiririk
        sudo mv -f ~/$CHROMEDRIVER_DIR/chromedriver /usr/local/bin/
        sudo chmod +x /usr/local/bin/chromedriver

        # Artıq faylları silirik
        rm -rf ~/$CHROMEDRIVER_ZIP ~/$CHROMEDRIVER_DIR
        echo "ChromeDriver uğurla quraşdırıldı!"
    fi
else
    echo "ChromeDriver tapılmadı. Yüklənir..."
    # Yüklənmə prosesi burada davam edir...
fi

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
