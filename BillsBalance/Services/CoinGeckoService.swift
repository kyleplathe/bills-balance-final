import Foundation

struct CoinGeckoPriceResponse: Decodable {
    let bitcoin: BitcoinPrice
}

struct BitcoinPrice: Decodable {
    let usd: Double
}

final class CoinGeckoService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchBTCPriceUSD() async throws -> Double {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let decoded = try JSONDecoder().decode(CoinGeckoPriceResponse.self, from: data)
        return decoded.bitcoin.usd
    }

    func usdToSats(usd: Double, btcPriceUSD: Double) -> Int64 {
        guard btcPriceUSD > 0 else { return 0 }
        let btc = usd / btcPriceUSD
        return Int64((btc * 100_000_000.0).rounded())
    }
}
