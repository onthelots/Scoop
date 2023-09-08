//
//  MapDetailViewModel.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/07.
//

import Combine
import Foundation
import Firebase
import MapKit


class MapDetailViewModel: ObservableObject {

    private let userInfoUseCase: UserInfoUseCase
    private let postUseCase: PostUseCase
    
    @Published var userInfo: UserInfo!
    @Published var posts: [Post]?

    // MapView 프로퍼티 추가
    var mapView: MKMapView?

    // Output
    let itemTapped = PassthroughSubject<(PostCategory, String), Never>() // 해당 점포를 눌렀을 때
    let categoryTapped = PassthroughSubject<PostCategory, Never>()

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

    // Store의 post 가져오기
    func fetchStorePost(category: PostCategory, storeName: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        postUseCase.fetchPostsStore(storeName: storeName, category: category) { result in
            switch result {
            case .success(let posts):
                self.posts = posts
                self.setRegionToStore(posts)
                completion(.success(posts)) // 데이터를 성공적으로 받아온 경우 성공 결과를 completion 클로저로 전달
            case .failure(let error):
                print("Error fetching posts around coordinate: \(error)")
                completion(.failure(error)) // 데이터를 가져오는 중 에러 발생 시 에러를 completion 클로저로 전달
            }
        }
    }


    // 해당 Post로 중심값 이동하기 👏
    func setRegionToStore(_ post: [Post]) {
        if let latitude = posts?.first?.location.latitude,
           let longitude = posts?.first?.location.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            self.mapView?.setRegion(region, animated: true)
        }
    }

    // 중심 좌표 주변의 데이터를 가져오는 메서드
    func fetchPostsAroundCoordinate(category: PostCategory, coordinate: CLLocationCoordinate2D) {
        // MARK: - 반경 설정 (미터)
        let radius: CLLocationDistance = 1000 // 1km 반경

        postUseCase.fetchPostsAroundCoordinate(category: category, coordinate: coordinate, radius: radius) { [weak self] result in
            switch result {
            case .success(let posts):
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

            // 어노테이션을 지도에 추가
            mapView.map { map in
                map.addAnnotation(annotation)
            }
        }
    }
}
