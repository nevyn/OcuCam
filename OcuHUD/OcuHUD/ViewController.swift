import UIKit

class ViewController: UIViewController {
	
	var ocuHUD: OcuHUDLayer!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.blackColor()
		
		ocuHUD = OcuHUDLayer(frame: self.view.bounds)
		self.view.layer.addSublayer(ocuHUD)
		ocuHUD.addAnimations()
	}


}

