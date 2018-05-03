//
//  QRCodeViewController.swift
//  ClubHub
//
//  Created by Christopher Giuffrida on 4/29/18.
//  Copyright © 2018 Christopher Giuffrida. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import QRCode

class QRCodeViewController: UIViewController {

    @IBOutlet weak var QRCodeimage: UIImageView!
    @IBOutlet weak var SaveQRCodeButton: UIButton!
    
    var text: String = ""
    var ClubKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationItem.setHidesBackButton(true, animated:true);

        
        // https://github.com/aschuch/QRCode
        let data = text.data(using: .isoLatin1)!
        let qrCode = QRCode(data)
        qrCode.image
        
        QRCodeimage.image = qrCode.image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your QR code has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "savedQR", sender: self)
                }))
            present(ac, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! ClubViewController
        secondViewController.ClubKey = ClubKey
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            for vc in viewControllers {
                if vc is ClubViewController {
                    self.navigationController!.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func saveQRCode(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(QRCodeimage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}
