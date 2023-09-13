//
//  HomeSectionHeaderReusableView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/25.
//

import UIKit

class HomeSectionHeaderReusableView: UICollectionReusableView {
    static let identifier = "HomeSectionHeaderReusableView"

    var categoryBar: UIView?

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
            sectionTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            sectionTitleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
        ])

        // Add CategoryBar
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
