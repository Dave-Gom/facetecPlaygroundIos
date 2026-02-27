//
//  ViewController.swift
//  facetecPlayground
//
//  Created by Dave Gomez on 2026-02-27.
//

import UIKit
import AVFoundation
import FaceTecSDK

class ViewController: UIViewController, FaceTecInitializeCallback {
    var facetecSDKInstance: FaceTecSDKInstance?

    override func viewDidLoad() {
        super.viewDidLoad()
      FaceTec.sdk.initializeWithSessionRequest(deviceKeyIdentifier: Config.DeviceKeyIdentifier, sessionRequestProcessor: SessionRequestProcessor(), completion: self)
    }


     func onFaceTecSDKInitializeSuccess(sdkInstance: FaceTecSDKInstance) {
         print("inicializando...")
         self.facetecSDKInstance = sdkInstance
         print("inicializado!")
     }

    func onFaceTecSDKInitializeError(error: FaceTecInitializationError) {
        print(FaceTec.sdk.description(for: error))
    }

    @IBAction func StartButtonPressed(_ sender: UIButton) {
        print("✅ Botón presionado!")
         let faceTcVC = facetecSDKInstance!.start3DLivenessThen3DFaceMatch(with: SessionRequestProcessor())
         self.present(faceTcVC, animated: true , completion: nil)
    }

}

