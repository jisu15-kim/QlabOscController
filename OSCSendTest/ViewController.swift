//
//  ViewController.swift
//  OSCSendTest
//
//  Created by 김지수 on 2023/03/27.
//

import UIKit
import OSCKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    enum TriggerType: String {
        case start
        case stop
    }
    
    //MARK: - Properties
    let oscClient = OSCClient()
    var disposeBag = DisposeBag()
    
    var firstIpAddress = "192.168.50.199"
    var secondIpAddress = "192.168.50.117"
    var cueNumber = 1
    
//    let buttonCount = 12
    var buttonDataSource = [Int]()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.identifier)
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var firstIpTextField: UITextField!
    @IBOutlet weak var secondIpTextField: UITextField!
    @IBOutlet weak var cueNumberTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        bind()
    }
    
    //MARK: - Functions
    private func setupData() {
        for i in 1...12 {
            self.buttonDataSource.append(i)
        }
    }
    
    func bind() {
        firstIpTextField.rx.text
            .bind { [weak self] value in
                if let ip = value {
                    self?.firstIpAddress = ip
                }
            }.disposed(by: disposeBag)
        
        secondIpTextField.rx.text
            .bind { [weak self] value in
                if let ip = value {
                    self?.secondIpAddress = ip
                }
            }.disposed(by: disposeBag)
        
        cueNumberTextField.rx.text
            .bind { [weak self] value in
                if let number = Int(value ?? "") {
                    self?.cueNumber = number
                }
            }.disposed(by: disposeBag)

        startButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let message = self.makePlayStopOSCMessage(type: .start)
                self.sendMessage(message)
            }.disposed(by: disposeBag)
        
        stopButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let message = self.makePlayStopOSCMessage(type: .stop)
                self.sendMessage(message)
            }.disposed(by: disposeBag)
    }
    
    
    func setupUI() {
        firstIpTextField.text = firstIpAddress
        secondIpTextField.text = secondIpAddress
        cueNumberTextField.text = "\(cueNumber)"
        
        [firstIpTextField, secondIpTextField, cueNumberTextField].forEach { textField in
            guard let tf = textField else { return }
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.separator.cgColor
            tf.layer.cornerRadius = 10
            tf.clipsToBounds = true
        }
        
        self.mainStackView.insertArrangedSubview(self.collectionView, at: 6)
        self.collectionView.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(150)
        }
    }
    
    //MARK: - Message Make
    func makePlayStopOSCMessage(type: TriggerType) -> OSCMessage {
        let messageString = "/cue/\(cueNumber)/\(type.rawValue)"
        messageLabel.text = messageString
        let message = OSCMessage(messageString)
        return message
    }

    
    func makeChangeVolumeOSCMessage(_ value: Float) -> OSCMessage {
        // 선택한 큐의 1번채널
        let messageString = "/cue/\(cueNumber)/sliderLevel/0"
        let message = OSCMessage(messageString, values: ["\(value)"])
        messageLabel.text = "\(messageString) \(value)"
        return message
    }
    
    //MARK: - Message Send
    func sendMessage(_ oscMessage: OSCMessage) {
        do {
            try oscClient.send(oscMessage, to: firstIpAddress, port: 53000)
            try oscClient.send(oscMessage, to: secondIpAddress, port: 53000)
            print("DEBUG - Message: \(oscMessage)")
        } catch {
            print(error)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buttonDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.identifier, for: indexPath) as? ButtonCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.buttonIndex = buttonDataSource[indexPath.row]
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = collectionView.frame.width
        width -= 5 * 5
        width /= 6
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension ViewController: ButtonCellDelegate {
    func buttonDidTapped(index: Int) {
        self.cueNumberTextField.text = String(index)
        self.cueNumber = index
    }
}
