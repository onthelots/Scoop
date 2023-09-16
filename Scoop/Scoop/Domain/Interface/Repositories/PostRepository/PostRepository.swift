//
//  PostRepository.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import CoreLocation
import UIKit
import Foundation

protocol PostRepository {

    func searchLocation(
        query: String,
        longitude: String,
        latitude: String,
        radius: Int,
        completion: @escaping (Result<KeywordSearchResult, Error>) -> Void
    )

    func addPost(
        _ post: Post,
        images: [UIImage],
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func fetchPostsAroundCoordinate(
        category: PostCategory,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    func fetchPostsStore(
        storeName: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    func fetchUserPosts(
        uid: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    func updatePost(
        _ post: Post,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func deletePost(
        storeName: String,
        nickname: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
