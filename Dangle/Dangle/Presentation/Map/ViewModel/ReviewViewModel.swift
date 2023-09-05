//
//  WriteReviewViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Foundation
import Firebase
import UIKit

class ReviewViewModel: ObservableObject {

    private let postUseCase: DefaultPostUseCase
    
    // 선택된 점포 정보 리스트 (Cell)
    @Published var userInfo: UserInfo!
    @Published var searchResults: [SearchResult] = []

    // Output (사용자가 최종적으로 선택한 Cell 값)
    let locationItemTapped = PassthroughSubject<SearchResult, Never>()
    let postButtonTapped = PassthroughSubject<Post, Never>()
    
    private var subscription = Set<AnyCancellable>()
    
    init(postUseCase: DefaultPostUseCase) {
        self.postUseCase = postUseCase
        addUserPost()
    }
    
    // 쿼리(검색)을 통해 주소값 가져오기
    func fetchSearchLoction(query: String, longitude: String, latitude: String, radius: Int) {
        postUseCase.execute(
            query: query,
            longitude: longitude,
            latitude: latitude,
            radius: radius
        ) { result in
            switch result {
            case .success(let address):
                print("받아온 데이터 : \(address)")
                self.searchResults = address.documents
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
    // 저장하기
    func addUserPost() {
        postButtonTapped
            .sink { post in
                print("저장된 포스트: \(post)")
            }.store(in: &subscription)
    }
}
