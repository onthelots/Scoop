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

    // MARK: - Components
    private lazy var postCategoryView: PostCategoryView = {
        let postCategoryView = PostCategoryView()
        postCategoryView.delegate = self
        return postCategoryView
    }()

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

    // MARK: - ViewWillAppera (Floating View initializer)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 뷰가 다시 나타날 때 스택뷰를 숨김
        floatingButton.categoryMenuStackView.arrangedSubviews.forEach { (button) in
            button.isHidden = true
        }
    }

    // MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(postCategoryView)
        view.addSubview(mapView)
        initalizerViewModel()
        viewModel.userAllInfoFetch()
        setupMapView()
        configureCollectionView()
        bind()
        setupUI()

//        viewModel.fetchFoodCategoryData(category: .restaurant, coordinate: mapView.map.centerCoordinate)
    }

    // viewModel 초기화
    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        let postUseCase = DefaultPostUseCase(postRepository: DefaultPostRepository(networkManager: NetworkService(configuration: .default), geocodeManager: GeocodingManager(), firestore: Firestore.firestore()))
        viewModel = MapViewModel(userInfoUseCase: userInfoUseCase, postUseCase: postUseCase)
    }

    // mapview 초기화 (delegate)
    private func setupMapView() {
        mapView.map.delegate = self
        // MapView 프로퍼티를 MapViewModel에 주입
        viewModel.mapView = mapView.map
    }

    // CollectionView 초기화
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        configuration()
    }

    // CollectionView DiffableDataSource
    private func configuration() {
        // Presentation
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
                return nil
            }
            cell.configure(items: item)
            cell.backgroundColor = .gray
            return cell
        })

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        self.dataSource.apply(snapshot)

        collectionView.collectionViewLayout = layout()
        collectionView.delegate = self
    }

    // 3. Apply Snapshot
    private func applyItem(_ item: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(item, toSection: .main)
        self.dataSource.apply(snapshot)
    }

    // 3. CollectionView layout
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(75))
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize,
                                                             repeatingSubitem: item,
                                                             count: 3)

        let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .estimated(225))
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize,
                                                                 repeatingSubitem: verticalGroup,
                                                                 count: 1)

        let section = NSCollectionLayoutSection(group: horizontalGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        return UICollectionViewCompositionalLayout(section: section)
    }

    // 4. viewModel 바인딩 (userInfo, Post 내용 가져오기)
    private func bind() {
        viewModel.$userInfo
            .sink { userInfo in
                // 지도 중심값 할당
                if let latitudeStr = userInfo?.latitude, let longitudeStr = userInfo?.longitude,
                   let latitude = Double(latitudeStr), let longitude = Double(longitudeStr) {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                    self.mapView.map.setRegion(region, animated: true)
                    self.userInfo = userInfo
                }
            }.store(in: &subscription)

        // floatingButton의 Category데이터 전달
        floatingButton.textLabelTappedSubject
            .sink { [weak self] text in
                guard let self = self else { return }
                let viewController = ReviewViewController(category: PostCategory(rawValue: text) ?? .beauty, userInfo: userInfo)
                viewController.navigationItem.title = "\(text) 글쓰기"
                viewController.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)

        // 데이터 필터링에 따라, snapshot을 업데이트
        viewModel.$filteredPostsForCategory
            .sink { post in
                var snapshot = self.dataSource.snapshot()
                snapshot.deleteAllItems()
                snapshot.appendSections([.main])
                snapshot.appendItems(post, toSection: .main)
                self.dataSource.apply(snapshot)
            }.store(in: &subscription)

        postCategoryView.viewModel = viewModel // CategoryView의 viewModel을 일치시킴
    }

    // 5. ViewController UI Setting
    private func setupUI() {
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
            mapView.leadingAnchor.constraint(equalTo: postCategoryView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: postCategoryView.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.6),

            collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10), // 수정된 부분
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10), // 수정된 부분
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// CollectionView Delegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // viewModel.item(빈 배열)-> indexPath의 아이템 값
//        let items = viewModel.items[indexPath.item]
//        print("--- didSelected Item: \(items)")
//        viewModel.itemTapped.send(items)
    }
}

// CategoryView Delegate
extension MapViewController: PostCategoryViewDelegate {
    func postCategoryLabelTapped(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel,
           let selectedCategory = PostCategory(rawValue: label.text ?? "") {
            self.postCategoryView.update(for: selectedCategory)
            self.viewModel.categoryTapped.send(selectedCategory)
            viewModel.fetchPostsAroundCoordinate(category: selectedCategory, coordinate: mapView.map.centerCoordinate)
        }
    }
}

// MKMap Delegate
extension MapViewController: MKMapViewDelegate {
    // Annotation 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "Custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
               annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)// 재사용 가능한 식별자를 갖고 어노테이션 뷰를 생성
               annotationView?.canShowCallout = true // 콜아웃 버튼을 보이게 함
               annotationView?.image = UIImage(systemName: "star.fill") // 이미지 변경
               let button = UIButton(type: .detailDisclosure)
               annotationView?.rightCalloutAccessoryView = button
           }

        return annotationView
    }

    // Annotation 탭할 시 호출
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        self.present(UIViewController(), animated: true)
        // 모달뷰를 띄운다던지..
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var centerCoordinate = mapView.centerCoordinate
        var selectedcategory = PostCategory.restaurant
        viewModel.categoryTapped
            .sink { category in
                selectedcategory = category
            }.store(in: &subscription)
        self.viewModel.fetchPostsAroundCoordinate(category: selectedcategory, coordinate: centerCoordinate)
    }
}
