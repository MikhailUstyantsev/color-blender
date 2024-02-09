//
//  ColorLabelView.swift
//  ColorBlender
//
//  Created by Михаил on 05.02.2024.
//

import UIKit

class ColorLabelView: UIView {

    private let label   = UILabel()
    private let button  = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        
        addSubview(label)
        addSubview(button)
        
        label.textAlignment                 = .center
        label.numberOfLines                 = 2
        label.minimumScaleFactor            = 0.65
        label.adjustsFontSizeToFitWidth     = true
        button.layer.cornerRadius           = 8
        button.clipsToBounds                = true
        
        let padding: CGFloat                = 8
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            label.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            label.heightAnchor.constraint(equalToConstant: 40),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            button.centerXAnchor.constraint(equalTo: label.centerXAnchor)
        ])
    }
    
    func addButtonTarget(target: Any?, action: Selector, tag: Int) {
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tag = tag
    }
    
    func set(color: UIColor) {
        button.backgroundColor = color
        label.text = color.accessibilityName.localizedUppercase
    }
    
    
}
