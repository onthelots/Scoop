//
//  UnderLineTextField.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/19.
//

import Foundation
import UIKit

class UnderLineTextField: UITextField {
    lazy var placeholderColor: UIColor = self.tintColor
    lazy var placeholderString = ""

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(underLineView)

        NSLayoutConstraint.activate([
            underLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            underLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 1)
        ])

        self.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
    }

    func setPlaceholder(placeholder: String, color: UIColor) {
        placeholderString = placeholder
        placeholderColor = color

        setPlaceholder()
        underLineView.backgroundColor = placeholderColor
    }

    func setPlaceholder() {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
    }

    func setError() {
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderString,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        )
        underLineView.backgroundColor = .red
    }
}

extension UnderLineTextField {
    @objc func editingDidBegin() {
        setPlaceholder()
        underLineView.backgroundColor = .label
    }

    @objc func editingDidEnd() {
        underLineView.backgroundColor = placeholderColor
    }
}

extension UnderLineTextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
