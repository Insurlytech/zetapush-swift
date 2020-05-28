import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(zetapush_swiftTests.allTests),
    ]
}
#endif
