//
//  EventDTO.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import Foundation

struct EventDetailDTO: Hashable {
    let title: String
    let category: String
    let useTarget: String?
    let date: String
    let location: String
    let description: String
    let thumbNail: String?
    let url: String?
}
