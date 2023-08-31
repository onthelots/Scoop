//
//  NewIssueCategoryView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/31.
//

import UIKit

protocol NewIssueCategoryViewDelegate: AnyObject {
    func categoryLabelTapped(_ gesture: UITapGestureRecognizer)
}

class NewIssueCategoryView: UIView {

    weak var delegate: NewIssueCategoryViewDelegate?
    let categories: [BlogName] = [.economy, .traffic, .safe, .house, .environment]

    // Components
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        addSubview(stackView)
        categoryConfigure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func categoryConfigure() {
        for category in categories {
            let categoryLabel = UILabel() // 라벨을 각각 생성
            categoryLabel.text = category.rawValue
            categoryLabel.textColor = .lightGray
            categoryLabel.textAlignment = .center
            categoryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            categoryLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryLabelTapped(_:)))
            categoryLabel.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(categoryLabel)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    @objc private func categoryLabelTapped(_ gesture: UITapGestureRecognizer) {
            delegate?.categoryLabelTapped(gesture)
    }
}
