//
//  PostFooterReusableView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/07.
//

import UIKit

class PostFooterReusableView: UICollectionReusableView {
    static let identifier: String = "PostFooterReusableView"

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .tintColor
        pageControl.pageIndicatorTintColor = .systemGray4
        return pageControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePageControl(currentPage: Int, totalPages: Int) {
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = totalPages
    }
}
