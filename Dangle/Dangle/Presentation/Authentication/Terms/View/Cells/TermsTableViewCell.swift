//
//  TermsTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/15.
//

import UIKit

protocol TermsTableViewCellDelegate: AnyObject {
    func termsCheckBoxStateChanged(_ termType: TermsType, isChecked: Bool)
}

class TermsTableViewCell: UITableViewCell {
    static let identifier = "SignUpTermsTableViewCell"

    weak var delegate: TermsTableViewCellDelegate?
    var termType: TermsType!

    lazy var termsButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(termsButton)
        contentView.addSubview(termsLabel)
        accessoryType = .disclosureIndicator

        termsButton.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
    }

    @objc func didTapButton() {
        configure(with: termType)
        delegate?.termsCheckBoxStateChanged(termType, isChecked: termType.isChecked)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            termsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            termsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            termsButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
            termsButton.widthAnchor.constraint(equalTo: termsButton.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            termsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: termsButton.trailingAnchor, constant: 5),
            termsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        termsLabel.text = nil
    }

    func configure(with termType: TermsType) {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        self.termType = termType
        termsLabel.text = termType.title
        termsButton.isSelected = termType.isChecked

        termsButton.setImage(
            termType.isChecked ?
                UIImage(systemName: "checkmark.circle.fill", withConfiguration: imageConfig) :
                UIImage(systemName: "checkmark.circle", withConfiguration: imageConfig),
            for: .normal
        )
    }
}
