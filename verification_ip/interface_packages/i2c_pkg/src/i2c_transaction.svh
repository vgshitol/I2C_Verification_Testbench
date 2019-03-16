class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

       bit [63:0] header, payload [8], trailer;
    rand bit [5:0]  delay;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("header:0x%x payload:0x%p trailer:0x%x delay:%d", header, payload, trailer, delay)};
    endfunction

    function bit compare(i2c_transaction rhs);
        return ((this.header  == rhs.header ) &&
            (this.payload == rhs.payload) &&
            (this.trailer == rhs.trailer) );
    endfunction
endclass
