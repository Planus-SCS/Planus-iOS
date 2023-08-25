//
//  PlaceholderTextView.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/04.
//

import UIKit

class PlaceholderTextView: UITextView {
    private let placeholderLabel: UILabel = UILabel()
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    var placeholderColor: UIColor = UIColor.lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            setupPlaceholderLayout()
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholderLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)
        setupPlaceholderLayout()
    }
    
    private func setupPlaceholderLayout() {
        placeholderLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().inset(textContainerInset.top)
            $0.leading.equalToSuperview().inset(textContainerInset.left + textContainer.lineFragmentPadding)
            $0.trailing.equalToSuperview().inset(textContainerInset.right + textContainer.lineFragmentPadding)
        }
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
}
