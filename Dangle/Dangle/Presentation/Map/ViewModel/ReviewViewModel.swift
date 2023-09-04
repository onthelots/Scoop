//
//  WriteReviewViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Foundation
import Combine
import UIKit

class ReviewViewModel: ObservableObject {

    private let postUseCase: DefaultPostUseCase

    // 선택된 점포 정보 리스트 (Cell)
    @Published var userLocation: [SearchResult] = []

    // Output (사용자가 최종적으로 선택한 Cell 값)
    let locationItemTapped = PassthroughSubject<[SearchResult], Never>()

    private var subscription = Set<AnyCancellable>()

    init(postUseCase: DefaultPostUseCase) {
        self.postUseCase = postUseCase
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
                self.userLocation = address.documents
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
}
