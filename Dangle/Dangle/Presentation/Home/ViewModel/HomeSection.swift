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
    case culturalEvent(viewModels: [CultureEventDTO])
    case educationEvent(viewModels: [EducationEventDTO])

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

// MARK: - 임시 DTO

struct DangleIssueDTO {
    let category: String
    let description: String
    let location: String
    let thumbNail: String?
}

struct CultureEventDTO {
    let title: String
    let time: String
    let location: String
    let thumbNail: String?
}

struct EducationEventDTO {
    let title: String
    let time: String
    let location: String
    let thumbNail: String?
}


extension DangleIssueDTO {
    static let mock = [DangleIssueDTO(
        category: "Technology",
        description: "Scleral fistula repair",
        location: "Frankfurt am Main",
        thumbNail: "http://dummyimage.com/213x100.png/cc0000/ffffff"), DangleIssueDTO(
            category: "Technology",
            description: "Scleral fistula repair",
            location: "Frankfurt am Main",
            thumbNail: "http://dummyimage.com/213x100.png/cc0000/ffffff"), DangleIssueDTO(
                category: "Technology",
                description: "Scleral fistula repair",
                location: "Frankfurt am Main",
                thumbNail: "http://dummyimage.com/213x100.png/cc0000/ffffff"), DangleIssueDTO(
                    category: "Technology",
                    description: "Scleral fistula repair",
                    location: "Frankfurt am Main",
                    thumbNail: "http://dummyimage.com/213x100.png/cc0000/ffffff"), DangleIssueDTO(
                        category: "Technology",
                        description: "Scleral fistula repair",
                        location: "Frankfurt am Main",
                        thumbNail: "http://dummyimage.com/213x100.png/cc0000/ffffff")]
}
