//
//  WriteFloatingButtonView.swift
//  Scoop
//
//  Created by Jae hyuk Yim on 2023/09/01.
//

import UIKit
import Combine

// MARK: - Floating 버튼에 대한 Delegate 설정 (-> 메인뷰인 MapViewController에서 위임받아 처리)
protocol ReviewFloatingViewDelegate: AnyObject {
    func activateDimView(_ activate: Bool)
}

class ReviewFloatingView: UIView {

    weak var delegate: ReviewFloatingViewDelegate?
    var floatingButtonFlag: Bool = true
    let initialRotationAngle: CGFloat = 0.0 // 플로팅 버튼 초기 회전 각도 (0도)
    var textLabelTappedSubject = PassthroughSubject<String, Never>()

    let categoryButtonImages: [PostCategory: UIImage] = [
        .restaurant: UIImage(named: "salad") ?? UIImage(),
        .cafe: UIImage(named: "coffee") ?? UIImage(),
        .beauty: UIImage(named: "make-up") ?? UIImage(),
        .hobby: UIImage(named: "painting") ?? UIImage(),
        .education: UIImage(named: "book") ?? UIImage(),
        .hospital: UIImage(named: "health-clinic") ?? UIImage()
    ]

    // 플로팅 버튼
    lazy var floatingButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 40)
        configuration.imagePlacement = .all
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 스택뷰 (카테고리 선택을 통한 글 작성하기)
    lazy var categoryMenuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let categories: [PostCategory] = [.restaurant, .cafe, .beauty, .hobby, .education, .hospital]

        categories.forEach { (category) in
            if let image = categoryButtonImages[category] {
                // MARK: - Named Image 사이즈 변경
                let resizeImage = image.resize()
                var configuration = UIButton.Configuration.plain()
                var titleContainer = AttributeContainer()
                titleContainer.font = UIFont.preferredFont(forTextStyle: .caption1)
                configuration.attributedTitle = AttributedString(category.rawValue, attributes: titleContainer)
                configuration.image = resizeImage
                configuration.image?.withRenderingMode(.alwaysTemplate)
                configuration.imagePadding = 20
                configuration.imagePlacement = .trailing
                configuration.baseForegroundColor = .black
                let button = UIButton(configuration: configuration)
                stackView.addArrangedSubview(button)
                button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            }
        }
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(floatingButton)
        addSubview(categoryMenuStackView)

        floatingButton.addTarget(self, action: #selector(tapMenuButton), for: .touchUpInside)
        floatingButton.transform = CGAffineTransform(rotationAngle: initialRotationAngle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            floatingButton.topAnchor.constraint(equalTo: self.topAnchor).withPriority(.defaultLow),
            floatingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            floatingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            floatingButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            categoryMenuStackView.topAnchor.constraint(equalTo: topAnchor).withPriority(.defaultHigh),
            categoryMenuStackView.centerXAnchor.constraint(equalTo: floatingButton.centerXAnchor),
            categoryMenuStackView.bottomAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -10)
        ])
    }

    // 메뉴 버튼(Floating Button)을 눌렀을 시
    @objc private func tapMenuButton() {
        self.floatingButtonFlag.toggle()
        let rotationAngle: CGFloat = self.floatingButtonFlag ? initialRotationAngle : CGFloat.pi / 4.0 // 토글 상태에 따라 회전 각도 결정
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseInOut) {
            self.floatingButton.transform = CGAffineTransform(rotationAngle: rotationAngle) // 버튼 회전 각도 적용
            self.categoryMenuStackView.arrangedSubviews.forEach { (button) in
                button.isHidden.toggle()
                self.delegate?.activateDimView(button.isHidden)
            }
            self.categoryMenuStackView.layoutIfNeeded()
        }
    }



    // 카테고리 버튼을 눌렀을 시
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            textLabelTappedSubject.send(text)
        }
    }
}
