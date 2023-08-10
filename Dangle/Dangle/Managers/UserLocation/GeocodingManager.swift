//
//  GeocodingManager.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/10.
//

import Foundation
import Combine

final class GeocodingManager {
    static let shared = GeocodingManager()

    struct Constants {

        // Header 1 : X-NCP-APIGW-API-KEY-ID:{Client ID}
        static let clientID: String = "6s9gpzi23j"
        // Header 2 : X-NCP-APIGW-API-KEY:{Client Secret}
        static let clientSecret: String = "CfWgGZ3jxLPoitULdZW7S9E1dMSEeo4U8C8zavYC"
        // Request URL
        static let requestURL: String = "https://naveropenapi.apigw.ntruss.com/"
        // Reverse Geocoding Endpoint
        static let reverseGeocodePath = "map-reversegeocode/v2/gc"
    }
}
