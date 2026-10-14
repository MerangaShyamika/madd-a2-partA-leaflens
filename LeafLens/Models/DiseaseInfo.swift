import Foundation

/// Plain-language information shown on the result screen for each model label.
/// General guidance only; users are told to confirm with a local agriculture instructor.
struct DiseaseInfo {
    let label: String
    let summary: String
    let symptoms: [String]
    let actions: [String]

    /// True for the "healthy" classes.
    var isHealthy: Bool {
        label.localizedCaseInsensitiveContains("healthy")
    }

    /// Returns the info for a model label, or a generic entry if it is unknown.
    static func forLabel(_ label: String) -> DiseaseInfo {
        library[label] ?? DiseaseInfo(
            label: label,
            summary: "No extra information is available for this result yet.",
            symptoms: [],
            actions: ["Ask your local agriculture instructor for advice."]
        )
    }

    private static let library: [String: DiseaseInfo] = [
        "Tomato healthy": DiseaseInfo(
            label: "Tomato healthy",
            summary: "No common disease signs were detected on this tomato leaf.",
            symptoms: [],
            actions: [
                "Keep watering at the base of the plant, ideally in the morning.",
                "Check the lower leaves once a week for new spots."
            ]
        ),
        "Tomato early blight": DiseaseInfo(
            label: "Tomato early blight",
            summary: "A fungal disease that usually starts on older, lower leaves.",
            symptoms: [
                "Brown spots with ring patterns, like a target",
                "Yellowing around the spots"
            ],
            actions: [
                "Remove and bin the infected lower leaves.",
                "Mulch the soil so water does not splash onto leaves.",
                "Water at the base and leave space between plants.",
                "Do not plant tomatoes in the same spot next season."
            ]
        ),
        "Tomato late blight": DiseaseInfo(
            label: "Tomato late blight",
            summary: "A fast-spreading disease that thrives in cool, wet weather.",
            symptoms: [
                "Large dark, water-soaked patches on leaves",
                "White fuzzy growth under leaves in humid weather"
            ],
            actions: [
                "Remove infected plants quickly and do not compost them.",
                "Keep leaves dry and improve airflow.",
                "Keep tomatoes away from potato plants.",
                "Get advice quickly, as it can spread to nearby plants."
            ]
        ),
        "Tomato leaf mould": DiseaseInfo(
            label: "Tomato leaf mould",
            summary: "A fungal disease common in humid, sheltered places.",
            symptoms: [
                "Pale yellow spots on the top of leaves",
                "Olive-green or grey velvety growth underneath"
            ],
            actions: [
                "Improve airflow and reduce humidity around plants.",
                "Remove affected leaves.",
                "Avoid watering over the leaves."
            ]
        ),
        "Tomato septoria leaf spot": DiseaseInfo(
            label: "Tomato septoria leaf spot",
            summary: "A fungal disease that spreads upward from the lower leaves.",
            symptoms: [
                "Many small round spots with dark edges and grey centres",
                "Tiny black dots inside the spots"
            ],
            actions: [
                "Remove infected lower leaves.",
                "Mulch and water at the base of the plant.",
                "Clean tools after working with infected plants."
            ]
        ),
        "Pepper healthy": DiseaseInfo(
            label: "Pepper healthy",
            summary: "No common disease signs were detected on this pepper leaf.",
            symptoms: [],
            actions: [
                "Keep watering at the base of the plant.",
                "Check leaves weekly for new spots."
            ]
        ),
        "Pepper bacterial spot": DiseaseInfo(
            label: "Pepper bacterial spot",
            summary: "A bacterial disease spread by splashing water and infected seed.",
            symptoms: [
                "Small water-soaked spots that turn brown",
                "Leaves turning yellow and dropping"
            ],
            actions: [
                "Remove infected leaves.",
                "Avoid handling plants while they are wet.",
                "Use disease-free seed and rotate crops.",
                "Ask your agriculture instructor about suitable sprays."
            ]
        )
    ]
}
