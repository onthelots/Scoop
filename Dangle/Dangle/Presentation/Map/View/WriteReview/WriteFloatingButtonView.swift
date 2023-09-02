//
//  WriteFloatingButtonView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import UIKit
import Combine

class WriteFloatingButtonView: UIView {

    var textLabelTappedSubject = PassthroughSubject<String, Never>()

    // 플로팅 버튼
    private var defaultButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(textStyle: .largeTitle))
        button.setImage(image, for: .normal)
        button.tintColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 버튼
    lazy var categoryMenuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let category: [PostCategory] = [.beauty, .education, .healthcare, .hobby, .restaurant]
        category.forEach { (category) in
            let button = UIButton(type: .system)
            button.setTitle(category.rawValue, for: .normal)
            stackView.addArrangedSubview(button)
            button.isHidden = true
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        }
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(defaultButton)
        addSubview(categoryMenuStackView)

        defaultButton.addTarget(self, action: #selector(tapMenuButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            defaultButton.topAnchor.constraint(equalTo: self.topAnchor).withPriority(.defaultLow),
            defaultButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            defaultButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            defaultButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            categoryMenuStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            categoryMenuStackView.bottomAnchor.constraint(equalTo: defaultButton.topAnchor, constant: -10),
            categoryMenuStackView.topAnchor.constraint(equalTo: topAnchor).withPriority(.defaultHigh)
        ])
    }

    @objc private func tapMenuButton() {

        // 일반적인 애니메이션 효과
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3) {
            self.categoryMenuStackView.arrangedSubviews.forEach { (button) in
                button.isHidden.toggle()
            }
        }
        categoryMenuStackView.layoutIfNeeded()
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        if let text = sender.title(for: .normal) {
            textLabelTappedSubject.send(text)
        }
    }
}
