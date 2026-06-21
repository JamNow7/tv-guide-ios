//
//  StringExtensionsTests.swift
//  GuiaTVTests
//
//  Tests para extensiones de String
//

import XCTest
@testable import GuiaTV

final class StringExtensionsTests: XCTestCase {

    // MARK: - stripHTML Tests

    func testStripHTML_RemovesTags() {
        // Given
        let input = "<p>Hello World</p>"
        let expected = "Hello World"

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_StringWithoutHTML() {
        // Given
        let input = "Hello World"
        let expected = "Hello World"

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_WithNestedTags() {
        // Given
        let input = "<div><p>Hello <span>World</span></p></div>"
        let expected = "Hello World"

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_WithComplexHTML() {
        // Given
        let input = "<div class='container'><p>Hello</p><br/><p>World</p></div>"
        let expected = "HelloWorld"  // stripHTML removes tags but doesn't convert <br> to newlines

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_RemovesHTMLEntities() {
        // Given
        let input = "Hello &nbsp;&amp;&nbsp;World"
        let expected = "Hello  & World"  // Two spaces from two &nbsp; entities

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_RemovesMultipleHTMLEntities() {
        // Given
        let input = "&lt;tag&gt; &amp; &quot;quoted&quot; &#39;apostrophe&#39;"
        let expected = "<tag> & \"quoted\" 'apostrophe'"

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_TrimsWhitespace() {
        // Given
        let input = "  <p>Test</p>  "
        let expected = "Test"

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_WithLineBreaks() {
        // Given
        let input = "<p>Line 1</p><br/><p>Line 2</p>"
        let expected = "Line 1Line 2"  // stripHTML removes <br> tags without adding newlines

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_EmptyString() {
        // Given
        let input = ""
        let expected = ""

        // When
        let result = input.stripHTML()

        // Then
        XCTAssertEqual(result, expected)
    }

    func testStripHTML_Performance() {
        let input = "<div><p>This is a <span>test</span> with <strong>various</strong> tags</p></div>"

        measure {
            for _ in 0..<1000 {
                _ = input.stripHTML()
            }
        }
    }

    // MARK: - flagEmoji Tests

    func testFlagEmoji_US_ReturnsCorrectFlag() {
        // Given
        let input = "US"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "🇺🇸")
    }

    func testFlagEmoji_ES_ReturnsCorrectFlag() {
        // Given
        let input = "ES"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "🇪🇸")
    }

    func testFlagEmoji_GB_ReturnsCorrectFlag() {
        // Given
        let input = "GB"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "🇬🇧")
    }

    func testFlagEmoji_EmptyString_ReturnsEmpty() {
        // Given
        let input = ""

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "")
    }

    func testFlagEmoji_SingleCharacter_ReturnsSingleFlag() {
        // Given
        let input = "A"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result.count, 1) // Single emoji
    }

    func testFlagEmoji_ThreeLetters_ReturnsTwoEmojiClusters() {
        // Given
        let input = "USA"

        // When
        let result = input.flagEmoji()

        // Then
        // "US" forms 🇺🇸 (1 emoji cluster), "A" forms 🇦 (1 standalone character)
        XCTAssertEqual(result.count, 2)
    }

    func testFlagEmoji_Lowercase_ReturnsCorrectFlag() {
        // Given
        let input = "us"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "🇺🇸")
    }

    func testFlagEmoji_MixedCase_ReturnsCorrectFlag() {
        // Given
        let input = "Us"

        // When
        let result = input.flagEmoji()

        // Then
        XCTAssertEqual(result, "🇺🇸")
    }

    func testFlagEmoji_Performance() {
        let input = "US"

        measure {
            for _ in 0..<1000 {
                _ = input.flagEmoji()
            }
        }
    }
}
