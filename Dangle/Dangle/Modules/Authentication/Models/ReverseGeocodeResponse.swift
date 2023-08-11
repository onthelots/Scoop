//
//  ReverseGeocodeResponse.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/11.
//


struct ReverseGeocodeResponse: Codable {
    let results: [LocationResult]
}

struct LocationResult: Codable {
    let code: Code
    let land: Land?
    let name: String
    let region: Region
}

struct Code: Codable {
    let id: String
    let mappingId: String
    let type: String
}

struct Land: Codable {
    let addition0: Addition
    let addition1: Addition
    let addition2: Addition
    let addition3: Addition
    let addition4: Addition
}

struct Area: Codable {
    let name: String
}

struct Region: Codable {
    let area0: Area
    let area1: Area
    let area2: Area
    let area3: Area
    let area4: Area
}

struct Addition: Codable {
    let type: String
    let value: String
}
