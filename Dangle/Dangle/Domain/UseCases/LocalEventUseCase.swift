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
            case .success(var issues):
                for (index, detail) in issues.seoulNewsList.detail.enumerated() {
                    do {
                        let doc: Document = try SwiftSoup.parse(detail.postContent)
                        let plainText = try doc.text()
                        issues.seoulNewsList.detail[index].postContent = plainText
                    } catch {
                        print("HTML parsing error : \(error)")
                    }
                }
                completion(.success(issues))
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
