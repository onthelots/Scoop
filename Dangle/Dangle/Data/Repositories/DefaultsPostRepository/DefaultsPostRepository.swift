//
//  DefaultPostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Foundation
import Firebase

class DefaultPostRepository: PostRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
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
