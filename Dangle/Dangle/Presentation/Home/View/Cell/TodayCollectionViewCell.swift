//
//  TodayCollectionViewCell.swift
//  Dangle
//
//  Created by Jae hyuk Yim on 2023/08/24.
//

import UIKit

class TodayCollectionViewCell: UICollectionViewCell {
    static let identifier = "TodayCollectionViewCell"

    // MARK: - Components
    private let locationLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let temperatureLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weatherImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .blue

        contentView.addSubview(locationLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(weatherImageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),

            statusLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor),

            temperatureLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            temperatureLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            weatherImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weatherImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            weatherImageView.heightAnchor.constraint(equalTo: weatherImageView.widthAnchor, multiplier: 1.0),
            weatherImageView.topAnchor.constraint(equalTo: locationLabel.topAnchor),
            weatherImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).withPriority(.defaultHigh),
            weatherImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            weatherImageView.leadingAnchor.constraint(lessThanOrEqualTo: locationLabel.trailingAnchor, constant: 10).withPriority(.defaultLow)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        locationLabel.text = ""
        statusLabel.text = ""
        temperatureLabel.text = ""
        weatherImageView.image = nil
    }

    // MARK: - 목업
    func configure(item: CultureEventDTO) {
        self.locationLabel.text = item.time
        self.weatherImageView.kf.setImage(
            with: URL(string: item.thumbNail ?? "")!,
            placeholder: UIImage(systemName: "hands.sparkles.fill")
        )
        self.statusLabel.text = item.title
        self.temperatureLabel.text = item.location
    }
}
