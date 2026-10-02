import Foundation

public struct SampleData {
    public static let sampleInstruments: [InstrumentData] = [
        InstrumentData(name: "Voz principal", confidence: 0.98, icon: "mic.fill"),
        InstrumentData(name: "Sintetizador", confidence: 0.87, icon: "pianokeys"),
        InstrumentData(name: "Batería", confidence: 0.82, icon: "circle.grid.cross.fill"),
        InstrumentData(name: "Bajo", confidence: 0.76, icon: "guitars.fill"),
        InstrumentData(name: "Guitarra eléctrica", confidence: 0.42, icon: "bolt.fill"),
        InstrumentData(name: "Teclado", confidence: 0.38, icon: "pianokeys.inverse"),
        InstrumentData(name: "Cuerdas", confidence: 0.21, icon: "waveform.path"),
        InstrumentData(name: "Otros", confidence: 0.12, icon: "ellipsis.circle")
    ]

    public static let sampleChordsBlindingLights: [ChordData] = [
        ChordData.standardChords["Fm"] ?? ChordData(name: "Fm", baseFret: 1, frets: [1, 3, 3, 1, 1, 1]),
        ChordData.standardChords["Ab"] ?? ChordData(name: "Ab", baseFret: 4, frets: [4, 6, 6, 5, 4, 4]),
        ChordData.standardChords["Eb"] ?? ChordData(name: "Eb", baseFret: 6, frets: [-1, 6, 8, 8, 8, 6]),
        ChordData.standardChords["Db"] ?? ChordData(name: "Db", baseFret: 4, frets: [-1, 4, 6, 6, 6, 4])
    ]

    public static let sampleChordsMidnightEcho: [ChordData] = [
        ChordData.standardChords["Bm"] ?? ChordData(name: "Bm", baseFret: 2, frets: [-1, 2, 4, 4, 3, 2]),
        ChordData.standardChords["G"] ?? ChordData(name: "G", baseFret: 1, frets: [3, 2, 0, 0, 0, 3]),
        ChordData.standardChords["D"] ?? ChordData(name: "D", baseFret: 1, frets: [-1, -1, 0, 2, 3, 2]),
        ChordData.standardChords["A"] ?? ChordData(name: "A", baseFret: 1, frets: [-1, 0, 2, 2, 2, 0])
    ]

    // MARK: - Blinding Lights
    public static let blindingLights: MediaTrack = {
        let lines: [TimedLine] = [
            TimedLine(
                startTime: 80.0,
                endTime: 83.5,
                originalText: "I've been on my own for long enough",
                translatedText: "He estado por mi cuenta el tiempo suficiente",
                originalWords: [
                    TimedWord(text: "I've", startTime: 80.0, endTime: 80.4, alignedTargetIndex: 0),
                    TimedWord(text: "been", startTime: 80.4, endTime: 80.8, alignedTargetIndex: 1),
                    TimedWord(text: "on", startTime: 80.8, endTime: 81.2, alignedTargetIndex: 2),
                    TimedWord(text: "my", startTime: 81.2, endTime: 81.6, alignedTargetIndex: 3),
                    TimedWord(text: "own", startTime: 81.6, endTime: 82.2, alignedTargetIndex: 4),
                    TimedWord(text: "for", startTime: 82.2, endTime: 82.6, alignedTargetIndex: 5),
                    TimedWord(text: "long", startTime: 82.6, endTime: 83.0, alignedTargetIndex: 6),
                    TimedWord(text: "enough", startTime: 83.0, endTime: 83.5, alignedTargetIndex: 7)
                ],
                translatedWords: [
                    TimedWord(text: "He", startTime: 80.0, endTime: 80.4),
                    TimedWord(text: "estado", startTime: 80.4, endTime: 80.8),
                    TimedWord(text: "por", startTime: 80.8, endTime: 81.2),
                    TimedWord(text: "mi", startTime: 81.2, endTime: 81.6),
                    TimedWord(text: "cuenta", startTime: 81.6, endTime: 82.2),
                    TimedWord(text: "el", startTime: 82.2, endTime: 82.6),
                    TimedWord(text: "tiempo", startTime: 82.6, endTime: 83.0),
                    TimedWord(text: "suficiente", startTime: 83.0, endTime: 83.5)
                ],
                chord: "Fm"
            ),
            TimedLine(
                startTime: 84.0,
                endTime: 88.0,
                originalText: "I've been tryna call",
                translatedText: "He estado intentando llamar",
                originalWords: [
                    TimedWord(text: "I've", startTime: 84.0, endTime: 84.5, alignedTargetIndex: 0),
                    TimedWord(text: "been", startTime: 84.5, endTime: 85.0, alignedTargetIndex: 1),
                    TimedWord(text: "tryna", startTime: 85.0, endTime: 86.2, alignedTargetIndex: 2),
                    TimedWord(text: "call", startTime: 86.2, endTime: 87.8, alignedTargetIndex: 3)
                ],
                translatedWords: [
                    TimedWord(text: "He", startTime: 84.0, endTime: 84.5),
                    TimedWord(text: "estado", startTime: 84.5, endTime: 85.0),
                    TimedWord(text: "intentando", startTime: 85.0, endTime: 86.2),
                    TimedWord(text: "llamar", startTime: 86.2, endTime: 87.8)
                ],
                chord: "Ab"
            ),
            TimedLine(
                startTime: 88.5,
                endTime: 93.0,
                originalText: "Maybe you can show me how to love, maybe",
                translatedText: "Tal vez puedas mostrarme cómo amar, tal vez",
                originalWords: [
                    TimedWord(text: "Maybe", startTime: 88.5, endTime: 89.2, alignedTargetIndex: 0),
                    TimedWord(text: "you", startTime: 89.2, endTime: 89.6, alignedTargetIndex: 1),
                    TimedWord(text: "can", startTime: 89.6, endTime: 90.0, alignedTargetIndex: 1),
                    TimedWord(text: "show", startTime: 90.0, endTime: 90.6, alignedTargetIndex: 2),
                    TimedWord(text: "me", startTime: 90.6, endTime: 91.0, alignedTargetIndex: 2),
                    TimedWord(text: "how", startTime: 91.0, endTime: 91.4, alignedTargetIndex: 3),
                    TimedWord(text: "to", startTime: 91.4, endTime: 91.7, alignedTargetIndex: 4),
                    TimedWord(text: "love,", startTime: 91.7, endTime: 92.2, alignedTargetIndex: 4),
                    TimedWord(text: "maybe", startTime: 92.2, endTime: 93.0, alignedTargetIndex: 5)
                ],
                translatedWords: [
                    TimedWord(text: "Tal vez", startTime: 88.5, endTime: 89.2),
                    TimedWord(text: "puedas", startTime: 89.2, endTime: 90.0),
                    TimedWord(text: "mostrarme", startTime: 90.0, endTime: 91.0),
                    TimedWord(text: "cómo", startTime: 91.0, endTime: 91.5),
                    TimedWord(text: "amar,", startTime: 91.5, endTime: 92.2),
                    TimedWord(text: "tal vez", startTime: 92.2, endTime: 93.0)
                ],
                chord: "Eb"
            ),
            TimedLine(
                startTime: 93.5,
                endTime: 98.0,
                originalText: "I'm going through withdrawals",
                translatedText: "Estoy pasando por abstinencia",
                originalWords: [
                    TimedWord(text: "I'm", startTime: 93.5, endTime: 94.2, alignedTargetIndex: 0),
                    TimedWord(text: "going", startTime: 94.2, endTime: 94.9, alignedTargetIndex: 1),
                    TimedWord(text: "through", startTime: 94.9, endTime: 95.7, alignedTargetIndex: 2),
                    TimedWord(text: "withdrawals", startTime: 95.7, endTime: 97.5, alignedTargetIndex: 3)
                ],
                translatedWords: [
                    TimedWord(text: "Estoy", startTime: 93.5, endTime: 94.2),
                    TimedWord(text: "pasando", startTime: 94.2, endTime: 94.9),
                    TimedWord(text: "por", startTime: 94.9, endTime: 95.7),
                    TimedWord(text: "abstinencia", startTime: 95.7, endTime: 97.5)
                ],
                chord: "Db"
            )
        ]

        return MediaTrack(
            title: "Blinding Lights",
            artistOrCreator: "The Weeknd",
            albumOrShow: "After Hours",
            year: "2020",
            duration: 200.0,
            mediaType: .music,
            lyricsLines: lines,
            keySignature: "F minor",
            bpm: 171,
            timeSignature: "4/4",
            chords: sampleChordsBlindingLights,
            instruments: sampleInstruments,
            isOfficialLyrics: true,
            aiConfidence: 0.98,
            relativeTimeString: "Hace 2 min",
            gradientColors: ["#8B0000", "#1E0505", "#000000"]
        )
    }()

    // MARK: - Midnight Echo
    public static let midnightEcho: MediaTrack = {
        let lines: [TimedLine] = [
            TimedLine(
                startTime: 78.0,
                endTime: 83.5,
                originalText: "The city sleeps but we're still awake",
                translatedText: "La ciudad duerme pero nosotros seguimos despiertos",
                originalWords: [
                    TimedWord(text: "The", startTime: 78.0, endTime: 78.4, alignedTargetIndex: 0),
                    TimedWord(text: "city", startTime: 78.4, endTime: 79.1, alignedTargetIndex: 1),
                    TimedWord(text: "sleeps", startTime: 79.1, endTime: 80.0, alignedTargetIndex: 2),
                    TimedWord(text: "but", startTime: 80.0, endTime: 80.6, alignedTargetIndex: 3),
                    TimedWord(text: "we're", startTime: 80.6, endTime: 81.4, alignedTargetIndex: 4),
                    TimedWord(text: "still", startTime: 81.4, endTime: 82.2, alignedTargetIndex: 5),
                    TimedWord(text: "awake", startTime: 82.2, endTime: 83.5, alignedTargetIndex: 6)
                ],
                translatedWords: [
                    TimedWord(text: "La", startTime: 78.0, endTime: 78.4),
                    TimedWord(text: "ciudad", startTime: 78.4, endTime: 79.1),
                    TimedWord(text: "duerme", startTime: 79.1, endTime: 80.0),
                    TimedWord(text: "pero", startTime: 80.0, endTime: 80.6),
                    TimedWord(text: "nosotros", startTime: 80.6, endTime: 81.4),
                    TimedWord(text: "seguimos", startTime: 81.4, endTime: 82.2),
                    TimedWord(text: "despiertos", startTime: 82.2, endTime: 83.5)
                ],
                chord: "Bm"
            ),
            TimedLine(
                startTime: 84.0,
                endTime: 89.5,
                originalText: "I hear your voice across the dark",
                translatedText: "Escucho tu voz entre la oscuridad",
                originalWords: [
                    TimedWord(text: "I", startTime: 84.0, endTime: 84.4, alignedTargetIndex: 0),
                    TimedWord(text: "hear", startTime: 84.4, endTime: 85.0, alignedTargetIndex: 0),
                    TimedWord(text: "your", startTime: 85.0, endTime: 85.6, alignedTargetIndex: 1),
                    TimedWord(text: "voice", startTime: 85.6, endTime: 86.8, alignedTargetIndex: 2),
                    TimedWord(text: "across", startTime: 86.8, endTime: 87.6, alignedTargetIndex: 3),
                    TimedWord(text: "the", startTime: 87.6, endTime: 88.2, alignedTargetIndex: 4),
                    TimedWord(text: "dark", startTime: 88.2, endTime: 89.5, alignedTargetIndex: 5)
                ],
                translatedWords: [
                    TimedWord(text: "Escucho", startTime: 84.0, endTime: 85.0),
                    TimedWord(text: "tu", startTime: 85.0, endTime: 85.6),
                    TimedWord(text: "voz", startTime: 85.6, endTime: 86.8),
                    TimedWord(text: "entre", startTime: 86.8, endTime: 87.6),
                    TimedWord(text: "la", startTime: 87.6, endTime: 88.2),
                    TimedWord(text: "oscuridad", startTime: 88.2, endTime: 89.5)
                ],
                chord: "G"
            ),
            TimedLine(
                startTime: 90.0,
                endTime: 95.0,
                originalText: "You pull me closer to the light",
                translatedText: "Me acercas poco a poco hacia la luz",
                originalWords: [
                    TimedWord(text: "You", startTime: 90.0, endTime: 90.5, alignedTargetIndex: 0),
                    TimedWord(text: "pull", startTime: 90.5, endTime: 91.2, alignedTargetIndex: 1),
                    TimedWord(text: "me", startTime: 91.2, endTime: 91.8, alignedTargetIndex: 0),
                    TimedWord(text: "closer", startTime: 91.8, endTime: 92.8, alignedTargetIndex: 2),
                    TimedWord(text: "to", startTime: 92.8, endTime: 93.4, alignedTargetIndex: 3),
                    TimedWord(text: "the", startTime: 93.4, endTime: 94.0, alignedTargetIndex: 4),
                    TimedWord(text: "light", startTime: 94.0, endTime: 95.0, alignedTargetIndex: 5)
                ],
                translatedWords: [
                    TimedWord(text: "Me", startTime: 90.0, endTime: 90.8),
                    TimedWord(text: "acercas", startTime: 90.8, endTime: 91.8),
                    TimedWord(text: "poco a poco", startTime: 91.8, endTime: 92.8),
                    TimedWord(text: "hacia", startTime: 92.8, endTime: 93.6),
                    TimedWord(text: "la", startTime: 93.6, endTime: 94.0),
                    TimedWord(text: "luz", startTime: 94.0, endTime: 95.0)
                ],
                chord: "D"
            ),
            TimedLine(
                startTime: 95.5,
                endTime: 101.0,
                originalText: "We move like shadows in the rain",
                translatedText: "Nos movemos como sombras bajo la lluvia",
                originalWords: [
                    TimedWord(text: "We", startTime: 95.5, endTime: 96.0, alignedTargetIndex: 0),
                    TimedWord(text: "move", startTime: 96.0, endTime: 96.8, alignedTargetIndex: 1),
                    TimedWord(text: "like", startTime: 96.8, endTime: 97.6, alignedTargetIndex: 2),
                    TimedWord(text: "shadows", startTime: 97.6, endTime: 98.8, alignedTargetIndex: 3),
                    TimedWord(text: "in", startTime: 98.8, endTime: 99.4, alignedTargetIndex: 4),
                    TimedWord(text: "the", startTime: 99.4, endTime: 99.9, alignedTargetIndex: 5),
                    TimedWord(text: "rain", startTime: 99.9, endTime: 101.0, alignedTargetIndex: 6)
                ],
                translatedWords: [
                    TimedWord(text: "Nos", startTime: 95.5, endTime: 96.0),
                    TimedWord(text: "movemos", startTime: 96.0, endTime: 96.8),
                    TimedWord(text: "como", startTime: 96.8, endTime: 97.6),
                    TimedWord(text: "sombras", startTime: 97.6, endTime: 98.8),
                    TimedWord(text: "bajo", startTime: 98.8, endTime: 99.4),
                    TimedWord(text: "la", startTime: 99.4, endTime: 99.9),
                    TimedWord(text: "lluvia", startTime: 99.9, endTime: 101.0)
                ],
                chord: "A"
            )
        ]

        return MediaTrack(
            title: "Midnight Echo",
            artistOrCreator: "Luna Rivera",
            albumOrShow: "Nocturne Horizons",
            year: "2024",
            duration: 232.0,
            mediaType: .music,
            lyricsLines: lines,
            keySignature: "B minor",
            bpm: 91,
            timeSignature: "4/4",
            chords: sampleChordsMidnightEcho,
            instruments: [
                InstrumentData(name: "Synthesizer", confidence: 0.94, icon: "pianokeys"),
                InstrumentData(name: "Drum Machine", confidence: 0.89, icon: "circle.grid.cross.fill"),
                InstrumentData(name: "Bass", confidence: 0.86, icon: "guitars.fill"),
                InstrumentData(name: "Electric Guitar", confidence: 0.42, icon: "bolt.fill")
            ],
            isOfficialLyrics: true,
            aiConfidence: 0.99,
            relativeTimeString: "Hace 10 min",
            gradientColors: ["#1B264F", "#274690", "#0D1B2A"]
        )
    }()

    // MARK: - Interstellar
    public static let interstellar: MediaTrack = {
        let lines: [TimedLine] = [
            TimedLine(
                startTime: 761.0,
                endTime: 764.5,
                originalText: "We're not meant to save the world.",
                translatedText: "No estamos destinados a salvar el mundo.",
                originalWords: [
                    TimedWord(text: "We're", startTime: 761.0, endTime: 761.5, alignedTargetIndex: 0),
                    TimedWord(text: "not", startTime: 761.5, endTime: 762.0, alignedTargetIndex: 0),
                    TimedWord(text: "meant", startTime: 762.0, endTime: 762.8, alignedTargetIndex: 2),
                    TimedWord(text: "to", startTime: 762.8, endTime: 763.1, alignedTargetIndex: 3),
                    TimedWord(text: "save", startTime: 763.1, endTime: 763.8, alignedTargetIndex: 4),
                    TimedWord(text: "the", startTime: 763.8, endTime: 764.1, alignedTargetIndex: 5),
                    TimedWord(text: "world.", startTime: 764.1, endTime: 764.5, alignedTargetIndex: 6)
                ],
                translatedWords: [
                    TimedWord(text: "No", startTime: 761.0, endTime: 761.5),
                    TimedWord(text: "estamos", startTime: 761.5, endTime: 762.0),
                    TimedWord(text: "destinados", startTime: 762.0, endTime: 762.8),
                    TimedWord(text: "a", startTime: 762.8, endTime: 763.1),
                    TimedWord(text: "salvar", startTime: 763.1, endTime: 763.8),
                    TimedWord(text: "el", startTime: 763.8, endTime: 764.1),
                    TimedWord(text: "mundo.", startTime: 764.1, endTime: 764.5)
                ]
            ),
            TimedLine(
                startTime: 765.0,
                endTime: 768.5,
                originalText: "Maybe we're meant to find a way.",
                translatedText: "Tal vez estamos destinados a encontrar un camino.",
                originalWords: [
                    TimedWord(text: "Maybe", startTime: 765.0, endTime: 765.6, alignedTargetIndex: 0),
                    TimedWord(text: "we're", startTime: 765.6, endTime: 766.1, alignedTargetIndex: 1),
                    TimedWord(text: "meant", startTime: 766.1, endTime: 766.9, alignedTargetIndex: 2),
                    TimedWord(text: "to", startTime: 766.9, endTime: 767.2, alignedTargetIndex: 3),
                    TimedWord(text: "find", startTime: 767.2, endTime: 767.8, alignedTargetIndex: 4),
                    TimedWord(text: "a", startTime: 767.8, endTime: 768.1, alignedTargetIndex: 5),
                    TimedWord(text: "way.", startTime: 768.1, endTime: 768.5, alignedTargetIndex: 6)
                ],
                translatedWords: [
                    TimedWord(text: "Tal vez", startTime: 765.0, endTime: 765.6),
                    TimedWord(text: "estamos", startTime: 765.6, endTime: 766.1),
                    TimedWord(text: "destinados", startTime: 766.1, endTime: 766.9),
                    TimedWord(text: "a", startTime: 766.9, endTime: 767.2),
                    TimedWord(text: "encontrar", startTime: 767.2, endTime: 767.8),
                    TimedWord(text: "un", startTime: 767.8, endTime: 768.1),
                    TimedWord(text: "camino.", startTime: 768.1, endTime: 768.5)
                ]
            ),
            TimedLine(
                startTime: 769.0,
                endTime: 774.0,
                originalText: "Love is the one thing that transcends time and space.",
                translatedText: "El amor es lo único que trasciende el tiempo y el espacio.",
                originalWords: [
                    TimedWord(text: "Love", startTime: 769.0, endTime: 769.6, alignedTargetIndex: 1),
                    TimedWord(text: "is", startTime: 769.6, endTime: 770.0, alignedTargetIndex: 2),
                    TimedWord(text: "the", startTime: 770.0, endTime: 770.3, alignedTargetIndex: 3),
                    TimedWord(text: "one", startTime: 770.3, endTime: 770.8, alignedTargetIndex: 4),
                    TimedWord(text: "thing", startTime: 770.8, endTime: 771.3, alignedTargetIndex: 4),
                    TimedWord(text: "that", startTime: 771.3, endTime: 771.7, alignedTargetIndex: 5),
                    TimedWord(text: "transcends", startTime: 771.7, endTime: 772.5, alignedTargetIndex: 6),
                    TimedWord(text: "time", startTime: 772.5, endTime: 773.1, alignedTargetIndex: 8),
                    TimedWord(text: "and", startTime: 773.1, endTime: 773.5, alignedTargetIndex: 9),
                    TimedWord(text: "space.", startTime: 773.5, endTime: 774.0, alignedTargetIndex: 11)
                ],
                translatedWords: [
                    TimedWord(text: "El", startTime: 769.0, endTime: 769.3),
                    TimedWord(text: "amor", startTime: 769.3, endTime: 769.8),
                    TimedWord(text: "es", startTime: 769.8, endTime: 770.2),
                    TimedWord(text: "lo", startTime: 770.2, endTime: 770.5),
                    TimedWord(text: "único", startTime: 770.5, endTime: 771.2),
                    TimedWord(text: "que", startTime: 771.2, endTime: 771.6),
                    TimedWord(text: "trasciende", startTime: 771.6, endTime: 772.5),
                    TimedWord(text: "el", startTime: 772.5, endTime: 772.8),
                    TimedWord(text: "tiempo", startTime: 772.8, endTime: 773.3),
                    TimedWord(text: "y", startTime: 773.3, endTime: 773.6),
                    TimedWord(text: "el", startTime: 773.6, endTime: 773.8),
                    TimedWord(text: "espacio.", startTime: 773.8, endTime: 774.0)
                ]
            )
        ]

        return MediaTrack(
            title: "Interstellar",
            artistOrCreator: "Película",
            albumOrShow: "Sci-Fi / Drama",
            year: "2014",
            duration: 2710.0,
            mediaType: .video,
            lyricsLines: lines,
            keySignature: "A minor",
            bpm: 60,
            timeSignature: "3/4",
            isOfficialLyrics: true,
            aiConfidence: 0.99,
            relativeTimeString: "Hace 1 h",
            gradientColors: ["#0B132B", "#1C2541", "#3A506B"]
        )
    }()

    // MARK: - Podcast
    public static let lexFridmanPodcast: MediaTrack = {
        let lines: [TimedLine] = [
            TimedLine(
                startTime: 734.0,
                endTime: 745.0,
                originalText: "I think the most interesting thing about AI is how quickly it's evolving.",
                translatedText: "Creo que lo más interesante sobre la inteligencia artificial es lo rápido que está evolucionando.",
                originalWords: [
                    TimedWord(text: "I", startTime: 734.0, endTime: 734.3, alignedTargetIndex: 0),
                    TimedWord(text: "think", startTime: 734.3, endTime: 734.8, alignedTargetIndex: 0),
                    TimedWord(text: "the", startTime: 734.8, endTime: 735.2, alignedTargetIndex: 1),
                    TimedWord(text: "most", startTime: 735.2, endTime: 735.8, alignedTargetIndex: 2),
                    TimedWord(text: "interesting", startTime: 735.8, endTime: 736.8, alignedTargetIndex: 3),
                    TimedWord(text: "thing", startTime: 736.8, endTime: 737.4, alignedTargetIndex: 3),
                    TimedWord(text: "about", startTime: 737.4, endTime: 738.0, alignedTargetIndex: 4),
                    TimedWord(text: "AI", startTime: 738.0, endTime: 739.0, alignedTargetIndex: 6),
                    TimedWord(text: "is", startTime: 739.0, endTime: 739.4, alignedTargetIndex: 7),
                    TimedWord(text: "how", startTime: 739.4, endTime: 739.9, alignedTargetIndex: 8),
                    TimedWord(text: "quickly", startTime: 739.9, endTime: 741.0, alignedTargetIndex: 9),
                    TimedWord(text: "it's", startTime: 741.0, endTime: 741.8, alignedTargetIndex: 11),
                    TimedWord(text: "evolving.", startTime: 741.8, endTime: 743.0, alignedTargetIndex: 12)
                ],
                translatedWords: [
                    TimedWord(text: "Creo", startTime: 734.0, endTime: 734.8),
                    TimedWord(text: "que", startTime: 734.8, endTime: 735.1),
                    TimedWord(text: "lo", startTime: 735.1, endTime: 735.4),
                    TimedWord(text: "más", startTime: 735.4, endTime: 735.8),
                    TimedWord(text: "interesante", startTime: 735.8, endTime: 736.8),
                    TimedWord(text: "sobre", startTime: 736.8, endTime: 737.6),
                    TimedWord(text: "la", startTime: 737.6, endTime: 738.0),
                    TimedWord(text: "inteligencia", startTime: 738.0, endTime: 738.8),
                    TimedWord(text: "artificial", startTime: 738.8, endTime: 739.5),
                    TimedWord(text: "es", startTime: 739.5, endTime: 739.9),
                    TimedWord(text: "lo", startTime: 739.9, endTime: 740.3),
                    TimedWord(text: "rápido", startTime: 740.3, endTime: 741.2),
                    TimedWord(text: "que", startTime: 741.2, endTime: 741.6),
                    TimedWord(text: "está", startTime: 741.6, endTime: 742.1),
                    TimedWord(text: "evolucionando.", startTime: 742.1, endTime: 743.5)
                ],
                speaker: "Lex Fridman",
                speakerAvatar: "person.circle.fill"
            ),
            TimedLine(
                startTime: 747.0,
                endTime: 757.0,
                originalText: "Exactly, and it's changing the way we work, learn and create.",
                translatedText: "Exactamente, y está cambiando la forma en que trabajamos, aprendemos y creamos.",
                speaker: "Invitado",
                speakerAvatar: "person.wave.2.fill"
            ),
            TimedLine(
                startTime: 759.0,
                endTime: 768.0,
                originalText: "Do you think this will continue in the next 10 years?",
                translatedText: "¿Crees que esto continuará en los próximos 10 años?",
                speaker: "Lex Fridman",
                speakerAvatar: "person.circle.fill"
            )
        ]

        return MediaTrack(
            title: "Lex Fridman Podcast",
            artistOrCreator: "Episodio #421",
            albumOrShow: "Artificial Intelligence",
            year: "2024",
            duration: 8314.0,
            mediaType: .podcast,
            lyricsLines: lines,
            keySignature: "None",
            bpm: 0,
            timeSignature: "",
            isOfficialLyrics: false,
            aiConfidence: 0.94,
            relativeTimeString: "Hace 3 h",
            gradientColors: ["#1F1A24", "#332940", "#141019"]
        )
    }()

    public static let sampleLibrary: [MediaTrack] = [
        blindingLights,
        interstellar,
        lexFridmanPodcast,
        MediaTrack(
            title: "Bohemian Rhapsody",
            artistOrCreator: "Queen",
            albumOrShow: "A Night at the Opera",
            year: "1975",
            duration: 354.0,
            mediaType: .music,
            keySignature: "Bb Major",
            bpm: 72,
            timeSignature: "4/4",
            relativeTimeString: "Hace 1 día",
            gradientColors: ["#4A154B", "#2E1A47", "#120826"]
        ),
        MediaTrack(
            title: "Oppenheimer",
            artistOrCreator: "Película",
            albumOrShow: "Biopic / Drama",
            year: "2023",
            duration: 10800.0,
            mediaType: .video,
            keySignature: "D minor",
            bpm: 80,
            timeSignature: "4/4",
            relativeTimeString: "Hace 2 días",
            gradientColors: ["#4A2810", "#28170B", "#100904"]
        ),
        MediaTrack(
            title: "TED: The future of AI",
            artistOrCreator: "Charla · 18 min",
            albumOrShow: "TED Conferences",
            year: "2024",
            duration: 1080.0,
            mediaType: .podcast,
            relativeTimeString: "Hace 3 días",
            gradientColors: ["#801A1A", "#330B0B", "#140404"]
        )
    ]

    public static let sampleLanguagePacks: [LanguagePack] = [
        LanguagePack(id: "es", name: "Español", flagEmoji: "🇪🇸", sizeMB: 412, isInstalled: true),
        LanguagePack(id: "en", name: "Inglés", flagEmoji: "🇬🇧", sizeMB: 386, isInstalled: true),
        LanguagePack(id: "fr", name: "Francés", flagEmoji: "🇫🇷", sizeMB: 338, isInstalled: false),
        LanguagePack(id: "de", name: "Alemán", flagEmoji: "🇩🇪", sizeMB: 433, isInstalled: false),
        LanguagePack(id: "it", name: "Italiano", flagEmoji: "🇮🇹", sizeMB: 403, isInstalled: false),
        LanguagePack(id: "ja", name: "Japonés", flagEmoji: "🇯🇵", sizeMB: 833, isInstalled: false),
        LanguagePack(id: "pt", name: "Portugués", flagEmoji: "🇵🇹", sizeMB: 413, isInstalled: false)
    ]

    public static let sampleAIModels: [LanguagePack] = [
        LanguagePack(id: "whisper", name: "Reconocimiento de voz", subtitle: "Whisper ASR local", flagEmoji: "🎙️", sizeMB: 1228, isInstalled: true, category: .aiModel),
        LanguagePack(id: "shazam", name: "Reconocimiento musical", subtitle: "Catálogo acústico local", flagEmoji: "🎵", sizeMB: 620, isInstalled: true, category: .aiModel),
        LanguagePack(id: "essentia_chords", name: "Análisis de acordes", subtitle: "Algoritmo HPCP Essentia", flagEmoji: "🎸", sizeMB: 310, isInstalled: false, category: .aiModel),
        LanguagePack(id: "instruments", name: "Detección de instrumentos", subtitle: "Clasificador multi-etiqueta", flagEmoji: "🥁", sizeMB: 780, isInstalled: false, category: .aiModel)
    ]
}
