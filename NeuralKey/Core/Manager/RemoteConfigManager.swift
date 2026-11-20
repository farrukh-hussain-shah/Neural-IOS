//
//  RemoteConfigManager.swift
//  NeuralKey
//
//  Created by Macbook 5 on 11/20/26.
//



import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager {

    static let shared = RemoteConfigManager()

    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()

        // Development: 0
        // Production: use 12 hours
        settings.minimumFetchInterval = 0

        remoteConfig.configSettings = settings
    }

    func fetchAndMapConfig() async throws -> AppConfig {

        try await remoteConfig.fetchAndActivate()

        return mapValues()
    }

    func currentConfig() -> AppConfig {
        mapValues()
    }

    private func mapValues() -> AppConfig {

        let config = remoteConfig

        return AppConfig(
            aiApiKey: config["ai_api_key"].stringValue,
            aiModelName: config["ai_model_name"].stringValue,

            isUpdateAvailable: config["is_update_available"].boolValue,
            isForceUpdate: config["is_force_update"].boolValue,

            latestVersionCode: config["latest_version_code"].numberValue.intValue,

            rewardedAdWords: config["rewarded_ad_words"].numberValue.intValue,

            playStoreUrl: config["playStoreUrl"].stringValue,

            minimumRewrite: config["minimum_rewrite"].numberValue.intValue,

            initialFreeWords: config["initial_free_words"].numberValue.intValue,

            rewardedAdId: config["rewarded_ad_id"].stringValue,

            bannerAdId: config["banner_ad_id"].stringValue,

            interstitialAdId: config["interstitial_ad_id"].stringValue,

            privacyPolicyUrl: config["privacy_policy_url"].stringValue,

            predictionDataVersion: config["prediction_data_version"].numberValue.intValue,

            adIntervalTime: config["ad_interval_time"].numberValue.intValue,

            nativeAdId: config["native_ad"].stringValue,

            dbCollection: config["db_collection"].stringValue,

            isFreeMode: config["is_free_mode"].boolValue
        )
    }
}
