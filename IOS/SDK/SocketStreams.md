# SocketStreams

NSStream

CFStream

InputStream
OutputSteam


```swift
import Foundation

import UIKit

protocol ChatRoomDelegate: class {
  func received(message: Message)
}

class ChatRoom: NSObject {
  weak var delegate: ChatRoomDelegate?

  // 1
  var inputStream: InputStream!
  var outputStream: OutputStream!

  // 2
  var username = ""

  // 3
  let maxReadLength = 4096

  func setupNetworkCommunication() {
    // 1
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?

    // 2
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       "localhost" as CFString,
                                       80,
                                       &readStream,
                                       &writeStream)

    // take the retained refrence
    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()

    inputStream.delegate = self

    // add to run loop
    inputStream.schedule(in: .current, forMode: .common)
    outputStream.schedule(in: .current, forMode: .common)

    inputStream.open()
    outputStream.open()
  }

  func joinChat(username: String) {
    // 1
    let data = "iam:\(username)".data(using: .utf8)!

    // 2
    self.username = username

    // 3
    _ = data.withUnsafeBytes {
      guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        print("Error joining chat")
        return
      }
      // 4
      outputStream.write(pointer, maxLength: data.count)
    }
  }

  func send(message: String) {
    let data = "msg:\(message)".data(using: .utf8)!

    _ = data.withUnsafeBytes {
      guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        print("Error joining chat")
        return
      }
      outputStream.write(pointer, maxLength: data.count)
    }
  }
  
  func stopChatSession() {
    inputStream.close()
    outputStream.close()
  }
}

extension ChatRoom: StreamDelegate {
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch eventCode {
    case .hasBytesAvailable:
      print("new message received")
      readAvailableBytes(stream: aStream as! InputStream)
    case .endEncountered:
      print("new message received")
      stopChatSession()
    case .errorOccurred:
      print("error occurred")
    case .hasSpaceAvailable:
      print("has space available")
    default:
      print("some other event...")
    }
  }

  private func readAvailableBytes(stream: InputStream) {
    // 1
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

    // 2
    while stream.hasBytesAvailable {
      // 3
      let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

      // 4
      if numberOfBytesRead < 0, let error = stream.streamError {
        print(error)
        break
      }

      // Construct the Message object
      if let message =
        processedMessageString(buffer: buffer, length: numberOfBytesRead) {
        // Notify interested parties
        delegate?.received(message: message)
      }
    }
  }

  private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                      length: Int) -> Message? {
    // 1
    guard
      let stringArray = String(
        bytesNoCopy: buffer,
        length: length,
        encoding: .utf8,
        freeWhenDone: true)?.components(separatedBy: ":"),
      let name = stringArray.first,
      let message = stringArray.last
    else {
      return nil
    }
    // 2
    let messageSender: MessageSender =
      (name == username) ? .ourself : .someoneElse
    // 3
    return Message(message: message, messageSender: messageSender, username: name)
  }
}
```

参考链接：

- [Introduction to Stream Programming Guide for Cocoa](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Streams.html#//apple_ref/doc/uid/10000188-SW1)