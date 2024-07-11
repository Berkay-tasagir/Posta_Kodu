import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var postalButton: UIButton!
    @IBOutlet weak var adressButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToPostalVCButtonTapped(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let bosVC = storyboard.instantiateViewController(withIdentifier: "PostalCodeSearchViewController") as? PostalCodeSearchViewController {
                self.navigationController?.pushViewController(bosVC, animated: true)
            }
        }
    
    @IBAction func goToAdressVCButtonTapped(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let bosVC = storyboard.instantiateViewController(withIdentifier: "AddressSearchViewController") as? AddressSearchViewController {
                self.navigationController?.pushViewController(bosVC, animated: true)
            }
        }


}

