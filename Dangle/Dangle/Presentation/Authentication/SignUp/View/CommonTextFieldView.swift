//
//  CommonTextFieldView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/19.
//

import UIKit

class CommonTextFieldView: UIView {

    // 라벨
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 텍스트필드
    let textField: UnderLineTextField = {
        let textField = UnderLineTextField()
        textField.frame.size.height = 40
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.clearButtonMode = .always
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    // 토글뷰 (에러시, 나타나는 뷰)
    let eventLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        let font = UIFont.systemFont(ofSize: 12)
        imageAttachment.image = UIImage(systemName: "exclamationmark.circle")
        imageAttachment.bounds = CGRect(x: -1, y: -2, width: 12, height: 12)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "이미 존재하는 이메일입니다. 다시 확인해주세요"))
        label.attributedText = attributedString
        label.sizeToFit()
        label.font = .systemFont(ofSize: 12)
        label.isHidden = true // 일단 숨겨놓음
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        addSubview(textLabel)
        addSubview(textField)
        addSubview(eventLabel)

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: self.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),

            textField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 5),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40),

            eventLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            eventLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            eventLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
