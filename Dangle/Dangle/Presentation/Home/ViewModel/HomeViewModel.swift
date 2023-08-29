//
//  HomeViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import Foundation
import Combine
import Firebase

class HomeViewModel: ObservableObject {

    private var localEventUseCase: LocalEventUseCase
    private var userInfoUseCase: UserInfoUseCase

    enum Item: Hashable {
        case newIssue(NewIssueDTO)
        case event(EventDetailDTO)
    }

    // 디테일 형식으로 퍼블리셔(PassthroughSubject)
    var newIssueSubject = PassthroughSubject<[NewIssueDetail], Never>()
    var culturalEventSubject = PassthroughSubject<[CulturalEventDetail], Never>()
    var educationEventSubject = PassthroughSubject<[EducationEventDetail], Never>()

    // Output (User Interaction)
    let itemTapped = PassthroughSubject<Item, Never>()

    @Published var userInfo: UserInfo!

    @Published var selectedCategory: String? {
         didSet {
             if let category = selectedCategory {
                 newIssueFetch(category: category)
             }
         }
     }

    // 구독자 --> 추후, 관련된 Cell을 클릭했을 때 활용
    private var subscription: Set<AnyCancellable> = []

    init(localEventUseCase: LocalEventUseCase, userInfoUseCase: UserInfoUseCase) {
        self.localEventUseCase = localEventUseCase
        self.userInfoUseCase = userInfoUseCase
        self.selectedCategory = "21"
    }

    // 2. 사용자 정보를 Firebase에서 가져옴
    func userInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        userInfoUseCase.execute(userId: userId) { result in
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

    func newIssueFetch(category: String) {
        localEventUseCase.execute(categoryCode: category) { result in
            switch result {
            case .success(let newIssue):
                self.newIssueSubject.send(newIssue.seoulNewsList.detail)
            case .failure(let error):
                print("Error fetching newIssue events: \(error)")
            }
        }
    }

    // 문화정보 파싱
    func culturalEventFetch(location: String) {
        localEventUseCase.execute(location: location) { result in
            switch result {
            case .success(let culturalEvent):
                self.culturalEventSubject.send(culturalEvent.culturalEventInfo.detail)
            case .failure(let error):
                print("Error fetching cultural events: \(error)")
            }
        }
    }

    // 교육정보 파싱
    func educationEventFetch(location: String) {
        localEventUseCase.execute(location: location) { result in
            switch result {
            case .success(let educationEvent):
                self.educationEventSubject.send(educationEvent.educationEventInfo.detail)
            case .failure(let error):
                print("Error fetching education events: \(error)")
            }
        }
    }
}
