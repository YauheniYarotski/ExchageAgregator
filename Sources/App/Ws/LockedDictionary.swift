/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct LockedDictionary<Key: Hashable, Value> {
  private let lock = NSLock()
  private var backing: [Key: Value] = [:]
  
  subscript(key: Key) -> Value? {
    get {
      lock.lock()
      defer { lock.unlock() }
      
      return backing[key]
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      
      backing[key] = newValue
    }
  }
}

extension LockedDictionary: ExpressibleByDictionaryLiteral {
  init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      backing[key] = value
    }
  }
}



struct LockedArray<T: AnyObject> {
  private let lock = NSLock()
  private var backing: [Weak<T>] = []
  
  subscript(index: Int) -> T? {
    get {
      lock.lock()
      defer { lock.unlock() }
      return backing[index].value
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      guard let newValue = newValue else {return}
      backing.insert(Weak(newValue), at: index)
    }
  }
  
  mutating func append(element: T) {
    lock.lock()
    defer { lock.unlock() }
    backing.append(Weak(element))
  }
  
  var allElements: [T] {
    lock.lock()
    defer { lock.unlock() }
    return backing.filter{ nil != $0.value }.map({$0.value!})
  }
}

extension LockedArray: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: T...) {
    for val in elements {
      backing.append(Weak(val))
    }
  }
}

extension LockedArray {
  mutating func reap () {
    lock.lock()
    defer { lock.unlock() }
    backing = backing.filter { nil != $0.value }
  }
}

class Weak<T: AnyObject> {
  weak var value : T?
  init (_ value: T) {
    self.value = value
  }
}





struct LockedSet<Value: Hashable> {
  private let lock = NSLock()
  private var backing: Set<Value> = []
  
  
  mutating func append(element: Value) {
    lock.lock()
    defer { lock.unlock() }
    backing.insert(element)
  }
  
  mutating func remove(element: Value) {
    lock.lock()
    defer { lock.unlock() }
    backing.remove(element)
  }
  
}

extension LockedSet: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: Value...) {
    backing = Set(elements)
  }
}
