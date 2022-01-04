//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "API-KEY"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for selectedCurrency: String) {
        let fetchUrl = "\(baseURL)/\(selectedCurrency)"
        
        self.performRequest(with: fetchUrl)
    }
    
    func parseJSON(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            
            let coin = CoinModel(rate: rate!, currency: currency!)
            return coin
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let headerConfiguration = URLSessionConfiguration.default
            headerConfiguration.httpAdditionalHeaders = ["X-CoinAPI-Key": apiKey]
            
            let session = URLSession(configuration: headerConfiguration)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCurrency(self, coin: coin)
                    }
                }
            }
            
            task.resume()
        }
    }
}
