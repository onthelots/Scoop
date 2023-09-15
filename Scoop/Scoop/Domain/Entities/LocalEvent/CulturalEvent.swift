//
//  CulturalEvent.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
// MARK: - Geocoding
struct CulturalEvent: Codable {
    let culturalEventInfo: CulturalEventInfo
}

// MARK: - CulturalEventInfo
struct CulturalEventInfo: Codable {
    let listTotalCount: Int
    let detail: [CulturalEventDetail]

    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case detail = "row"
    }
}

// MARK: - Row
struct CulturalEventDetail: Codable {
    let codename, guname, title, date: String
    let place, orgName, useTrgt, useFee: String
    let player, program, etcDesc: String
    let orgLink: String
    let mainImg: String
    let rgstdate, ticket, strtdate, endDate: String
    let themecode, lot, lat, isFree: String
    let hmpgAddr: String
    
    enum CodingKeys: String, CodingKey {
        case codename = "CODENAME"
        case guname = "GUNAME"
        case title = "TITLE"
        case date = "DATE"
        case place = "PLACE"
        case orgName = "ORG_NAME"
        case useTrgt = "USE_TRGT"
        case useFee = "USE_FEE"
        case player = "PLAYER"
        case program = "PROGRAM"
        case etcDesc = "ETC_DESC"
        case orgLink = "ORG_LINK"
        case mainImg = "MAIN_IMG"
        case rgstdate = "RGSTDATE"
        case ticket = "TICKET"
        case strtdate = "STRTDATE"
        case endDate = "END_DATE"
        case themecode = "THEMECODE"
        case lot = "LOT"
        case lat = "LAT"
        case isFree = "IS_FREE"
        case hmpgAddr = "HMPG_ADDR"
    }
}
