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

    // 유저의 현재 위치 좌표
    let userLocation: [String]
    
    private var viewModel: ReviewViewModel!
    private var reviewView = ReviewView()
    private var subscription = Set<AnyCancellable>()

    // 선택한 이미지의 id
    private var selectedAssetIdentifiers = [String]()

    // id와 Phpicker로 만든 딕셔너리 (이미지 데이터 저장)
    private var selections = [String: PHPickerResult]()

    init(category: String, userLocation: [String]) {
        self.category = category
        self.userLocation = userLocation
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
    private func presentPHPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared()) // 1. Identifier를 위해 초기화를 shared로 설정
        configuration.filter = PHPickerFilter.any(of: [.images]) // 2. Assets(속성)을 필터링 -> 여기서는 Image로
        configuration.selectionLimit = 3 // 3. 다중 선택갯수 설정
        configuration.selection = .ordered // 4. 선택 효과 (order : 숫자로 표현)
        configuration.preferredAssetRepresentationMode = .current // 트랜스 코딩 방지 (다른 Assets 속성을 인코딩 하는 경우)
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers // 선택했던 이미지를 기억 (Picker를 재 실행했을 시, 이미 이미지들이 체크되어 나옴)

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }

    // ImageProvider 처리 -> 로드 후, ImageView에 뿌려주거나 혹은 전역변수에 저장
    private func displayAndSaveImage() {
        // 1. 스택뷰의 모든 서브뷰를 제거함
        self.reviewView.imageStackView.subviews.forEach { $0.removeFromSuperview() }

        // 2. GCD 작업을 실시할 Group을 임의 생성함
        let dispatchGroup = DispatchGroup()

        // 3. Image의 identifier, UIImage를 받아올 임의 딕셔너리를 생성
        var imageDictionary = [String: UIImage]()

        for (identifier, result) in selections {
            dispatchGroup.enter() // 4. 디스패치 그룹에 하나 들어간다~

            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    guard let image = image as? UIImage else { return }
                    // 5. 임의 딕셔너리의 identifier 값에 image를 할당 (즉, identifier 순서에 따라 사용자가 선택한 image를 할당)
                    imageDictionary[identifier] = image
                    dispatchGroup.leave() // 6. dispatchGroup 대기열에서 삭제
                }
            } else {
                print("이미지 로드에 실패하였습니다")
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            self.reviewView.imageStackView.subviews.forEach { $0.removeFromSuperview() }
            for identifier in selectedAssetIdentifiers {
                guard let image = imageDictionary[identifier] else { return }
                self.reviewView.addImageView(image: image)
            }
        }
    }
}

extension ReviewViewController: ReviewViewDelegate {

    func didTappedPictureButton() {
        presentPHPicker()
    }

    func didTappedLocationButton() {
        // MARK: - 수정하려고 누를때, SelectedLocation을 초기화해야 하는데?
        let viewController = LocationSearchViewController(userLocation: userLocation)
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationItem.title = "위치검색"
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - PHPicker를 통해 이미지 선택
extension ReviewViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil) // 완료시, 화면 내리기

        var newSelection = [String: PHPickerResult]() // 1. Picker에서 이미지를 선택한 후, 새로 만들어질 selection 변수 선언

        for result in results {
            let identifier = result.assetIdentifier! // 2. Asset의 Identifier 설정
            // [Selection] 딕셔너리의 identifier값을 순서대로 할당함
            newSelection[identifier] = selections[identifier] ?? result
        }

        // 3. 새롭게 만들어진 selection을 기존에 선언한 전역변수인 selection로 다시 할당
        selections = newSelection

        // 4. 해당 Asset의 Identifier 또한, 선택한 결과값의 Identifier로 할당 (String 값)
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }

        if selections.isEmpty {
            // 5. pictureStackView 내부의 Subview(ImageView)를 초기화(삭제) 함
            self.reviewView.imageStackView.subviews.forEach { $0.removeFromSuperview() }
        } else {
            // 6. 비어있지 않다면? 기존의 imageViews 배열의 값을 모두 지우고, 새롭게 할당시켜줌?
            self.reviewView.imageViews = []
            displayAndSaveImage()
        }
    }
}
