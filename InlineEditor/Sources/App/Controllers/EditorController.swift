//
//  EditorController.swift
//  App
//
//  Created by Iman Zarrabian on 20/07/2018.
//

import Vapor
import Leaf

final class EditorController: RouteCollection {
   // var executionResult = ""
   // var currentScript = ""
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.post(InlineScript.self, use: createScriptHandler)
       // registerNotification()
    }


    private func registerNotification() {
//        NotificationCenter.default.addObserver(forName: printNotification,
//                                               object: nil,
//                                               queue: nil) { [weak self] notification in
//                                                if let message = notification.userInfo?[notificationMessageInfosKey] as? String {
//                                                    self?.executionResult += message
//                                                    print("NEW RESULT:" + self!.executionResult)
//                                                }
//        }
    }

    private func indexHandler(_ req: Request) throws -> Future<View> {
        let context = EditorContext(title: "Hop Inline Edtior")
        return try req.view().render("index", context)
    }

    private func createScriptHandler(_ req: Request, data: InlineScript) throws -> Future<View> {

        let filteredScript = data.script.replacingOccurrences(of: "\r\n", with: "\n")
        //maybe we should treat \r\n in the lexer
        let script = InlineScript(script: filteredScript)

        let promiseEvaluation = req.eventLoop.newPromise(EvaluationContext.self)
        NotificationCenter.default.addObserver(forName: printNotification,
                                               object: nil,
                                               queue: nil) { notification in
                                                var context: EvaluationContext!
                                                if let message = notification.userInfo?[notificationMessageInfosKey] as? String {
                                                    context = EvaluationContext(title: "Hop Inline Edtior", script: filteredScript, executionResult: message)

                                                } else {
                                                    context = EvaluationContext(title: "Hop Inline Edtior", script: filteredScript, executionResult: "Execution Error!")
                                                }

                                                promiseEvaluation.succeed(result: context) //Should treat the error as an actual failing case

        }

        let lexer = Lexer(script: script.script + "\n")
        let parser = Parser(with: lexer)
        if let program = try parser.parseProgram() {
            print("------------- parsing OK -----------\n")
            try program.perform()
            print("------------- perform OK -----------\n")
        }

        return promiseEvaluation.futureResult.flatMap { context in
            try req.view().render("index", context)
        }
    }
}
