//
//  SchedulingPageViewController.swift
//  schedyouler
//
//  Created by divine on 9/9/17.
//  Copyright © 2017 divine ikenna. All rights reserved.
//

import UIKit

class SchedulingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var VCArr: [UIViewController] = [UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC1"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC2"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC3"),
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC4")]
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = VCArr.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        for view in self.view.subviews {
//            if let scrollview = view as? UIScrollView {
//                scrollview.frame = UIScreen.main.bounds
//                //scrollview.contentSize = UIScreen.main.bounds.size
//            } else if view is UIPageControl {
//                view.backgroundColor = UIColor.clear
//            }
//        }
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            //print("guard1 failure, \(VCArr.index(of: viewController))")
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { print("guard2 failure, \(previousIndex)"); return VCArr.last }
        guard VCArr.count > previousIndex else { print("guard3 failure"); return nil }
        print("viewControllerBefore")
        return VCArr[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController)
            //else { print("guard4 failure, \(VCArr.index(of: viewController))"); return nil }
            else {return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < 0 else { print("guard5 failure, \(nextIndex)"); return VCArr.first }
        guard VCArr.count > nextIndex else { print("guard6 failure"); return nil }
        print("viewControllerAfter")
        return VCArr[nextIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
