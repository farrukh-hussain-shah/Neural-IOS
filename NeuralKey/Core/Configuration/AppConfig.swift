//
//  AppConfig.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation

struct AppConfig {
    let aiApiKey: String
    let aiModelName: String
    let isUpdateAvailable: Bool
    let isForceUpdate: Bool
    let latestVersionCode: Int
    let rewardedAdWords: Int
    let playStoreUrl: String
    let minimumRewrite: Int
    let initialFreeWords: Int
    let rewardedAdId: String
    let bannerAdId: String
    let interstitialAdId: String
    let privacyPolicyUrl: String
    let predictionDataVersion: Int
    let adIntervalTime: Int
    let nativeAdId: String
    let dbCollection: String
    let isFreeMode: Bool

    static let `default` = AppConfig(
        aiApiKey: "",
        aiModelName: "gemini-3.1-flash-lite",
        isUpdateAvailable: false,
        isForceUpdate: false,
        latestVersionCode: 1,
        rewardedAdWords: 0,
        playStoreUrl: "",
        minimumRewrite: 0,
        initialFreeWords: 0,
        rewardedAdId: "",
        bannerAdId: "",
        interstitialAdId: "",
        privacyPolicyUrl: "",
        predictionDataVersion: 1,
        adIntervalTime: 0,
        nativeAdId: "",
        dbCollection: "training_data_set",
        isFreeMode: false
    )
}
