class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

    bit [7:0] address;
    bit [7:0] data;
    bit rw;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("Address:0x%x Operation:%s Data:0x%p", address, (rw==1) ? "READ":"WRITE", data)};
    endfunction

    function bit compare(wb_transaction rhs);
        return ((this.address  == rhs.address ) &&
            (this.data == rhs.data) &&
            (this.rw == rhs.rw) );
    endfunction
endclass
