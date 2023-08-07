//
//  NSLayoutConstraint+Priority.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
