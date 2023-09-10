//
//  MapDetailViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/06.
//

import Combine
import UIKit
import MapKit
import Firebase
import CoreLocation

class MapDetailViewController: UIViewController {

    let storeCategory: PostCategory? // 이전 뷰에서 선택한 카테고리
    let storeName: String?

    private var viewModel: MapDetailViewModel!
    private var selectedCategory: PostCategory? // 사용자가 직접 선택하는 Category
    private var storeUserReviews: [Post] = []
    private var subscription = Set<AnyCancellable>()

    // MARK: - Components
    private lazy var postCategoryView: PostCategoryView = {
        let postCategoryView = PostCategoryView()
        postCategoryView.delegate = self
        return postCategoryView
    }()

    private lazy var mapView = MapView()

    init(storeCategory: PostCategory?, storeName: String?) {
        self.storeCategory = storeCategory
        self.storeName = storeName
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
        setupUI()
        initalizerViewModel()
        bind()
        setupMapView()
        mapTapGestureToDismissModality()
    }

    private func mapTapGestureToDismissModality() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView.map.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func mapViewTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - ViewWillAppear() : 이전 MapViewController에서 선택한 데이터를 우선적으로 나타냄 (모달뷰를 바로 띄움)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchStorePost(category: storeCategory ?? .restaurant, storeName: storeName ?? "") { result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let modalViewController = PostDetailModalViewController(storeUserReviews: posts)
                    self.setSheetPresentationController(modalViewController)
                    modalViewController.tableView.isScrollEnabled = posts.count > 3
                    self.present(modalViewController, animated: true, completion: nil)
                }
            case .failure(let error):
                print("error : \(error)")
            }
        }
        selectedStoreDataInitializer() // 넘어온 카테고리, 점포 이름에 따라 초기화 (라벨 위치, 주변 데이터 외)
    }

    // MARK: - setUI()
    private func setupUI() {
        view.addSubview(postCategoryView)
        view.addSubview(mapView)

        postCategoryView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            postCategoryView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            postCategoryView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            postCategoryView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            mapView.topAnchor.constraint(equalTo: postCategoryView.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = MapDetailViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }


    private func bind() {
        // 점포의 중심값을 받아와서, 세팅해야함
        viewModel.$posts
            .receive(on: RunLoop.main)
            .sink { posts in
                self.storeUserReviews = posts ?? [Post(authorUID: "", category: .restaurant, storeName: "선택된 점포가 없습니다.", review: "", nickname: "", location: GeoPoint(latitude: 0.0, longitude: 0.0), timestamp: Date())]
                print("선택된 점포의 post : \(self.storeUserReviews.count)")
            }.store(in: &subscription)

        // 카테고리 라벨을 탭 할때마다 업데이트
        viewModel.categoryTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] category in
                guard let self = self else { return }
                self.selectedCategory = category
            }.store(in: &subscription)

        // 해당 점포를 눌렀을 때 -> post 정보 받아와서 모달뷰 띄우기
        viewModel.itemTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] (category, storeName) in
                guard let self = self else { return }
                self.viewModel.fetchStorePost(category: category, storeName: storeName) { result in
                    switch result {
                    case .success(let updateReviews):
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.storeUserReviews = updateReviews
                            let modalViewController = PostDetailModalViewController(storeUserReviews: self.storeUserReviews)
                            self.setSheetPresentationController(modalViewController)
                            modalViewController.tableView.isScrollEnabled = self.storeUserReviews.count > 3
                            self.present(modalViewController, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print("error : \(error)")
                    }
                }
            }
            .store(in: &subscription)
    }

    private func setupMapView() {
        mapView.map.delegate = self
        viewModel.mapView = mapView.map
    }

    // MARK: - view 진입시, 초기값 설정
    private func selectedStoreDataInitializer() {
        self.selectedCategory = storeCategory
        self.postCategoryView.update(for: selectedCategory ?? .cafe)
        viewModel.fetchPostsAroundCoordinate(category: selectedCategory ?? .cafe, coordinate: mapView.map.centerCoordinate) // 해당 카테고리에 맞춰서 데이터 파싱
    }

    // MARK: - 모달뷰 세팅
    private func setSheetPresentationController(_ viewController: UIViewController) {
        let sheet = viewController.sheetPresentationController
        sheet?.preferredCornerRadius = 10
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet?.detents = [
            .custom { _ in
                return self.view.bounds.height * 0.35
            }
        ]
        sheet?.largestUndimmedDetentIdentifier = sheet?.detents[0].identifier
    }
}

// CategoryView Delegate
extension MapDetailViewController: PostCategoryViewDelegate {
    func postCategoryLabelTapped(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel,
           let selectedCategory = PostCategory(rawValue: label.text ?? "") {
            self.postCategoryView.update(for: selectedCategory) // 선택된 카테고리에 따라 view 업데이트
            self.viewModel.categoryTapped.send(selectedCategory) // 뷰 모델에 데이터 전달
            viewModel.fetchPostsAroundCoordinate(category: selectedCategory, coordinate: mapView.map.centerCoordinate) // 해당 카테고리에 맞춰서 데이터 파싱
        }
    }
}

// MKMap Delegate
extension MapDetailViewController: MKMapViewDelegate {

    // Annotation 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.canShowCallout = true
        annotationView.glyphImage = UIImage(systemName: "star.circle.fill")
        annotationView.markerTintColor = .tintColor
        return annotationView
    }

    // 중심값이 이동될 때 마다
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoordinate = mapView.centerCoordinate
        self.viewModel.fetchPostsAroundCoordinate(category: selectedCategory ?? .restaurant, coordinate: centerCoordinate)
    }

    // Annotation을 클릭했을 때 -> 해당 데이터 전달을 통해, 관련 리뷰 모달뷰로 띄우기
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedCategory = selectedCategory, let storeName = view.annotation?.title! {
            if presentationController != nil {
                dismiss(animated: true) {
                    self.showPostDetailModal(category: selectedCategory, storeName: storeName)
                }
            } else {
                self.showPostDetailModal(category: selectedCategory, storeName: storeName)
            }
        }
    }

    private func showPostDetailModal(category: PostCategory, storeName: String) {
          viewModel.itemTapped.send((category, storeName))
      }
}
