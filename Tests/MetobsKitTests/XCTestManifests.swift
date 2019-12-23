import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(ConstantsTests.allTests),
            testCase(DirectoryTests.allTests),
        ]
    }
#endif
