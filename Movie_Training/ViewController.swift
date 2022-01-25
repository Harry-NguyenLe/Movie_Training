//
//  ViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/2/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet weak var listFilmTableView: UITableView!
    let itemDataArray = NSMutableArray()
    let userLikedArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.listFilmTableView.dataSource = self
//        self.listFilmTableView.delegate = self
//        self.listFilmTableView.register(UINib(nibName: "MyCustomTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCustomTableViewCell")
//        deleteData()
//        deleteFilmLiked()
//        loadData(page: "1")
//        loadUserLikedDB()
//        loadDB()
//        listFilmTableView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
//        callMovieAPI()

    }

//    func loadData(page: String) {
//        let sv = UIViewController.displaySpinner(onView: self.view)
//        GlobalServices.filmService.FetchFilmFromServer(page: page) { (data, paging) in
//            GlobalServices.localDatabse.saveLocalDataBase()
//            self.itemDataArray.removeAllObjects()
//            self.itemDataArray.addObjects(from: data as! [Any])
//            self.listFilmTableView.reloadData()
//            UIViewController.removeSpinner(spinner: sv)
//        }
//    }
//
//    func loadUserLikedDB() {
//        if (UserDefaults.standard.value(forKey: "uid") != nil) {
//            GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: NSPredicate(format: "uid == %@", UserDefaults.standard.string(forKey: "uid")!)) { (items) in
//                if (items != nil) {
//                    self.userLikedArray.removeAllObjects()
//                    self.userLikedArray.addObjects(from: items as! [Any])
//                    //self.listFilmTableView.reloadData()
//                }
//            }
//        }
//    }
//
//    func loadDB() {
//        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData") { (items) in
//            if (items != nil) {
//                self.itemDataArray.removeAllObjects()
//                self.itemDataArray.addObjects(from: items as! [Any])
//                self.listFilmTableView.reloadData()
//            }
//        }
//    }
//
//    func deleteData() {
//        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData") { (items) in
//            if items != nil {
//                for item in items! {
//                    GlobalServices.localDatabse.manageObjectContext.delete(item as! NSManagedObject)
//                    GlobalServices.localDatabse.saveLocalDataBase()
//                }
//            }
//        }
//    }
//
//    func deleteFilmLiked() {
//        GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked") { (items) in
//            if items != nil {
//                for item in items! {
//                    GlobalServices.localDatabse.manageObjectContext.delete(item as! NSManagedObject)
//                    GlobalServices.localDatabse.saveLocalDataBase()
//                }
//            }
//        }
//    }
    
//    func callMovieAPI() {
//        let url = URL(string: "http://training-movie.bsp.vn:82/movie/list?page=3")!
//        var request = URLRequest(url: url)
//        request.setValue("dCuW7UQMbdvpcBDfzolAOSGFIcAec11a", forHTTPHeaderField: "app_token")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
//                DispatchQueue.main.async {
//                    let httpStatus = response as? HTTPURLResponse
//                    if httpStatus == nil || httpStatus?.statusCode != 200 { // check for http errors
////                        self.viewLoading.isHidden = true;
////                        self.myCustomSimplePopupAlert(message: "HTTP error code: \(String(describing: httpStatus?.statusCode))")
//                        return
//                    }
//
//                    let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//
//                    let arrayFilm = jsonObj!["data"] as? NSArray
//                    self.itemDataArray = arrayFilm!
//                    self.listFilmTableView.reloadData()
//                    }
//            }).resume()
//        }
//    }
}

//extension ViewController:UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return itemDataArray.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomTableViewCell") as! MyCustomTableViewCell
//        if (itemDataArray.count != 0) {
////            cell.updateData(data: itemDataArray[indexPath.row] as! NSDictionary)
//            cell.updateData(data: itemDataArray[indexPath.row] as! FilmData)
////            for userLiked in userLikedArray {
////                cell.updateFilmLiked(data: userLiked as! UserLiked)
////            }
//        }
////        cell.btnWatch.addTarget(self, action: #selector(didTapWatchMovieDetail(_: )), for: .touchUpInside)
//        cell.btnLike.addTarget(self, action: #selector(didTapBtnLike(_: )), for: .touchUpInside)
//        return cell
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
////    @objc func didTapWatchMovieDetail(_ sender: UIButton) {
////        //let btnWatch = sender
////        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
////        let uid = UserDefaults.standard.value(forKey: "uid")
////        guard uid != nil else {
////            let loginSV = storyBoard.instantiateViewController(withIdentifier: "LoginSV")
////            return self.present(loginSV, animated: true, completion: nil)
////        }
////
////        let filmDetailSV = storyBoard.instantiateViewController(withIdentifier: "FilmDetailView") as! FilmDetailViewController
////        filmDetailSV.film_ID = sender.tag
//////        self.present(filmDetailSV, animated: true, completion: nil)
////        self.navigationController?.pushViewController(filmDetailSV, animated: true)
////
////    }
//
//    @objc func didTapBtnLike(_ sender: UIButton) {
//        sender.setImage(UIImage(named: "ic_like_orange.png"), for: .normal)
//        sender.setTitle("  Đã thích", for: .normal)
//        sender.isEnabled = false
////        let userLiked = NSEntityDescription.insertNewObject(forEntityName: "UserLiked", into: GlobalServices.localDatabse.manageObjectContext) as! UserLiked
////        userLiked.updateUserLikedFilm(userID: UserDefaults.standard.value(forKey: "uid") as! String, filmID: sender.tag)
////        GlobalServices.localDatabse.saveLocalDataBase()
//    }
//}
//
//extension ViewController:UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.last == 9 {
//            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "End Page", message: "Loading")
//        }
//    }
//}
