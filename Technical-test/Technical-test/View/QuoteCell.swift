//
//  QuoteCell.swift
//  Technical-test
//
//  Created by Rost Balanyuk on 12.04.2023.
//

import UIKit

final class QuoteCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let lastLabel = UILabel()
    private let currencyLabel = UILabel()
    private let readableLastChangePercentLabel = UILabel()
    private let starIcon = UIImageView()
    
    private let noFavoriteImage = UIImage(named: "no-favorite")
    private let favoriteImage = UIImage(named: "favorite")
    
    private var enclosingFrameLayer = CALayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        addSubviews()
        setupAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if enclosingFrameLayer.frame != contentView.bounds {
            setupEnclosingFrameLayer()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        setupEnclosingFrameLayer()
    }
    
    func apply(quote: Quote) {
        nameLabel.text = quote.name
        lastLabel.text = quote.last
        currencyLabel.text = quote.currency
        readableLastChangePercentLabel.text = quote.readableLastChangePercent
        readableLastChangePercentLabel.textColor = quote.variationColor
            .map { self.color(for: $0) } ?? .black
        starIcon.image = quote.isFavorite ? favoriteImage : noFavoriteImage
    }
    
    private func color(for name: String) -> UIColor {
        let color = UIColor(named: "quote.variationColor." + name)
        return color ?? .black
    }
    
    private func addSubviews() {
        let smallFont = UIFont.systemFont(ofSize: 17)
        let primaryColor = UIColor.black
        let bigFont = UIFont.systemFont(ofSize: 28)
        
        contentView.layer.addSublayer(enclosingFrameLayer)
        
        nameLabel.font = smallFont
        nameLabel.textColor = primaryColor
        
        lastLabel.font = smallFont
        lastLabel.textColor = primaryColor
        
        currencyLabel.font = smallFont
        currencyLabel.textColor = primaryColor
        
        readableLastChangePercentLabel.font = bigFont
        readableLastChangePercentLabel.textColor = primaryColor
        readableLastChangePercentLabel.textAlignment = .right
        
        starIcon.image = noFavoriteImage
        
        [
            nameLabel, lastLabel, currencyLabel,
            readableLastChangePercentLabel, starIcon
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupAutolayout() {
        [
            nameLabel, lastLabel, currencyLabel,
            readableLastChangePercentLabel, starIcon
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        lastLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        readableLastChangePercentLabel.setContentHuggingPriority(.required, for: .horizontal)
        readableLastChangePercentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            lastLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            lastLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            lastLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            currencyLabel.leadingAnchor.constraint(equalTo: lastLabel.trailingAnchor, constant: 4),
            currencyLabel.firstBaselineAnchor.constraint(equalTo: lastLabel.firstBaselineAnchor),
            
            nameLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: readableLastChangePercentLabel.leadingAnchor, constant: -8
            ),
            currencyLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: readableLastChangePercentLabel.leadingAnchor, constant: -8
            ),
            
            readableLastChangePercentLabel.trailingAnchor.constraint(
                equalTo: starIcon.leadingAnchor, constant: -20
            ),
            readableLastChangePercentLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 4),
            
            starIcon.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            starIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            starIcon.heightAnchor.constraint(equalTo: starIcon.widthAnchor),
            starIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // TODO: Need to clarify with designer the enclosing frame (because cell animations and overlapping)
    private func setupEnclosingFrameLayer() {
        enclosingFrameLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        enclosingFrameLayer.frame = contentView.bounds
        enclosingFrameLayer.masksToBounds = true
        let frameLayer = CALayer()
        frameLayer.borderWidth = 4
        // TODO: is it what we see when cell was selected
        frameLayer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.black.cgColor
        frameLayer.frame = enclosingFrameLayer.bounds
            .inset(by: .init(top: -2, left: 0, bottom: -2, right: 0))
        
        enclosingFrameLayer.addSublayer(frameLayer)
    }

}
