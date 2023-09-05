//
//  PostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

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
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
}
