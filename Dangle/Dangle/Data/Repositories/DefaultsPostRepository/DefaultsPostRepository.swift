//
//  DefaultPostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import CoreLocation
import Foundation
import Firebase
import FirebaseStorage

class DefaultPostRepository: PostRepository {
    let database = Firestore.firestore()
    let storage = Storage.storage()

    private let kakaoAPIKey = Bundle.main.kakaoAPI
    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    private let firestore: Firestore

    init(networkManager: NetworkService, geocodeManager: GeocodingManager, firestore: Firestore) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
        self.firestore = firestore
    }

    // MARK: - 주소 검색
    func searchLocation(
        query: String,
        longitude: String,
        latitude: String,
        radius: Int,
        completion: @escaping (Result<KeywordSearchResult, Error>) -> Void
    ) {
        let params = [
            "query": "\(query)",
            "x": "\(longitude)",
            "y": "\(latitude)",
            "radius": "\(radius)"
        ]

        let resource: Resource<KeywordSearchResult> = Resource(
            base: geocodeManager.keywordSearchBaseURL,
            path: "",
            params: params,
            header: ["Authorization": "KakaoAK \(kakaoAPIKey)"]
        )

        networkManager.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("--> 쿼리를 통해 지오코딩 데이터를 가져오는데 실패했습니다: \(error)")
                case .finished:
                    print("--> 쿼리릍 통해 지오코딩 데이터를 가져왔습니다.")
                }
            } receiveValue: { items in
                completion(.success(items))
            }.store(in: &subscriptions)

    }

    // 카테고리에 따른 Firestore 컬렉션 참조를 가져오는 도움 함수
    private func getCollectionReference(for category: PostCategory) -> CollectionReference {
        return firestore.collection(category.rawValue)
    }

    // Post와 관련된 Firestore 문서 참조를 가져오는 도움 함수
    private func getDocumentReference(for post: Post, in category: PostCategory) -> DocumentReference {
        let collectionRef = getCollectionReference(for: category)
        return collectionRef.document(post.storeName).collection("UserReviews").document(post.authorUID)
    }

    // MARK: - 리뷰 저장
    func addPost(_ post: Post, images: [UIImage], completion: @escaping (Result<Void, Error>) -> Void) {
        var imageUrls: [String] = []

        let dispatchGroup = DispatchGroup()

        for image in images {
            dispatchGroup.enter()
            let imageReference = storage.reference().child("postImages/\(UUID().uuidString).jpg")

            if let imageData = image.jpegData(compressionQuality: 0.8) {
                imageReference.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        dispatchGroup.leave()
                        completion(.failure(error))
                        return
                    }

                    imageReference.downloadURL { url, error in
                        if let error = error {
                            dispatchGroup.leave()
                            completion(.failure(error))
                            return
                        }

                        if let imageUrl = url?.absoluteString {
                            imageUrls.append(imageUrl)
                        }

                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
                completion(.failure(NSError(domain: "Image Data Error", code: 0, userInfo: nil)))
            }
        }

        // 모든 이미지가 업로드 및 URL 획득될 때까지 기다립니다.
        dispatchGroup.notify(queue: .global()) {
            var updatedPost = post
            updatedPost.postImage = imageUrls

            do {
                let categoryName = post.category.rawValue
                let categoryCollection = self.firestore.collection(categoryName)
                let storeRef = categoryCollection.document(post.storeName)
                let userDocRef = storeRef.collection("UserReviews").document(post.authorUID)
                try userDocRef.setData(from: updatedPost) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Map 중심 위치에 따라, 데이터 가져오기 (카테고리 별로)
    func fetchPostsAroundCoordinate(
            category: PostCategory,
            coordinate: CLLocationCoordinate2D,
            radius: CLLocationDistance,
            completion: @escaping (Result<[Post], Error>) -> Void
        ) {
            // 중심 좌표를 기반으로 GeoPoint를 생성
            let centerGeoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)

            // MARK: - 여기서 부터 조정해서, 현재 맵뷰에서 안보이면 중심 좌표에서 반경(radius) 내 데이터를 쿼리하도록 함
            let latOffset = 0.007245 * (radius / 1000.0) // 1도의 위도 차이에 대한 상수값입니다.
            let lonOffset = 0.00925 * (radius / 1000.0) // 1도의 경도 차이에 대한 상수값입니다.

            let northEast = GeoPoint(latitude: centerGeoPoint.latitude + latOffset, longitude: centerGeoPoint.longitude + lonOffset)
            let southWest = GeoPoint(latitude: centerGeoPoint.latitude - latOffset, longitude: centerGeoPoint.longitude - lonOffset)

            var posts: [Post] = []

            let dispatchGroup = DispatchGroup()

            // Firestore 쿼리 - latitude와 longitude를 함께 사용하여 쿼리
            dispatchGroup.enter()
            let query = database.collectionGroup("UserReviews")
                .whereField("category", isEqualTo: category.rawValue) // 카테고리 별로 필터링
                .whereField("location", isGreaterThan: southWest)
                .whereField("location", isLessThan: northEast)

            query.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    dispatchGroup.leave()
                    return
                }

                for document in snapshot!.documents {
                    if let post = try? document.data(as: Post.self) {
                        posts.append(post)
                    }
                }

                dispatchGroup.leave()
            }

            // 모든 쿼리가 완료될 때까지 기다립니다.
            dispatchGroup.notify(queue: .main) {
                // 여기에서 posts 배열과 Firestore 쿼리 결과를 검사하는 추가 디버그를 수행할 수 있습니다.
                print("최종 검색된 게시물 수: \(posts.count)")
                completion(.success(posts))
            }
        }

    // MARK: - 해당 점포의 리뷰 가져오기
    func fetchPostsStore(
        storeName: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        var posts: [Post] = []
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        let query = database.collectionGroup("UserReviews")
            .whereField("category", isEqualTo: category.rawValue) // 카테고리 별로 필터링
            .whereField("storeName", isEqualTo: storeName)

            query.getDocuments { querySnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    dispatchGroup.leave()
                    return
                }

                for document in querySnapshot!.documents {
                    if let post = try? document.data(as: Post.self) {
                        posts.append(post)
                    }
                }
                dispatchGroup.leave()
            }
        // 모든 쿼리가 완료될 때까지 기다린 후, 넘김
        dispatchGroup.notify(queue: .main) {
            completion(.success(posts))
        }
    }

    // MARK: - 유저가 작성한 모든 게시물 가져오기
    func fetchUserPosts(uid: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        let query = database.collectionGroup("UserReviews")
            .whereField("authorUID", isEqualTo: uid)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            var posts: [Post] = []
            for document in snapshot!.documents {
                if let post = try? document.data(as: Post.self) {
                    posts.append(post)
                }
            }

            completion(.success(posts))
        }
    }

    // MARK: - 게시물을 업데이트
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let categoryName = post.category.rawValue
        let categoryCollection = firestore.collection(categoryName)
        let storeRef = categoryCollection.document(post.storeName)
        let userDocRef = storeRef.collection("UserReviews").document(post.authorUID)

        do {
            try userDocRef.setData(from: post) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    // 게시물을 삭제합니다.
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        let categoryName = post.category.rawValue
        let categoryCollection = firestore.collection(categoryName)
        let storeRef = categoryCollection.document(post.storeName)
        let userDocRef = storeRef.collection("UserReviews").document(post.authorUID)

        userDocRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
