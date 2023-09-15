//
//  NewIssueDetailViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import Foundation
import Combine

class NewIssueDetailViewModel {

    let newIssueItem: NewIssueDTO

    @Published var newIssueDTO: NewIssueDTO?

    init(newIssueItem: NewIssueDTO) {
        self.newIssueItem = newIssueItem
    }

    func fetch() {
        self.newIssueDTO = newIssueItem
    }
}
