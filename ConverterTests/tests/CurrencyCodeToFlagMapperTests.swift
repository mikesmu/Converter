//
//  CurrencyCodeToFlagMapperTests.swift
//  ConverterTestTests
//
//  Created by Michał Smulski on 26/01/2019.
//  Copyright © 2019 Michał Smulski. All rights reserved.
//

import XCTest
@testable import Converter

extension CurrencyCodeToFlagMapper {
    static let empty = CurrencyCodeToFlagMapper(map: [:])
}

class CurrencyCodeToFlagMapperTests: XCTestCase {
    var tested: CurrencyCodeToFlagMapper!

    override func tearDown() {
        tested = nil
    }
    
    func testEmptyMap() {
        tested = .empty
        
        let result = tested.flagEmoji(from: "invalid_currency_code")
        
        XCTAssertNil(result)
    }
    
    func testCurrencyCodeNotFound() {
        tested = CurrencyCodeToFlagMapper(map: ["MXN": "🌮", "USD": "🌭"])
        
        let result = tested.flagEmoji(from: "currency_code_u_will_not_find")
        
        XCTAssertNil(result)
    }

    func testCurrencyCodeFound() {
        tested = CurrencyCodeToFlagMapper(map: ["MXN": "🌮"])
        
        let result = tested.flagEmoji(from: "MXN")
        
        XCTAssertEqual(result, "🌮")
    }

}
