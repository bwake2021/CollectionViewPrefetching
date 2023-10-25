//
//  ViewController.swift
//  CollectionViewPrefetching
//
//  Created by Robert Wakefield on 10/13/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView?

    lazy var collectionViewController: CollectionViewController? = storyboard?.instantiateViewController(identifier: "CollectionViewController") as? CollectionViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let collectionViewController = collectionViewController else {
            preconditionFailure("Could not instantiate CollectionViewController!")
        }
        containerView?.addSubview(collectionViewController.view)
        addChild(collectionViewController)
        collectionViewController.didMove(toParent: self)
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
