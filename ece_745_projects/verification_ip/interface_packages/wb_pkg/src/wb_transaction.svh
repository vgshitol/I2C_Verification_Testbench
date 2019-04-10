class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

    bit  [7:0] data; bit[1:0] addr; bit type_op;
    bit enable, irq_c, detect_start, detect_stop;

    function new(string name="");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return {super.convert2string(),$sformatf("Address:0x%x Operation:%d Data:0x%x Enable:%d ", addr, type_op, data, enable)};
    endfunction

    /*function bit compare(abc_transaction_base rhs);
      return ((this.header  == rhs.header ) &&
              (this.payload == rhs.payload) &&
              (this.trailer == rhs.trailer) );
    endfunction*/
endclass
