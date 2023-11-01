//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let birthDay: BehaviorSubject<Date> = BehaviorSubject(value: .now)
    let year = BehaviorSubject(value: 0)
    let month = BehaviorSubject(value: 0)
    let day = BehaviorSubject(value: 0)
    let buttonColor = BehaviorSubject(value: UIColor.black)
    let buttonEnable = BehaviorSubject(value: false)
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
        
        bind()
    }
    
    func bind() {
        
        //1️⃣데이트피커의 날짜를 Observable(birthDay)에 전달
        birthDayPicker.rx.date
            .bind(to: birthDay)
            .disposed(by: disposeBag)
        
        //2️⃣전달받은 데이터를 년,월,일단위로 나눠 각 Observable에 이벤트 처리
        birthDay
            .subscribe(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                owner.year.onNext(component.year!) //year가 데이터를 처리하는 역할을 하게됨
                owner.month.onNext(component.month!)
                owner.day.onNext(component.day!)
            }
            //.dispose() //즉시 리소스 정리 (위의 코드가 더이상 동작하지 않게 됨) 처음 셋팅값은 반영되겠지만 이후 데이트피커를 조작해도 데이터처리가 되지 않아 레이블에 반영이 되지 않게된다.
            .disposed(by: disposeBag)
        
        
        //3️⃣birthDay를 통해 이벤트처리 받을 수 있도록 각레이블 구독
        year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                owner.monthLabel.text = "\(value)월"
            })
            .disposed(by: disposeBag)
        
        day
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                owner.dayLabel.text = "\(value)일"
            }
            .disposed(by: disposeBag)
        
        //버튼 활성화 여부 구독
        buttonEnable
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        buttonColor
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, color in
                owner.nextButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
//       birthDay
//            .map {  }
//            .observe(on: MainScheduler.instance)
//            .subscribe(with: self) { owner, value in
//                let color = value ? UIColor.blue : UIColor.black
//                owner.buttonColor.onNext(color)
//            }
        
        
    }
    
    @objc func nextButtonClicked() {
        print("가입완료")
    }

    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
