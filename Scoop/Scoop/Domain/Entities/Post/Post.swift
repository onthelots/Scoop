//
//  Post.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

import CoreLocation
import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

struct Post: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var authorUID: String
    var category: PostCategory
    var storeName: String
    var review: String
    var nickname: String
    var postImage: [String]?
    var location: GeoPoint
    var categoryGroupName: String
    var roadAddressName: String
    var placeURL: String
    var timestamp: Date
}

enum PostCategory: String, Codable {
    case restaurant = "맛집"
    case cafe = "카페"
    case hobby = "취미"
    case beauty = "뷰티"
    case hospital = "병원"
    case education = "교육"
}
