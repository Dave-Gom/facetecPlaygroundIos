//
//  ViewController.swift
//  facetecPlayground
//

import UIKit
import FaceTecSDK

class ViewController: UIViewController, FaceTecLivenessButtonDelegate {

    private var livenessButton: FaceTecLivenessButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLivenessButton()
    }

    private func setupLivenessButton() {
        livenessButton = FaceTecLivenessButton()
        livenessButton.translatesAutoresizingMaskIntoConstraints = false
        livenessButton.delegate = self

        view.addSubview(livenessButton)

        NSLayoutConstraint.activate([
            livenessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            livenessButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            livenessButton.widthAnchor.constraint(equalToConstant: 220),
            livenessButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - FaceTecLivenessButtonDelegate

    func faceTecLivenessDidComplete(success: Bool, result: FaceTecSessionResult?) {
        if success {
            print("Prueba de vida exitosa!")
            // Aquí puedes navegar a otra pantalla o hacer algo con el resultado
        } else {
            print("Prueba de vida fallida o cancelada")
        }
    }
}
