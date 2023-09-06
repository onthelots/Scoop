//
//  MapViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Foundation
import Firebase
import MapKit

class MapViewModel: ObservableObject {

    private let userInfoUseCase: UserInfoUseCase
    private let postUseCase: PostUseCase

    // Input
    @Published var userInfo: UserInfo!
    @Published var userLocation: [LocationInfo] = []
    @Published var filteredPostsForCategory: [Post] = []

    // MapView 프로퍼티 추가
     var mapView: MKMapView?

    // Output
    let itemTapped = PassthroughSubject<LocationInfo, Never>()

    //
    private var subscription = Set<AnyCancellable>()

    init(userInfoUseCase: UserInfoUseCase, postUseCase: PostUseCase) {
        self.userInfoUseCase = userInfoUseCase
        self.postUseCase = postUseCase
    }

    // 유저 정보 Coordinate 가져오기
    func userAllInfoFetch() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        userInfoUseCase.getUserInfo(userId: userId) { result in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // MARK: - viewDidLoad()시 나타낼 초기화 메서드
    func fetchFoodCategoryData() {
        filterAndMarkPostsOnMap(for: .restaurant)
    }

    // MARK: - 모든 Post 데이터 가져와서 지도에 마킹하기
    func fetchAllPostsAndMarkOnMap() {
        postUseCase.fetchPosts { result in
            switch result {
            case .success(let posts):
                // Post 데이터를 가져왔으므로, 지도에 마킹하기
                self.markPostsOnMap(posts)
            case .failure(let error):
                print("Error fetching all posts: \(error)")
            }
        }
    }

    // MARK: - 카테고리 별 데이터 필터링 및 지도에 마킹
    func filterAndMarkPostsOnMap(for category: PostCategory) {
        postUseCase.fetchPostsForCategory(category) { result in
            switch result {
            case .success(let posts):
                self.filteredPostsForCategory = posts
                self.markPostsOnMap(posts)
            case .failure(let error):
                print("Error fetching posts for category \(category.rawValue): \(error)")
            }
        }
    }

    // Post 데이터를 지도에 마킹하는 메서드
    private func markPostsOnMap(_ posts: [Post]) {
        mapView?.removeAnnotations(mapView?.annotations ?? [])
        for post in posts {
            guard let latitude = Double(post.latitude), let longitude = Double(post.longitude) else {
                continue
            }
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            // 어노테이션 생성 및 설정
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = post.storeName // 어노테이션 제목 설정

            // 어노테이션을 지도에 추가
            mapView.map { map in
                map.addAnnotation(annotation)
            }
        }
    }

    // Coordinate 변환
    private func fetchMyLocationCoordinate(latitude: String, longitude: String) -> CLLocationCoordinate2D? {
        guard let latitudeDouble = Double(latitude),
              let longitudeDouble = Double(longitude) else {
            return nil
        }
            let coordinate = CLLocationCoordinate2D(latitude: latitudeDouble, longitude: longitudeDouble)
            return coordinate
    }
}
