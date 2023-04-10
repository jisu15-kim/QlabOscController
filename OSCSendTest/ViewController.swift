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
    
    var ipAdress = "192.168.0.34"
    var cueNumber = 1
    
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var cueNumberTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
    }
    
    //MARK: - Functions
    func bind() {
        ipTextField.rx.text
            .bind { [weak self] value in
                if let ip = value {
                    self?.ipAdress = ip
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
        
        volumeSlider.rx.value
            .asObservable()
            .subscribe { [weak self] value in
                guard let self = self else { return }
                guard let volume = value.element else { return }
                let message = self.makeChangeVolumeOSCMessage((volume * 64) - 64)
                self.sendMessage(message)
            }.disposed(by: disposeBag)
    }
    
    
    func setupUI() {
        ipTextField.text = ipAdress
        cueNumberTextField.text = "\(cueNumber)"
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
            try oscClient.send(oscMessage, to: ipAdress, port: 53000)
            print("DEBUG - Message: \(oscMessage)")
        } catch {
            print(error)
        }
    }
}

