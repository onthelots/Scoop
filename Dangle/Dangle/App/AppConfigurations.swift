//
//  AppConfigurations.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/16.
//

import Foundation

// 앱키, URL 등
struct GeocodingManager {
    let restAPIKey: String = "d2e7271e2f362be0582f1b7897a516d3"
    let regionCodeBaseURL = "https://grpc-proxy-server-mkvo6j4wsq-du.a.run.app/v1/regcodes"
    let reverseGeocodeBaseURL = "https://dapi.kakao.com/v2/local/geo/coord2regioncode"
    let geocodeBaseURL = "https://dapi.kakao.com/v2/local/search/address"
}

// MARK: - 나중에 info 파일로 넣기
let restAPIKey: String = "6d6d676c586f6e74313130434f696361"

struct SeoulOpenDataMaanger {
    let openDataCulturalBaseURL: String = "http://openapi.seoul.go.kr:8088/\(restAPIKey)/json/culturalEventInfo/1/500/"
    let openDataEducationBaseURL: String = "http://openapi.seoul.go.kr:8088/\(restAPIKey)/json/tvYeyakCOllect/1/500/"
}
