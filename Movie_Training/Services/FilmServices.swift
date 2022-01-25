//
//  FilmServices.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class FilmServices: NSObject {
    func FetchFilmFromServer(page: String, handleComplete: @escaping (_ items:NSArray, _ pageInfo:NSDictionary) -> ()) {    GlobalServices.httpService.sendHttpRequestForGetData("http://training-movie.bsp.vn:82/movie/list?page=\(page)") { (isok, error, code, data) in
            if let arrayFilmDic = data?.toNSDictionary() {
                
//     --> save movie data to cloud firestore
//                let db = Firestore.firestore()
//                db.collection("filmdata").document("page_\(page)").setData( arrayFilmDic as! [String : Any])
                
//     --> save movie data to real time database
//                let db = Database.database()
//                let ref : DatabaseReference!
//                ref = db.reference()
//                ref.child("filmdata").child("page_\(page)").setValue(arrayFilmDic as! [String : Any])
                
                let pageInfo = arrayFilmDic.value(forKey: "paging") as? NSDictionary
                if let arrayFilm = arrayFilmDic.value(forKey: "data") as? NSArray {
                    let arrayReturn = NSMutableArray()
                    for filmDic in arrayFilm as! [NSDictionary] {
                        let filmData = NSEntityDescription.insertNewObject(forEntityName: "FilmData", into: GlobalServices.localDatabse.manageObjectContext) as! FilmData
                        filmData.updateDataFromDic(dic: filmDic)
                        arrayReturn.add(filmData)
                    }
                    handleComplete(arrayReturn, pageInfo!)
                }
            }
        }
    }
}
