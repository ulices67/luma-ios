# 🎵 Luma — Traductor Multimedia & Analizador Musical en Tiempo Real para iPhone

**Luma** es una aplicación nativa para iOS (Swift / SwiftUI) diseñada como un sistema universal de escucha, transcripción, traducción sincronizada palabra por palabra y análisis acústico-musical en tiempo real. 

Funciona para **música, películas, videos, podcasts, conferencias y audio capturado con el micrófono o reproducido en el dispositivo**.

---

## 📱 Pantallas y Flujos Implementados

La app reproduce al 100% el diseño y las especificaciones visuales de los mockups:

1. **Inicio (`HomeView`)**:
   - Selector rápido 2x2: **Música**, **Video**, **Micrófono** y **Archivo**.
   - Barra de búsqueda y pegado de enlaces multimedia.
   - Historial de recientes con acceso inmediato a reproducción.
   - Botón central flotante de escucha rápida con animación táctil.

2. **Música y Letras Sincronizadas (`AppleMusicStylePlayerView` & `MusicLyricsView`)**:
   - Estilo **Apple Music Lyrics** con fondo oscuro atmosférico dinámico y desenfoque gausiano.
   - Relleno progresivo letra por letra (`KaraokeWordView` con máscara geométrica `width = progress * totalWidth`) según los timestamps exactos de cada palabra (`TimedWord`).
   - Modos de visualización: **Original**, **Español**, **Ambos** y **Acordes**.
   - **Alineación de traducción original ↔ español**: Cuando el cantante pronuncia una palabra (*"tryna"* / *"voice"*), se ilumina en tiempo real la palabra correspondiente en español (*"intentando"* / *"voz"*).
   - Drawer inferior acoplable con **Acordes** (`Bm · G · D · A` / `Fm · Ab · Eb · Db`) e **Instrumentos** (`Synth · Bass · Drums`).

3. **Películas y Series (`VideoPlayerView`)**:
   - Marco de video panorámico con marcas de tiempo sincronizadas.
   - Subtítulos flotantes o en línea con resaltado en cápsula azul suave para la palabra activa.
   - Controles de salto retroceso/avance (-10s / +15s), selector de posición y botón de subtítulos CC.

4. **Podcasts y Conversaciones (`PodcastPlayerView`)**:
   - Transcripción dividida por hablantes (*Speaker Diarization*): Host (*Lex Fridman*) e Invitado con avatares independientes y marcas de tiempo.
   - Pestañas secundarias de **Transcripción**, **Resumen de IA** y **Notas del episodio**.
   - Selector de velocidad de audio (1.0x, 1.25x, 1.5x, 2.0x) y scrubber de forma de onda.

5. **Modo Músico y Análisis Acústico (`MusicAnalyzerView`)**:
   - **Instrumentos detectados** con barras de confianza: *Voz principal (98%), Sintetizador (87%), Batería (82%), Bajo (76%), Guitarra eléctrica (42%), Teclado (38%), Cuerdas (21%), Otros (12%)*.
   - **Progresión armónica**: Tonalidad (*F minor / B minor*), Tempo (*171 BPM / 91 BPM*), Compás (*4/4*) y línea de tiempo armónica.
   - **Diagramas de acordes de guitarra interactivos (`GuitarChordDiagramView`)**: Fretboard dibujado en vector con cuerdas (E A D G B e), cejillas (*barres*), trastes, dedos recomendados e indicadores de cuerdas pulsadas/muteadas.
   - **Controles de transposición**: Ajuste en semitonos `[-] / [+]` y Capo.

6. **Radar de Escucha en Directo (`ListeningView`)**:
   - Ondas concéntricas animadas (*Radar Pulse*) alrededor del micrófono central.
   - Visualizador de espectro de audio en tiempo real (`AudioVisualizerBarView`).
   - Tarjeta de reconocimiento automático *"Canción encontrada"* que abre inmediatamente la vista del reproductor.

7. **Traducción en Vivo Flotante (`FloatingPipCapsuleView`)**:
   - Ventana flotante estilo *Picture-in-Picture* arrastrable con gestos (`DragGesture`).
   - Vista compacta con palabra destacada en píldora azul y vista expandida con controles de tamaño de texto, estilo, posición y pausa.

8. **Ajustes de Subtítulos (`SubtitleSettingsView`)**:
   - Idioma original (Automático, Inglés, etc.) y traducción de destino.
   - Selector de estilo de tema: **Claro**, **Oscuro**, **Sistema** y **Personalizado**.
   - Slider de tamaño de fuente y posicionamiento: **Inferior**, **Centro** o **Superior**.
   - Modo de traducción: **Natural** o **Literal**.

9. **Gestor de Idiomas y Modelos Offline (`OfflineLanguagesView`)**:
   - Paquetes de idiomas descargables: Español (412 MB), Inglés (386 MB), Francés (338 MB), Alemán (433 MB), Italiano, Japonés, Portugués.
   - Modelos neuronales en dispositivo: *Whisper ASR (1.2 GB), Catálogo Shazam local (620 MB), Acordes Essentia HPCP (310 MB), Clasificador de instrumentos (780 MB)*.
   - Simulador de descarga con barra de progreso y cálculo de almacenamiento en disco.

10. **Biblioteca e Historial (`LibraryView`)**:
    - Filtros por categoría: **Todo**, **Música**, **Videos**, **Podcasts**, **Archivos**.
    - Acceso rápido con orden cronológico y metadatos relativos (*"Hace 2 min"*, *"Hace 1 h"*).

---

## 🛠️ Requisitos de Compilación

- **iOS Target**: iOS 17.0 o superior (compatible con iPhone 11 hasta iPhone 16 Pro Max y iPad).
- **Lenguaje**: Swift 5.9 / Swift 6.0.
- **Frameworks**:
  - `SwiftUI`
  - `AVFAudio` / `AVFoundation`
  - `ShazamKit`
  - `Combine`

---

## 🚀 Cómo Compilar y Ejecutar en iPhone

### Opción 1: Abrir con Xcode (Recomendado)

1. Abre la carpeta del proyecto en tu Mac.
2. Haz doble clic en el archivo:
   ```bash
   Luma.xcodeproj
   ```
3. Selecciona tu dispositivo de destino:
   - **Tu iPhone físico conectado por cable o Wi-Fi**, o
   - **Cualquier Simulador de iPhone con iOS 17 o iOS 18** (ej. *iPhone 16 Pro*).
4. Pulsa **Run** (`⌘R` o el botón ▶ de la barra superior).
5. La app compilará limpiamente sin dependencias externas pesadas adicionales y se ejecutará de inmediato.

### Opción 2: Compilar mediante Swift Package Manager

También puedes abrir directamente el archivo `Package.swift`:
```bash
open Package.swift
```
o compilar con:
```bash
swift build
```

---

## 📂 Estructura del Código

```text
c:\Users\urite\Downloads\luma\
├── Luma.xcodeproj/
│   └── project.pbxproj         # Configuración del proyecto Xcode para iOS 17+
├── Package.swift               # Soporte para Swift Package Manager
├── Luma/
│   ├── App/
│   │   ├── LumaApp.swift       # Inicialización de AVAudioSession y ciclo de vida de la App
│   │   └── ContentView.swift   # Envoltura de MainTabView
│   ├── Models/
│   │   ├── TimedWord.swift     # Timestamps palabra por palabra, progreso y alineación
│   │   ├── TimedLine.swift     # Línea sincronizada con acordes, hablantes y palabras
│   │   ├── ChordData.swift     # Datos de digitación para mástil de guitarra y librería de acordes
│   │   ├── InstrumentData.swift# Detección de instrumentos con % de confianza
│   │   ├── MediaTrack.swift    # Modelo de canciones, clips de video y podcasts
│   │   ├── LanguagePack.swift  # Modelos de idiomas y modelos de IA descargables
│   │   └── SubtitleSettings.swift # Configuración de estilo, tamaño y posición
│   ├── Services/
│   │   ├── AudioRecognitionService.swift # Integración ShazamKit + motor de captura y simulación
│   │   ├── MusicAnalysisService.swift    # Transposición tonal y detección de instrumentación
│   │   ├── TranslationService.swift      # Motor de alineación semántica y traducción
│   │   └── OfflineManager.swift          # Gestión de descargas y almacenamiento local
│   ├── ViewModels/
│   │   ├── AppState.swift                # Estado global y navegación
│   │   ├── PlayerViewModel.swift         # Sincronización y timer de reproducción
│   │   └── MusicAnalyzerViewModel.swift  # Estado de análisis de acordes y transposición
│   ├── Views/
│   │   ├── MainTabView.swift             # Navegación principal con botón central flotante
│   │   ├── Components/
│   │   │   ├── KaraokeWordView.swift     # Relleno de texto tipo Apple Music y badge pill
│   │   │   ├── GuitarChordDiagramView.swift # Diagramas vectoriales de mástil de guitarra
│   │   │   ├── AudioVisualizerBarView.swift # Barras de espectro de audio animadas
│   │   │   ├── RadarPulseView.swift      # Ondas de radar de escucha
│   │   │   ├── FloatingPipCapsuleView.swift # Ventana flotante PIP arrastrable
│   │   │   ├── CustomScrubberView.swift  # Scrubber interactivo con marcas de tiempo
│   │   │   └── ColorExtension.swift      # Soporte para códigos de color Hex
│   │   ├── Home/
│   │   │   └── HomeView.swift            # Pantalla principal con tarjetas 2x2
│   │   ├── Listening/
│   │   │   └── ListeningView.swift       # Pantalla de escucha y detección de canción
│   │   ├── Music/
│   │   │   ├── AppleMusicStylePlayerView.swift # Modo letras inmersivo tipo Apple Music
│   │   │   └── MusicLyricsView.swift     # Modo letras con pill highlights
│   │   ├── Video/
│   │   │   └── VideoPlayerView.swift     # Reproductor de películas y series con subtítulos
│   │   ├── Podcast/
│   │   │   └── PodcastPlayerView.swift   # Podcast con detección de hablantes
│   │   ├── Analyzer/
│   │   │   └── MusicAnalyzerView.swift   # Instrumentos, progresión y acordes
│   │   ├── Settings/
│   │   │   ├── SubtitleSettingsView.swift # Ajustes de apariencia de subtítulos
│   │   │   └── OfflineLanguagesView.swift # Descarga de idiomas y modelos de IA
│   │   └── Library/
│   │       └── LibraryView.swift         # Biblioteca y filtro de historial
│   └── Resources/
│       ├── SampleData.swift              # Canciones, películas y podcasts con letras sincronizadas
│       ├── Info.plist                    # Permisos de micrófono y audio en segundo plano
│       └── Assets.xcassets/              # Iconos y paleta de acentos
```
