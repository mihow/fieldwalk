import Foundation

struct DefaultTemplate {
    static func createEntries() -> [FormEntry] {
        [
            FormEntry(
                fieldLabel: "Category",
                fieldType: .dropdown,
                dropdownOptions: ["Vegetation", "Erosion", "Wildlife", "Infrastructure", "Water", "Other"]
            ),
            FormEntry(fieldLabel: "Condition", fieldType: .dropdown, dropdownOptions: ["Good", "Fair", "Poor", "Critical"]),
            FormEntry(fieldLabel: "Notes", fieldType: .text),
            FormEntry(fieldLabel: "Measurement", fieldType: .number),
        ]
    }
}
