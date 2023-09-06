//
//  Post.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var authorUID: String
    var category: PostCategory
    var storeName: String // 점포 이름 또는 ID
    var review: String
    var nickname: String
    var postImage: String?
    var latitude: String
    var longitude: String
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
