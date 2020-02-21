//
//  Data+Fake.swift
//  ConverterTestTests
//
//  Created by Michał Smulski on 26/01/2019.
//  Copyright © 2019 Michał Smulski. All rights reserved.
//

import Foundation

extension Data {
    static func fake(base: String) -> Data {
        guard let path = Bundle.test.path(forResource: "table_\(base)_base", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return Data()
        }
        return data
    }
    
    static func random() -> Data {
        return "some_random_string".data(using: .utf8)!
    }
}
