//
//  LocalEventUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol LocalEventUseCase {

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

    // NewIssue
    func execute(
        category: String,
        completion: @escaping (Result<NewIssue, Error>) -> Void
    )
}

final class DefaultLocalEventUseCase: LocalEventUseCase {
    // repository
    private let localEventRepository: LocalEventRepository

    init(localEventRepository: LocalEventRepository) {
        self.localEventRepository = localEventRepository
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

    // New Issue
    func execute(
        category: String,
        completion: @escaping (Result<NewIssue, Error>) -> Void
    ) {
        localEventRepository.newIssueParsing(category: category
        ) { result in
            switch result {
            case .success(let issues):
                completion(.success(issues))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
