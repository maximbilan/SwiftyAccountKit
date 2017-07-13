//
//  SwiftyAccountKit.swift
//  SwiftyAccountKit
//
//  Created by Maxim on 7/13/17.
//  Copyright © 2017 Maxim Bilan. All rights reserved.
//

import AccountKit

final class SwiftyAccountKit: NSObject {
	
	// MARK: - Shared Instance
	
	static let shared = SwiftyAccountKit()

	// MARK: - Constants
	
	static let didUserLogoutNotification = "AccountKitManagerDidUserLogout"
	
	// MARK: - Types
	
	typealias Success = ((LoginType) -> Void)?
	typealias AccountSuccess = ((String, String?, String?) -> Void)?
	typealias Failure = ((Error?) -> Void)?
	typealias Cancellation = (() -> Void)?
	
	// MARK: - Enumerations
	
	enum LoginType {
		case unknown
		case email
		case phoneNumber
	}
	
	// MARK: - Private properties
	
	private var accountKit: AKFAccountKit!
	fileprivate var loginType: LoginType = .unknown
	fileprivate var success: Success
	fileprivate var failure: Failure
	fileprivate var cancellation: Cancellation
	
	// MARK: - Initialization
	
	override private init() {
		super.init()
		
		accountKit = AKFAccountKit(responseType: .accessToken)
	}
	
	// MARK: - Login
	
	func login(withType type: LoginType, fromController controller: UIViewController, _ success: Success, _ failure: Failure, _ cancellation: Cancellation) {
		self.loginType = type
		
		self.success = success
		self.failure = failure
		self.cancellation = cancellation
		
		let state = UUID().uuidString
		var viewController: UIViewController? = nil
		
		switch type {
		case .email:
			viewController = accountKit.viewControllerForEmailLogin(withEmail: nil, state: state)
		case .phoneNumber:
			viewController = accountKit.viewControllerForPhoneLogin(with: nil, state: state)
			
		default:
			let error = NSError(domain: "AccountKitManager", code: 1, userInfo: ["description": "Unknown login type",
			                                                                     "localizedDescription": "Unknown login type"])
			failure?(error)
		}
		
		if viewController != nil {
			if let akViewController = viewController as? AKFViewController {
				akViewController.delegate = self
				controller.present(viewController!, animated: true, completion: nil)
			}
		}
	}
	
	// MARK: - Request Account
	
	func requestAccount(_ success: AccountSuccess, _ failure: Failure) {
		accountKit.requestAccount { (account, error) in
			if error != nil {
				failure?(error)
			}
			else {
				if let a = account {
					var email: String?
					var phone: String?
					
					if let e = a.emailAddress {
						email = e
					}
					if let phoneNumber = a.phoneNumber {
						phone = phoneNumber.stringRepresentation()
					}
					
					success?(a.accountID, email, phone)
				}
				else {
					failure?(nil)
				}
			}
		}
	}
	
	// MARK: - Access Token
	
	func accessToken() -> String? {
		guard let accessToken = accountKit.currentAccessToken else {
			return nil
		}
		return accessToken.tokenString
	}
	
	func hasAccessToken() -> Bool {
		return accountKit.currentAccessToken != nil
	}
	
	// MARK: - Logout
	
	func logout() {
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: SwiftyAccountKit.didUserLogoutNotification), object: nil)
		accountKit.logOut()
	}
	
}

extension SwiftyAccountKit: AKFViewControllerDelegate {
	
	func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
		success?(loginType)
	}
	
	func viewController(_ viewController: UIViewController!, didFailWithError error: Error!) {
		failure?(error)
	}
	
	func viewControllerDidCancel(_ viewController: UIViewController!) {
		cancellation?()
	}
	
}
