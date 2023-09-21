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
                // 데이터를 받은 후, HTML 파싱 및 UILabel에 표시
                let filteredItems = self.filterItems(items)
                completion(.success(filteredItems))
            }.store(in: &subscriptions)
    }

    func filterItems(_ items: NewIssue) -> NewIssue {
        var filteredItems = items
        var filteredDetails: [NewIssueDetail] = []

        for detail in filteredItems.seoulNewsList.detail {
            // 이미지가 포함된 게시물은 필터링
            if containsImages(detail.postContent) {
                continue
            }

            // 파일 링크가 있는지 확인
            if !containsFileLinks(detail.postContent) {
                // 파일 링크가 없는 경우만 처리
                if let attributedText = parseHTMLToAttributedString(htmlString: detail.postContent) {
                    var updatedDetail = detail
                    updatedDetail.attributedContent = attributedText
                    filteredDetails.append(updatedDetail)
                }
            }
        }

        filteredItems.seoulNewsList.detail = filteredDetails
        return filteredItems
    }

    func containsFileLinks(_ htmlString: String) -> Bool {
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

    func containsImages(_ htmlString: String) -> Bool {
        do {
            let document = try SwiftSoup.parse(htmlString)
            let images = try document.select("img")
            return !images.isEmpty
        } catch {
            print("HTML 파싱 오류: \(error)")
            return false
        }
    }

    func parseHTMLToAttributedString(htmlString: String) -> NSAttributedString? {
        do {
            // HTML 문자열을 SwiftSoup Document로 파싱합니다.
            let document = try SwiftSoup.parse(htmlString)

            // 파일이 포함되어 있는지 확인
            let fileLinks = try document.select("a")
            for fileLink in fileLinks {
                let href = try fileLink.attr("href")
                if href.lowercased().hasSuffix(".pdf") || href.lowercased().hasSuffix(".zip") {
                    return nil // PDF 및 ZIP 파일이 포함되어 있으면 데이터를 무시
                }
            }

            // NSAttributedString을 생성하여 UILabel에 표시할 준비를 합니다.
            let attributedString = NSMutableAttributedString()

            // 선택한 모든 <p> 요소를 NSAttributedString에 추가합니다.
            let paragraphs = try document.select("p")
            for paragraph in paragraphs {
                let paragraphText = try paragraph.text()

                // 각 단락을 NSAttributedString에 추가합니다.
                let paragraphAttributedString = NSAttributedString(string: paragraphText + "\n\n")
                attributedString.append(paragraphAttributedString)
            }

            return attributedString
        } catch {
            print("HTML 파싱 오류: \(error)")
            return nil
        }
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
