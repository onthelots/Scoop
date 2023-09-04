//
//  KeywordSearchResult.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/04.
//

import Foundation

struct KeywordSearchResult: Codable {
    let documents: [SearchResult]
    let meta: MetaData
}

struct SearchResult: Codable {
    let addressName, categoryGroupCode: String
    let categoryGroupName: String?
    let categoryName: String?
    let distance, id, phone, placeName: String
    let placeURL: String
    let roadAddressName: String
    let longitude: String
    let latitude: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case categoryName = "category_name"
        case distance, id, phone
        case placeName = "place_name"
        case placeURL = "place_url"
        case roadAddressName = "road_address_name"
        case longitude = "x"
        case latitude = "y"
    }
}

// MARK: - Meta
struct MetaData: Codable {
    let isEnd: Bool
    let pageableCount: Int
    let sameName: SameName
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case sameName = "same_name"
        case totalCount = "total_count"
    }
}

// MARK: - SameName
struct SameName: Codable {
    let keyword: String
    let region: [String]
    let selectedRegion: String
    
    enum CodingKeys: String, CodingKey {
           case keyword, region
           case selectedRegion = "selected_region"
       }
}

enum CategoryGroupName: String {
    case MT1 = "대형마트"
    case CS2 = "편의점"
    case PS3 = "어린이집/유치원"
    case SC4 = "학교"
    case AC5 = "학원"
    case PK6 = "주차장"
    case OL7 = "주유소"
    case SW8 = "지하철역"
    case BK9 = "은행"
    case CT1 = "문화시설"
    case AG2 = "중개업소"
    case PO3 = "공공기관"
    case AT4 = "관광명소"
    case AD5 = "숙박"
    case FD6 = "음식점"
    case CE7 = "카페"
    case HP8 = "병원"
    case PM9 = "약국"
}

