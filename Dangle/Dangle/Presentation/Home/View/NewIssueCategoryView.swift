//
//  NewIssueCategoryView.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/29.
//

//import UIKit
//
//class NewIssueCategoryView: UIView {
//
//    // Create and add labels/buttons for categories
//    let categories: [BlogName] = [.economy, .traffic, .safe, .house, .environment]
//    var lastLabel: UILabel?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        self.backgroundColor = .white
//        for category in categories {
//            let label = UILabel()
//            label.text = category.rawValue
//            label.textColor = .black
//            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//            label.translatesAutoresizingMaskIntoConstraints = false
//            self.addSubview(label)
//
//            if let lastLabel = lastLabel {
//                label.leadingAnchor.constraint(equalTo: lastLabel.trailingAnchor, constant: 16).isActive = true
//            } else {
//                label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
//            }
//
//            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//            lastLabel = label
//
//            // 카테고리 레이블 탭 핸들링
//            label.isUserInteractionEnabled = true
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryLabelTapped(_:)))
//            label.addGestureRecognizer(tapGesture)
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        NSLayoutConstraint.activate([
//
//        ])
//    }
//}
