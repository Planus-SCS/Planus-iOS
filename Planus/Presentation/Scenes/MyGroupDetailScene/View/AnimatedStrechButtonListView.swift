//
//  AnimatedStrechButtonListView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/22.
//

import UIKit

class AnimatedStrechButtonListView: UIView {

    enum Axis {
        case up
        case down
        case left
        case right
    }
    
    enum State {
        case shrinked
        case stretched
    }
    var axis: Axis = .up
    var state: State = .shrinked
    
    var buttons = [UIButton]()
    var anchorConstraints = [NSLayoutConstraint]()
    var spacing: CGFloat = 5
    
    var itemMaxWidth: CGFloat = 0
    var itemMaxHeight: CGFloat = 0
    
    convenience init(axis: Axis) {
        self.init(frame: .zero)
        
        self.axis = axis
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalToConstant: self.itemMaxWidth).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.itemMaxHeight).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButton(button: UIButton) {
        buttons.append(button)
        self.insertSubview(button, at: 0)
        
        let buttonWidth = max(button.constraints.first(where: { $0.firstAttribute == .width })?.constant ?? 0, button.frame.width)
        let buttonHeight = max(button.constraints.first(where: { $0.firstAttribute == .height })?.constant ?? 0, button.frame.height)
        
        self.itemMaxWidth = max(self.itemMaxWidth, buttonWidth)
        self.itemMaxHeight = max(self.itemMaxHeight, buttonHeight)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        var newConst: NSLayoutConstraint
        switch self.axis {
        case .up:
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            newConst = button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            self.constraints.first(where: { $0.firstAttribute == .height })?.constant += spacing + buttonHeight
            self.constraints.first(where: { $0.firstAttribute == .width })?.constant = itemMaxWidth
        case .down:
            button.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            newConst = button.topAnchor.constraint(equalTo: self.topAnchor)
            self.constraints.first(where: { $0.firstAttribute == .height })?.constant = spacing + buttonHeight
            self.constraints.first(where: { $0.firstAttribute == .width })?.constant = itemMaxWidth
        case .left:
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            newConst = button.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            self.constraints.first(where: { $0.firstAttribute == .width })?.constant = spacing + buttonWidth
            self.constraints.first(where: { $0.firstAttribute == .height })?.constant = itemMaxHeight
        case .right:
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            newConst = button.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            self.constraints.first(where: { $0.firstAttribute == .width })?.constant = spacing + buttonWidth
            self.constraints.first(where: { $0.firstAttribute == .height })?.constant = itemMaxHeight
        }
        
        newConst.isActive = true
        anchorConstraints.append(newConst)
    }
    
    func stretch() {
        self.state = .stretched
        var offset: CGFloat = 0
        for i in 0..<buttons.count {
            anchorConstraints[i].isActive = false
            var newConst: NSLayoutConstraint
            switch self.axis {
            case .up:
                newConst = buttons[i].bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: offset)
                offset -= (buttons[i].frame.height + spacing)
            case .down:
                newConst = buttons[i].topAnchor.constraint(equalTo: self.topAnchor, constant: offset)
                offset += (buttons[i].frame.height + spacing)
            case .left:
                newConst = buttons[i].trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: offset)
                offset -= (buttons[i].frame.width + spacing)
            case .right:
                newConst = buttons[i].leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: offset)
                offset += (buttons[i].frame.width + spacing)
            }
            newConst.isActive = true
            anchorConstraints[i] = newConst
        }
//
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func shrink(_ completion: (() -> Void)? = nil) {
        self.state = .shrinked
        for i in 0..<buttons.count {
            anchorConstraints[i].isActive = false
            var newConst: NSLayoutConstraint
            switch self.axis {
            case .up:
                newConst = buttons[i].bottomAnchor.constraint(equalTo: self.bottomAnchor)
            case .down:
                newConst = buttons[i].topAnchor.constraint(equalTo: self.topAnchor)
            case .left:
                newConst = buttons[i].trailingAnchor.constraint(equalTo: self.trailingAnchor)
            case .right:
                newConst = buttons[i].leadingAnchor.constraint(equalTo: self.leadingAnchor)
            }
            newConst.isActive = true
            anchorConstraints[i] = newConst
        }
//
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
        
    }
}
