//
//  PostRepository.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Foundation

protocol PostRepository {
    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
}
