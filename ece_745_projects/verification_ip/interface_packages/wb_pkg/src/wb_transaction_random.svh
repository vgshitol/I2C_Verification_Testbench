class wb_transaction_random extends wb_transaction;
  `ncsu_register_object(wb_transaction_random)

    function new(string name="");
        super.new(name);
    endfunction

    constraint csr_constraint {addr ==2'b00 -> irq_c == 1 && type_op == 0;}

    constraint cmdr_consraint { (addr == 2'b10 && type_op == 1) -> data inside {
        8'b00000001,
        8'b00000010,
        8'b00000011,
        8'b00000100,
        8'b00000101,
        8'b00000110,
        8'b00000000,
        8'b00000111,
        8'b11111111
        };
    }

    constraint fsmr_consraint { (addr == 2'b11) -> type_op == 0; }

endclass