//
//  CBCarrierName.swift
//  CBNab
//
//  Created by Uk on 05/06/2020.
//

import CoreTelephony

var carrierName: String? {
    let networkInfo = CTTelephonyNetworkInfo()
    let carrier = networkInfo.subscriberCellularProvider
    return carrier?.carrierName
}

var currencyCode: String? {
    let locale = Locale.current
    return locale.currencyCode
}
