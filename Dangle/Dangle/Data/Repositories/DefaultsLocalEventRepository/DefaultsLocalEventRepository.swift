//
//  DefaultsLocalEventRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import Combine

final class DefaultsLocalEventRepository: LocalEventRepository {
    private let networkManager: NetworkService
    private let seoulOpenDataManager: SeoulOpenDataMaanger
    private var subscriptions = Set<AnyCancellable>()

    init(networkManager: NetworkService, seoulOpenDataManager: SeoulOpenDataMaanger) {
        self.networkManager = networkManager
        self.seoulOpenDataManager = seoulOpenDataManager
    }

    func newIssueParsing(
        categoryCode: String, // 코드 번호를 String으로 받아옴
        completion: @escaping (Result<NewIssue, Error>) -> Void
    ) {
        // 서버 요청 시 필요한 파라미터를 설정하여 필터링된 데이터 가져오기
        let queryParameters: [String: String] = [
            "categoryCode": categoryCode // 코드 번호를 요청 파라미터로 설정
        ]

        let resource: Resource<NewIssue> = Resource(
            base: seoulOpenDataManager.openDataNewIssueBaseURL,
            path: "",
            params: queryParameters
        )
        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("---> 서울 새소식 파싱에 실패했습니다 : \(error)")
                case .finished:
                    print("---> 서울 새소식 파싱에 성공했습니다!")
                }
            } receiveValue: { items in
                completion(.success(items))
            }.store(in: &subscriptions)
    }

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
                    print("---> 문화행사 데이터 파싱에 실패했습니다 : \(error)")
                case .finished:
                    print("---> 문화행사 데이터 파싱에 성공했습니다!")
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
                    print("---> 교육 데이터 파싱에 실패했습니다 : \(error)")
                case .finished:
                    print("---> 교육 데이터 파싱에 성공했습니다!")
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

// MARK: - 받아오는 location의 '구' 명칭만 필터링
func extractGuFromLocation(_ location: String) -> String? {
    let components = location.split(separator: " ")
    guard components.count >= 2 else {
        return nil
    }
    return String(components[1])
}
