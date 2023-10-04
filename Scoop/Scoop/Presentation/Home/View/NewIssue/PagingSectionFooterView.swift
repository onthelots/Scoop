//
//  PagingSectionFooterView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 10/4/23.
//

import UIKit
import Combine

class PagingSectionFooterView: UICollectionReusableView {
    static let identifier = "PagingSectionFooterView"

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.isUserInteractionEnabled = true
        control.currentPageIndicatorTintColor = .systemOrange
        control.pageIndicatorTintColor = .systemGray5
        return control
    }()

    private var pagingInfoToken: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }

    func subscribeTo(subject: PassthroughSubject<PagingInfo, Never>, for section: Int) {
        pagingInfoToken = subject
            .filter { $0.sectionIndex == section }
            .receive(on: RunLoop.main)
            .sink { [weak self] pagingInfo in
                self?.pageControl.currentPage = pagingInfo.currentPage
                print("\(String(describing: self?.pageControl.currentPage))")
            }
    }

    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        pagingInfoToken?.cancel()
        pagingInfoToken = nil
    }
}
