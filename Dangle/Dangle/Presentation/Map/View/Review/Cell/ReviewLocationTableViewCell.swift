//
//  ReviewLocationTableViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/09/04.
//

import UIKit

class ReviewLocationTableViewCell: UITableViewCell {

    static let identifier = "ReviewLocationTableViewCell"

    // PlaceNameLabel
    private lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()

    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()

    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()

    private lazy var dotLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption2)
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .label
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption1)
        return label
    }()

    // 초기화 및 UI 설정
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(placeLabel)
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(dotLabel)
        contentView.addSubview(addressLabel)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 레이아웃 설정
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            placeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            placeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),

            categoryNameLabel.centerYAnchor.constraint(equalTo: placeLabel.centerYAnchor),
            categoryNameLabel.leadingAnchor.constraint(equalTo: self.placeLabel.trailingAnchor, constant: 5),

            distanceLabel.topAnchor.constraint(equalTo: placeLabel.bottomAnchor, constant: 5),
            distanceLabel.leadingAnchor.constraint(equalTo: placeLabel.leadingAnchor),

            dotLabel.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            dotLabel.leadingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: 5),

            addressLabel.centerYAnchor.constraint(equalTo: dotLabel.centerYAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: dotLabel.trailingAnchor, constant: 10)
        ])
    }


    // 셀 재사용 시 호출되는 메서드로 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        placeLabel.text = nil
        categoryNameLabel.text = nil
        distanceLabel.text = nil
        dotLabel.text = nil
        addressLabel.text = nil
    }

    // 셀에 주소 정보 표시
    func configure(address: SearchResult) {
        placeLabel.text = address.placeName
        distanceLabel.text = "\(address.distance)m"
        dotLabel.text = "|"
        addressLabel.text = address.addressName
        if let categoryGroupName = address.categoryGroupName, !categoryGroupName.isEmpty {
            categoryNameLabel.text = categoryGroupName
        } else {
            let categories = address.categoryName?.components(separatedBy: " > ")
            if let lastCategory = categories?.last {
                categoryNameLabel.text = lastCategory
            } else {
                categoryNameLabel.text = address.categoryName
            }
        }
    }
}
