//
//  LocalEventUseCase.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import SwiftSoup

protocol LocalEventUseCase {

    // NewIssue
    func newIssueParsing(
        categoryCode: String,
        completion: @escaping (Result<NewIssue, Error>) -> Void
    )

    // Culture
    func culturalEventParsing(
        location: String,
        completion: @escaping (Result<CulturalEvent, Error>) -> Void
    )

    // Education
    func educationEventParsing(
        location: String,
        completion: @escaping (Result<EducationEvent, Error>) -> Void
    )
}

final class DefaultLocalEventUseCase: LocalEventUseCase {
    private let localEventRepository: LocalEventRepository
    init(localEventRepository: LocalEventRepository) {
        self.localEventRepository = localEventRepository
    }

    // New Issue
    func newIssueParsing(
         categoryCode: String,
         completion: @escaping (Result<NewIssue, Error>) -> Void
     ) {
         localEventRepository.newIssueParsing(
             categoryCode: categoryCode
         ) { result in
             switch result {
             case .success(let issues):
                 var updatedDetail: [NewIssueDetail] = []
                 for detail in issues.seoulNewsList.detail {
                     if !detail.postContent.isEmpty && (detail.postContent.contains("□") || detail.postContent.contains("○")) {
                         do {
                             let doc: Document = try SwiftSoup.parse(detail.postContent)
                             var plainText = try doc.text()
                             plainText = plainText.replacingOccurrences(of: "□", with: "\n")
                             plainText = plainText.replacingOccurrences(of: "○", with: "\n")

                             var updatedDetailItem = detail
                             updatedDetailItem.postContent = plainText
                             updatedDetail.append(updatedDetailItem)
                         } catch {
                             print("HTML parsing error : \(error)")
                         }
                     }
                 }
                 let updatedIssues = NewIssue(seoulNewsList: SeoulNewsList(listTotalCount: updatedDetail.count, detail: updatedDetail))
                 completion(.success(updatedIssues))
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }

    // Cultural Event
    func culturalEventParsing(
        location: String,
        completion: @escaping (Result<CulturalEvent, Error>) -> Void
    ) {
        localEventRepository.culturalEventParsing(
            location: location
        ) { result in
            switch result {
            case .success(let events):
                completion(.success(events))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Education Event
    func educationEventParsing(
        location: String,
        completion: @escaping (Result<EducationEvent, Error>) -> Void
    ) {
        localEventRepository.educationEventParsing(location: location
        ) { result in
            switch result {
            case .success(let events):
                completion(.success(events))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
