//
//  WriteReviewViewController.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Firebase
import UIKit
import PhotosUI

class ReviewViewController: UIViewController {

    let category: PostCategory
    let userInfo: UserInfo!

    private var selectedLocation: SearchResult? // 선택한 위치 정보를 저장할 변수
    private var selectedImage: [UIImage] = []

    private var viewModel: ReviewViewModel!
    private var reviewView = ReviewView()
    private var subscription = Set<AnyCancellable>()

    // 선택한 이미지의 identifier
    private var selectedAssetIdentifiers = [String]()

    // id와 Phpicker로 만든 딕셔너리 (이미지 데이터 저장)
    private var selections = [String: PHPickerResult]()

    init(category: PostCategory, userInfo: UserInfo) {
        self.category = category
        self.userInfo = userInfo
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        view.backgroundColor = .systemBackground
        initializeViewModel()
        updatePostReviewButtonState()
        updateBarButton()
        reviewView.delegate = self
        setupUI()
    }

    // ViewModel 초기화
    private func initializeViewModel() {
        let userLocationUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = ReviewViewModel(postUseCase: userLocationUseCase)
    }

    private func updateBarButton() {
        let saveReviewBarButton: UIBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(didTapAddReview)
        )

        self.navigationItem.rightBarButtonItem = saveReviewBarButton
    }

    private func updatePostReviewButtonState() {
        // reviewTextView에 적어도 10자 이상의 텍스트가 있는지 확인
        let isReviewTextValid = reviewView.reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10

        // 위치가 선택되었는지 확인
        let isLocationSelected = selectedLocation != nil

        // 버튼의 활성화 및 색상 설정
        navigationItem.rightBarButtonItem?.isEnabled = isReviewTextValid && isLocationSelected
        navigationItem.rightBarButtonItem?.tintColor = isReviewTextValid && isLocationSelected ? .label : .quaternaryLabel
    }


    @objc func didTapAddReview() {
        showReviewAddAlert()
    }

    // MARK: - 사용자 리뷰 저장 Action
    public func showReviewAddAlert() {
        let alert = UIAlertController(
            title: "저장하기",
            message: "작성하신 리뷰를 등록하시겠습니까?",
            preferredStyle: .alert
        )
        // alert action
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "저장",
                                      style: .default,
                                      handler: { [weak self] _ in

            guard let userId = Auth.auth().currentUser?.uid,
                  let selectedImages = self?.selectedImage, // 이미지 배열
                  let category = self?.category,
                  let storeName = self?.selectedLocation?.placeName,
                  let reviewText = self?.reviewView.reviewTextView.text,
                  let nickname = self?.userInfo.nickname,
                  let latitude = self?.selectedLocation?.latitude,
                  let longitude = self?.selectedLocation?.longitude,
                  let categoryGroupName = self?.selectedLocation?.categoryGroupName,
                  let roadAddressName = self?.selectedLocation?.roadAddressName,
                  let placeURL = self?.selectedLocation?.placeURL else {
                print("정보가 없습니다.")
                return
            }

            let postInfo = Post(
                authorUID: userId,
                category: PostCategory(rawValue: category.rawValue) ?? .beauty,
                storeName: storeName,
                review: reviewText,
                nickname: nickname,
                postImage: [], // 이미지 배열 전달
                location: GeoPoint(latitude: Double(latitude) ?? 0.0,
                                   longitude: Double(longitude) ?? 0.0),
                categoryGroupName: categoryGroupName,
                roadAddressName: roadAddressName,
                placeURL: placeURL,
                timestamp: Date()
            )

            // 이미지 배열과 함께 Post 정보 전달
            self?.viewModel.postButtonTapped.send((postInfo, selectedImages))
            self?.navigationController?.popViewController(animated: true)

        }))
        present(alert, animated: true)
    }


    // MARK: - UI Setting
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

    // MARK: - ImageProvider 처리 -> 로드 후, ImageView에 뿌려주거나 혹은 전역변수에 저장 (itemProvider가 비동기적 처리임. 따라서 순서대로가 아닌 용량이 작은 순서대로 나타나기 때문에, 이에 따라 dispatchGroup으로 작업함)
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
                self.reviewView.addImageView(image: image) // View 업데이트
                // 최종 선택된 image
                let selectedImage = imageDictionary.values.map { $0 }
                self.selectedImage = selectedImage
            }
        }
    }
}

// MARK: - ReviewView(리뷰 작성뷰) Delegate
extension ReviewViewController: ReviewViewDelegate {
    func didTappedPictureButton() {
        presentPHPicker()
    }

    func didTappedLocationButton() {
        let viewController = LocationSearchViewController(userLocation: [userInfo.longitude ?? "", userInfo.latitude ?? ""])
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationItem.title = "위치검색"
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.updatePostReviewButtonState()
    }
}

// MARK: - PHPicker를 통해 이미지 선택
extension ReviewViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil) // 완료시, 화면 내리기

        var isAnyImageSelected = false // 선택된 이미지를 확인하기 위한 변수

        var newSelection = [String: PHPickerResult]() // 1. Picker에서 이미지를 선택한 후, 새로 만들어질 selection 변수 선언

        for result in results {
            let identifier = result.assetIdentifier! // 2. Asset의 Identifier 설정
            // [Selection] 딕셔너리의 identifier값을 순서대로 할당함
            // 이미 선택한 이미지인지 확인
            if selections[identifier] == nil {
                newSelection[identifier] = result
            } else {
                isAnyImageSelected = true
            }
        }

        // 기존에 선택한 이미지가 없고, 새로 선택한 이미지도 없을 경우, 빈 배열로 업데이트
        if !isAnyImageSelected && newSelection.isEmpty {
            self.selectedImage = []
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

// LocationSearchViewController Delegate (선택된 주소 + reviewView 내 LocationView에 할당할 주소 라벨)
extension ReviewViewController: LocationSearchViewControllerDelegate {
    func locationSelected(_ location: SearchResult) {
        self.selectedLocation = location
        self.reviewView.addLocationLabel(location: location)
        updatePostReviewButtonState()
    }
}
