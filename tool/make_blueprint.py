#!/usr/bin/env python3
"""Writes content/blueprint.json: the topic list, per-topic targets and the three exam patterns."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# section key, title, [(topic key, id prefix, title, test items, practice items, scope note)]
SECTIONS = [
    ("verbal", "English / Verbal", [
        ("sentence-completion", "sc", "Sentence Completion", 160, 15, "One or two blanks; vocabulary in context and logic of the sentence."),
        ("analogy", "an", "Analogies", 120, 15, "WORD : WORD pairs; state the relationship in the explanation."),
        ("antonym", "at", "Antonyms", 100, 15, "Word most opposite in meaning."),
        ("synonym", "sy", "Synonyms", 100, 15, "Word closest in meaning."),
        ("comprehension", "rc", "Reading Comprehension", 120, 18, "Sets: one original passage of 150-220 words with 6 questions (main idea, detail, inference, tone, vocabulary in context)."),
        ("error-correction", "ec", "Grammar and Sentence Correction", 100, 15, "Spot the error or pick the correct sentence: tense, agreement, prepositions, articles, parallelism."),
    ]),
    ("analytical", "Analytical Reasoning", [
        ("scenario", "pz", "Scenario Puzzles", 300, 25, "Sets: a short arrangement, ordering, grouping or scheduling scenario with its rules, followed by 5 questions."),
        ("critical-reasoning", "cr", "Statements: Critical Reasoning", 100, 15, "Short statement; find the assumption, conclusion, strengthener or weakener."),
        ("syllogism", "lg", "Syllogisms and Deduction", 80, 15, "Which conclusion must follow from the statements."),
        ("series", "se", "Number and Letter Series", 80, 15, "Next term or missing term; the rule stated in the explanation."),
        ("coding", "cd", "Coding and Decoding", 60, 15, "Letter or number codes."),
        ("relations-direction", "rd", "Blood Relations and Directions", 80, 15, "Family relationships and direction-sense problems."),
    ]),
    ("quant", "Quantitative", [
        ("number-system", "nm", "Number System", 60, 15, "Factors, HCF/LCM, fractions, decimals, order of operations, divisibility."),
        ("percentage", "pc", "Percentages", 60, 15, "Percentage change, successive change, comparisons."),
        ("ratio", "ra", "Ratio and Proportion", 60, 15, "Ratios, sharing, direct and inverse proportion, mixtures."),
        ("average", "av", "Averages", 40, 15, "Means, weighted averages, age problems."),
        ("speed-work", "sw", "Speed, Time and Work", 60, 15, "Distance, relative speed, pipes and work rates."),
        ("profit-interest", "pi", "Profit, Loss and Interest", 40, 15, "Cost, sale, discount, simple and compound interest."),
        ("algebra", "ag", "Algebra", 100, 15, "Linear and quadratic equations, simplification, exponents, inequalities, word problems."),
        ("geometry", "ge", "Geometry", 80, 15, "Angles, triangles, circles, area, perimeter, volume, described fully in words without figures."),
        ("data", "dt", "Statistics and Data Interpretation", 60, 15, "Use the optional `table` field; mean, median, mode, reading a table."),
        ("probability", "pb", "Probability and Counting", 40, 15, "Simple probability and basic counting."),
    ]),
    ("physics", "Physics", [
        ("mechanics", "pm", "Mechanics", 50, 10, "Vectors, kinematics, forces, circular motion, work, energy, power, fluids."),
        ("waves", "pw", "Oscillations, Waves and Sound", 30, 10, "SHM, waves, sound, Doppler effect."),
        ("heat", "ph", "Heat and Thermodynamics", 20, 10, "Kinetic theory, laws of thermodynamics."),
        ("electricity", "pe", "Electricity and Magnetism", 50, 10, "Electrostatics, current, magnetism, EM induction, AC."),
        ("optics", "po", "Optics", 20, 10, "Reflection, refraction, lenses, interference, diffraction."),
        ("modern", "pn", "Modern Physics", 30, 10, "Quantum ideas, atomic and nuclear physics, electronics."),
    ]),
    ("chemistry", "Chemistry", [
        ("basics", "cb", "Basic Concepts and Atomic Structure", 40, 10, "Mole, stoichiometry, states of matter, atomic structure."),
        ("physical", "cp", "Physical Chemistry", 50, 10, "Bonding, equilibrium, kinetics, thermochemistry, electrochemistry, solutions."),
        ("inorganic", "ci", "Inorganic Chemistry", 50, 10, "Periodic table, s/p/d block, industrial chemistry."),
        ("organic", "co", "Organic Chemistry", 60, 10, "Hydrocarbons, functional groups, reaction types, biomolecules, polymers."),
    ]),
    ("math", "Mathematics", [
        ("algebra", "ma", "Algebra", 60, 10, "Functions, quadratics, sequences, matrices, permutations, binomial theorem."),
        ("trigonometry", "mt", "Trigonometry", 40, 10, "Identities, equations, inverse functions."),
        ("calculus", "mc", "Calculus", 60, 10, "Limits, differentiation, integration, applications."),
        ("analytic-geometry", "mg", "Analytic Geometry and Vectors", 40, 10, "Lines, circles, conics, vectors."),
    ]),
    ("biology", "Biology", [
        ("cell", "bc", "Cell Biology and Biomolecules", 60, 10, "Cell structure, enzymes, biomolecules, bioenergetics."),
        ("diversity", "bd", "Diversity of Life", 70, 10, "Classification, kingdoms, plants, animals, ecology."),
        ("physiology", "bp", "Human Physiology", 90, 10, "Digestion, circulation, respiration, excretion, nervous and endocrine systems, immunity, reproduction."),
        ("genetics", "bg", "Genetics and Evolution", 60, 10, "Inheritance, DNA, biotechnology, evolution."),
    ]),
    ("computer", "Computer Science", [
        ("intro", "ic", "Introduction to Computers", 80, 15, "Hardware, software, memory, number systems, networks, security."),
        ("programming", "ip", "Programming Fundamentals", 60, 15, "Language-neutral and C/C++ basics: variables, control flow, arrays, functions, tracing output."),
        ("database", "id", "Database Fundamentals", 60, 15, "Tables, keys, relationships, normalisation, basic SQL."),
    ]),
    ("gk", "General Knowledge", [
        ("world", "gw", "World Affairs and History", 100, 12, "Stable facts only: organisations, treaties, world history, firsts."),
        ("science", "gs", "Everyday Science", 70, 12, "Inventions, human body, environment, space, technology."),
        ("geography", "gg", "World Geography", 70, 12, "Continents, oceans, capitals, currencies, landmarks."),
        ("civics", "gc", "Economy and Civics", 60, 12, "Basic economics, government, abbreviations, international bodies."),
    ]),
    ("islamic", "Islamic Studies", [
        ("quran", "iq", "Quran", 70, 12, "Revelation, compilation, surahs, stories of the prophets, teachings."),
        ("hadith", "ih", "Hadith and Sunnah", 40, 12, "Compilers, the major collections, well-known teachings."),
        ("beliefs", "ib", "Beliefs and Pillars", 90, 12, "Tawhid, prophethood, the hereafter, prayer, fasting, zakat, Hajj."),
        ("seerah", "is", "Seerah", 60, 12, "Life of the Holy Prophet (PBUH), key events and dates."),
        ("history", "ir", "Rightly Guided Caliphs and Islamic History", 40, 12, "The four caliphs, early battles, Muslim contributions."),
    ]),
    ("pakistan", "Pakistan Studies", [
        ("movement", "km", "Pakistan Movement", 90, 12, "1857 to 1947, leaders, resolutions, sessions, dates."),
        ("constitution", "kc", "Constitution and Government", 40, 12, "1956, 1962 and 1973 constitutions, structure of the state. Stable facts, no office holders."),
        ("geography", "kg", "Geography of Pakistan", 40, 12, "Provinces, rivers, mountains, passes, dams, neighbours."),
        ("culture", "ke", "Culture and Economy", 30, 12, "National symbols, languages, heritage sites, resources, industries."),
    ]),
    ("ethics", "Ethics", [
        ("ethics", "et", "Ethics (option for non-Muslim candidates)", 150, 20, "Honesty, justice, duty, tolerance, citizenship, professional conduct, major world religions' shared moral teaching."),
    ]),
]

# Mode patterns. An explicit dict gives the exact per-paper quota; an integer is split across the section's topics.
NAT_V = {"sentence-completion": 5, "analogy": 3, "antonym": 4, "comprehension": 5, "synonym": 3}
NAT_A = {"scenario": 12, "critical-reasoning": 3, "syllogism": 2, "series": 1, "coding": 1, "relations-direction": 1}
NAT_Q = {"number-system": 2, "percentage": 3, "ratio": 2, "average": 2, "speed-work": 2, "profit-interest": 2, "algebra": 4, "geometry": 3}
APT = [("verbal", NAT_V), ("analytical", NAT_A), ("quant", NAT_Q)]
MODES = {
    "nat": {
        "title": "NAT", "subtitle": "National Aptitude Test", "minutes": 120, "questions": 90,
        "streams": {
            "ie": {"title": "NAT-IE (Pre-Engineering)", "sections": APT + [("physics", 10), ("chemistry", 10), ("math", 10)]},
            "im": {"title": "NAT-IM (Pre-Medical)", "sections": APT + [("physics", 8), ("chemistry", 8), ("biology", 14)]},
            "ics": {"title": "NAT-ICS (Computer Science)", "sections": APT + [("physics", 10), ("math", 10), ("computer", {"intro": 4, "programming": 3, "database": 3})]},
            "ia": {"title": "NAT-IA (Arts)", "sections": APT + [("islamic", 10), ("pakistan", 10), ("gk", 10)]},
        },
    },
    "gat": {
        "title": "GAT General", "subtitle": "Graduate Assessment Test", "minutes": 120, "questions": 100,
        "streams": {"general": {"title": "GAT General", "sections": [
            ("verbal", {"sentence-completion": 8, "analogy": 6, "antonym": 5, "synonym": 5, "comprehension": 6, "error-correction": 5}),
            ("analytical", {"scenario": 15, "critical-reasoning": 5, "syllogism": 4, "series": 4, "coding": 3, "relations-direction": 4}),
            ("quant", {"number-system": 3, "percentage": 3, "ratio": 3, "average": 2, "speed-work": 3, "profit-interest": 2, "algebra": 5, "geometry": 4, "data": 3, "probability": 2}),
        ]}},
    },
    "rec": {
        "title": "Recruitment", "subtitle": "Job tests (typical pattern)", "minutes": 120, "questions": 100,
        "streams": {"general": {"title": "Recruitment", "sections": [
            ("verbal", {"sentence-completion": 6, "analogy": 2, "antonym": 4, "synonym": 4, "comprehension": 5, "error-correction": 4}),
            ("quant", {"number-system": 3, "percentage": 3, "ratio": 2, "average": 2, "speed-work": 2, "profit-interest": 2, "algebra": 3, "geometry": 1, "data": 2}),
            ("analytical", {"scenario": 5, "critical-reasoning": 2, "syllogism": 2, "series": 2, "coding": 2, "relations-direction": 2}),
            ("gk", 15), ("islamic", 15), ("pakistan", 10),
        ]}},
    },
}

doc = {
    "sections": [
        {"key": k, "title": t, "topics": [
            {"key": tk, "prefix": p, "title": tt, "test": a, "practice": b, "scope": s} for tk, p, tt, a, b, s in topics
        ]} for k, t, topics in SECTIONS
    ],
    "modes": {m: {**v, "streams": {s: {"title": d["title"], "sections": [{"section": k, "quota": q} for k, q in d["sections"]]} for s, d in v["streams"].items()}} for m, v in MODES.items()},
    "papers": 20,
}
for m in doc["modes"].values():
    for s in m["streams"].values():
        total = sum(q if isinstance(q, int) else sum(q.values()) for q in (x["quota"] for x in s["sections"]))
        assert total == m["questions"], (s["title"], total)
(ROOT / "content/blueprint.json").write_text(json.dumps(doc, indent=1) + "\n")
print("test", sum(t[3] for _, _, ts in SECTIONS for t in ts), "practice", sum(t[4] for _, _, ts in SECTIONS for t in ts))
