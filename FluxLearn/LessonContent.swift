import Foundation

struct LessonContent {
    static func pages(for lessonTitle: String) -> [LessonPage] {
        guard let lesson = LessonRepository.all.first(where: { $0.title == lessonTitle }) else {
            return [LessonPage(title: "Coming Soon", explanation: "This lesson is under development.", codeExample: nil, hint: nil)]
        }

        let paragraphs = splitIntoParagraphs(lesson.content, count: 4)

        switch lesson.id {
        case 0:
            return [
                LessonPage(
                    title: "Origins of the Sundial",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "The gnomon must point toward the celestial pole for accurate readings."
                ),
                LessonPage(
                    title: "The Hemicyclium & Roman Sundials",
                    explanation: paragraphs[1],
                    codeExample: "Shadow angle = 15° × hours from noon\nAt latitude φ, gnomon tilt = φ",
                    hint: "Berossus designed the hemicyclium around 300 BCE."
                ),
                LessonPage(
                    title: "Temporal vs Equal Hours",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Temporal hours varied in length with the seasons."
                ),
                LessonPage(
                    title: "Legacy of Shadow Clocks",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Augustus installed an obelisk sundial 30 meters tall."
                ),
            ]

        case 1:
            return [
                LessonPage(
                    title: "What Is a Clepsydra?",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Clepsydra means 'water thief' in Greek."
                ),
                LessonPage(
                    title: "Ctesibius & Inflow Clocks",
                    explanation: paragraphs[1],
                    codeExample: "Flow rate Q = A × √(2gh)\nwhere h = water height, A = orifice area",
                    hint: "Ctesibius used feedback regulation to maintain constant flow."
                ),
                LessonPage(
                    title: "Su Song's Clock Tower",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Su Song's tower was 12 meters tall with rotating mannequins."
                ),
                LessonPage(
                    title: "3000 Years of Water Clocks",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Water clocks were the most accurate timekeepers for millennia."
                ),
            ]

        case 2:
            return [
                LessonPage(
                    title: "Candle Clocks of King Alfred",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Metal pins falling onto plates created audible alarms."
                ),
                LessonPage(
                    title: "Incense Clocks of East Asia",
                    explanation: paragraphs[1],
                    codeExample: "Burn rate ≈ 1 inch per ~20 minutes\nTotal candle time = height × rate",
                    hint: "Different scented incense marked different time intervals."
                ),
                LessonPage(
                    title: "Geisha Time Billing",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Incense stick length determined the session price."
                ),
                LessonPage(
                    title: "Chemistry as Chronometry",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Combustion is a valid chronometric principle."
                ),
            ]

        case 3:
            return [
                LessonPage(
                    title: "The Verge-and-Foliot",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "The verge is a vertical shaft with two pallets."
                ),
                LessonPage(
                    title: "How Escapements Work",
                    explanation: paragraphs[1],
                    codeExample: "Energy stored → Crown wheel turns\n→ Pallet catches tooth → Oscillation\n→ Pallet releases → Repeat",
                    hint: "An escapement regulates the release of stored energy."
                ),
                LessonPage(
                    title: "First Public Clocks",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Milan's Sant'Eustorgio had a clock by 1309."
                ),
                LessonPage(
                    title: "750 Years of Mechanical Watches",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Every mechanical watch uses a descendant of this invention."
                ),
            ]

        case 4:
            return [
                LessonPage(
                    title: "Galileo's Discovery",
                    explanation: paragraphs[0],
                    codeExample: "Period T = 2π × √(L / g)\nL = pendulum length, g = 9.81 m/s²",
                    hint: "Galileo timed oscillations against his own pulse."
                ),
                LessonPage(
                    title: "Huygens' Pendulum Clock",
                    explanation: paragraphs[1],
                    codeExample: nil,
                    hint: "Accuracy improved from 15 min/day to 15 sec/day — a 60× gain."
                ),
                LessonPage(
                    title: "The Cycloidal Curve",
                    explanation: paragraphs[2],
                    codeExample: "Cycloid: x = r(θ − sinθ), y = r(1 − cosθ)\nTrue isochronous path",
                    hint: "A cycloid path makes the pendulum truly isochronous."
                ),
                LessonPage(
                    title: "Legacy of the Pendulum",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "A 1-meter pendulum has a period of almost exactly 2 seconds."
                ),
            ]

        case 5:
            return [
                LessonPage(
                    title: "The Longitude Problem",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "The British Parliament offered £20,000 for a longitude solution."
                ),
                LessonPage(
                    title: "Harrison's Marine Chronometers",
                    explanation: paragraphs[1],
                    codeExample: "Longitude = (Time_local − Time_ref) × 15°/hour\n1 second error ≈ 0.25 nautical miles",
                    hint: "Harrison spent 31 years building five chronometers."
                ),
                LessonPage(
                    title: "The H4 Revolution",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "H4 lost only 5.1 seconds over 81 days at sea."
                ),
                LessonPage(
                    title: "Mapping the World",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Harrison's principles remain in high-end watchmaking today."
                ),
            ]

        case 6:
            return [
                LessonPage(
                    title: "The Piezoelectric Effect",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Pierre and Jacques Curie discovered piezoelectricity in 1880."
                ),
                LessonPage(
                    title: "How Quartz Oscillators Work",
                    explanation: paragraphs[1],
                    codeExample: "Frequency: 32,768 Hz = 2¹⁵\n15 flip-flop dividers → 1 Hz output\nAccuracy: ~15 seconds/month",
                    hint: "32,768 is a power of 2, making binary division trivial."
                ),
                LessonPage(
                    title: "The Quartz Crisis",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Seiko's Astron (1969) was the first quartz wristwatch."
                ),
                LessonPage(
                    title: "Modern Precision",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "OCXO achieves ~0.3 seconds per year accuracy."
                ),
            ]

        case 7:
            return [
                LessonPage(
                    title: "The First Cesium Clock",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Essen and Parry built the first cesium clock in 1955."
                ),
                LessonPage(
                    title: "Redefining the Second",
                    explanation: paragraphs[1],
                    codeExample: "1 second = 9,192,631,770 periods\nof Cs-133 hyperfine transition",
                    hint: "Cesium is the literal definition of time since 1967."
                ),
                LessonPage(
                    title: "Fountain Clocks",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "NIST-F2 is accurate to ~1 second in 300 million years."
                ),
                LessonPage(
                    title: "Atomic Clocks in GPS",
                    explanation: paragraphs[3],
                    codeExample: "GPS position error without atomic clocks:\n~10 km per day",
                    hint: "GPS depends on nanosecond timing between satellites."
                ),
            ]

        case 8:
            return [
                LessonPage(
                    title: "Beyond Microwaves",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Optical clocks use visible light at ~500 THz."
                ),
                LessonPage(
                    title: "The Optical Lattice",
                    explanation: paragraphs[1],
                    codeExample: "Optical frequency: ~500 THz\nFractional uncertainty: 1.4 × 10⁻¹⁸\nDetects 2 cm altitude change",
                    hint: "The 'magic wavelength' prevents the trap from shifting the clock transition."
                ),
                LessonPage(
                    title: "Gravitational Redshift Detection",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "Jun Ye's group detected redshift from raising a clock 2 cm."
                ),
                LessonPage(
                    title: "Redefining Time Itself",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "These clocks could enable relativistic geodesy."
                ),
            ]

        case 9:
            return [
                LessonPage(
                    title: "300 Local Times",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "The US had over 300 local times before 1883."
                ),
                LessonPage(
                    title: "The 1884 Meridian Conference",
                    explanation: paragraphs[1],
                    codeExample: "24 time zones × 15° each = 360°\nUTC offset = longitude ÷ 15",
                    hint: "Greenwich was chosen as Prime Meridian by 22-to-1 vote."
                ),
                LessonPage(
                    title: "France's Resistance",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "France called it 'Paris Mean Time retarded by 9 minutes 21 seconds.'"
                ),
                LessonPage(
                    title: "UTC and Leap Seconds",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "UTC is maintained by ~450 atomic clocks worldwide."
                ),
            ]

        case 10:
            return [
                LessonPage(
                    title: "Special Relativity",
                    explanation: paragraphs[0],
                    codeExample: "Time dilation factor:\nγ = 1 / √(1 − v²/c²)\nAt 0.9c → γ ≈ 2.29",
                    hint: "At 90% of light speed, time passes at 43.6% normal rate."
                ),
                LessonPage(
                    title: "General Relativity & Gravity",
                    explanation: paragraphs[1],
                    codeExample: nil,
                    hint: "Clocks run slower in stronger gravitational fields."
                ),
                LessonPage(
                    title: "GPS Relativistic Corrections",
                    explanation: paragraphs[2],
                    codeExample: "GR effect: +45 μs/day (faster)\nSR effect: −7 μs/day (slower)\nNet: +38 μs/day correction needed",
                    hint: "Without corrections, GPS would drift ~11 km/day."
                ),
                LessonPage(
                    title: "Hafele–Keating Experiment",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "Cesium clocks on airliners confirmed time dilation in 1971."
                ),
            ]

        case 11:
            return [
                LessonPage(
                    title: "Nuclear Clocks",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "Thorium-229 nuclear transitions could achieve 10⁻¹⁹ uncertainty."
                ),
                LessonPage(
                    title: "Entanglement-Enhanced Clocks",
                    explanation: paragraphs[1],
                    codeExample: "Standard quantum limit: δf ∝ 1/√N\nEntangled limit: δf ∝ 1/N\nN = number of atoms",
                    hint: "Quantum correlations surpass the standard quantum limit."
                ),
                LessonPage(
                    title: "Chip-Scale Atomic Clocks",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "CSACs are only 17 cm³ at 120 mW power."
                ),
                LessonPage(
                    title: "Philosophical Implications",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "10⁻²⁰ precision may detect quantum gravity signatures."
                ),
            ]

        case 12:
            return [
                LessonPage(
                    title: "The Suprachiasmatic Nucleus",
                    explanation: paragraphs[0],
                    codeExample: nil,
                    hint: "The SCN is a cluster of ~20,000 neurons in the hypothalamus."
                ),
                LessonPage(
                    title: "Molecular Clock Mechanism",
                    explanation: paragraphs[1],
                    codeExample: "CLOCK + BMAL1 → activate PER & CRY\nPER + CRY → inhibit CLOCK/BMAL1\nCycle duration: ~24 hours",
                    hint: "This feedback loop won the 2017 Nobel Prize."
                ),
                LessonPage(
                    title: "Simplest Known Clock",
                    explanation: paragraphs[2],
                    codeExample: nil,
                    hint: "KaiA, KaiB, KaiC maintain a 24-hour cycle in a test tube."
                ),
                LessonPage(
                    title: "Clocks Without Sunlight",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "The naked mole-rat has a degraded circadian clock."
                ),
            ]

        case 13:
            return [
                LessonPage(
                    title: "The Gregorian Reform",
                    explanation: paragraphs[0],
                    codeExample: "Gregorian year: 365.2425 days\nTropical year: 365.24219 days\nError: 1 day in 3,236 years",
                    hint: "October 4, 1582 was followed by October 15."
                ),
                LessonPage(
                    title: "Lunar & Lunisolar Calendars",
                    explanation: paragraphs[1],
                    codeExample: nil,
                    hint: "The Islamic calendar causes Ramadan to cycle through all seasons."
                ),
                LessonPage(
                    title: "The Maya Long Count",
                    explanation: paragraphs[2],
                    codeExample: "Maya base-20 system:\n1 kin = 1 day\n1 uinal = 20 kin\n1 tun = 360 kin\n1 baktun = 144,000 kin",
                    hint: "December 21, 2012 was simply a baktun rollover."
                ),
                LessonPage(
                    title: "Calendar Diversity",
                    explanation: paragraphs[3],
                    codeExample: nil,
                    hint: "The Ethiopian calendar has 13 months and is 7-8 years behind."
                ),
            ]

        default:
            return paragraphs.enumerated().map { idx, text in
                LessonPage(title: "Part \(idx + 1)", explanation: text, codeExample: nil, hint: nil)
            }
        }
    }

    private static func splitIntoParagraphs(_ text: String, count: Int) -> [String] {
        let sentences = text.components(separatedBy: ". ")
        guard sentences.count >= count else {
            let base = [text]
            return base + Array(repeating: "", count: max(0, count - 1))
        }
        let perChunk = sentences.count / count
        var result: [String] = []
        for i in 0..<count {
            let start = i * perChunk
            let end = (i == count - 1) ? sentences.count : (i + 1) * perChunk
            let chunk = sentences[start..<end].joined(separator: ". ")
            result.append(chunk.hasSuffix(".") ? chunk : chunk + ".")
        }
        return result
    }
}
