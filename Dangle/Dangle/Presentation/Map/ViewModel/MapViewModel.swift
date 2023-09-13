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
    @Published var filteredPostsForCategory: [Post] = []
    @Published private(set) var emptyLabelHidden: Bool = true

    // MapView 프로퍼티 추가
    var mapView: MKMapView?

    // Output
    let categoryTapped = PassthroughSubject<PostCategory, Never>()
    let itemTapped = PassthroughSubject<(PostCategory, String), Never>()

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

    // 중심 좌표 주변의 데이터를 가져오는 메서드
    func fetchPostsAroundCoordinate(category: PostCategory, coordinate: CLLocationCoordinate2D) {
        // MARK: - 반경 설정 (미터)
        let radius: Double = 1000.0 // 1km 반경
        postUseCase.fetchPostsAroundCoordinate(category: category, coordinate: coordinate, radius: radius) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.filteredPostsForCategory = posts
                self?.markPostsOnMap(posts)
            case .failure(let error):
                // 에러 처리
                print("Error fetching posts around coordinate: \(error)")
            }
        }
    }

    // Post 데이터를 지도에 마킹하는 메서드
    private func markPostsOnMap(_ posts: [Post]) {
        mapView?.removeAnnotations(mapView?.annotations ?? [])
        for post in posts {
            let latitude = post.location.latitude
            let longitude = post.location.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            // 어노테이션 생성 및 설정
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = post.storeName // 어노테이션 제목 설정
            annotation.subtitle = post.category.rawValue

            // 어노테이션을 지도에 추가
            mapView.map { map in
                map.addAnnotation(annotation)
            }
        }
    }

    // 첫 화면에서 나타날 초기값
    func fetchFoodCategoryData(category: PostCategory, coordinate: CLLocationCoordinate2D) {
        fetchPostsAroundCoordinate(category: category, coordinate: coordinate)
    }
}
