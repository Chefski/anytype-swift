extension Array {
    
  func reordered<T: Comparable>(
    by order: [T],
    transform: (Element) -> T
  ) -> [Element] {
    sorted { a, b in
      let transformedA = transform(a)
      let transformedB = transform(b)
      guard let first = order.firstIndex(of: transformedA) else {
        return false
      }
      guard let second = order.firstIndex(of: transformedB) else {
        return true
      }

      return first < second
    }
  }
    
}