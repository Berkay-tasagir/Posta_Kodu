import Foundation
import UIKit

class PostalCodeSearchViewController: UIViewController {

    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Posta Koduna Göre Arama"
    }

    @IBAction func searchByPostalCode(_ sender: UIButton) {
        guard let postalCode = postalCodeTextField.text, postalCode.count == 5 else {
            resultLabel.text = "Lütfen geçerli bir posta kodu girin."
            return
        }

        let ilCode = String(postalCode.prefix(2))
        if let ilNumber = Int(ilCode), let il = IlData.ilList.first(where: { $0.number == ilNumber }) {
            fetchPostalCodes(for: il.number) { [weak self] postalCodes in
                if let postalCodeData = postalCodes.first(where: { $0.pk == postalCode }) {
                    DispatchQueue.main.async {
                        self?.resultLabel.text = "\(il.name), \(postalCodeData.ilce), \(postalCodeData.semt), \(postalCodeData.mahalle)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.resultLabel.text = "Adres bulunamadı."
                    }
                }
            }
        } else {
            resultLabel.text = "İl bulunamadı."
        }
    }

    private func fetchPostalCodes(for il: Int, completion: @escaping ([(ilce: String, semt: String, mahalle: String, pk: String)]) -> Void) {
        let urlString = "https://api.ubilisim.com/postakodu/il/\(il)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
            
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(PostaKoduResponse.self, from: data)

                completion(decodedData.postakodu.map { entry -> (ilce: String, semt: String, mahalle: String, pk: String) in
                    let ilce = entry.ilce
                    let semt = entry.semt_bucak_belde
                    let mahalle = entry.mahalle
                    let pk = entry.pk
                    return (ilce, semt, mahalle, pk)
                })

            } catch {
                print("JSON serialization error: (error.localizedDescription)")
            }
        }.resume()
    }
}
