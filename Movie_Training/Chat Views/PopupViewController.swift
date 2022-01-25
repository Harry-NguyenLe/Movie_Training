//
//  PopupViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/22/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

class PopupViewController: UIViewController {

    @IBOutlet weak var txtChannelName : UITextField!
    
    weak var delegate : ReloadChannelsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showAnimate()
    }

    @IBAction func didTapBtnClosePopup(_ sender: Any) {
        self.delegate?.setViewState()
        removeAnimate()
    }
    
    @IBAction func didTapBtnCreateChannel(_ sender: Any) {
        let db = Firestore.firestore()
        let channelName = txtChannelName.text!
        db.collection("channels").addDocument(data: ["name" : channelName]).collection("Thread").document()
        self.delegate?.loadChannel()
        self.delegate?.setViewState()
        removeAnimate()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }

}
