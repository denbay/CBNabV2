//
//  App2DeleCurrency.swift
//  CBNab
//
//  Created by KillAll on 05/06/2020.
//

import UIKit
import CoreTelephony

var currencyCode: String? {
    let locale = Locale.current
    return locale.currencyCode
}

var carrierName: String? {
    let networkInfo = CTTelephonyNetworkInfo()
    let carrier = networkInfo.subscriberCellularProvider
    return carrier?.carrierName
}
