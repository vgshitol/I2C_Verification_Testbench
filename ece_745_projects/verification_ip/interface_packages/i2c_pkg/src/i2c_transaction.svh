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
    	if(op==READ)
            return {$sformatf(" I2C Address:0x%x , Operation: READ , I2C Data:%p",  i2c_address ,i2c_data)};
        if(op==WRITE)
            return {$sformatf(" I2C Address:0x%x , Operation: WRITE , I2C Data:%p",  i2c_address ,i2c_data)};
        endfunction

    function bit compare(i2c_transaction rhs);
        return ((this.i2c_data  == rhs.i2c_data ) &&
            (this.i2c_address == rhs.i2c_address) &&
            (this.op == rhs.op) );
    endfunction
endclass
