//
//  NewIssueDetailViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import Foundation
import Combine

class NewIssueDetailViewModel {

    let newIssueItem: NewIssueDTO

    @Published var newIssueDTO: NewIssueDTO? = nil

    init(newIssueItem: NewIssueDTO) {
        self.newIssueItem = newIssueItem
    }

    // unowned self? -> 참조하는 객체 인스턴스의 RC를 증가시키지 않음
    // 데이터를 불러오는 과정이므로, global() GCD로 처리함
    // 그냥 패치하는것과 무슨 차이가 있을까?
    func fetch() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            self.newIssueDTO = newIssueItem
        }
    }
}
