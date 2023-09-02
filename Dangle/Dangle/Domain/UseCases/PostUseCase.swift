//
//  PostUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import Foundation

// UseCase
protocol PostUseCase {
    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultPostUseCase: PostUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func addPost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postRepository.addPost(post, completion: completion)
    }

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        postRepository.fetchPosts(completion: completion)
    }

    func updatePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postRepository.updatePost(post, completion: completion)
    }

    func deletePost(_ post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        postRepository.deletePost(post, completion: completion)
    }
}