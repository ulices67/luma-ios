# 🎵 Luma — Traductor Multimedia & Analizador Musical en Tiempo Real para iPhone

**Luma** es una aplicación nativa para iOS (Swift / SwiftUI) diseñada como un sistema universal de escucha, transcripción, traducción sincronizada palabra por palabra y análisis acústico-musical en tiempo real. 

Funciona para **música, películas, videos, podcasts, conferencias y audio capturado con el micrófono o reproducido en el dispositivo**, con **detección y traducción 100% REAL** (sin simulaciones).

---

## ⚡ Novedades Principales

### 1. 🎛️ Widget para el Centro de Control (iOS 18+) & Live Activities (Dynamic Island)
- **Widget de Centro de Control (`LumaControlCenterWidget`)**:
  - Implementado con el protocolo `ControlWidget` (iOS 18) y `AppIntent` (`RecognizeAndTranslateIntent`).
  - Permite activar la escucha y traducción instantánea con un toque desde el Centro de Control de iOS sin tener que buscar la app.
- **Actividades en Vivo & Dynamic Island (`LumaLyricsLiveActivity`)**:
  - Utiliza `ActivityKit` para proyectar la canción detectada y la letra en curso.
  - **Dynamic Island Compacto**: Muestra el icono de onda de Luma y el acorde actual (`Bm`, `Fm`, etc.).
  - **Dynamic Island Expandido**: Título de la pista, artista, letra original y traducción al español debajo.
  - **Pantalla de Bloqueo / StandBy**: Banner persistente con subtítulos en tiempo real mientras escuchas música en Spotify, Apple Music o el entorno.
- **Widget de Pantalla de Inicio (`LumaHomeWidget`)**:
  - Formatos pequeño, mediano y grande con actualización en directo.

### 2. 🧠 Motores 100% Reales (Sin Simulaciones)
- **Reconocimiento Acústico ShazamKit**: Captura del búfer del micrófono mediante `AVAudioEngine` y emparejamiento con el catálogo global de firmas acústicas de Apple (`SHSession`).
- **Letras Sincronizadas LRCLIB Real**: Conexión a la API de LRCLIB (`https://lrclib.net/api/get`), extrayendo el contenido LRC sincronizado con marcas de tiempo a nivel de milisegundos.
- **Transcripción de Voz en Dispositivo (`SFSpeechRecognizer`)**: Reconocimiento neural local de Apple (`requiresOnDeviceRecognition = true`) que genera marcas de tiempo reales palabra por palabra (`segment.timestamp`, `segment.duration`).
- **Traducción en Tiempo Real (`Translation` & `NaturalLanguage`)**: Detección automática del idioma original con `NLLanguageRecognizer` y traducción en el dispositivo con `TranslationSession` o edge translator con preservación de alineación.
- **Análisis Armónico FFT Real (`Accelerate` / `vDSP`)**: Descomposición matemática de Fourier en tiempo real del búfer del micrófono, generando perfiles cromáticos de 12 semitonos (C a B) y detección de acordes y frecuencias instrumentales.

### 3. 🔐 Sistema de Autenticación Completo (`AuthService`)
- **Iniciar sesión con Apple (`SignInWithAppleButton`)** nativo de iOS.
- **Autenticación con Correo Electrónico y Contraseña**.
- **Modo Invitado (Offline)** para uso inmediato sin conexión.
- Almacenamiento seguro de tokens y perfil de usuario con indicador PRO.

### 4. ☁️ Conexión a Cloudflare Edge para Actualizaciones OTA
- Integración en `CloudflareService`:
  - Conexión a endpoints de Cloudflare Workers y almacenamiento R2.
  - Verificación de actualizaciones Over-The-Air (OTA) de nuevos modelos neuronales CoreML (Whisper, clasificadores de instrumentos, diccionarios de traducción).
  - Sincronización de biblioteca y favoritos.
  - Soporte de caché perimetral HTTP con cabeceras `ETag`.

### 5. 🎨 Icono Oficial Luma Integrado
- Se ha integrado el icono oficial con el diseño de 5 barras de onda azul vibrante en cápsula vertical sobre fondo blanco.
- Configurado en `Assets.xcassets/AppIcon.appiconset` (1024x1024 universal) y `Assets.xcassets/LumaLogo.imageset`.
- Componente vectorial nativo `LumaLogoView` para renderizado dinámico en cualquier resolución.

---

## 📱 Pantallas y Flujos de la App

1. **Inicio (`HomeView`)**: Selector 2x2 (Música, Video, Micrófono, Archivo), buscador con soporte de enlaces, perfil de usuario y recientes.
2. **Música y Letras Sincronizadas (`AppleMusicStylePlayerView` & `MusicLyricsView`)**: Estilo Apple Music con fondo atmosférico desenfocado, relleno progresivo letra por letra (`KaraokeWordView`), selector Original / Español / Ambos / Acordes, y barra inferior con acordes e instrumentos.
3. **Películas y Series (`VideoPlayerView`)**: Subtítulos bilingües interactivos con palabra activa en cápsula azul.
4. **Podcasts (`PodcastPlayerView`)**: Diarización de hablantes (Host e Invitado), transcripción bilingüe y control de velocidad.
5. **Modo Músico (`MusicAnalyzerView`)**: Porcentajes de confianza de instrumentos, progresión de acordes, transposición en semitonos y mástiles de acordes de guitarra interactivos (`GuitarChordDiagramView`).
6. **Radar de Escucha (`ListeningView`)**: Ondas de radar concéntricas (`RadarPulseView`), visualizador de espectro (`AudioVisualizerBarView`) y detección automática.
7. **Traductor Flotante PiP (`FloatingPipCapsuleView`)**: Ventana flotante arrastrable sobre cualquier contenido.
8. **Ajustes de Subtítulos (`SubtitleSettingsView`)**: Personalización de temas (Claro, Oscuro, Sistema), tamaño y posición.
9. **Idiomas sin Conexión (`OfflineLanguagesView`)**: Gestor de paquetes y estado de conexión a Cloudflare Edge.
10. **Biblioteca (`LibraryView`)**: Historial clasificado con filtros.

---

## 🛠️ Requisitos y Compilación

- **Requisitos**: macOS con Xcode 15 o Xcode 16.
- **Destino**: iOS 17.0+ (compatible con iOS 18).
- **Dispositivos**: iPhone 11 en adelante, iPhone 16 / 16 Pro, iPad.

### Pasos para Compilar:

1. Abre la carpeta `luma` en tu Mac:
   ```bash
   open Luma.xcodeproj
   ```
2. Selecciona tu **iPhone físico** o un **Simulador (iPhone 16 Pro)**.
3. Presiona **`⌘ + R`** (Build & Run).
4. La app compilará limpiamente con todas las capacidades activas.

---

## 📂 Arquitectura del Proyecto

```text
c:\Users\urite\Downloads\luma\
├── Luma.xcodeproj/
│   └── project.pbxproj            # Proyecto Xcode actualizado con widgets y servicios
├── Package.swift                  # Swift Package Manager
├── README.md                      # Documentación completa
└── Luma/
    ├── App/
    │   ├── LumaApp.swift          # AVAudioSession y ciclo de vida de la app
    │   └── ContentView.swift      # Envoltura principal
    ├── Models/
    │   ├── TimedWord.swift        # Timestamps palabra por palabra, progreso y alineación
    │   ├── TimedLine.swift        # Líneas sincronizadas con acordes y hablantes
    │   ├── ChordData.swift        # Digitación para mástil de guitarra y librería de acordes
    │   ├── InstrumentData.swift   # Confianza de clasificación de instrumentos
    │   ├── MediaTrack.swift       # Modelo multimedia unificado
    │   ├── LanguagePack.swift     # Paquetes de idiomas y modelos de IA offline
    │   ├── SubtitleSettings.swift # Configuración de subtítulos
    │   └── UserSession.swift      # Sesión de usuario para autenticación y Cloudflare
    ├── Services/
    │   ├── AudioRecognitionService.swift      # Orquestador de escucha en vivo
    │   ├── RealLyricsService.swift            # Conexión LRCLIB para letras sincronizadas reales
    │   ├── RealSpeechTranscriptionService.swift # Transcripción neural SFSpeechRecognizer
    │   ├── RealTranslationService.swift       # Traducción real en dispositivo y edge
    │   ├── RealAudioHarmonicService.swift     # FFT vDSP de Accelerate y detección de acordes
    │   ├── AuthService.swift                  # Iniciar sesión con Apple y correo
    │   ├── CloudflareService.swift            # Actualizaciones OTA y sincronización Cloudflare
    │   ├── MusicAnalysisService.swift         # Transposición armónica
    │   └── OfflineManager.swift               # Gestor de modelos locales
    ├── ViewModels/
    │   ├── AppState.swift                     # Estado global y navegación
    │   ├── PlayerViewModel.swift              # Timer y sincronización
    │   └── MusicAnalyzerViewModel.swift       # Estado de instrumentos y acordes
    ├── Views/
    │   ├── MainTabView.swift                  # Barra de pestañas y botón central
    │   ├── Components/
    │   │   ├── LumaLogoView.swift             # Icono oficial Luma vectorial
    │   │   ├── KaraokeWordView.swift          # Relleno progresivo Apple Music
    │   │   ├── GuitarChordDiagramView.swift   # Mástil vectorial de guitarra
    │   │   ├── AudioVisualizerBarView.swift   # Espectro de ondas animado
    │   │   ├── RadarPulseView.swift           # Ondas de radar concéntricas
    │   │   ├── FloatingPipCapsuleView.swift   # Ventana flotante PiP
    │   │   └── CustomScrubberView.swift       # Barra de progreso táctil
    │   ├── Home/HomeView.swift
    │   ├── Listening/ListeningView.swift
    │   ├── Music/
    │   │   ├── AppleMusicStylePlayerView.swift
    │   │   └── MusicLyricsView.swift
    │   ├── Video/VideoPlayerView.swift
    │   ├── Podcast/PodcastPlayerView.swift
    │   ├── Analyzer/MusicAnalyzerView.swift
    │   ├── Auth/
    │   │   ├── LoginView.swift                # Iniciar sesión con Apple y correo
    │   │   └── UserProfileView.swift          # Perfil y estado de Cloudflare
    │   ├── Settings/
    │   │   ├── SubtitleSettingsView.swift
    │   │   └── OfflineLanguagesView.swift
    │   └── Library/LibraryView.swift
    ├── Widgets/
    │   ├── LumaWidgetsBundle.swift            # Bundle de widgets
    │   ├── LumaControlWidget.swift            # Control Center Widget (iOS 18)
    │   ├── LumaLyricsLiveActivity.swift       # Live Activity & Dynamic Island
    │   └── LumaHomeWidget.swift               # Widget de Pantalla de Inicio / Bloqueo
    └── Resources/
        ├── Info.plist                         # Permisos de micrófono, voz y Live Activities
        ├── SampleData.swift                   # Datos de muestra de alta fidelidad
        └── Assets.xcassets/
            ├── AppIcon.appiconset/            # Icono oficial Luma 1024x1024
            ├── LumaLogo.imageset/             # Asset de imagen del logo
            └── AccentColor.colorset/          # Color de acento azul Luma
```
