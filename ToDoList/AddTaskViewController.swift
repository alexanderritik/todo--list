//
//  AddTaskViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionDatePicker: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate : todoListDelegate?
    
    lazy var touchView : UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(doneButtonTapped))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        _touchView.isUserInteractionEnabled = true
        
        return _touchView
        
    }()
    
    let toolbarDone = UIToolbar.init()
    
    var activeField : UITextField?
    var activeTextView : UITextView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let navigationItem = UINavigationItem(title: "add task")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTouch))
        
        navigationBar.items = [navigationItem]
        
        taskDetailsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        taskDetailsTextView.layer.borderWidth = CGFloat(1)
        
        taskDetailsTextView.layer.cornerRadius = CGFloat(3)
        
        
        taskNameTextField.delegate = self
        taskDetailsTextView.delegate = self
        
        // adding tool bar
        
        toolbarDone.sizeToFit()
        
        toolbarDone.barTintColor = UIColor.red
        
        toolbarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let barBtnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        
        barBtnDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize : 17), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace , barBtnDone , flexSpace]

        taskNameTextField.inputAccessoryView = toolbarDone
        taskDetailsTextView.inputAccessoryView = toolbarDone
    }
    
    

    @objc func doneButtonTapped(){
        view.endEditing(true)
    }
    
    @objc func cancelButtonDidTouch(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTaskDidTouch(_ sender: Any) {
        
        guard let taskName = taskNameTextField.text , !taskName.isEmpty else { return }
        
        if taskName.count > 50 {
            reportError(title: "task length ", message: "exceeds")
            return
        }
        
        if taskDetailsTextView.text.isEmpty {
            reportError(title: "Task Detail", message: "It is empty")
            return
        }
        
        let taskDetail = taskDetailsTextView.text!
        
        let completionDate : Date = taskCompletionDatePicker.date
        
        if completionDate < Date(){
            reportError(title: "Completion Date", message: "It's date is beyond.")
            return
        }
        
        
        let todoItem = ToDoItemModel(name: taskName, detail: taskDetail, completionDate: completionDate)
        
        let todoDict: [String : ToDoItemModel] = ["task" : todoItem]
        
//        one way to add task in todoItem
//        delegate?.add(task: todoItem)
        
//        another way to add task
//        NotificationCenter.default.post(name: NSNotification.Name.init("com.todoList.addTask"), object: todoItem)

//        add another way to task
        NotificationCenter.default.post(name: NSNotification.Name.init("com.todoList.addTask") , object: nil, userInfo: todoDict)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func reportError(title : String , message: String){
        let error = UIAlertController(title: title, message: message , preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK",style: .default) { (action) in
            error.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            error.dismiss(animated: true, completion: nil)
        }
        
        error.addAction(okAction)
        error.addAction(cancelAction)
        
        present(error,animated: true ,completion: nil)
    }
    
    

}


extension AddTaskViewController  {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resgisterKeyBoardNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotification()
    }

    func resgisterKeyBoardNotification(){

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification : )), name: UIWindow.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification : )), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    func unregisterKeyboardNotification(){

        NotificationCenter.default.removeObserver(self, name:UIWindow.keyboardWillShowNotification, object: nil )

        NotificationCenter.default.removeObserver(self, name:UIWindow.keyboardWillHideNotification, object: nil )
    }

    @objc func keyboardWasShown(notification : NSNotification){
        view.addSubview(touchView)

//        for adjusting view when keyboard appears
        
//        let info : NSDictionary = notification.userInfo! as NSDictionary
//
//        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//
//        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + toolbarDone.frame.size.height + 10.0), right: 0.0)
//
//        self.scrollView.contentInset = contentInsets
//
//        self.scrollView.scrollIndicatorInsets = contentInsets
//
//        var aRect: CGRect = UIScreen.main.bounds
//
//        aRect.size.height -= keyboardSize!.height
//
//        if activeField != nil {
//            if (!aRect.contains(activeField!.frame.origin)){
//                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
//            }
//        }
//
//        else if activeTextView != nil {
//            let textContent: CGPoint = CGPoint(x: activeTextView!.frame.origin.x, y: activeTextView!.frame.size.height + activeTextView!.frame.size.height)
//
//            if (aRect.contains(textContent)){
//                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
//            }
//
//        }

    }

    @objc func keyboardWasHidden(notification : NSNotification){
        touchView.removeFromSuperview()

//        let contentInsets : UIEdgeInsets = UIEdgeInsets.zero
//
//        self.scrollView.contentInset = contentInsets
//
//        self.scrollView.scrollIndicatorInsets = contentInsets

        self.view.endEditing(true)
    }

}

extension AddTaskViewController : UITextViewDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

}


extension AddTaskViewController : UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
}
