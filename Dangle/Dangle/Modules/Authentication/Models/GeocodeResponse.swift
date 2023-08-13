//
//  GeocodeResponse.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/13.
//

import Foundation

// MARK: - Geocoding
struct GeocodeResponse: Codable {
    let meta: Meta
    let documents: [Document]
}

// MARK: - Document
struct Document: Codable {
    let latitude: String
    let addressName: String
    let addressType: String
    let longitude: String
    let address: Address
    
    enum CodingKeys: String, CodingKey {
        case latitude = "y"
        case addressName = "address_name"
        case addressType = "address_type"
        case longitude = "x"
        case address
    }
}

// MARK: - Address
struct Address: Codable {
    let addressName, subAddressNo, bCode, region1DepthName: String
    let region3DepthName, region2DepthName, longitude, latitude: String
    let mountainYn, region3DepthHName, mainAddressNo, hCode: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case subAddressNo = "sub_address_no"
        case bCode = "b_code"
        case region1DepthName = "region_1depth_name"
        case region3DepthName = "region_3depth_name"
        case region2DepthName = "region_2depth_name"
        case longitude = "x"
        case latitude = "y"
        case mountainYn = "mountain_yn"
        case region3DepthHName = "region_3depth_h_name"
        case mainAddressNo = "main_address_no"
        case hCode = "h_code"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let isEnd: Bool
    let pageableCount, totalCount: Int

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
    }
}
