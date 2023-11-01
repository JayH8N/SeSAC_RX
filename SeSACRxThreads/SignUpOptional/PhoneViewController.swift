//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let themeColor = BehaviorSubject(value: UIColor.black)
    let phoneNumber = BehaviorSubject(value: "010")
    let buttonEnabled = BehaviorSubject(value: false)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        bind()
    }
    
    func bind() {
        
        buttonEnabled
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        themeColor
            .bind(to: phoneTextField.rx.tintColor,
                  nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        themeColor
            .map { $0.cgColor }
            .bind(to: phoneTextField.layer.rx.borderColor )
            .disposed(by: disposeBag)
        
        phoneNumber
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        phoneNumber
            .map { $0.count >= 13 }
            .subscribe(with: self) { owner, value in
                let enable = value ? UIColor.blue : UIColor.black
                owner.themeColor.onNext(enable)
                owner.buttonEnabled.onNext(value)
            }
            .disposed(by: disposeBag)
        
        
        phoneTextField
            .rx
            .text
            .orEmpty
            .subscribe { value in
                let result = value.formated(by: "###-####-####")
                print(value, result)
                self.phoneNumber.onNext(result)
            }
            .disposed(by: disposeBag)
        
        
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(NicknameViewController(), animated: true)
    }

    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
