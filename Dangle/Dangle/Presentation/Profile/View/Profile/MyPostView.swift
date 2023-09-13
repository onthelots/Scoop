//
//  MyPostView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/12.
//

import UIKit

protocol MyPostViewDelegete: AnyObject {
    func myPostCheckButtonTapped()
    func customerServiceButtonTapped()
    func noticeButtonTapped()
}

class MyPostView: UIView {

    weak var delegate: MyPostViewDelegete!

    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .systemBackground
        return stackView
    }()

    lazy var myPostButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.boldSystemFont(ofSize: 15)
        configuration.attributedTitle = AttributedString("내가 쓴 글", attributes: titleContainer)
        configuration.image = UIImage(systemName: "bell")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        configuration.imagePadding = 10
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(myPostCheckButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var customerServiceButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.boldSystemFont(ofSize: 15)
        configuration.attributedTitle = AttributedString("고객센터", attributes: titleContainer)
        configuration.image = UIImage(systemName: "person.fill.questionmark")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        configuration.imagePadding = 10
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(customerServiceButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var noticeButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.boldSystemFont(ofSize: 15)
        configuration.attributedTitle = AttributedString("공지사항", attributes: titleContainer)
        configuration.image = UIImage(systemName: "speaker.wave.2")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20)
        configuration.imagePadding = 10
        configuration.imagePlacement = .top
        let button = UIButton(configuration: configuration)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(noticeButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func myPostCheckButtonTapped() {
        delegate.myPostCheckButtonTapped()
    }

    @objc private func customerServiceButtonTapped() {
        delegate.customerServiceButtonTapped()
    }

    @objc private func noticeButtonTapped() {
        delegate.noticeButtonTapped()
    }

    private func setupUI() {
        self.buttonStackView.addArrangedSubview(myPostButton)
        self.buttonStackView.addArrangedSubview(customerServiceButton)
        self.buttonStackView.addArrangedSubview(noticeButton)
        self.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            buttonStackView.topAnchor.constraint(equalTo: self.topAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

}
