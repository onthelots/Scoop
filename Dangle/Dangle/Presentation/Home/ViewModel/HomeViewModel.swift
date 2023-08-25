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

    // 로컬 데이터를 불러오는 UseCase
    private var localEventUseCase: LocalEventUseCase

    // 사용자 데이터를 가져오는 UseCase
    private var userInfoUseCase: UserInfoUseCase

    // 디테일 형식으로 퍼블리셔(PassthroughSubject)
    var culturalEventSubject = PassthroughSubject<[CulturalEventDetail], Never>()
    var educationEventSubject = PassthroughSubject<[EducationEventDetail], Never>()

    @Published var userInfo: UserInfo!

    @Published var dangleIssueEventTapped: [DangleIssueDTO] = []
    @Published var culturalEventTapped: [CultureEventDTO] = []
    @Published var educationEventTapped: [EducationEventDTO] = []


    // 구독자 --> 추후, 관련된 Cell을 클릭했을 때 활용
    private var subscription: Set<AnyCancellable> = []

    init(localEventUseCase: LocalEventUseCase, userInfoUseCase: UserInfoUseCase) {
        self.localEventUseCase = localEventUseCase
        self.userInfoUseCase = userInfoUseCase
    }

    // 2. 사용자 정보를 Firebase에서 가져옴
    func userInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        print("현재 유저의 Id : \(userId)")

        // MARK: - dangle Issue에 데이터 전달하기
        /*
         1. firestore에 있는 특정 location 루트를 받아온 후, 데이터를 전달하기
         2. dangleIssueFetch() 메서드를 실행하기
         */

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

    // MARK: - dangleIssue 파싱
    func dangleIssueFetch() {
        // 
    }

    // 문화정보 파싱
    func culturalEventFetch(location: String) {
        localEventUseCase.execute(location: location) { result in
            switch result {
            case .success(let culturalEvent):
                print("파싱성공 : 문화행사 데이터", culturalEvent.culturalEventInfo.detail.count)
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
                print("파싱성공 : 교육 데이터", educationEvent.educationEventInfo.detail.count)
                self.educationEventSubject.send(educationEvent.educationEventInfo.detail)
            case .failure(let error):
                print("Error fetching education events: \(error)")
            }
        }
    }
}
