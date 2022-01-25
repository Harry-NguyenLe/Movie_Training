//
//  MyDrawerViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/10/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class MyDrawerViewController: MMDrawerController {

    weak var delegate: ReloadViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainSV = storyBoard.instantiateViewController(withIdentifier: "MainView")
//        let movieListSV = storyBoard.instantiateViewController(withIdentifier: "MovieListView") as! MovieListTableViewController
        let leftSV = storyBoard.instantiateViewController(withIdentifier: "LeftSideView") as! LeftSideViewController
//        leftSV.delegate = movieListSV
        self.centerViewController = mainSV
        self.leftDrawerViewController = leftSV
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
