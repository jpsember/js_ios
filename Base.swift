import Foundation

func puts(message: String!) {
    if let msg = message {
        JSBase.logString(msg + "\n")
    }
}

