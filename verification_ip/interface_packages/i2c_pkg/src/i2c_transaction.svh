class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

    bit [7:0] write_data [];
    bit [7:0] read_data [];
    bit [7:0] monitor_address;
    bit [7:0] monitor_data;
    bit monitor_op;
    bit op;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("Address:0x%x Operation:%s Data:0x%p", address, (rw==1) ? "READ":"WRITE", data)};
    endfunction

    function bit compare(i2c_transaction rhs);
        return ((this.address  == rhs.address ) &&
            (this.data == rhs.data));
    endfunction
endclass
