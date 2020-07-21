//
//  Optional+Cam.swift
//  GIF-E
//
//  Created by Cam on 7/20/20.
//  Copyright © 2020 Cam Hunt. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    func nilIfEmpty() -> Wrapped? {
        if let string = self, !string.isEmpty {
            return string
        } else {
            return nil
        }
    }
}
