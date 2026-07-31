# Qt 6.2+ için En Temiz QML Style & Theme Mimarisi

> Bu doküman; **Qt 6.2 ve üzeri** (özellikle 6.6–6.8) sürümler için, **Kirigami'den ilham alan fakat daha deterministik, test edilebilir ve ölçeklenebilir** bir **style / theme yönetim sistemi**ni anlatır.

Hedef kitle:
- Embedded / kiosk / HMI projeleri
- White‑label (multi‑brand) ürünler
- Uzun ömürlü (5–10 yıl) Qt kod tabanları

---

## 1. Tasarım İlkeleri (Non‑Negotiable)

Bu sistem aşağıdaki kuralları **bilinçli olarak** uygular:

1. **Style = Data, Component = Behaviour**
2. Theme dosyalarında **logic YOK**
3. Component’ler **renk / font / spacing bilmez**
4. Runtime string lookup **YASAK**
5. IDE (qml‑ls) ve autocomplete **tam çalışır**
6. C++ / QML sınırı **net ve kasıtlıdır**

---

## 2. Katmanlı Mimari

```
ui/
├── tokens/              # Design tokens (interface)
│   ├── ColorSet.qml
│   ├── Spacing.qml
│   ├── Radius.qml
│   └── Typography.qml
│
├── themes/              # Concrete implementations
│   ├── Light.qml
│   ├── Dark.qml
│   └── BrandX.qml
│
├── style/               # Public facade
│   ├── Style.qml
│   └── StyleManager.cpp
│
├── controls/            # UI components
│   ├── Button.qml
│   ├── Card.qml
│   └── Dialog.qml
```

---

## 3. Design Token Katmanı (En Kritik Kısım)

### 3.1 Token = Interface

Token dosyaları **değer içermez**, sadece **kontrat** tanımlar.

### `tokens/ColorSet.qml`
```qml
QtObject {
    readonly property color primary
    readonly property color onPrimary
    readonly property color surface
    readonly property color onSurface
    readonly property color danger
}
```

Bu yapı:
- IDE autocomplete sağlar
- Yanlış token kullanımını derleme aşamasında yakalatır
- Theme dosyalarının eksik tanımlanmasını engeller

Aynı yaklaşım spacing, typography ve radius için de uygulanır.

---

## 4. Theme Katmanı (Pure Data)

### 4.1 Theme = Immutable Object Graph

### `themes/Dark.qml`
```qml
import "../tokens"

QtObject {
    readonly property ColorSet colors: ColorSet {
        primary: "#4F8CFF"
        onPrimary: "white"
        surface: "#121212"
        onSurface: "#E0E0E0"
        danger: "#FF5252"
    }

    readonly property Spacing spacing: Spacing {
        xs: 4
        sm: 8
        md: 12
        lg: 20
    }

    readonly property Typography typography: Typography {
        body: Qt.font({ pixelSize: 14 })
        title: Qt.font({ pixelSize: 18, weight: Font.Medium })
    }
}
```

**Kurallar:**
- `if`, `Binding`, `Connections` YOK
- Singleton YOK
- Runtime state YOK

---

## 5. Style Facade (Public API)

### 5.1 Style = Dependency Injection Point

### `style/Style.qml`
```qml
QtObject {
    readonly property ColorSet colors: _theme.colors
    readonly property Spacing spacing: _theme.spacing
    readonly property Typography typography: _theme.typography

    property QtObject _theme
}
```

Component’ler **yalnızca Style görür**, Theme’i asla bilmez.

---

## 6. Runtime Theme Switching (O(1))

### 6.1 StyleManager (C++)

```cpp
class StyleManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QObject* theme READ theme NOTIFY themeChanged)

public:
    QObject* theme() const { return m_theme; }

    Q_INVOKABLE void setTheme(const QUrl& url) {
        QObject* obj = qmlEngine(this)->objectForUrl(url);
        if (obj == m_theme) return;
        m_theme = obj;
        emit themeChanged();
    }

signals:
    void themeChanged();

private:
    QObject* m_theme = nullptr;
};
```

- Theme switch = pointer değişimi
- Binding invalidation otomatik
- No global side effects

---

## 7. Component Kullanımı

### `controls/Button.qml`
```qml
import Tvm.Style

Rectangle {
    radius: Style.radius.sm
    color: Style.colors.primary

    Text {
        color: Style.colors.onPrimary
        font: Style.typography.body
    }
}
```

Component:
- Dark / Light bilmez
- Brand bilmez
- Token dışında hiçbir şey bilmez

---

## 8. Multi‑Brand (White‑Label) Theme Yaklaşımı

### 8.1 Strateji

- **Token interface SABİT**
- Her marka = ayrı Theme dosyası

```
themes/
├── BrandA.qml
├── BrandB.qml
├── OEM.qml
```

### 8.2 Brand Override (Partial Theme)

```qml
import "./Dark.qml" as Base

QtObject {
    readonly property ColorSet colors: ColorSet {
        primary: "#FF9900"   // brand override
        onPrimary: Base.colors.onPrimary
        surface: Base.colors.surface
        onSurface: Base.colors.onSurface
        danger: Base.colors.danger
    }
}
```

Avantaj:
- %90 shared
- %10 override
- Fork yok

---

## 9. Figma → Token Pipeline

### 9.1 Tek Gerçek Kaynak: Design Tokens

Figma tarafında:
- Color / spacing / typography **token olarak** tanımlanır
- Hex değer değil, semantic name kullanılır

Örnek:
```
color.primary
spacing.md
radius.sm
```

### 9.2 Export Aşaması

Pipeline:

```
Figma → JSON → Codegen → QML Theme
```

Üretilen çıktı **SADECE theme dosyasıdır**.

> Token interface ASLA otomatik üretilmez (bilinçli karar)

---

## 10. C++ Compile‑Time Token Enforcement

### 10.1 Amaç

- Yanlış token ismi **derleme aşamasında hata** versin
- QML string lookup tamamen ortadan kalksın

### 10.2 Yaklaşım

```cpp
struct ColorToken {
    enum Id {
        Primary,
        OnPrimary,
        Surface,
        OnSurface,
        Danger
    };
};
```

```cpp
QColor resolveColor(ColorToken::Id id) const;
```

QML tarafı:
```qml
color: Style.colors.primary   // compile‑time bound
```

Sonuç:
- String yok
- Reflection yok
- Runtime crash yok

---

## 11. Neden Kirigami’den Daha Temiz?

| Alan | Kirigami | Bu Sistem |
|---|---|---|
| Theme | data + logic | saf data |
| Override | implicit | explicit |
| Debug | zor | kolay |
| White‑label | sınırlı | doğal |
| Embedded | ağır | hafif |

---

## 12. Sonuç

Bu mimari:
- Qt’nin **binding modeline %100 uyumlu**
- Kirigami’nin güçlü yanlarını alır
- Zayıf soyutlamalarını çöpe atar

> Bu yapı, **bugün Qt ile yapılabilecek en temiz style sistemidir**.

---

**Devam edilebilecek başlıklar:**
- Token diff / migration stratejileri
- Theme unit testing (headless)
- Style performance benchmark
- Material / Fluent üstüne inşa

