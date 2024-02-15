//
//  CreateDateVC.swift
//  NOTEme
//
//  Created by Christina on 9.02.24.
//

import UIKit
import SnapKit
import Storage
import CoreData

@objc protocol CreateDateViewModelProtocol: AnyObject {
    
    var catchTitleError: ((String?) -> Void)? { get set }
    var catchDateError: ((String?) -> Void)? { get set }
    var title: String? { get set }
    var comment: String? { get set }
    var date: Date? { get set }
    func string(from date: Date?) -> String?
    func createDidTap()
    @objc func cancelDidTap()
}

final class CreateDateVC: UIViewController {
    
    private enum L10n {
        static let titleLabel: String =
        "createDate_titleLabel".localized
        static let createButton: String =
        "createDate_createButton".localized
        static let cancelButton: String =
        "createDate_cancelButton".localized
        static let titleTextField: String =
        "createDate_title".localized
        static let titlePlaceholderTextField: String =
        "createDate_titlePlaceholder".localized
        static let dateTextFieldTitle: String =
        "createDate_date".localized
        static let datePlaceholderTextField: String =
        "createDate_datePlaceholder".localized
        static let commentTextFieldTitle: String =
        "createDate_comment".localized
        static let commentPlaceholderTextField: String =
        "createDate_commentPlaceholder".localized
    }
    
    private lazy var contentView: UIView = .basicView()
    
    private lazy var titleLabel: UILabel =
        .dataBoldLabel(L10n.titleLabel)
    
    private lazy var infoView: UIView = .plainViewWithShadow()

    private lazy var createButton: UIButton =
        .yellowRoundedButton(L10n.createButton)
        .withAction(self, #selector(createDidTap))
   
    private lazy var cancelButton: UIButton =
        .cancelButton()
        .withAction(viewModel,
                    #selector(CreateDateViewModelProtocol.cancelDidTap))
    
    private lazy var titleTextField: LineTextField = {
        let textField = LineTextField()
        textField.title = L10n.titleTextField
        textField.delegate = self
        textField.placeholder = L10n.titlePlaceholderTextField
        return textField
    }()
    
    private lazy var dateTextField: LineTextField = {
        let textField = LineTextField()
        textField.title = L10n.dateTextFieldTitle
        textField.delegate = self
        textField.placeholder = L10n.datePlaceholderTextField
        return textField
    }()
    
    private lazy var commentTextView: LineTextView = {
        let textView = LineTextView()
        textView.title = L10n.commentTextFieldTitle
        textView.placeholder = L10n.commentPlaceholderTextField
        return textView
    }()
    
    private var viewModel: CreateDateViewModelProtocol
    
    init(viewModel: CreateDateViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCustomInputView()
        
    }
    
    private func bind() {
        viewModel.catchDateError = { [weak self] error in
            self?.dateTextField.errorText = error
        }
        
        viewModel.catchTitleError = { [weak self] error in
            self?.titleTextField.errorText = error
        }
    }
    //MARK: - UI
    private func setupUI() {
    
        view.backgroundColor = .appBlack
        view.addSubview(contentView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
     
        contentView.addSubview(infoView)
        contentView.addSubview(titleLabel)
        
        infoView.addSubview(titleTextField)
        infoView.addSubview(dateTextField)
        infoView.addSubview(commentTextView)
    }
    
    private func setupConstraints() {
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(createButton.snp.centerY)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(8.0)
            make.horizontalEdges.equalToSuperview().inset(20.0)
            make.height.equalTo(45.0)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).inset(-8.0)
            make.horizontalEdges.equalToSuperview().inset(20.0)
            make.height.equalTo(45.0)
        }
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20.0)
            make.leading.equalTo(20.0)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.height.equalTo(250.0)
        }
        
        
        titleTextField.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16.0)
            make.bottom.equalTo(dateTextField.snp.top).inset(-16.0)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).inset(16.0)
            make.horizontalEdges.equalToSuperview().inset(16.0)
            make.bottom.equalTo(commentTextView.snp.top).inset(-16.0)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(16.0)
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.bottom.lessThanOrEqualToSuperview().inset(16.0)
        }
        
    }
    
    //MARK: - Private Methods
    private func setupCustomInputView() {
        let datePicker = CustomInputView(.date)
        datePicker.delegate = self
        dateTextField.customInputView = datePicker
    }
    
    @objc private func createDidTap() {
        viewModel.createDidTap()
    }
   
}

//MARK: - Delegates
extension CreateDateVC: LineTextFieldDelegate {
    func lineTextField(_ textfield: LineTextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
        if textfield == titleTextField {
            viewModel.title = textfield.text
        } else if textfield == dateTextField {
            if let dateString = textfield.text {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                viewModel.date = dateFormatter.date(from: dateString)
            } else {
                viewModel.date = nil
            }
        }
        return true
    }
}

extension CreateDateVC: CustomInputViewDelegate {
    func datePickerValueChanged(date: Date?) {
        viewModel.date = date
    }
    
    func cancelDidTap() {
        dateTextField.endEditing(true)
        viewModel.date = nil
    }
    
    func selectDidTap() {
        dateTextField.endEditing(true)
    }
    
}
