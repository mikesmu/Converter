//
//  CurrencyTable+Fake.swift
//  ConverterTestTests
//
//  Created by Michał Smulski on 26/01/2019.
//  Copyright © 2019 Michał Smulski. All rights reserved.
//

import Foundation
@testable import Converter

extension CurrencyTable {
    static func makeFake(data: Data) -> CurrencyTable  {
        do {
            return try JSONDecoder().decode(CurrencyTable.self, from: data)
        } catch {
            return CurrencyTable.empty
        }
    }
}
