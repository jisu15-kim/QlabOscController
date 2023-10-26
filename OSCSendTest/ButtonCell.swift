//
//  ButtonCell.swift
//  OSCSendTest
//
//  Created by 김지수 on 2023/10/27.
//

import UIKit
import SnapKit

protocol ButtonCellDelegate: AnyObject {
    func buttonDidTapped(index: Int)
}

class ButtonCell: UICollectionViewCell {
    //MARK: - Properties
    static let identifier = "ButtonCell"
    
    weak var delegate: ButtonCellDelegate?
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemIndigo
        button.tintColor = .white
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    var buttonIndex: Int? {
        didSet {
            self.configure()
        }
    }
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    @objc private func buttonTapped() {
        guard let index = buttonIndex else { return }
        self.delegate?.buttonDidTapped(index: index)
    }
    
    private func setupUI() {
        self.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
    }
    
    private func configure() {
        guard let index = buttonIndex else { return }
        self.button.setTitle(String(index), for: .normal)
    }
}
