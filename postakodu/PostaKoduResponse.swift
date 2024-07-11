import Foundation
struct PostaKoduResponse: Codable {
    let success: Bool
    let status: String
    let dataupdatedate: String
    let description: String
    let pagecreatedate: String
    let postakodu: [PostaKodu]
}

struct PostaKodu: Codable {
    let plaka: Int
    let il: String
    let ilce: String
    let semt_bucak_belde: String
    let mahalle: String
    let pk: String
}
