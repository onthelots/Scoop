//
//  HomeSection.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

enum HomeSectionType {
//     case의 각각의 ViewModels는, 받아오는 데이터(Paring)의 DTO (entitiy에서 파생)
    case culturalEvent(viewModels: [CultureEventDTO])
    case educationEvent(viewModels: [EducationEventDTO])

    var title: String {
        switch self {
        case .culturalEvent:
            return "문화행사, 우리동네 즐길거리"
        case .educationEvent:
            return "교육강좌, 배우고 성장하기"
        }
    }
}

// MARK: - 임시 DTO
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
