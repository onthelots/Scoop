//
//  NewIssueDTO.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/29.
//

import Foundation

struct NewIssueDTO: Hashable {
    let title: String
    let category: String
    let thumbURL: String?
    let excerpt: String // 요약글
    let publishDate: String // 날짜
    let modifyDate: String // 수정날짜
    let postContent: String // 전체내용
    let managerDept: String // 담당부서
    let managerName: String // 담당자
    let attributedContent: NSAttributedString // HTML 변환된 내용

    init(title: String, category: String, thumbURL: String?, excerpt: String, publishDate: String, modifyDate: String, postContent: String, managerDept: String, managerName: String, attributedContent: NSAttributedString) {
           self.title = title
           self.category = category
           self.thumbURL = thumbURL
           self.excerpt = excerpt
           self.publishDate = publishDate
           self.modifyDate = modifyDate
           self.postContent = postContent
           self.managerDept = managerDept
           self.managerName = managerName
           self.attributedContent = attributedContent
       }
}
