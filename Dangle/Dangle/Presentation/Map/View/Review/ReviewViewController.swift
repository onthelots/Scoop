//
//  WriteReviewViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Firebase
import UIKit
import PhotosUI

class ReviewViewController: UIViewController {

    // 저장된 카테고리
    let category: String
    private var viewModel: ReviewViewModel!
    private var reviewView = ReviewView()
    private var subscription = Set<AnyCancellable>()

    // 이미지 담기
    private var itemProviders: [NSItemProvider] = []

    // 선택한 이미지의 id
    private var selectedAssetIdentifiers = [String]()

    // id와 Phpicker로 만든 딕셔너리 (이미지 데이터 저장)
    private var selections = [String : PHPickerResult]()

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
        reviewView.reviewViewDelegate = self
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

    // ImagePicker -> 버튼 누르면 이미지 피커 띄우기
    private func imagePickerConfiguration() {
        if reviewView.imageViews.count > 3 {
            return
        }
        var configuration = PHPickerConfiguration()
        configuration.selection = .ordered // 선택한 순서 표현
        configuration.preferredAssetRepresentationMode = .current // 트랜스 코딩 방지
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers // 선택했던 이미지를 기억 (Picker를 재 실행했을 시, 이미 이미지들이 체크되어 나옴)
        configuration.selectionLimit = 3
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension ReviewViewController: ReviewViewDelegate {

    func didTappedPictureButton() {
        imagePickerConfiguration()
    }

    func didTappedLocationButton() {
        // go to LocationView
    }
}

// MARK: - PHPicker를 통해 이미지 선택
extension ReviewViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in

                // PHPicker에서 선택된 UIImage
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        // imageViews 배열에 할당하고, Stack View 업데이트 실시
                        self?.reviewView.addImageView(image: image)
                    }
                }
            }
        }
    }
}
