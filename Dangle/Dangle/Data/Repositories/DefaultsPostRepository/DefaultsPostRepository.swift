//
//  DefaultPostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
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
                print("---> 검색 결과 : \(items)")
                completion(.success(items))
            }.store(in: &subscriptions)

    }

    // MARK: - Post 정보 등록하기
    func addPost(_ post: Post, image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        // 1. 이미지를 Firebase Storage에 업로드
        // 아래는 이미지 참조체 imageReference
        let imageReference = storage.reference().child("postImages/\(UUID().uuidString).jpg")
        // 실제 이미지 데이터를 jpegData로 변환한 후,
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // 참조체에 변환 데이털르 할당
            imageReference.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                // 2. 이미지 업로드가 성공하면 해당 이미지의 다운로드 URL을 가져옴
                imageReference.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    // 3. 이미지 다운로드 URL을 Post 객체에 URL로 저장함
                    var updatedPost = post
                    updatedPost.postImage = url?.absoluteString

                    // 4. Post 객체를 Firestore에 저장
                    do {
                        let _ = try self.firestore.collection("Posts").addDocument(from: updatedPost) { error in
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

    // MARK: - Post 전체 정보 불러오기
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        firestore.collection("Posts").getDocuments { querySnapshot, error in
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

    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentID = post.id else {
            completion(.failure(NSError(domain: "Invalid Post", code: 0, userInfo: nil)))
            return
        }

        do {
            let _ = try firestore.collection("Posts").document(documentID).setData(from: post) { error in
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

    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentID = post.id else {
            completion(.failure(NSError(domain: "Invalid Post", code: 0, userInfo: nil)))
            return
        }

        firestore.collection("Posts").document(documentID).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
