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
