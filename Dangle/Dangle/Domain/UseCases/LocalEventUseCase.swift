//
//  LocalEventUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import SwiftSoup

protocol LocalEventUseCase {

    // NewIssue
    func execute(
        categoryCode: String,
        completion: @escaping (Result<NewIssue, Error>) -> Void
    )

    // Culture
    func execute(
        location: String,
        completion: @escaping (Result<CulturalEvent, Error>) -> Void
    )

    // Education
    func execute(
        location: String,
        completion: @escaping (Result<EducationEvent, Error>) -> Void
    )
}

final class DefaultLocalEventUseCase: LocalEventUseCase {
    // repository
    private let localEventRepository: LocalEventRepository

    init(localEventRepository: LocalEventRepository) {
        self.localEventRepository = localEventRepository
    }

    // New Issue
    func execute(
         categoryCode: String,
         completion: @escaping (Result<NewIssue, Error>) -> Void
     ) {
         localEventRepository.newIssueParsing(
             categoryCode: categoryCode
         ) { result in
             switch result {
             case .success(let issues):
                 // 새로운 빈 배열을 생성
                 var updatedDetail: [NewIssueDetail] = []

                 for detail in issues.seoulNewsList.detail {
                     // postContent만 filtering해서 다시 할당하고자 함
                     // 1. 비어있지 않거나, ㅁ, o 가 포함되어 있다면
                     if !detail.postContent.isEmpty && (detail.postContent.contains("□") || detail.postContent.contains("○")) {
                         do {
                             // 2. 각 아이템의 postContent를 변환 (HTML -> JSON 형식)
                             let doc: Document = try SwiftSoup.parse(detail.postContent)

                             // 2. plainText 형태(String)으로 만들어 줌
                             var plainText = try doc.text()

                             // 3. plainText중, ㅁ과 o를 줄바꿈(\n)으로 대체함
                             plainText = plainText.replacingOccurrences(of: "□", with: "\n")
                             plainText = plainText.replacingOccurrences(of: "○", with: "\n")

                             // 4. 변수 선언(DetailItem)
                             var updatedDetailItem = detail
                             // 5. deatil postContent에 변환이 완료된 plainText를 순회하며 할당
                             updatedDetailItem.postContent = plainText
                             // 6. 빈 배열에 업데이트 된 DeatilItem을 할당함
                             updatedDetail.append(updatedDetailItem)
                         } catch {
                             print("HTML parsing error : \(error)")
                         }
                     }
                 }

                 // 7. 최종적으로, NewIssues 타입을 전달하기 위해, 앞서 변환된 updateDetail 배열을 detail에 할당함
                 let updatedIssues = NewIssue(seoulNewsList: SeoulNewsList(listTotalCount: updatedDetail.count, detail: updatedDetail))
                 completion(.success(updatedIssues))
             case .failure(let error):
                 completion(.failure(error))
             }
         }
     }






    // Cultural Event
    func execute(
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
    func execute(
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
