//
//  ViewController.swift
//  ColorBlender
//
//  Created by Михаил on 05.02.2024.
//

import UIKit

final class ViewController: UIViewController {
    
    //MARK: - Properties
    
    let firstView   = ColorLabelView()
    let secondView  = ColorLabelView()
    let resultView  = ColorLabelView()
    
    let plusImage   = UIImageView()
    let equalImage  = UIImageView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [firstView, plusImage, secondView, equalImage, resultView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = UIStackView.spacingUseSystem
        return stackView
    }()
    
    var colors: [UIColor] = [.yellow, .blue]
    
    var onColorPick: (UIColor) -> Void = { _ in }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargets()
        configureColorViews()
        configureStackView()
        configureView(for: traitCollection)
    }
    
    //MARK: - Configuration methods
    
    func configureStackView() {
        
        plusImage.contentMode = .scaleAspectFit
        equalImage.contentMode = .scaleAspectFit
        
        plusImage.image  = R.Images.plusImage
        equalImage.image = R.Images.equalImage
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(firstView)
        stackView.addArrangedSubview(plusImage)
        stackView.addArrangedSubview(secondView)
        stackView.addArrangedSubview(equalImage)
        stackView.addArrangedSubview(resultView)
        
        [firstView, secondView, resultView].forEach {
            $0.heightAnchor.constraint(equalToConstant: 140).isActive = true
        }
        
        NSLayoutConstraint.activate(commonConstraints)
    }
    
    func addTargets() {
        firstView.addButtonTarget(target: self, action: #selector(pickColor), tag: 0)
        secondView.addButtonTarget(target: self, action: #selector(pickColor), tag: 1)
    }
    
    func configureColorViews() {
        let color1 = colors[0]
        let color2 = colors[1]
        
        firstView.set(color: color1)
        secondView.set(color: color2)
        resultView.set(color: blend(colors: [color1, color2]))
    }
    
    //MARK: - Constraints
    
    private lazy var commonConstraints: [NSLayoutConstraint] = {
        let margins = view.safeAreaLayoutGuide
        
        return [
            stackView.topAnchor.constraint(equalTo: margins.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -100),
            stackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
        ]
    }()
    
    private lazy var compactConstraints: [NSLayoutConstraint] = {
        let margins = view.safeAreaLayoutGuide
        
        return [
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -50),
            
        ]
    }()
    
    //MARK: - Horizontal transition methods
    
    private func configureView(for traitCollection: UITraitCollection) {
        if traitCollection.verticalSizeClass == .compact {
            stackView.axis = .horizontal
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            stackView.axis = .vertical
            NSLayoutConstraint.deactivate(compactConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            configureView(for: traitCollection)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if traitCollection.verticalSizeClass != newCollection.verticalSizeClass {
            animateStack(with: coordinator)
        }
    }
    
    //MARK: - Stackview animation
    
    private func animateStack(with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.stackView.transform = CGAffineTransform(scaleX: AnimationMetrics.transformScale, y: AnimationMetrics.transformScale)
        }, completion: { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: AnimationMetrics.duration, delay: 0, options: [], animations: {
                self.stackView.transform = .identity
            })
        })
    }
    
    //MARK: Color Button handler
    
    @objc func pickColor(sender: UIButton) {
        
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true)
        
        onColorPick = { [weak self] color in
            guard let self = self else { return }
            switch sender.tag {
            case 0: self.colors[0] = color
            case 1: self.colors[1] = color
            default: break
            }
            self.configureColorViews()
        }
    }
    
    
    //MARK: - Blending colors function
    
    func blend(colors: [UIColor]) -> UIColor {
        let numberOfColors = CGFloat(colors.count)
        var (red, green, blue, alpha) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        
        let componentsSum = colors.reduce((red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat())) { temp, color in
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (temp.red+red, temp.green + green, temp.blue + blue, temp.alpha+alpha)
        }
        return UIColor(red: componentsSum.red / numberOfColors,
                       green: componentsSum.green / numberOfColors,
                       blue: componentsSum.blue / numberOfColors,
                       alpha: componentsSum.alpha / numberOfColors)
    }
}

    //MARK: - ColorPickerViewControllerDelegate

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        onColorPick(color)
    }
}


extension ViewController {
    private enum AnimationMetrics {
        static let duration: TimeInterval = 0.5
        static let transformScale: CGFloat = 1.5
    }
}
