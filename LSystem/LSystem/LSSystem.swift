//
//  LSSystem.swift
//  LSystem
//
//  Created by Paweł Wszeborowski on 12/03/2019.
//  Copyright © 2019 Paweł Wszeborowski. All rights reserved.
//

import Foundation

public protocol LSSymbol: Hashable {
    var description: String { get }
}

public struct LSGrammar<Symbol: LSSymbol> {

    public enum GrammarError: String, Error {
        case unknownSymbolInAxiom = "Unknown symbol found in axiom."
        case unknownSymbolInProductionRules = "Unknown symbol found in production rules."

        public var localizedDescription: String {
            return rawValue
        }
    }

    public enum ProductionRule: Equatable {
        case identity
        case produce([Symbol])

        func apply(to symbol: Symbol) -> [Symbol] {
            switch self {
            case .identity:
                return [symbol]
            case .produce(let symbols):
                return symbols
            }
        }
    }

    let symbolsAndRules: [Symbol: ProductionRule]
    let axiom: [Symbol]

    public init(symbolsWithProductionRules: [Symbol: ProductionRule], axiom: [Symbol]) throws {
        try LSGrammar.validateInitializationData(symbolsWithProductionRules, axiom: axiom)
        self.symbolsAndRules = symbolsWithProductionRules
        self.axiom = axiom
    }

    private static func validateInitializationData(_ data: [Symbol: ProductionRule], axiom: [Symbol]) throws {
        let knownSymbols = data.keys
        let containsOnlyKnownSymbols = { (rule: ProductionRule) -> Bool in
            if case .produce(let symbols) = rule {
                return symbols.allSatisfy(knownSymbols.contains)
            }
            return true
        }
        guard data.values.allSatisfy(containsOnlyKnownSymbols) else {
            throw GrammarError.unknownSymbolInProductionRules
        }
        guard axiom.allSatisfy(knownSymbols.contains) else {
            throw GrammarError.unknownSymbolInAxiom
        }
    }
}

/**
 Struct representing Lindenmayer system

 [Wiki article]: https://en.wikipedia.org/wiki/L-system ""
 For more information, see [Wiki article].
*/
public struct LSSystem<Symbol> where Symbol: LSSymbol {

    public enum LSSystemError: String, Error {
        case invalidRecursionsCount = "Recursions count must be non-negative."

        public var localizedDescription: String {
            return rawValue
        }
    }

    public struct Iteration {
        public let input: [Symbol]

        init(input: [Symbol]) {
            self.input = input
        }

        func applyRules(_ rules: [Symbol: LSGrammar<Symbol>.ProductionRule]) -> Iteration {
            return Iteration(input: input.flatMap { rules[$0]!.apply(to: $0) })
        }
    }

    public struct Fractal {
        private let rules: [Symbol: LSGrammar<Symbol>.ProductionRule]

        public let iterations: [Iteration]

        var currentIteration: Iteration {
            return iterations.last!
        }

        public var result: [Symbol] {
            return currentIteration.input
        }

        init(axiom: [Symbol], rules: [Symbol: LSGrammar<Symbol>.ProductionRule]) {
            self.rules = rules
            self.iterations = [Iteration(input: axiom)]
        }

        private init(iterations: [Iteration], rules: [Symbol: LSGrammar<Symbol>.ProductionRule]) {
            self.rules = rules
            self.iterations = iterations
        }

        public func nextRecursion() -> Fractal {
            let newIteration = currentIteration.applyRules(rules)

            return Fractal(
                iterations: [iterations, [newIteration]].flatMap { $0 },
                rules: rules
            )
        }
    }

    /// User-defined name
    public let name: String

    public let grammar: LSGrammar<Symbol>

    public let fractal: Fractal

    public init(name: String, grammar: LSGrammar<Symbol>) {
        self.name = name
        self.grammar = grammar
        self.fractal = Fractal(axiom: grammar.axiom, rules: grammar.symbolsAndRules)
    }

    public func fractal(afterRecursionsCount count: Int) throws -> Fractal {
        guard count >= 0 else {
            throw LSSystemError.invalidRecursionsCount
        }
        let fractal = self.fractal
        return (0..<count).reduce(fractal, { fractal, _ in return fractal.nextRecursion() })
    }
}

extension LSSystem: CustomStringConvertible {
    public var description: String {
        let (constants, variables) = grammar.symbolsAndRules.split {
            $0.value == .identity
        }
        let constantsNames = constants.map { $0.0.description }.joined(separator: ", ")
        let variablesNames = variables.map { $0.0.description }.joined(separator: ", ")

        let rules = variables.map { tuple -> String in
            let (symbol, rule) = tuple
            return "(\(symbol.description) -> \(rule.apply(to: symbol).map { $0.description }.joined()))"
        }.joined(separator: ", ")

        return [
            "\n\"\(name)\"",
            "\tConstants: \(constantsNames)",
            "\tVariables: \(variablesNames)",
            "\tAxiom: \(grammar.axiom.map { $0.description }.joined(separator: ", "))",
            "\tRules: \(rules)"
        ].joined(separator: "\n")
    }
}

extension LSSystem.Fractal: CustomStringConvertible {
    public var description: String {
        let axiom = iterations.first!.input.map { $0.description }.joined(separator: ", ")
        let iterationsString = iterations.dropFirst().enumerated().map { tuple in
            let (index, iteration) = tuple
            return "Recursion \(index):\n\t\(iteration.input.map { $0.description }.joined(separator: ", "))"
        }.joined(separator: "\n")
        return "\nAxiom:\n\t\(axiom)\n\(iterationsString)"
    }
}
