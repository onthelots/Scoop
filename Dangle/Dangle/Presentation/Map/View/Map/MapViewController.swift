//
//  MapViewController.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/07.
//

import Combine
import UIKit
import MapKit
import Firebase
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Binding Data, ViewModel
    private var viewModel: MapViewModel!
    private var userInfo: UserInfo! // 유저의 정보
    private var selectedCategory: PostCategory?

    private var currentPage = 0
    private var totalPages = 0

    private var emptyPostToggleView = EmptyPostToggleView()

    // MARK: - Components
    private lazy var postCategoryView: PostCategoryView = {
        let postCategoryView = PostCategoryView()
        postCategoryView.delegate = self
        return postCategoryView
    }()

    private var filteredPostsForCategory: [Post] = []

    private lazy var mapView = MapView()
    private var collectionView: UICollectionView!
    private lazy var floatingButton = ReviewFloatingView()

    private var subscription = Set<AnyCancellable>()

    // MARK: - Diffable DataSource
    enum Section {
        case main
    }

    typealias Item = Post

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureCollectionView()
        setupUI()
        initalizerViewModel()
        bind()
        setupMapView()
        viewModel.userAllInfoFetch()
        dataLoadingCompleted()
    }
    // MARK: - ViewWillAppera (Floating View initializer)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let presentedModal = presentedViewController as? PostsModalViewController {
            presentedModal.dismiss(animated: true)
        }

        floatingButton.categoryMenuStackView.arrangedSubviews.forEach { (button) in
            button.isHidden = true
        }
        categoryAndfetchPostInitializer()
    }

    // MARK: - setUI()
    private func setupUI() {
        view.addSubview(postCategoryView)
        view.addSubview(mapView)
        view.addSubview(collectionView)
        view.addSubview(floatingButton)

        postCategoryView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            postCategoryView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            postCategoryView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            postCategoryView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mapView.topAnchor.constraint(equalTo: postCategoryView.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: postCategoryView.leadingAnchor, constant: 10),
            mapView.trailingAnchor.constraint(equalTo: postCategoryView.trailingAnchor, constant: -10),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.6),
            collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: postCategoryView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: postCategoryView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // ToogleView 나타내기
    private func showEmptyPostToggleView() {
        if emptyPostToggleView.superview == nil {
            view.addSubview(emptyPostToggleView)
            emptyPostToggleView.translatesAutoresizingMaskIntoConstraints = false

            // 애니메이션 효과 추가
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.activate([
                    self.emptyPostToggleView.heightAnchor.constraint(equalToConstant: 50),
                    self.emptyPostToggleView.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
                    self.emptyPostToggleView.leadingAnchor.constraint(equalTo: self.postCategoryView.leadingAnchor),
                    self.emptyPostToggleView.trailingAnchor.constraint(equalTo: self.postCategoryView.trailingAnchor),
                ])

                // floatingButton을 emptyPostToggleView 위에 오도록 함
                self.view.bringSubviewToFront(self.floatingButton)
                self.view.layoutIfNeeded()
            }
        }

        emptyPostToggleView.isHidden = false
    }

    private func hideEmptyPostToggleView() {
        // 애니메이션 효과 추가
        UIView.animate(withDuration: 1.3) {
            self.emptyPostToggleView.isHidden = true
        }
    }

    private func dataLoadingCompleted() {
        // 데이터 로딩이 완료되면 emptyPostToggleView를 숨깁니다.
        hideEmptyPostToggleView()
    }


    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = MapViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }

    // CollectionView 초기화
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PostFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PostFooterReusableView.identifier)
        collectionView.isPagingEnabled = true // 수평스크롤 Ok
        collectionView.isScrollEnabled = false // 수직 스크롤 X
        configuration()
    }

    // CollectionView DiffableDataSource
    private func configuration() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                return nil
            }
            cell.configure(items: item)
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemGray6
            return cell
        })

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionFooter {
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PostFooterReusableView.identifier, for: indexPath) as? PostFooterReusableView else {
                    return UICollectionReusableView()
                }
                return footerView
            }
            return nil
        }
        collectionView.collectionViewLayout = self.layout()
        collectionView.delegate = self  
    }

    // 3. CollectionView layout
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(90))
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                             repeatingSubitem: item,
                                                             count: 3)

        let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .absolute(270))
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                 repeatingSubitem: verticalGroup,
                                                                 count: 1)

        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [configureFooterLayout()]
        return UICollectionViewCompositionalLayout(section: section)
    }

    // Collectionview footer layout
    private func configureFooterLayout() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        return footer
    }

    // 4. viewModel 바인딩 (userInfo, Post 내용 가져오기)
    private func bind() {
        viewModel.$userInfo
            .sink { userInfo in
                // 1. 유저의 위치를 바탕으로 Center와 span값을 설정 (초기값)
                if let latitudeStr = userInfo?.latitude, let longitudeStr = userInfo?.longitude,
                   let latitude = Double(latitudeStr), let longitude = Double(longitudeStr) {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
                    self.mapView.map.setRegion(region, animated: true)
                    self.userInfo = userInfo
                }
            }.store(in: &subscription)

        // floatingButton의 Category데이터 전달
        floatingButton.textLabelTappedSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                let viewController = ReviewViewController(category: PostCategory(rawValue: text) ?? .beauty, userInfo: userInfo)
                viewController.navigationItem.title = "\(text) 글쓰기"
                viewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)

        viewModel.categoryTapped
            .receive(on: RunLoop.main)
            .sink { [weak self] category in
                guard let self = self else { return }
                self.selectedCategory = category
            }.store(in: &subscription)

        // 데이터 필터링에 따라, snapshot을 업데이트
        viewModel.$filteredPostsForCategory
            .sink { post in
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteAllItems()
                snapshot.appendSections([.main])
                snapshot.appendItems(post, toSection: .main)
                self.dataSource.apply(snapshot)

                if post.isEmpty {
                    self.showEmptyPostToggleView() // 데이터가 없을 때 emptyPostToggleView를 표시
                } else {
                    self.hideEmptyPostToggleView() // 데이터가 있을 때 emptyPostToggleView를 숨김
                    self.filteredPostsForCategory = post
                }

            }.store(in: &subscription)

        viewModel.itemTapped
            .receive(on: RunLoop.main)
            .sink { (category, storeName) in
                let viewController = MapDetailViewController(storeCategory: category, storeName: storeName)
                print("전달하는 데이터 : \(category), \(storeName)")
                viewController.navigationItem.largeTitleDisplayMode = .never
                viewController.title = "Dangle Map"
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)

        postCategoryView.viewModel = viewModel // CategoryView의 viewModel을 일치시킴
    }

    // mapview 초기화 (delegate)
    private func setupMapView() {
        mapView.map.delegate = self
        mapView.layer.cornerRadius = 5
        mapView.layer.masksToBounds = true
        viewModel.mapView = mapView.map

    }

    // MARK: - view 진입시, 초기값 설정
    private func categoryAndfetchPostInitializer() {
        self.selectedCategory = .restaurant
        viewModel.fetchFoodCategoryData(category: .restaurant, coordinate: mapView.map.centerCoordinate)
        self.postCategoryView.update(for: .restaurant)
    }

    // MARK: - modalController 세팅
    private func setSheetPresentationController(_ viewController: UIViewController) {
        let sheet = viewController.sheetPresentationController
        sheet?.preferredCornerRadius = 10
        sheet?.prefersGrabberVisible = true
        sheet?.largestUndimmedDetentIdentifier = .medium
        sheet?.detents = [
            .custom { _ in
                return 200
            }
        ]
    }
}

// CollectionView Delegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let items = viewModel.filteredPostsForCategory[indexPath.item]
        viewModel.itemTapped.send((items.category, items.storeName))
    }
}

// CategoryView Delegate
extension MapViewController: PostCategoryViewDelegate {
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
extension MapViewController: MKMapViewDelegate {

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
        // 현재 지도에 보이는 영역의 좌표 가져오기
        let visibleMapRect = mapView.visibleMapRect
        let visibleRegion = MKCoordinateRegion(visibleMapRect)
        let centerCoordinate = visibleRegion.center
        self.viewModel.fetchPostsAroundCoordinate(category: self.selectedCategory ?? .restaurant, coordinate: centerCoordinate)
        self.viewModel.$filteredPostsForCategory
            .receive(on: RunLoop.main)
            .sink { [weak self] post in
                guard let self = self else { return }
                self.filteredPostsForCategory = post
            }.store(in: &subscription)
    }

    // Annotation을 클릭했을 때 -> 해당 데이터 전달을 통해, 관련 리뷰 모달뷰로 띄우기
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedCategory = selectedCategory, let storeName = view.annotation?.title! {
            viewModel.itemTapped.send((selectedCategory, storeName))
        }
    }
}
