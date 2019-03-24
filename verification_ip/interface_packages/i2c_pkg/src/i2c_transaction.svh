class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

    bit [7:0] write_data [];
    bit [7:0] read_data [];
    bit [7:0] monitor_address;
    bit [7:0] monitor_data [];
    bit monitor_op;
    bit op;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("Address:0x%x Operation:0x%x Data:0x%p", monitor_address
        , monitor_op, monitor_data)};
    endfunction

    function bit compare(i2c_transaction rhs);
        $display("RHS Address: 0x%x Operation: 0x%x Data: 0x%p",
            rhs.monitor_address,
            rhs.monitor_op,
            rhs.monitor_data
            );
        $display("THIS  Address: 0x%x Operation: 0x%x Data: 0x%p",
            this.monitor_address,
            this.monitor_op,
            this.monitor_data
            );
        return ((this.monitor_address  == rhs.monitor_address ) &&
            (this.monitor_data == rhs.monitor_data) &&
            (this.monitor_op == rhs.monitor_op)
            );
    endfunction
endclass
