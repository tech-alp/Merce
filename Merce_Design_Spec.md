Merce Design System - Teknik Spesifikasyon (Qt 6.11+)Sürüm: 1.1.0Hedef Framework: Qt 6.11+ (QML Modern Syntax)Mimari: Modüler, CMake Tabanlı, Katı Tip GüvenliğiKullanım Alanı: Smart Cart Ekosistemi (Kiosk, Tablet, Gömülü Sistemler)1. Mimari Genel BakışMerce, "Monolitik" bir kütüphane yerine, bağımlılıkları yönetilen ayrık QML Modülleri olarak tasarlanmıştır. Qt 6.11'in yeni property semantikleri (virtual, override, final) kullanılarak bileşen hiyerarşisi katı kurallara bağlanmıştır.Modül Bağımlılık Ağacıgraph TD
    A[Uygulama (SmartCart App)] --> B[Merce.Controls]
    A --> C[Merce.Notifications]
    B --> D[Merce.Foundation]
    C --> D
    D --> E[Merce.Core]
2. Klasör ve Dosya YapısıProje kök dizininde modern Qt 6 modül yapısı uygulanır. Her modül kendi içinde tip-güvenli ve izoledir./Merce
├── CMakeLists.txt              (Root Build Konfigürasyonu)
├── /Core                       (URI: Merce.Core) - Theme, Palette, Icons
├── /Foundation                 (URI: Merce.Foundation) - MSurface, MText
├── /Controls                   (URI: Merce.Controls) - MButton, MInput
└── /Notifications              (URI: Merce.Notifications) - MToast, MDialog
3. QML İmplementasyon Standartları (Qt 6.11+ Syntax)Qt 6.11 ile gelen yeni mülkiyet (property) semantikleri Merce'nin kalbini oluşturur. Bu anahtar kelimeler, bileşenlerin genişletilebilirliğini kontrol eder.3.1. Virtual ve Override KullanımıBileşen kalıtımında, üst bileşende özelleştirilmeye izin verilen özellikler virtual olarak işaretlenir. Alt bileşenler bu özellikleri override ile ezmek zorundadır.Örnek: Foundation Seviyesinde Base Kontrol// MBaseControl.qml (Merce.Foundation)
import QtQuick

Item {
    // Alt bileşenlerin bu rengi değiştirmesine izin veriyoruz
    virtual property color accentColor: "blue"
    
    // Alt bileşenlerin bu metriği değiştirmesine izin verilmiyor
    final property int touchTarget: 44 
}
Örnek: Controls Seviyesinde Uygulama// MButton.qml (Merce.Controls)
import QtQuick
import Merce.Foundation

MBaseControl {
    // Üst sınıftaki özelliği açıkça ezdiğimizi belirtiyoruz
    override property color accentColor: Theme.colors.action.primary
}
3.2. Final ve Required Property StratejisiSistemin kararlılığı için kritik olan (örneğin kurumsal kimlik renkleri veya dokunmatik hedef boyutları) özellikler final olarak işaretlenerek alt sınıflarda değiştirilmeleri engellenir.// MSurface.qml (Merce.Foundation)
import QtQuick

Rectangle {
    // Zorunlu özellik: Bu yüzeyin bir tipi olmalı
    required property int surfaceType 
    
    // Değiştirilemez özellik: Kiosk cihaz standartı
    final property int minTouchArea: 44 
}
4. Singleton "Theme" Yönetimi (Merce.Core)Theme.qml, nested QtObject yapısı kullanılarak semantik olarak organize edilir. Bu yapı, Theme.colors.text.primary gibi anlamlı zincirleme erişim sağlar.// Merce/Core/Theme.qml
pragma Singleton
import QtQuick

QtObject {
    id: themeRoot

    // -------------------------------------------------------------------------
    // 1. PALETTE (PRIVATE) - Ham Renkler
    // -------------------------------------------------------------------------
    property QtObject _palette: QtObject {
        readonly property color blue500: "#2A64DB"
        readonly property color green400: "#28A745"
        readonly property color red600: "#DC3545"
        readonly property color gray900: "#212529"
        readonly property color white: "#FFFFFF"
    }

    // -------------------------------------------------------------------------
    // 2. SEMANTIC TOKENS (PUBLIC API)
    // -------------------------------------------------------------------------
    
    property QtObject colors: QtObject {
        // Eylem Grubu (Nested)
        property QtObject action: QtObject {
            readonly property color primary: themeRoot._palette.blue500
            readonly property color success: themeRoot._palette.green400
            readonly property color destructive: themeRoot._palette.red600
            
            function base(variant) {
                if (variant === "success") return success
                if (variant === "destructive") return destructive
                return primary
            }
        }

        // Metin Grubu (Nested)
        property QtObject text: QtObject {
            readonly property color primary: themeRoot._palette.gray900
            readonly property color inverse: themeRoot._palette.white
        }
    }
    
    property QtObject metrics: QtObject {
        final property int touchTarget: 44 
        readonly property int spacingBase: 8
    }
}
5. Modüler CMake EntegrasyonuHer modül, CMake üzerinden bağımsız bir target olarak tanımlanır.# Merce/Controls/CMakeLists.txt
qt_add_qml_module(MerceControls
    URI "Merce.Controls"
    VERSION 1.0
    QML_FILES
        MButton.qml
        MInput.qml
)

target_link_libraries(MerceControls PRIVATE MerceFoundation MerceCore)
6. Geliştirici Deneyimi (Vibe Code)Merce, geliştiricilere tip-güvenli bir deneyim sunar. Yanlışlıkla final bir özelliği ezmeye çalışmak derleme veya çalışma zamanında (QML linter/engine) hata verecektir.Kullanım Örneği:import Merce.Core
import Merce.Controls

MButton {
    text: "Ödemeyi Yap"
    variant: "primary"
    
    // Layout kuralları Merce.Foundation'dan override edilerek gelir
    width: parent.width
    height: Theme.metrics.touchTarget
    
    onClicked: {
        // Semantic access
        console.log("Color used:", Theme.colors.action.primary)
    }
}
