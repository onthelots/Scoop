//
//  EmptyPostToggleView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/11.
//

import UIKit

class EmptyPostToggleView: UIView {
    // MARK: - Components

    // veticalStactkView
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    // label
    lazy var alertlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.sizeToFit()
        label.numberOfLines = 0
        label.text = "인근에 작성된 이웃의 이야기가 없습니다"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()

    // button
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.text = "+ 버튼을 눌러, 내 동네 이야기를 작성해주세요"
//        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .tintColor
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        self.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // UI Update
    override func layoutSubviews() {
        verticalStackView.addArrangedSubview(alertlabel)
        verticalStackView.addArrangedSubview(descriptionLabel)
        addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
}
