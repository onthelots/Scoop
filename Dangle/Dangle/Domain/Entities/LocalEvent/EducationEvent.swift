//
//  EducationEvent.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

struct EducationEvent: Codable {
    let educationEventInfo: EducationEventInfo

    enum CodingKeys: String, CodingKey {
        case educationEventInfo = "ListPublicReservationEducation"
    }
}

// MARK: - ListPublicReservationEducation
struct EducationEventInfo: Codable {
    let listTotalCount: Int
    let detail: [EducationEventDetail]

    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case detail = "row"
    }
}

// MARK: - Row
struct EducationEventDetail: Codable {
    let gubun, svcid, maxclassnm, minclassnm: String
    let svcstatnm, svcnm, payatnm, placenm: String
    let usetgtinfo: String
    let svcurl: String
    let lot, lat, svcopnbgndt, svcopnenddt: String
    let rcptbgndt, rcptenddt, areanm: String
    let imgurl: String
    let dtlcont, telno, vMax, vMin: String
    let revstddaynm, revstdday: String

    enum CodingKeys: String, CodingKey {
        case gubun = "GUBUN"
        case svcid = "SVCID"
        case maxclassnm = "MAXCLASSNM"
        case minclassnm = "MINCLASSNM"
        case svcstatnm = "SVCSTATNM"
        case svcnm = "SVCNM"
        case payatnm = "PAYATNM"
        case placenm = "PLACENM"
        case usetgtinfo = "USETGTINFO"
        case svcurl = "SVCURL"
        case lot = "X"
        case lat = "Y"
        case svcopnbgndt = "SVCOPNBGNDT"
        case svcopnenddt = "SVCOPNENDDT"
        case rcptbgndt = "RCPTBGNDT"
        case rcptenddt = "RCPTENDDT"
        case areanm = "AREANM"
        case imgurl = "IMGURL"
        case dtlcont = "DTLCONT"
        case telno = "TELNO"
        case vMax = "V_MAX"
        case vMin = "V_MIN"
        case revstddaynm = "REVSTDDAYNM"
        case revstdday = "REVSTDDAY"
    }
}
