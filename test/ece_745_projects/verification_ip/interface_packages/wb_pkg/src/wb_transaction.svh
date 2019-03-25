class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

       bit [1:0] addr;
    bit [7:0] data;
    bit enable;
    bit op_RorW;
    bit ifIRQ;
    bit detect_start;
    bit detect_stop;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("addr:0x%x data:0x%x enable:%d op_WorR:%d", addr, data, enable, op_RorW)};
    endfunction

    /*function bit compare(abc_transaction_base rhs);
      return ((this.header  == rhs.header ) &&
              (this.payload == rhs.payload) &&
              (this.trailer == rhs.trailer) );
    endfunction*/
endclass
