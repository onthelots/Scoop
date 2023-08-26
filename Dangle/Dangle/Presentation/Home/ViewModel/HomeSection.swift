//
//  HomeSection.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

enum HomeSectionType {
//     case의 각각의 ViewModels는, 받아오는 데이터(Paring)의 DTO (entitiy에서 파생)
    case newIssue(viewModels: [DangleIssueDTO])
    case culturalEvent(viewModels: [EventDetailDTO])
    case educationEvent(viewModels: [EventDetailDTO])

    var title: String {
        switch self {
        case .newIssue:
            return "새로 올라온 동네소식"
        case .culturalEvent:
            return "문화행사, 우리동네 즐길거리"
        case .educationEvent:
            return "교육강좌, 배우고 성장하기"
        }
    }
}
