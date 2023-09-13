//
//  AppConfigurations.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

// 앱키, URL 등
struct GeocodingManager {
    let regionCodeBaseURL = "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes"
    let reverseGeocodeBaseURL = "https://dapi.kakao.com/v2/local/geo/coord2regioncode"
    let geocodeBaseURL = "https://dapi.kakao.com/v2/local/search/address"
    let keywordSearchBaseURL = "https://dapi.kakao.com/v2/local/search/keyword"
}

struct SeoulOpenDataManager {
    let openDataCulturalBaseURL: String = "http://openapi.seoul.go.kr:8088/\(Bundle.main.seoulAPI)/json/culturalEventInfo/1/300/"
    let openDataEducationBaseURL: String = "http://openapi.seoul.go.kr:8088/\(Bundle.main.seoulAPI)/json/tvYeyakCOllect/1/300/"
    let openDataNewIssueBaseURL: String = "http://openapi.seoul.go.kr:8088/\(Bundle.main.seoulAPI)/json/SeoulNewsList/1/30/"
}
