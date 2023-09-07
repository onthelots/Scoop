//
//  PostUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import CoreLocation
import Foundation
import UIKit

// UseCase
protocol PostUseCase {
    // 주소 검색 메서드
    func searchLocation(
        query: String,
        longitude: String,
        latitude: String,
        radius: Int,
        completion: @escaping (Result<KeywordSearchResult, Error>) -> Void
    )

    // Post 등록
    func addPost(
        _ post: Post,
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 모든 Post 가져오기
    func fetchPosts(
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 카테고리 별 Post 가져오기
    func fetchPostsForCategory(
        _ category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    func fetchPostsAroundCoordinate(
        category: PostCategory,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 작성한 Post 업데이트
    func updatePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // 작성한 Post 삭제
    func deletePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

class DefaultPostUseCase: PostUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    // 주소 검색 메서드
    func searchLocation(
        query: String,
        longitude: String,
        latitude: String,
        radius: Int,
        completion: @escaping (Result<KeywordSearchResult, Error>) -> Void
    ) {
        postRepository.searchLocation(
            query: query,
            longitude: longitude,
            latitude: latitude,
            radius: radius,
            completion: completion
        )
    }

    // 리뷰 저장 메서드
    func addPost(
        _ post: Post,
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        postRepository.addPost(
            post,
            image: image,
            completion: completion
        )
    }

    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        postRepository.fetchPosts(completion: completion)
    }

    func fetchPostsForCategory(_ category: PostCategory, completion: @escaping (Result<[Post], Error>) -> Void) {
        postRepository.fetchPostsForCategory(
            category,
            completion: completion
        )
    }

    // 중심 좌표 주변의 데이터 가져오기
    func fetchPostsAroundCoordinate(category: PostCategory, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, completion: @escaping (Result<[Post], Error>) -> Void) {
        postRepository.fetchPostsAroundCoordinate(
            category: category,
            coordinate: coordinate,
            radius: radius,
            completion: completion
        )
    }

    func updatePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        postRepository.updatePost(
            post,
            in: category,
            completion: completion
        )
    }

    func deletePost(
        _ post: Post,
        in category: PostCategory,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        postRepository.deletePost(
            post,
            in: category,
            completion: completion
        )
    }
}
