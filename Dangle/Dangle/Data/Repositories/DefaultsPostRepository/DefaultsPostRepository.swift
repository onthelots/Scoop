//
//  DefaultPostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Combine
import Foundation
import Firebase

class DefaultPostRepository: PostRepository {

    private let networkManager: NetworkService
    private let geocodeManager: GeocodingManager
    private var subscriptions = Set<AnyCancellable>()

    private let firestore: Firestore

    init(networkManager: NetworkService, geocodeManager: GeocodingManager, firestore: Firestore) {
        self.networkManager = networkManager
        self.geocodeManager = geocodeManager
        self.firestore = firestore
    }

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

    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try firestore.collection("Posts").addDocument(from: post) { error in
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
