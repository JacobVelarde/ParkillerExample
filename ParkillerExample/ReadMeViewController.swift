//
//  ReadMeViewController.swift
//  ParkillerExample
//
//  Created by Jacob Velarde on 18/08/16.
//  Copyright © 2016 Jacob Velarde. All rights reserved.
//

import UIKit

class ReadMeViewController: UIViewController {
    
    @IBOutlet weak var textViewInformation: UITextView!
    
    var tapGesture = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReadMeViewController.dismiss(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    
    func dismiss(gestureReconizer: UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}