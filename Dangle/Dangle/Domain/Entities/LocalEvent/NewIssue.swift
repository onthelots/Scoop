//
//  NewIssue.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/26.
//

import Foundation

// MARK: - NewIssue
struct NewIssue: Codable {
    let seoulNewsList: SeoulNewsList

    enum CodingKeys: String, CodingKey {
        case seoulNewsList = "SeoulNewsList"
    }
}

// MARK: - SeoulNewsList
struct SeoulNewsList: Codable {
    let listTotalCount: Int
    let detail: [NewIssueDetail]

    enum CodingKeys: String, CodingKey {
        case listTotalCount = "list_total_count"
        case detail = "row"
    }
}


// MARK: - Row
struct NewIssueDetail: Codable {
    let blogID: Int
    let blogName: BlogName // BlogName에 따라, 
    let postID, postTitle, thumbURI, postExcerpt: String
    let publishDate, modifyDate: String
    let postContent, managerName, managerPhone, managerDept: String

    enum CodingKeys: String, CodingKey {
        case blogID = "BLOG_ID"
        case blogName = "BLOG_NAME"
        case postID = "POST_ID"
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
    case economy = "경제"
    case traffic = "교통"
    case safe = "안전"
    case house = "주택"
    case environment = "환경"
}
