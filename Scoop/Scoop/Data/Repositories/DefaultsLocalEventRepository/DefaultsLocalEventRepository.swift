//
//  DefaultsLocalEventRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Combine
import Foundation

final class DefaultsLocalEventRepository: LocalEventRepository {
    private let networkManager: NetworkService
    private let seoulOpenDataManager: SeoulOpenDataManager
    private var subscriptions = Set<AnyCancellable>()

    init(networkManager: NetworkService, seoulOpenDataManager: SeoulOpenDataManager) {
        self.networkManager = networkManager
        self.seoulOpenDataManager = seoulOpenDataManager
    }

    // newIssueParsing
    // newIssueParsing
    func newIssueParsing(
        categoryCode: String,
        completion: @escaping (Result<NewIssue, Error>) -> Void
    ) {
        let resource: Resource<NewIssue> = Resource(
            base: seoulOpenDataManager.openDataNewIssueBaseURL + "\(categoryCode)",
            path: ""
        )
        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error : \(error)")
                case .finished:
                    break
                }
            } receiveValue: { items in
                // 이미지 경로를 수정하여 https:// 를 추가하거나 절대 URL로 변환
                let modifiedItems = self.modifyImagePaths(in: items)
                completion(.success(modifiedItems))
            }.store(in: &subscriptions)
    }

    // 이미지 경로 수정 함수
    // 이미지 경로 수정 함수
    private func modifyImagePaths(in items: NewIssue) -> NewIssue {
        var modifiedItems = items
        for (index, detail) in modifiedItems.seoulNewsList.detail.enumerated() where detail.postContent.contains("src=\"//") {
            // 이미지 경로가 상대 경로인 경우에만 처리
            let modifiedDetail = detail.postContent.replacingOccurrences(of: "src=\"//", with: "src=\"https://")
            modifiedItems.seoulNewsList.detail[index].postContent = modifiedDetail
        }
        return modifiedItems
    }

    // culturalEvent 파싱
    func culturalEventParsing(
        location: String,
        completion: @escaping (Result<CulturalEvent, Error>) -> Void
    ) {
        guard let userGu = extractGuFromLocation(location) else {
            let error = NSError(domain: "Invalid Location", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }

        let resource: Resource<CulturalEvent> = Resource(
            base: seoulOpenDataManager.openDataCulturalBaseURL,
            path: ""
        )

        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error : \(error)")
                case .finished:
                    break
                }
            } receiveValue: { items in
                // 종료시간이 현재 시점보다 이후인 경우만 걸러서 필터링
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.S"

                let filteredDetails = items.culturalEventInfo.detail.filter { eventDetail in
                    if let endDate = dateFormatter.date(from: eventDetail.endDate) {
                        return eventDetail.guname == userGu && endDate >= currentDate
                    }
                    return false
                           }
                let filteredCulturalEventInfo = CulturalEventInfo(
                    listTotalCount: filteredDetails.count,
                    detail: filteredDetails
                )
                let filteredCulturalEvent = CulturalEvent(
                    culturalEventInfo: filteredCulturalEventInfo
                )
                completion(.success(filteredCulturalEvent))
            }.store(in: &subscriptions)
    }

    // educationEvent 파싱
    func educationEventParsing(
        location: String,
        completion: @escaping (Result<EducationEvent, Error>) -> Void
    ) {
        guard let userGu = extractGuFromLocation(location) else {
            let error = NSError(domain: "Invalid Location", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }

        let resource: Resource<EducationEvent> = Resource(
            base: seoulOpenDataManager.openDataEducationBaseURL,
            path: " "
        )
        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error : \(error)")
                case .finished:
                    break
                }
            } receiveValue: { items in
                let filteredDetails = items.educationEventInfo.detail.filter { eventDetail in
                    return eventDetail.areanm == userGu && (eventDetail.svcstatnm == "접수중" || eventDetail.svcstatnm == "안내중")
                }

                let filteredEducationEventInfo = EducationEventInfo(
                    listTotalCount: filteredDetails.count,
                    detail: filteredDetails
                )
                let filteredEducationEvent = EducationEvent(
                    educationEventInfo: filteredEducationEventInfo
                )
                completion(.success(filteredEducationEvent))
            }.store(in: &subscriptions)
    }
}

// 받아오는 location의 '구' 명칭만 필터링
func extractGuFromLocation(_ location: String) -> String? {
    let components = location.split(separator: " ")
    guard components.count >= 2 else {
        return nil
    }
    return String(components[1])
}
