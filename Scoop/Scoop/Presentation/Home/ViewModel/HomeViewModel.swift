//
//  HomeViewModel.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import Combine
import Firebase

class HomeViewModel: ObservableObject {

    private let localEventUseCase: LocalEventUseCase
    private let userInfoUseCase: UserInfoUseCase

    enum Item: Hashable {
        case newIssue(NewIssueDTO)
        case event(EventDetailDTO)
    }

    // MARK: - Input
    @Published var userInfo: UserInfo!
    @Published var selectedCategory: String? {
         didSet {
             if let category = selectedCategory {
                 newIssueFetch(category: category)
             }
         }
     }

    // MARK: - OutPut
    var newIssueSubject = PassthroughSubject<[NewIssueDetail], Never>()
    var culturalEventSubject = PassthroughSubject<[CulturalEventDetail], Never>()
    var educationEventSubject = PassthroughSubject<[EducationEventDetail], Never>()
    let itemTapped = PassthroughSubject<Item, Never>()

    private var subscription = Set<AnyCancellable>()

    init(localEventUseCase: LocalEventUseCase, userInfoUseCase: UserInfoUseCase) {
        self.localEventUseCase = localEventUseCase
        self.userInfoUseCase = userInfoUseCase
        self.selectedCategory = "21"
    }

    // 유저 정보 가져오기
    func userInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        userInfoUseCase.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                self.culturalEventFetch(location: userInfo.location ?? "")
                self.educationEventFetch(location: userInfo.location ?? "")
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // NewIssue 데이터 파싱
    func newIssueFetch(category: String) {
        localEventUseCase.newIssueParsing(categoryCode: category) { result in
            switch result {
            case .success(let newIssue):
                self.newIssueSubject.send(newIssue.seoulNewsList.detail)
            case .failure(let error):
                print("Error fetching newIssue events: \(error)")
            }
        }
    }

    // culturalEvent 데이터 파싱
    func culturalEventFetch(location: String) {
        localEventUseCase.culturalEventParsing(location: location) { result in
            switch result {
            case .success(let culturalEvent):
                self.culturalEventSubject.send(culturalEvent.culturalEventInfo.detail)
            case .failure(let error):
                print("Error fetching cultural events: \(error)")
            }
        }
    }

    // educationEvent 데이터 파싱
    func educationEventFetch(location: String) {
        localEventUseCase.educationEventParsing(location: location) { result in
            switch result {
            case .success(let educationEvent):
                self.educationEventSubject.send(educationEvent.educationEventInfo.detail)
            case .failure(let error):
                print("Error fetching education events: \(error)")
            }
        }
    }
}
