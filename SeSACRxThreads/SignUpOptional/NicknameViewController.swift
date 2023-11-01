//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NicknameViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    let isHidden = BehaviorSubject(value: false)
    let name = BehaviorSubject(value: "")
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
       
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        bind()
    }
    
    func bind() {
        
        //텍스트필드 입력값을 name에 이벤트 처리
        nicknameTextField
            .rx
            .text
            .orEmpty
            .subscribe { value in
                self.name.onNext(value)
            }
            .disposed(by: disposeBag)
        
        name
            .bind(to: nicknameTextField.rx.text) //단방향?
            .disposed(by: disposeBag)
        
        isHidden
            .bind(to: nextButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        name
            .map{ $0.count >= 2 && $0.count < 6 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                print(value)
                owner.isHidden.onNext(value)
            }
            .disposed(by: disposeBag)
        
        
        
        
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(BirthdayViewController(), animated: true)
    }

    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
         
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
