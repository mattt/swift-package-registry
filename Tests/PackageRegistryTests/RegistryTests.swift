import XCTest
@testable import PackageRegistry
import Foundation
import AnyCodable

final class RegistryTests: XCTestCase {
    func testCreateAndPublish() throws {
        let url = try temporaryDirectory()
        
        let configuration: [String: String] = [
            "user.name": "Swift Package Registry",
            "user.email": "noreply@swift.org"
        ]
        let registry = try Registry.create(at: url, with: configuration)

        let package = Package("@SwiftDocOrg/Markup")!
        let release = try registry.publish(version: "0.0.2", of: package)
        try registry.update(metadata: ["name": "Markup"], for: release)

        let entry = registry.repository.index?["ma/rk/@swiftdocorg/markup/0.0.2.zip"]
        let file = entry?.externalFile
        XCTAssertEqual(file?.path.hasSuffix("0.0.2.zip"), true)
        XCTAssertEqual(file?.size, 23408)
        XCTAssertEqual(file?.checksum, "ebd3b483c8bbd76a3a2fe6ef5135595f0b6b6eb44a8ec07e2134f3b32a233e53")

        let packages = try registry.packages()
        XCTAssertEqual(packages.count, 1)
        XCTAssertEqual(packages.first, package)

        let releases = try registry.releases(for: packages.first!)
        XCTAssertEqual(releases.count, 1)
        XCTAssertEqual(releases.first?.package, package)

        if let release = releases.first {
            XCTAssertEqual(try registry.metadata(for: release)?["name"], "Markup")
        }
    }
}
