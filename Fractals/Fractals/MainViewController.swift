//
//  MainViewController.swift
//  Fractals
//
//  Created by Paweł Wszeborowski on 12/03/2019.
//  Copyright © 2019 Paweł Wszeborowski. All rights reserved.
//

import AppKit
import LSystem

fileprivate let degrees120: CGFloat = 2 * .pi / 3

enum SierpinskiTriangleSymbol: String, LSSymbol {
    case drawForward
    case drawForward2
    case turnLeft120
    case turnRight120

    var description: String {
        return rawValue
    }
}

fileprivate let sierpinskiTriangle = try! LSSystem<SierpinskiTriangleSymbol>(
    name: "Sierpiński triangle",
    grammar: .init(
        symbolsWithProductionRules: [
            .drawForward: .produce([.drawForward, .turnRight120, .drawForward2, .turnLeft120, .drawForward, .turnLeft120, .drawForward2, .turnRight120, .drawForward]),
            .drawForward2: .produce([.drawForward2, .drawForward2]),
            .turnLeft120: .identity,
            .turnRight120: .identity
        ],
        axiom: [.drawForward, .turnRight120, .drawForward2, .turnRight120, .drawForward2]
    )
).fractal(afterRecursionsCount: 9)

class MainViewController: NSViewController {
    private let canvas = CanvasView()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        canvas.drawSierpinski(sierpinskiTriangle, from: CGPoint(x: 10, y: 10), segmentLength: 2)
    }
}

class CanvasView: NSView {
    private var paths: [CGPath] = []

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = .white
        layer?.borderColor = .black
        layer?.borderWidth = 1
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let context = NSGraphicsContext.current?.cgContext
        paths.forEach {
            NSColor.black.setStroke()
            context?.addPath($0)
            context?.strokePath()
        }
    }
}

extension CanvasView {
    private func calculatePointAndAngle(afterApplying symbol: SierpinskiTriangleSymbol, toCurrentPointAndAngle pointAndAngle: (CGPoint, CGFloat), segmentLength: CGFloat) -> (CGPoint, CGFloat) {
        let (currentPoint, currentAngle) = pointAndAngle
        switch symbol {
        case .turnRight120:
            return (currentPoint, currentAngle + degrees120)
        case .turnLeft120:
            return (currentPoint, currentAngle - degrees120)
        case .drawForward, .drawForward2:
            return (CGPoint(x: currentPoint.x + segmentLength * sin(currentAngle), y: currentPoint.y + segmentLength * cos(currentAngle)), currentAngle)
        }
    }

    func drawSierpinski(_ fractal: LSSystem<SierpinskiTriangleSymbol>.Fractal, from bottomLeftCorner: CGPoint, segmentLength: CGFloat) {
        let path = CGMutablePath()
        path.move(to: bottomLeftCorner)

        var pointAndAngle = (bottomLeftCorner, CGFloat(0))
        for symbol in fractal.result {
            pointAndAngle = calculatePointAndAngle(afterApplying: symbol, toCurrentPointAndAngle: pointAndAngle, segmentLength: segmentLength)
            path.addLine(to: pointAndAngle.0)
        }   

        paths.append(path)
        setNeedsDisplay(frame)
    }
}
