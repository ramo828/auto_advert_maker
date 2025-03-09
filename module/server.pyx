import threading
import time
import json
from flask import Flask, render_template, jsonify, request
from waitress import serve
from ext import get_resource_path
import os
app = Flask(__name__)



# Ayarları JSON dosyasından okuma
def load_settings():
    with open(get_resource_path('settings.json'), 'r') as f:
        settings = json.load(f)
    return settings

settings = load_settings()

# Nömrələr siyahısı
data = [
    # Örnek veriler, gerçek veriler burada kullanılabilir
]  


def format_phone(number):
    number = str(number)
    sep = settings['site_settings']['phone_separator']  # JSON'dan ayırıcıyı al
    return f"{number[:3]}{sep}{number[3:6]}{sep}{number[6:8]}{sep}{number[8:]}"

app.jinja_env.filters['format_phone'] = format_phone  # Filtreyi Jinja2'ye ekle

@app.route('/')
def home():
    data_dict = {
        'title': settings['site_settings']['title'],  # JSON dosyasından başlık
        'heading': data,  # Nömrə siyahısı,
        'description': settings['site_settings']['description'],  # JSON'dan açıklama
        'phone': settings['site_settings']['phone'],  # JSON'dan telefon numarası
        'message': settings['site_settings']['message'],  # JSON'dan mesaj
        'icons': settings['site_settings']['icons'],  # JSON'dan ikonlar
        'css_path': settings['site_settings']['css_path'],  # JSON'dan CSS yolu
        'logo_path': settings['site_settings']['logo_path']  # JSON'dan logo yolu

    }
    # Template dosyasını ve CSS yolunu JSON'dan alıyoruz
    return render_template(settings['site_settings']['template_path'], data=data_dict)

# API son nöqtəsi: Nömrələr siyahısını JSON formatında qaytarır
@app.route('/api/numbers', methods=['GET'])
def get_numbers():
    return jsonify({"numbers": data})

# API son nöqtəsi: Yeni nömrə əlavə etmə
@app.route('/api/numbers', methods=['POST'])
def add_number():
    new_number = request.json.get("number")  # JSON məlumatından nömrəni alır
    if new_number and new_number not in data:  # Nömrə boş deyilsə və daha əvvəl əlavə olunmayıbsa
        data.append(new_number)
        return jsonify({"message": "Nömrə əlavə olundu", "numbers": data}), 201
    return jsonify({"message": "Yanlış və ya artıq əlavə edilmiş nömrə"}), 400

# API son nöqtəsi: Nömrələr siyahısını tamamilə dəyişdirmək
@app.route('/api/numbers', methods=['PUT'])
def set_numbers():
    new_list = request.json.get("numbers")  # Yeni nömrələr siyahısını alır
    if isinstance(new_list, list):  # Göndərilən məlumat siyahıdırmı yoxlayır
        global data
        data = new_list  # Siyahını yeniləyir
        return jsonify({"message": "Nömrələr siyahısı yeniləndi", "numbers": data}), 200
    return jsonify({"message": "Yanlış məlumat formatı"}), 400

# Thread idarəetməsi üçün dəyişənlər
stop_event = threading.Event()
flask_thread = None

def run_flask():
    global stop_event
    while not stop_event.is_set():
        try:
            # JSON'dan alınan host ve port bilgisiyle server'ı çalıştırıyoruz
            serve(app, host=settings['server_settings']['host'], port=settings['server_settings']['port'])
        except Exception as e:
            print("Flask dayandırıldı:", e)
            break

def start_flask():
    global flask_thread, stop_event
    if flask_thread is None or not flask_thread.is_alive():
        stop_event.clear()
        flask_thread = threading.Thread(target=run_flask, daemon=True)
        flask_thread.start()
        print("Flask başladıldı.")


def stop_flask():
    global stop_event, flask_thread
    if flask_thread and flask_thread.is_alive():
        stop_event.set()
        print("Flask dayandırılır...")
        time.sleep(1)
        flask_thread = None
        print("Flask dayandırıldı.")

