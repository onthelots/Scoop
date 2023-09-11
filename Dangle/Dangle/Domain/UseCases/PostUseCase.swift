//
//  PostUseCase.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import CoreLocation
import Foundation
import UIKit

protocol PostUseCase {
    // 주소 검색
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
        images: [UIImage],
        completion: @escaping (Result<Void, Error>) -> Void
    )

    // Map 중심 위치에 따라, 데이터 가져오기 (카테고리 별로)
    func fetchPostsAroundCoordinate(
        category: PostCategory,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    )

    // 해당 점포의 리뷰 가져오기
    func fetchPostsStore(
        storeName: String,
        category: PostCategory,
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

    // MARK: - 주소 검색
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

    // MARK: - 리뷰 저장
    func addPost(
        _ post: Post,
        images: [UIImage],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        postRepository.addPost(
            post,
            images: images,
            completion: completion)
    }

    // MARK: - Map 중심 위치에 따라, 데이터 가져오기 (카테고리 별로)
    func fetchPostsAroundCoordinate(
        category: PostCategory,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        postRepository.fetchPostsAroundCoordinate(
            category: category,
            coordinate: coordinate,
            radius: radius,
            completion: completion
        )
    }

    // MARK: - 해당 점포의 리뷰 가져오기
    func fetchPostsStore(
        storeName: String,
        category: PostCategory,
        completion: @escaping (Result<[Post], Error>) -> Void
    ) {
        postRepository.fetchPostsStore(
            storeName: storeName,
            category: category,
            completion: completion
        )
    }


    // MARK: - 리뷰 업데이트
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

    // MARK: - 리뷰 삭제
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
