'// Created on 28-May-25 07:59

constructor MenuBase()

end constructor

destructor MenuBase()

end destructor

constructor MenuBar()

end constructor

constructor MenuBar(parent as Form ptr)
    this._handle = CreateMenu()
    this._formPtr = parent
    this._font = new Font("Tahoma", 11)
    this._grayCref = RgbColor.getCREF(&h979dac)
    this._grayBrush = CreateSolidBrush(RgbColor.getCREF(&hced4da))
end constructor

destructor MenuBar()

end destructor