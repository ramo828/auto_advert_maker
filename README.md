# Telefon Nömrəsi Satışı üçün Elan Yaratma Tətbiqi

Bu tətbiq, telefon nömrəsi satışına dair elanlar yaratmaq üçün avtomatlaşdırılmış bir həll təqdim edir. İstifadəçilər, tətbiqin interfeysi vasitəsilə, telefon nömrələri üzrə satışı üçün elanlar yaradırlar. Tətbiq, müəyyən bir dizayna əsaslanaraq elan şəkillərini avtomatik olaraq yaradır və bu şəkillər nömrə satışında istifadə olunur.

## Əsas Xüsusiyyətlər:

### **Avtomatlaşdırılmış Şəkil Yaratma:**

- Tətbiq, nömrələr üçün nəzərdə tutulan şəkilləri, öncədən müəyyən edilmiş bir dizayna əsasən avtomatik olaraq yaradır.
- İstifadəçilər şəkil formatını və dizayn elementlərini öz istəyinə uyğun tənzimləyə bilərlər.
- Yaradılan şəkillər, satış məqsədilə elan olaraq istifadə edilə bilər.

### **Sürətli və Asan İlan Yaratma:**

- İlanlar yaratmaq üçün yalnız nömrə məlumatlarını əlavə etmək kifayətdir.
- İlan şəkilləri və məlumatları avtomatik olaraq müvafiq formatda yaradılır.
- Əl ilə elan hazırlamağa ehtiyac yoxdur; tətbiq avtomatik olaraq şəkilləri yaradır və elanları təqdim edir.

### **Dinamiki Quraşdırma:**

- İstifadəçilər, öz tələblərinə uyğun şəkildə tətbiq parametrlərini tənzimləyə bilərlər.
- Parametrlər JSON formatında saxlanılır və tətbiqin istənilən vaxt yenilənməsi mümkündür.

### **Sadə və Təhlükəsiz İnterfeys:**

- İstifadəçi dostu bir interfeys ilə, istifadəçilər nömrələri əlavə edib, şəkillərini yarada bilərlər.
- Avtomatik olaraq elan şəkilləri yaradılaraq satış üçün hazır hala gətirilir.

### **Qovluq İdarəetməsi:**

- Tətbiq, yaradılan şəkilləri müvafiq qovluqda saxlayır və istifadəçilərin istəyi üzrə həmin qovluqları idarə edir.
- Şəkillərin yerləşdiyi qovluq avtomatik olaraq yaradılır və ya mövcud qovluqlar təmizlənir.

### **Əlavə Xüsusiyyətlər:**

- JSON formatında olan `settings.json` faylından istifadə edərək tətbiq konfiqurasiyasını asanlıqla dəyişdirə bilərsiniz.
- Həmçinin, tətbiq müxtəlif əlavə modullar və interfeyslər vasitəsilə genişləndirilə bilər.

## İstifadə

1. **Tətbiqi yükləyin** və `settings.json` faylını öz tələblərinizə uyğun konfiqurasiya edin.
2. Nömrələr əlavə edərək Elan şəkillərinizi yaradın.
3. Şəkilləri müvafiq qovluğa saxlayın və satış üçün istifadə edin.

### **Quraşdırma:**
- Windows üçün: install.bat

- Linux üçün: install.sh

- Daha sonra dist qovluğundaki main faylını klikləyib çalışdırın