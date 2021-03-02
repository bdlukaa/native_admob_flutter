extension Int {
    func dp() -> Int {
        if (self == -1 || self == -2) {return self}
        let density = UIScreen.main.scale
        return Int(CGFloat(self) * density)
    }
}

