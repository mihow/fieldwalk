import SwiftUI

struct FormFieldView: View {
    @Bindable var entry: FormEntry

    var body: some View {
        switch entry.fieldType {
        case .dropdown:
            Picker(entry.fieldLabel, selection: $entry.value) {
                Text("Select...").tag("")
                ForEach(entry.dropdownOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        case .text:
            TextField(entry.fieldLabel, text: $entry.value, axis: .vertical)
                .lineLimit(2...4)
        case .number:
            HStack {
                Text(entry.fieldLabel)
                Spacer()
                TextField("", text: $entry.value)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
        case .toggle:
            Toggle(entry.fieldLabel, isOn: Binding(
                get: { entry.value == "true" },
                set: { entry.value = $0 ? "true" : "false" }
            ))
        }
    }
}
