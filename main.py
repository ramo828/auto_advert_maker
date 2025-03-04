from PySide6.QtCore import QThread, Signal
from PySide6.QtWidgets import QApplication, QMainWindow, QMessageBox
from ui.main_ui import Ui_main_ui
from server import start_flask, stop_flask
from screenshot import avtomatlaşdırma
from ext import get_resource_path
import json
import sys

# Ya da, doğrudan kod içinde tanımlayın:
class FlaskThread(QThread):
    """Flask serverini ayrı bir threadde çalıştırır"""
    terminal_signal = Signal(str)

    def run(self):
        self.terminal_signal.emit("Flask sunucusu başlanğıc edir...")
        start_flask()
        self.terminal_signal.emit("Flask sunucusu başladı.")

class AutomationThread(QThread):
    """Selenium avtomatlaşdırmasını ayrı bir threadde çalıştırır"""
    terminal_signal = Signal(str)

    def run(self):
        self.terminal_signal.emit("Avtomatlaşdırma başladı.")
        avtomatlaşdırma()
        self.terminal_signal.emit("Avtomatlaşdırma bitdi.")

class MyApp(QMainWindow, Ui_main_ui):  
    def __init__(self):  
        super().__init__()  
        self.setupUi(self)  
        self.load_settings()
        self.setup_connections()
        self.start_app_button.clicked.connect(self.start)

        # Thread'ler
        self.server_thread = FlaskThread()
        self.automation_thread = AutomationThread()

        # Sinyalleri bağla
        self.server_thread.terminal_signal.connect(self.yaz_terminal)
        self.automation_thread.terminal_signal.connect(self.yaz_terminal)
        self.number_limit.valueChanged.connect(self.updateSeqmentDisplay)

    def closeEvent(self, event):
        """Pencere kapatıldığında Flask sunucusunu durdur."""
        reply = QMessageBox.question(self, "Çıxış Təsdiqi",
                                     "Proqramı bağlamaq istədiyinizdən əminsiniz?",
                                     QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                                     QMessageBox.StandardButton.No)

        if reply == QMessageBox.StandardButton.Yes:
            stop_flask()
            event.accept()
        else:
            event.ignore()
    def updateSeqmentDisplay(self):
        self.number_limit_display.display(self.number_limit.value())

    def yaz_terminal(self, mesaj):
        """Thread-safe terminal mesajları"""
        self.terminal.appendPlainText(mesaj)

    def load_settings(self):
        """JSON ve numbers.list dosyalarını yükler."""
        try:
            with open(get_resource_path('data/numbers.list'), 'r') as f:
                numbers_text = f.read()
                self.numbers.setPlainText(numbers_text)
            self.yaz_terminal("numbers.list uğurla yükləndi.")
        except FileNotFoundError:
            self.numbers.setPlainText("")
            self.yaz_terminal("numbers.list faylı tapılmadı, boş siyahı yaradıldı.")

        with open(get_resource_path('settings.json'), 'r') as f:
            self.settings = json.load(f)
            self.title.setText(self.settings['site_settings']['title'])
            self.description.setText(self.settings['site_settings']['description'])
            self.phone.setText(self.settings['site_settings']['phone'])
            self.message.setText(self.settings['site_settings']['message'])
            self.number_limit.setValue(self.settings['max_number'])
            self.number_limit_display.display(self.settings['max_number'])
            self.window_x.setText(str(self.settings['window_size'][0]))
            self.window_y.setText(str(self.settings['window_size'][1]))
            self.output_path_name.setText(self.settings['save_directory'])
            self.screenshot_filename.setText(self.settings['screenshot_filename'])
            self.chrome_drv_path.setText(self.settings['chromedriver_path'])
            self.auto_crt_dir.setChecked(self.settings['auto_create_directory'])
            self.auto_dir_cln.setChecked(self.settings['auto_clean_output'])
            self.crm_drv_mng_sts.setChecked(self.settings['use_chromedriver_manager'])
            self.headless_sts.setChecked(self.settings['headless'])

        self.yaz_terminal("Ayarlar settings.json-dan uğurla yükləndi.")

    def setup_connections(self):
        """UI değişikliklerini JSON dosyasına kaydeder."""
        self.title.textChanged.connect(lambda: self.save_setting('site_settings', 'title', self.title.text()))
        self.description.textChanged.connect(lambda: self.save_setting('site_settings', 'description', self.description.text()))
        self.phone.textChanged.connect(lambda: self.save_setting('site_settings', 'phone', self.phone.text()))
        self.message.textChanged.connect(lambda: self.save_setting('site_settings', 'message', self.message.text()))
        self.number_limit.valueChanged.connect(lambda value: self.save_setting('max_number', None, value))
        self.window_x.textChanged.connect(lambda: self.save_window_size())
        self.window_y.textChanged.connect(lambda: self.save_window_size())
        self.output_path_name.textChanged.connect(lambda: self.save_setting('save_directory', None, self.output_path_name.text()))
        self.screenshot_filename.textChanged.connect(lambda: self.save_setting('screenshot_filename', None, self.screenshot_filename.text()))
        self.chrome_drv_path.textChanged.connect(lambda: self.save_setting('chromedriver_path', None, self.chrome_drv_path.text()))
        self.auto_crt_dir.toggled.connect(lambda state: self.save_setting('auto_create_directory', None, state))
        self.auto_dir_cln.toggled.connect(lambda state: self.save_setting('auto_clean_output', None, state))
        self.crm_drv_mng_sts.toggled.connect(lambda state: self.save_setting('use_chromedriver_manager', None, state))
        self.headless_sts.toggled.connect(lambda state: self.save_setting('headless', None, state))
        self.numbers.textChanged.connect(self.save_numbers_list)

    def save_setting(self, category, key, value):
        """JSON dosyasını günceller."""
        if key:
            self.settings[category][key] = value
        else:
            self.settings[category] = value
        
        with open(get_resource_path('settings.json'), 'w') as f:
            json.dump(self.settings, f, indent=4)
        
        self.yaz_terminal(f"{category} -> parametri yeniləndi: {value}")

    def save_window_size(self):
        """Pəncərə ölçüsünü JSON faylında yadda saxlayır."""
        try:
            width = int(self.window_x.text())
            height = int(self.window_y.text())
            self.settings['window_size'] = [width, height]

            with open('settings.json', 'w') as f:
                json.dump(self.settings, f, indent=4)

            self.yaz_terminal(f"Pəncərə ölçüsü yeniləndi: {width}x{height}")
        except ValueError:
            self.yaz_terminal("Xəta: Pəncərə ölçüsünü düzgün daxil edin.")

    def save_numbers_list(self):
        """numbers.list faylını yeniləyir."""
        with open(get_resource_path('data/numbers.list'), 'w') as f:
            f.write(self.numbers.toPlainText())

        self.yaz_terminal("numbers.list faylı uğurla yadda saxlandı.")

    def start(self):
        """Başlat düğmesine basıldığında thread'leri çalıştırır."""
        self.yaz_terminal("Start düyməsi klikləndi.")

        if not self.server_thread.isRunning():
            self.server_thread.start()

        if not self.automation_thread.isRunning():
            self.automation_thread.start()

        self.yaz_terminal("Avtomatlaşdırma prosesi başladı.")


app = QApplication(sys.argv)  
window = MyApp()  
window.show()  
sys.exit(app.exec())  
