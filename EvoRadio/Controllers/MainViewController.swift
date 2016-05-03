//
//  MainViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class MainViewController: ViewController {

    private var sortTabBar: TabBar!
    private var playerBar: PlayerBar!
    private var contentView = UIScrollView()
    
    private var nowViewController = ChannelViewController(radioID: 0)
    private var personalController = PersonalViewController()
    private var channel1Controller = ChannelViewController()
    private var channel2Controller = ChannelViewController()
    private var channel3Controller = ChannelViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Evo Radio"
    
        prepareTabBar()
        preparePlayerBar()
        prepareContentView()
        
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        channel2Controller.radioID = customRadios[1]["radio_id"] as! Int
        channel3Controller.radioID = customRadios[2]["radio_id"] as! Int
        addChildViewControllers([nowViewController, channel1Controller, channel2Controller,channel3Controller,personalController], inView: contentView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.customRadiosChanged), name: "CustomRadiosChanged", object: nil)
    }
    
    func prepareTabBar() {
        let customRadios = CoreDB.getCustomRadios()
//        customRadios.filter({$key == "name"})
        var titles = ["时刻"]
        for item in customRadios {
            titles.append(item["radio_name"] as! String)
        }
        titles.append("我的")
        sortTabBar = TabBar(titles: titles)
        view.addSubview(sortTabBar)
        sortTabBar.delegate = self
        sortTabBar.snp_makeConstraints { (make) in
            make.height.equalTo(34)
            make.top.equalTo(view.snp_top).inset(64)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
    }
    
    func preparePlayerBar() {
        playerBar = PlayerBar()
        view.addSubview(playerBar)
        playerBar.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        
        
    }
    
    func prepareContentView() {
//        contentView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(contentView)
        contentView.pagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.clipsToBounds = true
        contentView.delegate = self
        contentView.snp_makeConstraints { (make) in
            make.top.equalTo(sortTabBar.snp_bottom)
            make.bottom.equalTo(playerBar.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*5, 0)
        
    }
    
    //MARK: event
    func customRadiosChanged(notification: NSNotification) {
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        channel2Controller.radioID = customRadios[1]["radio_id"] as! Int
        channel3Controller.radioID = customRadios[2]["radio_id"] as! Int
        
        var titles = ["时刻"]
        for item in customRadios {
            titles.append(item["radio_name"] as! String)
        }
        titles.append("我的")
        sortTabBar.updateTitles(titles)
        
        channel1Controller.updateChannels()
        channel2Controller.updateChannels()
        channel3Controller.updateChannels()
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        self.sortTabBar.updateLineConstraint(offsetX*0.2)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX % Device.width() == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width()) + 1
        
        sortTabBar.updateCurrentIndex(pageIndex)
        
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetX = scrollView.contentOffset.x        
        if offsetX < -80 {
            let panel = SelectiveTimePanel(frame: Device.keyWindow().bounds)
            Device.keyWindow().addSubview(panel)
        }
    }
}

extension MainViewController: TabBarDelegate {
    func tabBarSelectedItemAtIndex(index: Int) {
        self.contentView.setContentOffset(CGPointMake(Device.width()*CGFloat(index), 0), animated: true)
    }
}

