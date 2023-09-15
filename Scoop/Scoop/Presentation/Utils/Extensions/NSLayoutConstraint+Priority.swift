//
//  NSLayoutConstraint+Priority.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Foundation
import UIKit

// 우선도 설정
extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
