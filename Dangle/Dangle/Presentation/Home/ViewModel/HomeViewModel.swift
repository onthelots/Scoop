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

    var newIssueSubject = PassthroughSubject<[NewIssueDetail], Never>()
    var culturalEventSubject = PassthroughSubject<[CulturalEventDetail], Never>()
    var educationEventSubject = PassthroughSubject<[EducationEventDetail], Never>()

    let itemTapped = PassthroughSubject<Item, Never>()

    @Published var userInfo: UserInfo!
    @Published var selectedCategory: String? {
         didSet {
             if let category = selectedCategory {
                 newIssueFetch(category: category)
             }
         }
     }

    private var subscription: Set<AnyCancellable> = []

    init(localEventUseCase: LocalEventUseCase, userInfoUseCase: UserInfoUseCase) {
        self.localEventUseCase = localEventUseCase
        self.userInfoUseCase = userInfoUseCase
        self.selectedCategory = "21"
    }

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
