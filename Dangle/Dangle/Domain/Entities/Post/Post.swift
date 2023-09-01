//
//  Post.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // 고유한 문서(Document) 아이디
    var authorUID: String // 사용자 UID
    var category: PostCategory // 작성 카테고리
    var address: String // 점포 위치
    var review: String // 리뷰내용
    var nickname: String? // 섬네일
    var postImage: String? // 이미지
    var latitude: Double // 좌표
    var longitude: Double // 좌표
    var timestamp: Date // 시간
}

enum PostCategory: String, Codable {
    case restaurant = "맛집/카페"
    case hobby = "취미/클래스"
    case beauty = "뷰티/헬스"
    case healthcare = "병원/약국"
    case education = "문화/교육"
}
