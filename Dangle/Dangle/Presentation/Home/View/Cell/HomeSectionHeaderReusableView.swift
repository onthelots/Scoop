//
//  HomeSectionHeaderReusableView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit

class HomeSectionHeaderReusableView: UICollectionReusableView {
    static let identifier = "HomeSectionHeaderReusableView"

    private lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    var categoryBar: UIView? // 카테고리 바를 담을 변수입니다.

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(sectionTitleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            sectionTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])

        // 만약 카테고리 바가 존재한다면, 해당 바를 섹션 헤더에 추가합니다.
        if let categoryBar = categoryBar {
            addSubview(categoryBar)
            categoryBar.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                categoryBar.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 20),
                categoryBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                categoryBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                categoryBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            ])
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sectionTitleLabel.text = nil
    }

    func configure(with title: String) {
        sectionTitleLabel.text = title
    }
}
