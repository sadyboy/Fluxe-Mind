import SwiftUI

// MARK: - Topic Category

enum GlossaryTopic: String, CaseIterable, Identifiable {
    case sundials = "Sundials"
    case waterClocks = "Water Clocks"
    case fireClocks = "Fire Clocks"
    case mechanical = "Mechanical"
    case pendulum = "Pendulum"
    case marine = "Marine"
    case quartz = "Quartz"
    case atomic = "Atomic"
    case optical = "Optical"
    case timeZones = "Time Zones"
    case relativity = "Relativity"
    case quantum = "Quantum"
    case biological = "Biological"
    case calendars = "Calendars"
    case general = "General"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sundials: return "sun.max.fill"
        case .waterClocks: return "drop.fill"
        case .fireClocks: return "flame.fill"
        case .mechanical: return "gearshape.2.fill"
        case .pendulum: return "metronome.fill"
        case .marine: return "safari.fill"
        case .quartz: return "waveform.path"
        case .atomic: return "atom"
        case .optical: return "light.beacon.max.fill"
        case .timeZones: return "globe.americas.fill"
        case .relativity: return "warp"
        case .quantum: return "waveform.badge.magnifyingglass"
        case .biological: return "heart.circle.fill"
        case .calendars: return "calendar.badge.clock"
        case .general: return "clock.fill"
        }
    }

    var color: Color {
        switch self {
        case .sundials: return FLColor.warmEmber
        case .waterClocks: return FLColor.biolumCyan
        case .fireClocks: return Color(red: 0.95, green: 0.55, blue: 0.1)
        case .mechanical: return FLColor.biolumViolet
        case .pendulum: return FLColor.auroraA
        case .marine: return Color(red: 0.1, green: 0.3, blue: 0.6)
        case .quartz: return Color(red: 0.6, green: 0.6, blue: 0.75)
        case .atomic: return FLColor.biolumGreen
        case .optical: return FLColor.biolumPink
        case .timeZones: return FLColor.auroraC
        case .relativity: return Color(red: 0.6, green: 0.1, blue: 0.9)
        case .quantum: return FLColor.biolumCyan
        case .biological: return Color(red: 0.8, green: 0.15, blue: 0.3)
        case .calendars: return FLColor.moltenGold
        case .general: return Color.white
        }
    }

    /// Maps to lesson ID for "Go to Lesson" linking
    var lessonID: Int? {
        switch self {
        case .sundials: return 0
        case .waterClocks: return 1
        case .fireClocks: return 2
        case .mechanical: return 3
        case .pendulum: return 4
        case .marine: return 5
        case .quartz: return 6
        case .atomic: return 7
        case .optical: return 8
        case .timeZones: return 9
        case .relativity: return 10
        case .quantum: return 11
        case .biological: return 12
        case .calendars: return 13
        case .general: return nil
        }
    }
}

// MARK: - Glossary Term

struct GlossaryTerm: Identifiable {
    let id: String
    let term: String
    let definition: String
    let topic: GlossaryTopic
    let relatedTerms: [String]
}

// MARK: - Glossary Repository

struct GlossaryRepository {
    static let all: [GlossaryTerm] = [

        // ── Sundials ──────────────────────────────────────────────
        GlossaryTerm(id: "gnomon", term: "Gnomon",
                     definition: "The shadow-casting element of a sundial. Must be aligned with Earth's rotational axis (pointed toward the celestial pole) for the shadow to track solar time accurately throughout the year.",
                     topic: .sundials, relatedTerms: ["sundial", "temporal_hours"]),
        GlossaryTerm(id: "sundial", term: "Sundial",
                     definition: "Humanity's oldest timekeeping instrument, dating to ~1500 BCE in Egypt. It measures time by the position of a shadow cast by a gnomon onto a marked surface.",
                     topic: .sundials, relatedTerms: ["gnomon", "hemicyclium"]),
        GlossaryTerm(id: "hemicyclium", term: "Hemicyclium",
                     definition: "A concave (bowl-shaped) sundial designed by Berossus around 300 BCE. The curved surface improved shadow reading accuracy by projecting the gnomon's shadow onto a hemisphere.",
                     topic: .sundials, relatedTerms: ["gnomon", "sundial"]),
        GlossaryTerm(id: "temporal_hours", term: "Temporal Hours",
                     definition: "An ancient system where daytime was divided into 12 equal parts regardless of season. This meant hours were longer in summer and shorter in winter, unlike modern equal hours.",
                     topic: .sundials, relatedTerms: ["sundial", "equation_of_time"]),
        GlossaryTerm(id: "equation_of_time", term: "Equation of Time",
                     definition: "The difference between apparent solar time (as read from a sundial) and mean solar time (as shown by a clock). Caused by Earth's elliptical orbit and axial tilt; varies up to ±16 minutes.",
                     topic: .sundials, relatedTerms: ["temporal_hours", "sundial", "mean_solar_time"]),

        // ── Water Clocks ──────────────────────────────────────────
        GlossaryTerm(id: "clepsydra", term: "Clepsydra",
                     definition: "Greek for 'water thief.' A water clock that measures time by the regulated flow of water into or out of a vessel. Used from 1400 BCE in Egypt through the medieval period.",
                     topic: .waterClocks, relatedTerms: ["outflow_clepsydra", "inflow_clepsydra"]),
        GlossaryTerm(id: "outflow_clepsydra", term: "Outflow Clepsydra",
                     definition: "The simplest water clock design: a vessel with a small hole near the base. Water drains at a roughly constant rate, and markings on the interior wall indicate elapsed time.",
                     topic: .waterClocks, relatedTerms: ["clepsydra", "inflow_clepsydra"]),
        GlossaryTerm(id: "inflow_clepsydra", term: "Inflow Clepsydra",
                     definition: "An advanced water clock where a rising float in a receiving vessel drives a pointer. Ctesibius of Alexandria (285–222 BCE) pioneered feedback-regulated versions with constant flow rates.",
                     topic: .waterClocks, relatedTerms: ["clepsydra", "ctesibius"]),
        GlossaryTerm(id: "ctesibius", term: "Ctesibius of Alexandria",
                     definition: "Greek engineer (285–222 BCE) who revolutionized water clock design. His inflow clepsydrae featured float-and-pointer mechanisms, feedback-regulated flow, and gear-driven automata.",
                     topic: .waterClocks, relatedTerms: ["inflow_clepsydra", "clepsydra"]),
        GlossaryTerm(id: "su_song", term: "Su Song's Clock Tower",
                     definition: "A 12-meter astronomical clock tower built in China in 1088 CE, powered by a water-wheel escapement. Featured an armillary sphere, celestial globe, and five tiers of rotating mannequins.",
                     topic: .waterClocks, relatedTerms: ["escapement", "armillary_sphere"]),

        // ── Fire Clocks ──────────────────────────────────────────
        GlossaryTerm(id: "candle_clock", term: "Candle Clock",
                     definition: "A timekeeping device using candles of uniform thickness with evenly spaced markings. Standardized by King Alfred the Great (849–899 CE), each inch burned represented ~20 minutes.",
                     topic: .fireClocks, relatedTerms: ["incense_clock"]),
        GlossaryTerm(id: "incense_clock", term: "Incense Clock",
                     definition: "An East Asian timekeeping device using powdered incense trails laid in labyrinthine patterns. Different scented incense at calculated intervals served as olfactory time markers.",
                     topic: .fireClocks, relatedTerms: ["candle_clock"]),

        // ── Mechanical ────────────────────────────────────────────
        GlossaryTerm(id: "escapement", term: "Escapement",
                     definition: "The critical mechanism in a mechanical clock that regulates the release of stored energy (from a weight or spring) into controlled, periodic motion. Every mechanical watch uses one.",
                     topic: .mechanical, relatedTerms: ["verge_and_foliot", "anchor_escapement"]),
        GlossaryTerm(id: "verge_and_foliot", term: "Verge-and-Foliot",
                     definition: "The first mechanical escapement (~1270 CE). A vertical shaft (verge) with pallets alternately catches and releases teeth on a crown wheel. The foliot (horizontal bar with weights) controls oscillation rate. Accurate to ~15 min/day.",
                     topic: .mechanical, relatedTerms: ["escapement", "crown_wheel", "foliot"]),
        GlossaryTerm(id: "foliot", term: "Foliot",
                     definition: "A horizontal bar with adjustable weights at each end, used in early mechanical clocks to control the oscillation rate of the verge escapement. Moving the weights changes the period.",
                     topic: .mechanical, relatedTerms: ["verge_and_foliot", "escapement"]),
        GlossaryTerm(id: "crown_wheel", term: "Crown Wheel",
                     definition: "A gear wheel with teeth projecting from its rim, shaped like a crown. In the verge-and-foliot escapement, it's the driven gear whose teeth alternately engage the pallets on the verge.",
                     topic: .mechanical, relatedTerms: ["verge_and_foliot", "escapement"]),
        GlossaryTerm(id: "mainspring", term: "Mainspring",
                     definition: "A coiled spring that stores energy in portable mechanical watches and clocks. As it unwinds, it powers the gear train through the escapement. Invented ~15th century, replacing hanging weights.",
                     topic: .mechanical, relatedTerms: ["escapement", "balance_wheel"]),
        GlossaryTerm(id: "anchor_escapement", term: "Anchor Escapement",
                     definition: "Invented by Robert Hooke (~1657), this improved escapement uses an anchor-shaped component that rocks back and forth, engaging a toothed escape wheel. Enabled smaller pendulum swings and greater accuracy.",
                     topic: .mechanical, relatedTerms: ["escapement", "pendulum"]),
        GlossaryTerm(id: "complication", term: "Complication",
                     definition: "In watchmaking, any function beyond basic hours, minutes, and seconds. Examples: chronograph, moon phase, perpetual calendar, tourbillon, minute repeater. The most complex watches have 50+ complications.",
                     topic: .mechanical, relatedTerms: ["tourbillon", "mainspring"]),
        GlossaryTerm(id: "tourbillon", term: "Tourbillon",
                     definition: "A rotating cage mechanism invented by Abraham-Louis Breguet in 1801 that counteracts the effect of gravity on the balance wheel. The entire escapement rotates (usually once per minute) to average out positional errors.",
                     topic: .mechanical, relatedTerms: ["complication", "balance_wheel"]),

        // ── Pendulum ──────────────────────────────────────────────
        GlossaryTerm(id: "pendulum", term: "Pendulum",
                     definition: "A weight suspended from a pivot that swings freely. Galileo discovered its isochronism (~1583): period depends only on length, not amplitude. A 1-meter pendulum has a period of ~2 seconds.",
                     topic: .pendulum, relatedTerms: ["isochronism", "pendulum_clock"]),
        GlossaryTerm(id: "isochronism", term: "Isochronism",
                     definition: "The property of a pendulum whereby its period of oscillation remains constant regardless of the amplitude (swing angle). Strictly true only for a cycloid curve, not a circular arc.",
                     topic: .pendulum, relatedTerms: ["pendulum", "cycloid"]),
        GlossaryTerm(id: "cycloid", term: "Cycloid",
                     definition: "A curve traced by a point on a circle rolling along a straight line. Huygens discovered that a pendulum swinging along a cycloid path is truly isochronous, and designed cycloidal cheeks to guide the cord.",
                     topic: .pendulum, relatedTerms: ["isochronism", "huygens"]),
        GlossaryTerm(id: "pendulum_clock", term: "Pendulum Clock",
                     definition: "Built by Christiaan Huygens in 1656, it improved accuracy from ~15 min/day to ~15 sec/day — a 60× improvement. Remained the world's most accurate timekeeper for 270 years until quartz (1927).",
                     topic: .pendulum, relatedTerms: ["pendulum", "huygens", "isochronism"]),
        GlossaryTerm(id: "huygens", term: "Christiaan Huygens",
                     definition: "Dutch mathematician and physicist (1629–1695) who built the first pendulum clock (1656), discovered cycloidal isochronism, and wrote 'Horologium Oscillatorium' (1673), a foundation of oscillatory physics.",
                     topic: .pendulum, relatedTerms: ["pendulum_clock", "cycloid"]),

        // ── Marine ────────────────────────────────────────────────
        GlossaryTerm(id: "longitude_problem", term: "Longitude Problem",
                     definition: "The critical navigation challenge: determining east-west position at sea required knowing the exact time at a reference point. Without accurate clocks, ships had no reliable way to find longitude, causing catastrophic wrecks.",
                     topic: .marine, relatedTerms: ["harrison", "chronometer"]),
        GlossaryTerm(id: "chronometer", term: "Marine Chronometer",
                     definition: "A highly accurate portable timekeeper designed for use at sea. Harrison's H4 (1759) lost only 5.1 seconds over 81 days — revolutionary for its era. The word now refers to any certified high-precision timepiece.",
                     topic: .marine, relatedTerms: ["harrison", "longitude_problem"]),
        GlossaryTerm(id: "harrison", term: "John Harrison",
                     definition: "Self-taught English carpenter (1693–1776) who spent 31 years building marine chronometers H1–H5 to solve the Longitude Problem. H4, a pocket-watch-sized instrument, won the £20,000 Longitude Prize.",
                     topic: .marine, relatedTerms: ["chronometer", "longitude_problem", "remontoire"]),
        GlossaryTerm(id: "remontoire", term: "Remontoire",
                     definition: "A constant-force mechanism that periodically re-tensions a small secondary spring from the mainspring, ensuring uniform force is delivered to the escapement. Used by Harrison in H4 for extreme accuracy.",
                     topic: .marine, relatedTerms: ["harrison", "mainspring"]),
        GlossaryTerm(id: "balance_wheel", term: "Balance Wheel",
                     definition: "A weighted wheel that oscillates back and forth, regulated by a hairspring. It serves the same role as a pendulum in portable watches. Harrison's H4 beat at 5 oscillations/second for stability at sea.",
                     topic: .marine, relatedTerms: ["hairspring", "chronometer"]),
        GlossaryTerm(id: "hairspring", term: "Hairspring (Balance Spring)",
                     definition: "A thin coiled spring attached to the balance wheel that provides the restoring force, causing the wheel to oscillate. Its material and geometry determine the watch's rate and temperature sensitivity.",
                     topic: .marine, relatedTerms: ["balance_wheel"]),

        // ── Quartz ────────────────────────────────────────────────
        GlossaryTerm(id: "piezoelectric", term: "Piezoelectric Effect",
                     definition: "Discovered by Pierre and Jacques Curie (1880): mechanical stress on certain crystals generates voltage, and applied voltage causes deformation. This reciprocal effect makes quartz crystals vibrate at precise frequencies.",
                     topic: .quartz, relatedTerms: ["quartz_oscillator"]),
        GlossaryTerm(id: "quartz_oscillator", term: "Quartz Oscillator",
                     definition: "A timekeeping circuit where a precisely cut quartz crystal vibrates at 32,768 Hz (2¹⁵) when energized. A digital divider chain of 15 flip-flops divides this to exactly 1 Hz. Accurate to ~15 seconds/month.",
                     topic: .quartz, relatedTerms: ["piezoelectric", "quartz_crisis"]),
        GlossaryTerm(id: "quartz_crisis", term: "Quartz Crisis",
                     definition: "Period (1969–1985) when affordable, accurate quartz watches nearly destroyed the traditional Swiss mechanical watch industry. Triggered by the Seiko Astron (1969), the first quartz wristwatch.",
                     topic: .quartz, relatedTerms: ["quartz_oscillator"]),
        GlossaryTerm(id: "tcxo", term: "TCXO",
                     definition: "Temperature-Compensated Crystal Oscillator. Uses electronic circuits to adjust for quartz frequency drift caused by temperature changes. Achieves accuracy of ~0.5 ppm (~1.5 sec/month).",
                     topic: .quartz, relatedTerms: ["ocxo", "quartz_oscillator"]),
        GlossaryTerm(id: "ocxo", term: "OCXO",
                     definition: "Oven-Controlled Crystal Oscillator. Maintains the quartz crystal at a constant elevated temperature inside a miniature oven, eliminating temperature-related drift. Achieves ~0.01 ppm accuracy (~0.3 sec/year).",
                     topic: .quartz, relatedTerms: ["tcxo", "quartz_oscillator"]),

        // ── Atomic ────────────────────────────────────────────────
        GlossaryTerm(id: "atomic_clock", term: "Atomic Clock",
                     definition: "A clock that uses the resonance frequency of atoms as its timekeeping element. The cesium-133 hyperfine transition at 9,192,631,770 Hz defines the SI second since 1967.",
                     topic: .atomic, relatedTerms: ["cesium_standard", "si_second"]),
        GlossaryTerm(id: "cesium_standard", term: "Cesium Standard",
                     definition: "A primary frequency standard based on cesium-133 atoms transitioning between two hyperfine ground states when exposed to microwave radiation at exactly 9,192,631,770 Hz.",
                     topic: .atomic, relatedTerms: ["atomic_clock", "si_second"]),
        GlossaryTerm(id: "si_second", term: "SI Second",
                     definition: "Since 1967, defined as exactly 9,192,631,770 periods of radiation corresponding to the transition between two hyperfine levels of the cesium-133 ground state. The most precisely realized SI unit.",
                     topic: .atomic, relatedTerms: ["atomic_clock", "cesium_standard"]),
        GlossaryTerm(id: "laser_cooling", term: "Laser Cooling",
                     definition: "A technique using laser beams to slow atoms to near absolute zero (~1 μK). Used in cesium fountain clocks to launch cooled atoms upward through a microwave cavity, greatly increasing measurement time.",
                     topic: .atomic, relatedTerms: ["cesium_fountain"]),
        GlossaryTerm(id: "cesium_fountain", term: "Cesium Fountain Clock",
                     definition: "Modern primary standard (e.g., NIST-F2) that launches laser-cooled cesium atoms upward. As they rise and fall through a microwave cavity, the extended interaction time achieves accuracy of ~1 second in 300 million years.",
                     topic: .atomic, relatedTerms: ["laser_cooling", "atomic_clock"]),

        // ── Optical ───────────────────────────────────────────────
        GlossaryTerm(id: "optical_clock", term: "Optical Clock",
                     definition: "A clock using visible-light (optical) frequencies (~500 THz) rather than microwaves (~9 GHz) to probe atomic transitions. Higher frequency means finer time slicing and far greater precision.",
                     topic: .optical, relatedTerms: ["optical_lattice", "magic_wavelength"]),
        GlossaryTerm(id: "optical_lattice", term: "Optical Lattice",
                     definition: "A standing wave of laser light creating an egg-carton-like array of potential wells that trap thousands of atoms simultaneously. Enables parallel interrogation for lower statistical uncertainty.",
                     topic: .optical, relatedTerms: ["optical_clock", "magic_wavelength"]),
        GlossaryTerm(id: "magic_wavelength", term: "Magic Wavelength",
                     definition: "A specific laser wavelength at which the trapping light shifts both energy levels of the clock transition equally, so the trapping laser doesn't affect the measured frequency. Essential for optical lattice clocks.",
                     topic: .optical, relatedTerms: ["optical_lattice", "optical_clock"]),
        GlossaryTerm(id: "relativistic_geodesy", term: "Relativistic Geodesy",
                     definition: "Using ultra-precise clocks to map Earth's gravitational field by measuring time dilation. A strontium lattice clock can detect the gravitational redshift from a height change of just 2 centimeters.",
                     topic: .optical, relatedTerms: ["optical_clock", "gravitational_redshift"]),

        // ── Time Zones ────────────────────────────────────────────
        GlossaryTerm(id: "prime_meridian", term: "Prime Meridian",
                     definition: "The 0° longitude line passing through Greenwich, England. Established at the 1884 International Meridian Conference (22 votes in favor, 1 against). All time zones are defined as offsets from it.",
                     topic: .timeZones, relatedTerms: ["gmt", "utc"]),
        GlossaryTerm(id: "gmt", term: "Greenwich Mean Time (GMT)",
                     definition: "Mean solar time at the Royal Observatory, Greenwich. Was the world's time standard from 1884 until replaced by UTC in 1972. France adopted it only in 1911.",
                     topic: .timeZones, relatedTerms: ["prime_meridian", "utc"]),
        GlossaryTerm(id: "utc", term: "UTC (Coordinated Universal Time)",
                     definition: "The modern world time standard since 1972, maintained by a weighted average of ~450 atomic clocks worldwide. Leap seconds are inserted to keep UTC within 0.9 seconds of Earth's irregular rotation.",
                     topic: .timeZones, relatedTerms: ["gmt", "leap_second"]),
        GlossaryTerm(id: "leap_second", term: "Leap Second",
                     definition: "A one-second adjustment applied to UTC to account for irregularities in Earth's rotation. Positive leap seconds have been added 27 times since 1972. May be abolished after 2035.",
                     topic: .timeZones, relatedTerms: ["utc"]),
        GlossaryTerm(id: "international_date_line", term: "International Date Line",
                     definition: "An imaginary line roughly following the 180° meridian where the calendar date changes. It zigzags to keep island nations and territories unified within the same day.",
                     topic: .timeZones, relatedTerms: ["prime_meridian", "utc"]),
        GlossaryTerm(id: "mean_solar_time", term: "Mean Solar Time",
                     definition: "An average of apparent solar time over the year, smoothing out variations caused by Earth's elliptical orbit and axial tilt. A clock showing mean solar time runs at a constant rate unlike a sundial.",
                     topic: .timeZones, relatedTerms: ["equation_of_time", "gmt"]),

        // ── Relativity ────────────────────────────────────────────
        GlossaryTerm(id: "time_dilation", term: "Time Dilation",
                     definition: "The phenomenon where time passes at different rates depending on relative velocity (special relativity) or gravitational field strength (general relativity). Not an illusion — clocks genuinely tick at different rates.",
                     topic: .relativity, relatedTerms: ["lorentz_factor", "gravitational_redshift"]),
        GlossaryTerm(id: "lorentz_factor", term: "Lorentz Factor (γ)",
                     definition: "γ = 1/√(1−v²/c²). Describes how much time slows for a moving object. At 90% light speed, γ ≈ 2.29, meaning time passes at only 43.6% the stationary rate.",
                     topic: .relativity, relatedTerms: ["time_dilation", "special_relativity"]),
        GlossaryTerm(id: "special_relativity", term: "Special Relativity",
                     definition: "Einstein's 1905 theory: the laws of physics are the same in all inertial frames, and the speed of light is constant. Consequence: moving clocks tick slower (time dilation), and no object can exceed light speed.",
                     topic: .relativity, relatedTerms: ["lorentz_factor", "general_relativity"]),
        GlossaryTerm(id: "general_relativity", term: "General Relativity",
                     definition: "Einstein's 1915 theory extending special relativity to include gravity. Mass curves spacetime; clocks run slower in stronger gravitational fields. GPS satellites must correct for this daily (~45 μs/day).",
                     topic: .relativity, relatedTerms: ["special_relativity", "gravitational_redshift"]),
        GlossaryTerm(id: "gravitational_redshift", term: "Gravitational Redshift",
                     definition: "Light climbing out of a gravitational well loses energy and shifts to longer (redder) wavelengths. Equivalently, clocks in stronger gravity tick slower. Confirmed by the Pound-Rebka experiment (1959).",
                     topic: .relativity, relatedTerms: ["general_relativity", "time_dilation"]),
        GlossaryTerm(id: "hafele_keating", term: "Hafele–Keating Experiment",
                     definition: "A 1971 test that flew cesium clocks on commercial airliners. Eastbound clocks lost 59±10 ns, westbound gained 273±7 ns — precisely matching relativistic predictions and confirming time dilation.",
                     topic: .relativity, relatedTerms: ["time_dilation", "atomic_clock"]),

        // ── Quantum ───────────────────────────────────────────────
        GlossaryTerm(id: "nuclear_clock", term: "Nuclear Clock",
                     definition: "A proposed next-generation clock using transitions in the thorium-229 nucleus rather than electron shells. Could achieve 10⁻¹⁹ fractional uncertainty, potentially detecting variations in fundamental constants.",
                     topic: .quantum, relatedTerms: ["optical_clock"]),
        GlossaryTerm(id: "csac", term: "CSAC (Chip-Scale Atomic Clock)",
                     definition: "Miniaturized atomic clock technology developed by DARPA, shrinking to 17 cm³ at 120 mW. Enables precision timing in drones, portable equipment, and underwater vehicles.",
                     topic: .quantum, relatedTerms: ["atomic_clock"]),
        GlossaryTerm(id: "quantum_entanglement_clocks", term: "Entanglement-Enhanced Clocks",
                     definition: "Optical clocks using quantum entanglement between atoms to surpass the standard quantum limit. JILA demonstrated this in 2024, enabling even greater precision without adding more atoms.",
                     topic: .quantum, relatedTerms: ["optical_clock"]),

        // ── Biological ────────────────────────────────────────────
        GlossaryTerm(id: "circadian_rhythm", term: "Circadian Rhythm",
                     definition: "An approximately 24-hour internal biological cycle regulating sleep-wake patterns, hormone release, body temperature, and metabolism. Driven by molecular feedback loops in nearly every cell.",
                     topic: .biological, relatedTerms: ["scn", "clock_genes"]),
        GlossaryTerm(id: "scn", term: "Suprachiasmatic Nucleus (SCN)",
                     definition: "A cluster of ~20,000 neurons in the hypothalamus that serves as the master circadian pacemaker in mammals. Receives light signals from the retina and coordinates body clocks.",
                     topic: .biological, relatedTerms: ["circadian_rhythm", "clock_genes"]),
        GlossaryTerm(id: "clock_genes", term: "Clock Genes (PER, CRY, CLOCK, BMAL1)",
                     definition: "Core genes of the molecular circadian clock. CLOCK and BMAL1 proteins activate PER and CRY genes. PER/CRY proteins accumulate, form complexes, and inhibit their own transcription — a ~24-hour feedback loop.",
                     topic: .biological, relatedTerms: ["circadian_rhythm", "scn"]),
        GlossaryTerm(id: "kai_proteins", term: "KaiA, KaiB, KaiC",
                     definition: "Three proteins composing the cyanobacterial circadian clock — the simplest known biological clock. KaiC phosphorylation cycles autonomously over 24 hours in a test tube, needing no gene expression.",
                     topic: .biological, relatedTerms: ["circadian_rhythm"]),

        // ── Calendars ─────────────────────────────────────────────
        GlossaryTerm(id: "gregorian_calendar", term: "Gregorian Calendar",
                     definition: "Introduced in 1582 by Pope Gregory XIII to correct the Julian calendar's 10-day drift. Leap year rule: divisible by 4, except centuries, except centuries divisible by 400. Average year: 365.2425 days.",
                     topic: .calendars, relatedTerms: ["julian_calendar", "leap_year"]),
        GlossaryTerm(id: "julian_calendar", term: "Julian Calendar",
                     definition: "Introduced by Julius Caesar in 46 BCE with a simple leap year every 4 years (avg 365.25 days). Its 11-minute annual error accumulated to 10 days by 1582, prompting the Gregorian reform.",
                     topic: .calendars, relatedTerms: ["gregorian_calendar"]),
        GlossaryTerm(id: "leap_year", term: "Leap Year",
                     definition: "A year with an extra day (Feb 29) to keep the calendar aligned with Earth's orbit. Gregorian rule: divisible by 4, NOT if divisible by 100, UNLESS also divisible by 400. (2000 = leap, 1900 = not).",
                     topic: .calendars, relatedTerms: ["gregorian_calendar"]),
        GlossaryTerm(id: "metonic_cycle", term: "Metonic Cycle",
                     definition: "A 19-year period after which lunar phases repeat on nearly the same calendar dates. Used by the Hebrew calendar to insert a 13th month (Adar II) in 7 of every 19 years to synchronize lunar and solar years.",
                     topic: .calendars, relatedTerms: ["lunisolar"]),
        GlossaryTerm(id: "lunisolar", term: "Lunisolar Calendar",
                     definition: "A calendar system using both the Moon's phases (months) and the Sun's position (year length). The Hebrew and Chinese calendars are lunisolar, periodically adding leap months to stay aligned with seasons.",
                     topic: .calendars, relatedTerms: ["metonic_cycle"]),
        GlossaryTerm(id: "baktun", term: "Baktun",
                     definition: "A unit of the Maya Long Count calendar equal to 144,000 days (~394 years). The '2012 apocalypse' was simply the completion of the 13th baktun (13.0.0.0.0) — a calendar rollover, not an ending.",
                     topic: .calendars, relatedTerms: ["gregorian_calendar"]),

        // ── General ───────────────────────────────────────────────
        GlossaryTerm(id: "horology", term: "Horology",
                     definition: "The science and art of time measurement, including the design, construction, and study of timepieces. Derived from Greek 'hora' (hour) and 'logos' (study).",
                     topic: .general, relatedTerms: ["escapement", "complication"]),
        GlossaryTerm(id: "frequency", term: "Frequency",
                     definition: "The number of oscillations per second, measured in Hertz (Hz). A quartz watch vibrates at 32,768 Hz; cesium atoms resonate at 9,192,631,770 Hz. Higher frequency generally means greater precision.",
                     topic: .general, relatedTerms: ["quartz_oscillator", "atomic_clock"]),
        GlossaryTerm(id: "oscillator", term: "Oscillator",
                     definition: "Any system that swings, vibrates, or cycles between states at a regular rate. Pendulums, balance wheels, quartz crystals, and atomic transitions are all oscillators used for timekeeping.",
                     topic: .general, relatedTerms: ["pendulum", "quartz_oscillator", "balance_wheel"]),
        GlossaryTerm(id: "accuracy_vs_precision", term: "Accuracy vs Precision",
                     definition: "Accuracy: how close a measurement is to the true value. Precision: how reproducible measurements are. A clock can be precise (consistent) but inaccurate (consistently wrong by 5 seconds).",
                     topic: .general, relatedTerms: ["frequency"]),
        GlossaryTerm(id: "armillary_sphere", term: "Armillary Sphere",
                     definition: "A model of celestial objects consisting of rings (armillae) centered on Earth or the Sun, representing the celestial equator, ecliptic, and other great circles. Used for astronomy and navigation since antiquity.",
                     topic: .general, relatedTerms: ["su_song"]),
        GlossaryTerm(id: "ppm", term: "Parts Per Million (ppm)",
                     definition: "A unit for expressing clock accuracy. 1 ppm = 1 microsecond per second, or about 31.5 seconds per year. A typical quartz watch runs at ~15 ppm; TCXO at ~0.5 ppm; atomic clocks at ~10⁻¹² ppm.",
                     topic: .general, relatedTerms: ["accuracy_vs_precision", "tcxo"]),
        GlossaryTerm(id: "chronograph", term: "Chronograph",
                     definition: "A timepiece with a built-in stopwatch function. Not to be confused with chronometer (a high-accuracy watch). Features start/stop/reset pushers and sub-dials for elapsed seconds and minutes.",
                     topic: .general, relatedTerms: ["complication", "chronometer"]),
    ]
}
