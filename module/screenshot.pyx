import os
import json
import shutil
import requests
from time import sleep
from selenium import webdriver
from ext import get_resource_path
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support import expected_conditions as EC

# JSON ayarlarını yükləyən funksiya
def yukle_ayarlar():
    with open(get_resource_path("settings.json"), "r") as file:
        return json.load(file)

# Çıxış qovluğunu yoxla, lazım gələrsə təmizlə və ya yarat
def qovlugu_idare_et(SAXLA_QOVLUQ, auto_qovluq_temizle, auto_qovluq_yarat):
    if os.path.exists(SAXLA_QOVLUQ):
        if auto_qovluq_temizle:
            print(f"'{SAXLA_QOVLUQ}' qovluğu təmizlənir...")
            shutil.rmtree(SAXLA_QOVLUQ)
    
    if auto_qovluq_yarat:
        os.makedirs(SAXLA_QOVLUQ, exist_ok=True)
        print(f"'{SAXLA_QOVLUQ}' qovluğu yaradıldı.")

# Selenium üçün WebDriver-i başladan funksiya
def baslat_driver(headless, pencere_olcusu, chromedriver_auto, chromedriver_yolu):
    chrome_options = Options()
    if headless:
        chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--incognito")  # **Gizli mod** (Önbellek yok)

    if chromedriver_auto:
        service = Service(ChromeDriverManager().install())
    else:
        service = Service(executable_path=chromedriver_yolu)

    driver = webdriver.Chrome(service=service, options=chrome_options)
    driver.set_window_size(*pencere_olcusu)
    return driver

# Ekran görüntüsü alan funksiya
def save_screenshot(driver, SAXLA_QOVLUQ, ekran_fayl_adi, ekran_sayi, ekran_format, ss_fullpage=False):
    try:
        sc_element = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, "content-wrapper"))
        )
        if(not ss_fullpage):
            screenshot = sc_element.screenshot_as_png
        else:
            screenshot = driver.get_screenshot_as_png()
        filename = f"{SAXLA_QOVLUQ}/{ekran_fayl_adi}-{ekran_sayi}.{ekran_format}"

        with open(filename, "wb") as f:
            f.write(screenshot)

        print(f"Ekran görüntüsü {ekran_sayi}: {filename}")
        return ekran_sayi + 1
    except Exception as e:
        print(f"Ekran görüntüsü alınmadı: {e}")
        return ekran_sayi

# Əsas avtomatlaşdırma prosesini işlədən funksiya
def avtomatlaşdırma():
    # JSON ayarlarını yüklə
    ayarlar = yukle_ayarlar()

    # Parametrləri götür
    max_nomre = ayarlar["max_number"]
    SAXLA_QOVLUQ = ayarlar["save_directory"]
    auto_qovluq_yarat = ayarlar["auto_create_directory"]
    auto_qovluq_temizle = ayarlar["auto_clean_output"]
    chromedriver_auto = ayarlar["use_chromedriver_manager"]
    chromedriver_yolu = ayarlar["chromedriver_path"]
    ekran_fayl_adi = ayarlar["screenshot_filename"]
    ekran_format = ayarlar["screenshot_format"]
    nomre_siyahisi_fayli = ayarlar["number_list_path"]
    api_url = ayarlar["api_url"]
    web_url = ayarlar["web_url"]
    headless = ayarlar["headless"]
    pencere_olcusu = ayarlar["window_size"]
    tam_olcu = ayarlar["full_page"]
    win_x_offset = ayarlar["window_x_offset"]
    win_y_offset = ayarlar["window_y_offset"]



    # Qovluq idarəetməsini et
    qovlugu_idare_et(SAXLA_QOVLUQ, auto_qovluq_temizle, auto_qovluq_yarat)
    pencere_olcusu = [pencere_olcusu[0]+win_x_offset, pencere_olcusu[1]+win_y_offset]
    # WebDriver-i başlat
    driver = baslat_driver(headless, pencere_olcusu, chromedriver_auto, chromedriver_yolu)

    try:
        # Nömrə siyahısını fayldan oxu
        if not os.path.exists(get_resource_path(nomre_siyahisi_fayli)):
            print(f"Xəta: '{nomre_siyahisi_fayli}' faylı mövcud deyil!")
            return

        with open(get_resource_path(nomre_siyahisi_fayli), "r") as file:
            data = [line.strip() for line in file]

        if not data:
            print("Xəta: Nömrə siyahısı boşdur!")
            return

        driver.get(web_url)
        sleep(3)

        ekran_sayi = 1
        nomre_sayaci = 0

        while nomre_sayaci < len(data):
            gonderilecek_nomreler = data[nomre_sayaci:nomre_sayaci + max_nomre]
            response = requests.put(api_url, json={"numbers": gonderilecek_nomreler})

            if response.status_code == 200:
                print(f"{len(gonderilecek_nomreler)} nömrə API-yə göndərildi.")
            else:
                print(f"Xəta: API cavabı {response.status_code}")

            driver.refresh()
            sleep(3)

            ekran_sayi = save_screenshot(driver, SAXLA_QOVLUQ, ekran_fayl_adi, ekran_sayi, ekran_format, tam_olcu)

            nomre_sayaci += max_nomre

    except Exception as e:
        print(f"Xəta meydana gəldi: {e}")

    finally:
        driver.quit()
        print("Brauzer bağlandı.")
