//
//  ViewController.swift
//  Contacts
//
//  Created by 徐 栋栋 on 5/12/16.
//  Copyright © 2016 EdisonHsu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, [String:String]>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dict = loadDict("dict") as! [[String:String]]

        
        let items = Observable.just([
            SectionModel(model: "RECENT", items: [
                [
                    "name":"Mrs. Carolyn Tillman",
                    "avatar":"avatar13",
                    "mobile":"1-764-949-9148",
                    "email":"ardella.mueller@hotmail.com",
                    "notes":"Quod pickled vel post-ironic et. Sit consequatur consectetur quod. Et salvia small batch exercitationem."
                ],
                [
                    "name":"Geovanni Will",
                    "avatar":"avatar14",
                    "mobile":"905-253-0435", "email":"antonina@hotmail.com",
                    "notes":"Et gentrify enim art party dolorum sint sunt wes anderson. Et cray literally id totam."
                ],
                [
                    "name":"Edythe Stoltenberg",
                    "avatar":"avatar15",
                    "mobile":"696-408-8248",
                    "email":"viviane_lockman@gmail.com",
                    "notes":"Farm-to-table ea non nesciunt chambray quia. Bitters voluptatem paleo sed."
                ]]),
            SectionModel(model: "FRIENDS", items: dict)
            ])

        
        let dataSource = setupDataSource()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        
        items
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        tableView
            .rx_itemSelected
            .subscribeNext { [weak self] indexPath in
                let sb = UIStoryboard(name: "Main" ,bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
                let item = self!.dataSource.itemAtIndexPath(indexPath)
                vc._name = item["name"]!
                vc._avatar = item["avatar"]!
                vc._note = item["notes"]!
                vc._email = item["email"]!
                vc._mobile = item["mobile"]!
                
                self?.navigationController?.pushViewController(vc, animated: true)
            }.addDisposableTo(disposeBag)
        
        
        tableView.rx_setDelegate(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, [String:String]>> {
        dataSource.configureCell = { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCellWithIdentifier("Content")!
            cell.textLabel?.text = element["name"]
            
            let image = UIImage(named: element["avatar"]!)
            let imageSize = CGSizeMake(36, 36)
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            let imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height)
            image?.drawInRect(imageRect)
            
        
            cell.imageView?.layer.cornerRadius = 18
            cell.imageView?.layer.masksToBounds = true
            
            cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return cell
        }
        
        return dataSource
    }
    
    func loadDict(fileName: String) -> [NSDictionary]? {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                do {
                    let jsonResult: [NSDictionary] = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                    return jsonResult
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getRandomAvatar() -> String {
        let random = Int(arc4random_uniform(15) + 1)
        return String(format: "avatar%2d", random)
    }

}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Header")
        let greenColour = UIColor(red: 139/255, green: 87/255, blue: 42/255, alpha: 1)
        let attributedColour = [NSForegroundColorAttributeName : greenColour];
        let attributedString = NSAttributedString(string: dataSource.sectionAtIndex(section).model, attributes: attributedColour)
        cell!.textLabel?.attributedText = attributedString
        return cell
    }
}

