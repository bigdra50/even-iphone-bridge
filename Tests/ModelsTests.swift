import XCTest
@testable import EvenG2Bridge

// StatusDoc/Group/Segment は toolbar の status-types.ts と一致させる契約。
// JSON のキー (camelCase) と Optional の省略挙動が崩れないことを担保する。
final class ModelsTests: XCTestCase {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func testSegmentRoundTrip() throws {
        let segment = Segment(
            id: "iphone.battery",
            label: "Battery",
            value: "62%",
            percent: 62,
            reset: nil,
            defaultEnabled: true
        )

        let data = try encoder.encode(segment)
        let decoded = try decoder.decode(Segment.self, from: data)

        XCTAssertEqual(decoded.id, segment.id)
        XCTAssertEqual(decoded.value, segment.value)
        XCTAssertEqual(decoded.percent, 62)
        XCTAssertEqual(decoded.defaultEnabled, true)
        XCTAssertNil(decoded.reset)
    }

    func testSegmentUsesCamelCaseKeys() throws {
        let segment = Segment(id: "s", label: "L", value: "V", percent: 10, defaultEnabled: false)
        let json = try XCTUnwrap(String(data: encoder.encode(segment), encoding: .utf8))

        // toolbar 側のキー名と一致していること
        XCTAssertTrue(json.contains("\"defaultEnabled\""), "defaultEnabled キーが必要")
        XCTAssertTrue(json.contains("\"percent\""))
    }

    func testOptionalsAreOmittedWhenNil() throws {
        let segment = Segment(id: "s", label: "L", value: "V")
        let json = try XCTUnwrap(String(data: encoder.encode(segment), encoding: .utf8))

        // percent/reset/defaultEnabled は nil のときキーごと省略される
        XCTAssertFalse(json.contains("percent"))
        XCTAssertFalse(json.contains("reset"))
    }

    func testStatusDocRoundTrip() throws {
        let doc = StatusDoc(
            version: 1,
            ts: 1_700_000_000,
            groups: [
                Group(
                    id: "iphone",
                    label: "iPhone",
                    segments: [Segment(id: "iphone.battery", label: "Battery", value: "62%", percent: 62)]
                )
            ]
        )

        let decoded = try decoder.decode(StatusDoc.self, from: encoder.encode(doc))

        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.groups.count, 1)
        XCTAssertEqual(decoded.groups.first?.segments.first?.percent, 62)
    }
}
