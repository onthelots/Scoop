//
//  LocalEventUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation

protocol LocalEventUseCase {
    func execute(
        location: String,
        completion: @escaping (Result<CulturalEvent, Error>) -> Void
    )
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
