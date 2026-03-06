import XCTest
@testable import FieldWalk

final class DefaultTemplateTests: XCTestCase {

    func testCreates4Entries() {
        let entries = DefaultTemplate.createEntries()
        XCTAssertEqual(entries.count, 4)
    }

    func testFirstEntryIsCategoryDropdown() {
        let entries = DefaultTemplate.createEntries()
        let category = entries[0]
        XCTAssertEqual(category.fieldLabel, "Category")
        XCTAssertEqual(category.fieldType, .dropdown)
        XCTAssertEqual(category.dropdownOptions, ["Vegetation", "Erosion", "Wildlife", "Infrastructure", "Water", "Other"])
    }

    func testSecondEntryIsConditionDropdown() {
        let entries = DefaultTemplate.createEntries()
        let condition = entries[1]
        XCTAssertEqual(condition.fieldLabel, "Condition")
        XCTAssertEqual(condition.fieldType, .dropdown)
        XCTAssertEqual(condition.dropdownOptions, ["Good", "Fair", "Poor", "Critical"])
    }

    func testThirdEntryIsNotesTextField() {
        let entries = DefaultTemplate.createEntries()
        let notes = entries[2]
        XCTAssertEqual(notes.fieldLabel, "Notes")
        XCTAssertEqual(notes.fieldType, .text)
    }

    func testFourthEntryIsMeasurementNumberField() {
        let entries = DefaultTemplate.createEntries()
        let measurement = entries[3]
        XCTAssertEqual(measurement.fieldLabel, "Measurement")
        XCTAssertEqual(measurement.fieldType, .number)
    }
}
