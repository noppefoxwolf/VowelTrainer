//
//  ViewController.swift
//  VowelTrainer
//
//  Created by Tomoya Hirano on 2019/12/01.
//  Copyright © 2019 Tomoya Hirano. All rights reserved.
//

import UIKit
import ARKit

struct Log {
    let vowel: String
    let values: [ARFaceAnchor.BlendShapeLocation : Double]
}

class ViewController: UIViewController {
    let vowels: [String] = ["a", "i", "u", "e", "o", "n"]
    let targetLocations: [ARFaceAnchor.BlendShapeLocation] = [.mouthClose,.mouthDimpleLeft,.mouthDimpleRight,.mouthFrownLeft,.mouthFrownRight,.mouthFunnel,.mouthLeft,.mouthLowerDownLeft,.mouthLowerDownRight,.mouthPressLeft,.mouthPressRight,.mouthPucker,.mouthRight,.mouthRollLower,.mouthRollUpper,.mouthShrugLower,.mouthShrugUpper,.mouthSmileLeft,.mouthSmileRight,.mouthStretchLeft,.mouthStretchRight,.mouthUpperUpLeft,.mouthUpperUpRight]
    
    
    let label: UILabel = .init(frame: .zero)
    let previewView: ARSCNView = .init(frame: .zero)
    let recordButton: UIButton = .init(type: .custom)
    let outputButton: UIButton = .init(type: .custom)
    lazy var vowelSegment: UISegmentedControl = .init(items: vowels)
    var currentVowel: String? = nil
    var logs: [Log] = []
    
    override func loadView() {
        super.loadView()
        view.addSubview(previewView)
        previewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        label.text = "0"
        recordButton.setTitle("Record", for: .normal)
        recordButton.sizeToFit()
        outputButton.setTitle("Output", for: .normal)
        outputButton.sizeToFit()
        let stackView = UIStackView(arrangedSubviews: [label, vowelSegment, recordButton, outputButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ARFaceTrackingConfiguration()
        previewView.session.delegate = self
        previewView.session.run(config, options: .resetTracking)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
        recordButton.addGestureRecognizer(longPress)
        outputButton.addTarget(self, action: #selector(onTapOutput(_:)), for: .touchUpInside)
    }
    
    @objc private func onLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            currentVowel = vowels[vowelSegment.selectedSegmentIndex]
        case .ended:
            currentVowel = nil
        default: break
        }
    }
    
    @objc private func onTapOutput(_ sender: UIButton) {
        let header = "vowel," + targetLocations.map({ "\($0.rawValue)" }).joined(separator: ",")
        var output: String = header + "\n"
        for log in logs {
            let line = "\(log.vowel)," + targetLocations.map({ log.values[$0]! }).map({ "\($0)" }).joined(separator: ",")
            output += line + "\n"
        }
        print(output)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        guard let currentVowel = currentVowel else { return }
        
        var locationAndValues: [ARFaceAnchor.BlendShapeLocation : Double] = [:]
        for location in targetLocations {
            if let value = faceAnchor.blendShapes[location] as? Double {
                locationAndValues[location] = value
            }
        }
        logs.append(Log(vowel: currentVowel, values: locationAndValues))
        label.text = "\(logs.count)"
    }
}
