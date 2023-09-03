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

    private let postUseCase: PostUseCase

    // 포스트 버튼을 누르게 되면 -> UseCase를 활용 -> Firebase에 저장
    let postButtonTapped = PassthroughSubject<Post, Never>()

    private var subscription = Set<AnyCancellable>()

    init(postUseCase: PostUseCase) {
        self.postUseCase = postUseCase
    }
}
