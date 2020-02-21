//
//  TimerTests.swift
//  ConverterTestTests
//
//  Created by Michał Smulski on 26/01/2019.
//  Copyright © 2019 Michał Smulski. All rights reserved.
//

import XCTest
@testable import Converter

class CustomTimerTests: XCTestCase {
    var tested: CustomTimer!
    
    override func tearDown() {
        tested = nil
        super.tearDown()
    }
    
    func testNonRepeating() {
        let expectaction = expectation(description: "testNonRepeating")
        tested = CustomTimer(deadline: DispatchTime.now(), repeatingInterval: .infinity) { expectaction.fulfill() }
        
        tested.start()
        
        wait(for: [expectaction], timeout: 1.0)
    }
}
