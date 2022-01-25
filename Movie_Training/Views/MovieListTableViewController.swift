//
//  MovieListTableViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/6/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class MovieListTableViewController: UITableViewController, ReloadViewControllerDelegate {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    let itemDataArray = NSMutableArray()
    let userLikedArray = NSMutableArray()
    var itemsPerPage = 0
    var totalPage = 0
    var reachedEndOfItems = false
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        clearAllAfterLogout()
        let imageView = UIImageView(image: UIImage(named: "bg@3x.png"))
        imageView.contentMode = .scaleToFill
        self.tableView.backgroundView = imageView
        self.tableView.register(UINib(nibName: "MyCustomTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCustomTableViewCell")
        self.tableView.refreshControl?.addTarget(self, action: #selector(refreshData(_ :)), for: .valueChanged)
        loadData()
    }
    
    @objc func refreshData(_ sender: Any) {
        self.itemsPerPage = 0
        self.totalPage = 0
        self.reachedEndOfItems = false
        self.currentPage = 1
        self.itemDataArray.removeAllObjects()
        self.userLikedArray.removeAllObjects()
        loadData()
        self.refreshControl?.endRefreshing()
    }
    
    func loadData() {
        if Reachability.isConnectedToNetwork() {
            deleteData()
            loadListMovie(page: String(currentPage))
            loadUserLikedFilm()
//        deleteFilmLiked()
        } else {
            loadDataFromLocalDB()
            loadUserLikedFilm()
//            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "alert", message: "Internet Connection not Available!")
        }
    }
    
    func loadListMovie(page: String) {
        let sv = UIViewController.displaySpinner(onView: self.view)
            GlobalServices.filmService.FetchFilmFromServer(page: page) { (data, pageInfo) in
                GlobalServices.localDatabse.saveLocalDataBase()
    //            self.itemDataArray.removeAllObjects()
                self.totalPage = pageInfo.value(forKey: "total_pages") as! Int
                self.itemsPerPage = pageInfo.value(forKey: "per_page") as! Int
                self.itemDataArray.addObjects(from: data as! [Any])
                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                self.tableView.reloadData()
                UIViewController.removeSpinner(spinner: sv)
            }
    }
    
    func loadUserLikedFilm() {
        if (UserDefaults.standard.value(forKey: "uid") != nil) {
            GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: NSPredicate(format: "uid == %@", UserDefaults.standard.string(forKey: "uid")!)) { (items) in
                if (items != nil) {
                    self.userLikedArray.removeAllObjects()
                    self.userLikedArray.addObjects(from: items as! [Any])
                    self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadDataFromLocalDB() {
        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData") { (items) in
            if (items != nil) {
                self.itemDataArray.removeAllObjects()
                self.itemDataArray.addObjects(from: items as! [Any])
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteData() {
        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData") { (items) in
            if items != nil {
                for item in items! {
                    GlobalServices.localDatabse.manageObjectContext.delete(item as! NSManagedObject)
                    GlobalServices.localDatabse.saveLocalDataBase()
                }
            }
        }
    }
    
    func deleteFilmLiked() {
        GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked") { (items) in
            if items != nil {
                for item in items! {
                    GlobalServices.localDatabse.manageObjectContext.delete(item as! NSManagedObject)
                    GlobalServices.localDatabse.saveLocalDataBase()
                }
            }
        }
    }
    
    
    func clearAllAfterLogout() {
        let sv = UIViewController.displaySpinner(onView: self.view)
        UserDefaults.standard.set(nil, forKey: "uid")
        UserDefaults.standard.set(nil, forKey: "name")
        UserDefaults.standard.set(nil, forKey: "profile_image")
        UserDefaults.standard.set(nil, forKey: "fbImageURL")
        UserDefaults.standard.set(nil, forKey: "device_token")
        self.userLikedArray.removeAllObjects()
        self.tableView.reloadData()
        UIViewController.removeSpinner(spinner: sv)
    }
    
    @IBAction func didTappedBtnMenu(_ sender: UIButton) {
        let leftSV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftSideView") as! LeftSideViewController
        self.mm_drawerController.leftDrawerViewController = leftSV
        self.mm_drawerController.toggle(.left, animated: true) { (animate) in
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemDataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomTableViewCell") as! MyCustomTableViewCell
        if (itemDataArray.count != 0) {
            //            cell.updateData(data: itemDataArray[indexPath.row] as! NSDictionary)
            
            if (reachedEndOfItems && indexPath.row == itemDataArray.count - 1) {
                if (currentPage <= self.totalPage ) {
                    self.reachedEndOfItems = false
                    loadMoreItems()
                }
            }
            cell.updateData(data: itemDataArray[indexPath.row] as! FilmData)
            for userLiked in userLikedArray {
                cell.updateFilmLiked(data: userLiked as! UserLiked)
            }
            cell.btnWatch.addTarget(self, action: #selector(didTapWatchMovieDetail(_: )), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(didTapBtnLike(_: )), for: .touchUpInside)
        }
        return cell
    }
    
    func loadMoreItems() {
        let sv = UIViewController.displaySpinner(onView: self.view)
        guard !reachedEndOfItems else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.currentPage += 1
            GlobalServices.filmService.FetchFilmFromServer(page: String(self.currentPage)) { (data, paging) in
                GlobalServices.localDatabse.saveLocalDataBase()
                self.itemDataArray.addObjects(from: data as! [Any])
                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                self.tableView.reloadData()
                if (data.count < self.itemsPerPage) {
                    self.reachedEndOfItems = true
                }
                UIViewController.removeSpinner(spinner: sv)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == itemDataArray.count - 1 {
            reachedEndOfItems = true
        }
    }
    
    @objc func didTapWatchMovieDetail(_ sender: UIButton) {
        //let btnWatch = sender
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let uid = UserDefaults.standard.value(forKey: "uid")
        guard uid != nil else {
            let loginSV = storyBoard.instantiateViewController(withIdentifier: "LoginSV") as! LoginViewController
            loginSV.delegate = self
            return self.present(loginSV, animated: true, completion: nil)
        }
        let movieDetailView = storyBoard.instantiateViewController(withIdentifier: "MovieDetailView") as! MovieDetailTableViewController
        movieDetailView.film_ID = sender.tag
        movieDetailView.delegate = self
        
        self.navigationController?.pushViewController(movieDetailView, animated: true)
    }
    
    @objc func didTapBtnLike(_ sender: MyCustomLikeButton) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        if UserDefaults.standard.value(forKey: "uid") != nil {
            let btnLike = sender
            btnLike.isLiked = !btnLike.isLiked
            if (btnLike.isLiked) {
                let userLiked = NSEntityDescription.insertNewObject(forEntityName: "UserLiked", into: GlobalServices.localDatabse.manageObjectContext) as! UserLiked
                userLiked.updateUserLikedFilm(userID: UserDefaults.standard.string(forKey: "uid")!, filmID: btnLike.btn_id)
                GlobalServices.localDatabse.saveLocalDataBase()
                loadUserLikedFilm()
            } else {
                let predicate = NSPredicate(format:"uid == %@ && fid == %@", UserDefaults.standard.string(forKey: "uid")!, String(btnLike.btn_id))
                GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: predicate) { (items) in
                    if (items != nil) {                    GlobalServices.localDatabse.manageObjectContext.delete(items?.firstObject as! NSManagedObject)
                        GlobalServices.localDatabse.saveLocalDataBase()
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            let loginSV = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginSV") as! LoginViewController
            self.present(loginSV, animated: true, completion: nil)
        }
        UIViewController.removeSpinner(spinner: sv)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

