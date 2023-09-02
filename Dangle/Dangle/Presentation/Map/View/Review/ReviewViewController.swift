//
//  WriteReviewViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Firebase
import UIKit

/*
 1. 작성하는 값, 저장된 위치값, 사진 -> 저장
 2. 저장 버튼이 필요함 
 */

class ReviewViewController: UIViewController {

    // 저장된 카테고리
    let category: String
    private var viewModel: ReviewViewModel!
    private var reviewView = ReviewView()

    init(category: String) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        view.addSubview(reviewView)
        reviewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reviewView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            reviewView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            reviewView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            reviewView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // Bind를 통해, 저장된 데이터 전달하기
//    private func bind() {
//        viewModel.postButtonTapped
//    }

}
