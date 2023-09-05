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

    private var viewModel: MapViewModel!
    private var collectionView: UICollectionView!
    private var userInfo: UserInfo! // 유저의 정보

    private lazy var postCategoryView: PostCategoryView = {
        let postCategoryView = PostCategoryView()
        postCategoryView.delegate = self // delegate를 실행할 수 있게끔 선언함
        return postCategoryView
    }()

    private lazy var mapView = MapView()
    private lazy var floatingButton = ReviewFloatingView()

    private var subscription = Set<AnyCancellable>()

    enum Section {
        case main
    }
    typealias Item = Post
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 뷰가 다시 나타날 때 스택뷰를 숨김
        floatingButton.categoryMenuStackView.arrangedSubviews.forEach { (button) in
            button.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(postCategoryView)
        view.addSubview(mapView)
        initalizerViewModel()
        viewModel.userAllInfoFetch()
        configureCollectionView()
        setupMapView()
        setupUI()
        bind()
    }

    func setupMapView() {
        mapView.map.delegate = self
    }

    private func initalizerViewModel() {
        let userInfoUseCase = DefaultsUserInfoUseCase(userInfoRepository: DefaultsUserInfoRepository())
        viewModel = MapViewModel(userInfoUseCase: userInfoUseCase)
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground

        // Cell 및 ReusableView 등록
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)

        // MARK: - Footer View에 PageController 추가할 것
        configuration()
    }

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

        // data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        self.dataSource.apply(snapshot)

        // layout
        collectionView.collectionViewLayout = layout()

        // delegate3
        collectionView.delegate = self
    }

    private func applyItem(_ item: [Post]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(item, toSection: .main)
        self.dataSource.apply(snapshot)
    }

    // CollectionView layout
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)

        let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))

        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: verticalGroupSize, repeatingSubitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: verticalGroup)

        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func bind() {
        viewModel.$userInfo
            .sink { userInfo in
                // 지도 중심값 할당
                if let latitudeStr = userInfo?.latitude, let longitudeStr = userInfo?.longitude,
                   let latitude = Double(latitudeStr), let longitude = Double(longitudeStr) {

                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007))
                    self.mapView.map.setRegion(region, animated: true)
                    self.userInfo = userInfo
                }

                // POST 내용 받아오기 -> applyItem에 할당하기

            }.store(in: &subscription)

        // floatingButton의 Category데이터 전달
        floatingButton.textLabelTappedSubject
            .sink { [weak self] text in
                guard let self = self else { return }
                let viewController = ReviewViewController(category: PostCategory(rawValue: text) ?? .beauty, userInfo: userInfo)
                viewController.navigationItem.title = "\(text) 글쓰기"
                viewController.navigationItem.largeTitleDisplayMode = .never
                viewController.delegate = self
                self.navigationController?.pushViewController(viewController, animated: true)
            }.store(in: &subscription)
    }

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

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // viewModel.item(빈 배열)-> indexPath의 아이템 값
//        let items = viewModel.items[indexPath.item]
//        print("--- didSelected Item: \(items)")
//        viewModel.itemTapped.send(items)
    }
}


extension MapViewController: PostCategoryViewDelegate {
    func postCategoryLabelTapped(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel,
           let selectedCategory = PostCategory(rawValue: label.text ?? "") {
            //            self.viewModel.selectedCategory = categoryCode
            self.postCategoryView.update(for: selectedCategory)
            print("선택된 카테고리 : \(selectedCategory)")

            // MARK: - CollectionView Cell 하위 평가데이터 변경 (snapshot 변경)
            //            var snapshot = dataSource.snapshot()
            //            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .newIssue))
            //            dataSource.apply(snapshot)

            // MARK: - MapPin도 변경할 수 있도록 함
            //            var snapshot = dataSource.snapshot()
            //            snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .newIssue))
            //            dataSource.apply(snapshot)
        }
    }
}

extension MapViewController: ReviewViewControllerDelegate {
    func createAnnotation(title: String, location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()

        annotation.coordinate = location
        annotation.title = title
        mapView.map.addAnnotation(annotation)
    }
}

extension MapViewController: MKMapViewDelegate {
    // Annotation 커스터마이징
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "Custom"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
               // 재사용 가능한 식별자를 갖고 어노테이션 뷰를 생성
               annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

               // 콜아웃 버튼을 보이게 함
               annotationView?.canShowCallout = true
               // 이미지 변경
               annotationView?.image = UIImage(systemName: "star.fill")

               // 상세 버튼 생성 후 액세서리에 추가 (i 모양 버튼)
               // 버튼을 만들어주면 callout 부분 전체가 버튼 역활을 합니다
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

}


// Annotation Custom Class
class CustomAnnotation: NSObject, MKAnnotation {
    var title: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D

    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
