//
//  NewIssue.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

import Foundation

// MARK: - NewIssue
struct NewIssue: Codable {
    var seoulNewsList: SeoulNewsList

    enum CodingKeys: String, CodingKey {
        case seoulNewsList = "SeoulNewsList"
    }
}

// MARK: - SeoulNewsList
struct SeoulNewsList: Codable {
    let listTotalCount: Int
    var detail: [NewIssueDetail]

    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case detail = "row"
    }
}

// MARK: - Row
struct NewIssueDetail: Codable {
    let blogID: Int
    let blogName: BlogName // 카테고리
    var postTitle: String // 타이틀
    let thumbURI: String // 썸네일 URL (없는 경우가 많음)
    let postExcerpt: String // 요약글
    let publishDate: String // 날짜
    let modifyDate: String // 수정날짜
    var postContent: String
    let managerName, managerPhone, managerDept: String
    var attributedContent: NSAttributedString? // 추가: NSAttributedString을 저장할 속성

    enum CodingKeys: String, CodingKey {
        case blogID = "BLOG_ID"
        case blogName = "BLOG_NAME"
        case postTitle = "POST_TITLE"
        case thumbURI = "THUMB_URI"
        case postExcerpt = "POST_EXCERPT"
        case publishDate = "PUBLISH_DATE"
        case modifyDate = "MODIFY_DATE"
        case postContent = "POST_CONTENT"
        case managerName = "MANAGER_NAME"
        case managerPhone = "MANAGER_PHONE"
        case managerDept = "MANAGER_DEPT"
    }
}

enum BlogName: String, Codable {
    case traffic = "교통"
    case safe = "안전"
    case house = "주택"
    case economy = "경제"
    case environment = "환경"
}
