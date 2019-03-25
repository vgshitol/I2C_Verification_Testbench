class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)

       bit [7:0] i2c_data [];
    bit [6:0] i2c_address;
    i2c_op_t op;
    bit [7:0] read_data[];

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        if(op==WRITE)
            return {/*super.convert2string(),*/$sformatf("I2C_DATA:%p   I2C_ADDRESS:0x%x   OP:  WRITE", i2c_data, i2c_address)};
        if(op==READ)
            return {/*super.convert2string(),*/$sformatf("I2C_DATA:%p   I2C_ADDRESS:0x%x   OP:  READ", i2c_data, i2c_address)};
    endfunction

    function bit compare(i2c_transaction rhs);
        return ((this.i2c_data  == rhs.i2c_data ) &&
            (this.i2c_address == rhs.i2c_address) &&
            (this.op == rhs.op) );
    endfunction
endclass
