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

    let postUseCase: DefaultPostUseCase

    @Published var userInfo: UserInfo!
    @Published var searchResults: [SearchResult] = []

    // Output (사용자가 최종적으로 선택한 Cell 값)
    let locationItemTapped = PassthroughSubject<SearchResult, Never>()
    let postButtonTapped = PassthroughSubject<(Post, [UIImage]), Never>() // 튜플로 변경
    
    private var subscription = Set<AnyCancellable>()
    
    init(postUseCase: DefaultPostUseCase) {
        self.postUseCase = postUseCase
        addUserPost()
    }
    
    // 쿼리(검색)을 통해 주소값 가져오기
    func fetchSearchLoction(query: String, longitude: String, latitude: String, radius: Int) {
        postUseCase.searchLocation(
            query: query,
            longitude: longitude,
            latitude: latitude,
            radius: radius
        ) { result in
            switch result {
            case .success(let address):
                self.searchResults = address.documents
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }

    // 리뷰 저장하기
    func addUserPost() {
        postButtonTapped
            .sink { [weak self] post, imageUrls in
                self?.postUseCase.addPost(post, images: imageUrls) { result in
                    switch result {
                    case .success:
                        print("Post가 성공적으로 저장되었습니다.")
                    case .failure(let error):
                        print("Post 저장 실패: \(error.localizedDescription)")
                    }
                }
            }.store(in: &subscription)
    }
}
