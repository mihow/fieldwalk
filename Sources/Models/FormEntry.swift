import Foundation
import SwiftData

@Model
final class FormEntry {
    var id: UUID
    var fieldLabel: String
    var fieldType: FormFieldType
    var value: String
    var dropdownOptions: [String]
    var observation: FieldObservation?

    init(fieldLabel: String, fieldType: FormFieldType, value: String = "", dropdownOptions: [String] = []) {
        self.id = UUID()
        self.fieldLabel = fieldLabel
        self.fieldType = fieldType
        self.value = value
        self.dropdownOptions = dropdownOptions
    }
}
