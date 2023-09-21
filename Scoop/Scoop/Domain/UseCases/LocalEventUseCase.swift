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
                 completion(.success(issues))
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
