//
//  ProfileTableViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import Combine
import Foundation

class ProfileTableViewModel: ObservableObject {
    @Published var items: [ProfileTableItem] = []

    func fetchData() {
        // 프로필 테이블 뷰의 항목을 초기화합니다.
        items = [
            ProfileTableItem(title: "약관 확인", action: .openURL("https://naver.com")),
            ProfileTableItem(title: "자주 찾는 질문", action: .openURL("https://naver.com")),
            ProfileTableItem(title: "앱 소개", action: .openURL("https://naver.com")),
            ProfileTableItem(title: "로그아웃", action: .showAlert)
        ]
    }
}

// MARK: - ProfileTableUtem Struct
struct ProfileTableItem {
    let title: String
    let action: ProfileAction

    enum ProfileAction {
        case openURL(String)
        case showAlert
    }
}
