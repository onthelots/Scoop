//
//  DefaultsLocalEventRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Combine
import Foundation
import SwiftSoup

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
            .sink { result in
                switch result {
                case .failure(let error):
                    print("error : \(error)")
                    completion(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { items in
                // 이미지 경로를 수정하여 https:// 를 추가하거나 절대 URL로 변환
                var modifiedItems = self.modifyImagePaths(in: items)

                // postTitle을 필터링하여 백슬래시(\)가 포함된 경우 백슬래시를 제거
                modifiedItems.seoulNewsList.detail = modifiedItems.seoulNewsList.detail.map { detail in
                    var updatedDetail = detail
                    if self.containsBackslash(updatedDetail.postTitle) {
                        updatedDetail.postTitle = updatedDetail.postTitle.replacingOccurrences(of: "\\", with: "")
                    }
                    return updatedDetail
                }

                // PDF나 ZIP 파일이 포함되지 않은 데이터를 필터링
                let filteredDetails = modifiedItems.seoulNewsList.detail.filter { !self.containsFileLinks($0.postContent) }
                modifiedItems.seoulNewsList.detail = filteredDetails

                // 필터링된 데이터를 completion에 넣어서 반환
                completion(.success(modifiedItems))
            }
            .store(in: &subscriptions)
    }


    // 파일이 있는 게시물
    private func containsFileLinks(_ htmlString: String) -> Bool {
        do {
            let document = try SwiftSoup.parse(htmlString)
            let fileLinks = try document.select("a")
            for fileLink in fileLinks {
                let href = try fileLink.attr("href")
                if href.lowercased().hasSuffix(".pdf") || href.lowercased().hasSuffix(".zip") {
                    return true // PDF 및 ZIP 파일이 포함된 경우
                }
            }
        } catch {
            print("HTML 파싱 오류: \(error)")
        }

        return false
    }

    // 타이틀에 백 슬래시가 포함됨
    private func containsBackslash(_ text: String) -> Bool {
        return text.contains("\\")
    }

    // 이미지 경로 수정 함수
    private func modifyImagePaths(in items: NewIssue) -> NewIssue {
        var modifiedItems = items
        for (index, detail) in modifiedItems.seoulNewsList.detail.enumerated() where detail.postContent.contains("src=\"//") {
            // 이미지 경로가 상대 경로인 경우에만 처리
            let modifiedDetail = detail.postContent.replacingOccurrences(of: "src=\"//", with: "src=\"https://")
            modifiedItems.seoulNewsList.detail[index].postContent = modifiedDetail
        }

        // 링크 URL 앞에 https:를 추가
        modifiedItems.seoulNewsList.detail = modifiedItems.seoulNewsList.detail.map { detail in
            var updatedDetail = detail
            if updatedDetail.postContent.contains("<a href=\"//") {
                updatedDetail.postContent = updatedDetail.postContent.replacingOccurrences(of: "<a href=\"//", with: "<a href=\"https:")
            }
            return updatedDetail
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
