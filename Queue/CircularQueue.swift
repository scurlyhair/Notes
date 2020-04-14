// 循环队列

import Foundation

class CircularQueue {

    private var array: [Int?]
    private var size: Int
    private var head: Int
    private var tail: Int
    
    /** Initialize your data structure here. Set the size of the queue to be k. */
    init(_ k: Int) {
        array = Array(repeating: nil, count: k)
        size = k
        head = -1
        tail = -1
    }
    
    /** Insert an element into the circular queue. Return true if the operation is successful. */
    func enQueue(_ value: Int) -> Bool {
        if isFull() {
            return false
        }
        if isEmpty() {
            head += 1
        }
        tail += 1
        tail %= size
        array[tail] = value
        return true
    }
    
    /** Delete an element from the circular queue. Return true if the operation is successful. */
    func deQueue() -> Bool {
        if isEmpty() {
            return false
        }
        if head == tail {
            head = -1
            tail = -1
            return true
        }
        head += 1
        head %= size
        return true
    }
    
    /** Get the front item from the queue. */
    func Front() -> Int {
        if isEmpty() {
            return -1
        }
        return array[head]!
    }
    
    /** Get the last item from the queue. */
    func Rear() -> Int {
        if isEmpty() {
            return -1
        }
        return array[tail]!
    }
    
    /** Checks whether the circular queue is empty or not. */
    func isEmpty() -> Bool {
        return head == -1
    }
    
    /** Checks whether the circular queue is full or not. */
    func isFull() -> Bool {
        return (tail + 1)%size == head
    }
}
