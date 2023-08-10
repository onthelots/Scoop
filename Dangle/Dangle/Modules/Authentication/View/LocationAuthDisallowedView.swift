//
//  LocationAuthDisallowedView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/09.
//

import UIKit

protocol LocationAuthDisallowedViewDelegate: AnyObject {
    func locationAuthDisallowedViewDidTapButton(_ view: LocationAuthDisallowedView)
}


class LocationAuthDisallowedView: UIView {
    weak var delegate: LocationAuthDisallowedViewDelegate?

    // MARK: - Components

    // veticalStactkView
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    // label
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }()

    // button
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.link, for: .normal)
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return button
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        isHidden = true

        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Button Action
    @objc func didTapButton() {
        delegate?.locationAuthDisallowedViewDidTapButton(self)
    }

    // UI Update
    override func layoutSubviews() {
        verticalStackView.addArrangedSubview(label)
        verticalStackView.addArrangedSubview(button)
        addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }

    // label, button을 viewModel의 유형에 맞게끔 설정
    func configure(with viewModel: LocationAuthDisallowedViewModel) {
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
