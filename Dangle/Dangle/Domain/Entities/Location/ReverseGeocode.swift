//
//  ReverseGeocodee.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//

import Foundation

// MARK: - ReverseGeocodeResponse
struct ReverseGeocode: Codable {
    let reverseMeta: ReverseMeta
    let reverseDocument: [ReverseDocument]

    enum CodingKeys: String, CodingKey {
        case reverseMeta = "meta"
        case reverseDocument = "documents"
    }
}

// MARK: - Document
struct ReverseDocument: Codable {
    let longitude: Double
    let region2DepthName, region3DepthName: String
    let latitude: Double
    let code, regionType, addressName, region4DepthName: String
    let region1DepthName: String

    enum CodingKeys: String, CodingKey {
        case longitude = "x"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case latitude = "y"
        case code
        case regionType = "region_type"
        case addressName = "address_name"
        case region4DepthName = "region_4depth_name"
        case region1DepthName = "region_1depth_name"
    }
}

// MARK: - Meta
struct ReverseMeta: Codable {
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
}
