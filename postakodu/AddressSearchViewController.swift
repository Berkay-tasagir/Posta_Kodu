import Foundation
import UIKit

class AddressSearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var ilPickerView: UIPickerView!
    @IBOutlet weak var ilcePickerView: UIPickerView!
    @IBOutlet weak var semtPickerView: UIPickerView!
    @IBOutlet weak var mahallePickerView: UIPickerView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    var ilceData: [String] = []
    var semtData: [String] = []
    var mahalleData: [String] = []
    var postalCodes: [(ilce: String, semt: String, mahalle: String, pk: String)] = []
    
    var selectedIl: Int?
    var selectedIlce: String?
    var selectedSemt: String?
    var selectedMahalle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ilPickerView.delegate = self
        ilPickerView.dataSource = self
        ilcePickerView.delegate = self
        ilcePickerView.dataSource = self
        semtPickerView.delegate = self
        semtPickerView.dataSource = self
        mahallePickerView.delegate = self
        mahallePickerView.dataSource = self
        self.title = "Adrese Göre Arama"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case ilPickerView:
            return IlData.ilList.count
        case ilcePickerView:
            return ilceData.count
        case semtPickerView:
            return semtData.count
        case mahallePickerView:
            return mahalleData.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case ilPickerView:
            return IlData.ilList[row].name
        case ilcePickerView:
            return ilceData[row]
        case semtPickerView:
            return semtData[row]
        case mahallePickerView:
            return mahalleData[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case ilPickerView:
            selectedIl = IlData.ilList[row].number
            fetchPostalCodes()
        case ilcePickerView:
            if row < ilceData.count {
                selectedIlce = ilceData[row]
                filterSemt()
            }
        case semtPickerView:
            if row < semtData.count {
                selectedSemt = semtData[row]
                filterMahalle()
            }
        case mahallePickerView:
            if row < mahalleData.count {
                selectedMahalle = mahalleData[row]
            }
        default:
            break
        }
    }
    
    @IBAction func searchAddress(_ sender: UIButton) {
        guard let ilce = selectedIlce, let semt = selectedSemt, let mahalle = selectedMahalle else {
            resultLabel.text = "Lütfen tüm alanları seçin."
            return
        }
        
        if let postalCode = postalCodes.first(where: { $0.ilce == ilce && $0.semt == semt && $0.mahalle == mahalle }) {
            resultLabel.text = "Posta Kodu: \(postalCode.pk)"
        } else {
            resultLabel.text = "Posta kodu bulunamadı."
        }
    }
    
    private func fetchPostalCodes() {
        guard let il = selectedIl else { return }
        
        let urlString = "https://api.ubilisim.com/postakodu/il/\(il)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print("Data task error: \(error.localizedDescription)")
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(PostaKoduResponse.self, from: data)
                
                self.postalCodes = decodedData.postakodu.map { entry -> (ilce: String, semt: String, mahalle: String, pk: String) in
                    let ilce = entry.ilce
                    let semt = entry.semt_bucak_belde
                    let mahalle = entry.mahalle
                    let pk = entry.pk
                    return (ilce, semt, mahalle, pk)
                }
                
                self.filterIlce()
            } catch {
                print("JSON serialization error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func filterIlce() {
        guard selectedIl != nil else { return }
        
        let ilceSet = Set(postalCodes.map { $0.ilce })
        ilceData = Array(ilceSet).sorted()
        selectedIlce = ilceData.first
        filterSemt()
        
        DispatchQueue.main.async {
            self.ilcePickerView.reloadAllComponents()
        }
    }
    
    private func filterSemt() {
        guard let ilce = selectedIlce else { return }
        
        let semtSet = Set(postalCodes.filter { $0.ilce == ilce }.map { $0.semt })
        semtData = Array(semtSet).sorted()
        selectedSemt = semtData.first
        filterMahalle()
        
        DispatchQueue.main.async {
            self.semtPickerView.reloadAllComponents()
        }
    }
    
    private func filterMahalle() {
        guard let semt = selectedSemt else { return }
        
        mahalleData = postalCodes.filter { $0.semt == semt }.map { $0.mahalle }
        selectedMahalle = mahalleData.first
        
        DispatchQueue.main.async {
            self.mahallePickerView.reloadAllComponents()
        }
    }
}
