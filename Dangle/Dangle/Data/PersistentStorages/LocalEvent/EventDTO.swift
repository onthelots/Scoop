//
//  EventDTO.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import Foundation

struct DangleIssueDTO {
    let category: String
    let description: String
    let location: String
    let thumbNail: String?
}

struct EventDetailDTO {
    let title: String
    let category: String
    let useTarget: String
    let date: String
    let location: String
    let description: String
    let thumbNail: String?
    let url: String?
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
