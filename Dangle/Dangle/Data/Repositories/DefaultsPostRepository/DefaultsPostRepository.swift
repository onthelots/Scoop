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

    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    private let firestore: Firestore

    init(networkManager: NetworkService, geocodeManager: GeocodingManager, firestore: Firestore) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
        self.firestore = firestore
    }

    // MARK: - 카카오 키워드 검색
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
            header: ["Authorization": "KakaoAK \(geocodeManager.restAPIKey)"]
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

    // Post 등록
    func addPost(_ post: Post, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        let imageReference = storage.reference().child("postImages/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            imageReference.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                imageReference.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    var updatedPost = post
                    updatedPost.postImage = url?.absoluteString

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
        } else {
            completion(.failure(NSError(domain: "Image Data Error", code: 0, userInfo: nil)))
        }
    }

    // 모든 Post 가져오기
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        firestore.collection("UserReviews").getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let posts = querySnapshot?.documents.compactMap { document -> Post? in
                do {
                    let post = try document.data(as: Post.self)
                    return post
                } catch {
                    print("Error decoding Post: \(error)")
                    return nil
                }
            } ?? []

            completion(.success(posts))
        }
    }

    // 카테고리 별 Post 가져오기
    func fetchPostsForCategory(_ category: PostCategory, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        database.collectionGroup("UserReviews").whereField("category", isEqualTo: category.rawValue).getDocuments { (snapshot, error) in

            var posts: [Post] = []

            if let error = error {
                print("error: \(error)")
            } else {
                for userReviewDocument in snapshot!.documents {
                    do {
                        // 문서(UID)를 Post 모델로 디코딩
                        let post = try? userReviewDocument.data(as: Post.self)
                        if let post = post {
                            posts.append(post)
                        }
                    }
                }

                // 모든 UserReviews 데이터를 가져왔을 때 완료 처리
                completion(.success(posts))
            }
        }
    }

    // MARK: - 문서 리뷰를 모두 가져오기
    func fetchPostsAroundCoordinate(
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        // 중심 좌표를 기반으로 GeoPoint를 생성
        let centerGeoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)

        // 중심 좌표에서 반경(radius) 내 데이터를 쿼리
        let latOffset = 0.01449 * (radius / 1000.0) // 1도의 위도 차이에 대한 상수값입니다.
        let lonOffset = 0.01850 * (radius / 1000.0) // 1도의 경도 차이에 대한 상수값입니다.

        let northEast = GeoPoint(latitude: centerGeoPoint.latitude + latOffset, longitude: centerGeoPoint.longitude + lonOffset)
        let southWest = GeoPoint(latitude: centerGeoPoint.latitude - latOffset, longitude: centerGeoPoint.longitude - lonOffset)

        let query = firestore.collectionGroup("UserReviews")
            .whereField("location", isGreaterThan: southWest)
            .whereField("location", isLessThan: northEast)

        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            var posts: [Post] = []

            for document in snapshot!.documents {
                do {
                    let post = try? document.data(as: Post.self)
                    if let post = post {
                        posts.append(post)
                    }
                }
            }

            completion(.success(posts))
        }
    }

    // 작성한 Post 업데이트
    func updatePost(_ post: Post, in category: PostCategory, completion: @escaping (Result<Void, Error>) -> Void) {
         let documentRef = getDocumentReference(for: post, in: category)

         do {
             try documentRef.setData(from: post) { error in
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

    // 작성한 Post 삭제
    func deletePost(_ post: Post, in category: PostCategory, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = getDocumentReference(for: post, in: category)

        documentRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
