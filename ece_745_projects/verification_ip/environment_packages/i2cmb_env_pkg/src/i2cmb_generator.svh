
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));

    ncsu_component #(wb_transaction) wb_p0_agent;
    ncsu_component #(i2c_transaction) i2c_p1_agent;
    i2c_transaction i2c_trans;
    wb_transaction wb_trans;

    static int data_select;

    string wb_trans_name;
    string i2c_trans_name = "i2c_transaction";

    bit [7:0] read_data_i2c[32];
    bit [7:0] read_alt_data[];
    bit alt;
    int data=63;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", wb_trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", wb_trans_name);
    endfunction

    virtual task run();
        fork
         //   begin wishbone(); end
            begin bitlevelfsm(); end
            begin i2c(); end
        join_none
    endtask

    task i2c();
        forever begin
                $cast(i2c_trans,ncsu_object_factory::create(i2c_trans_name));
                if(data_select==0) begin
                    foreach(read_data_i2c[i]) begin read_data_i2c[i] = i+100; end
                    i2c_trans.read_data = read_data_i2c;
                    i2c_p1_agent.bl_put(i2c_trans);
                    if(i2c_trans.op==READ)
                        data_select++;
                end
                else if(data_select>0) begin
                    read_alt_data=new[1];
                    read_alt_data[0] = data;
                    i2c_trans.read_data = read_alt_data;
                    i2c_p1_agent.bl_put(i2c_trans);
                    if(i2c_trans.op==READ) begin
                            data_select++;
                            data--;
                        end
                end
            end
    endtask

    task wishbone();
        initialise_core();
        start(1);
        address_calculation(8'h00000044);
        for(byte i=0;i<32;i++) begin write(i); end
        stop();
        start(1);
        address_calculation_read(8'h00000045);
        for(byte i=0; i<31;i++) begin read_with_ack(); end
        read_with_nack();
        stop();
        for(byte alt=0;alt<64;alt++) begin
            start(1);
//            if(alt==0) $display("START!");
//            else $display("RESTART!");
            address_calculation(8'h00000044);
            write(alt+64);
            start(1);
            address_calculation_read(8'h00000045);
            read_with_nack();
        end
        stop();
        $display("STOP!!!");
    endtask

    task make_transaction( bit [1:0] addr, bit [7:0] data, bit irq_c, bit type_op);
        $cast(wb_trans,ncsu_object_factory::create(wb_trans_name));
        wb_trans.addr=addr;
        wb_trans.data=data;
        wb_trans.irq_c=irq_c;
        wb_trans.type_op=type_op;
        wb_p0_agent.bl_put(wb_trans);
    endtask

    task initialise_core(); // setting up the core of i2cmb
        make_transaction(2'b00,8'b11xxxxxx,0,1);
        make_transaction(2'b01,8'bxxxxxx01,0,1);
        make_transaction(2'b10,8'bxxxxx110,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task start(bit fsm_monitor = 0); // start the i2c
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx100,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #300000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #500000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task restart(bit fsm_monitor = 0); // start the i2c
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx100,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #280000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #4000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #4000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation(byte address = 8'h00000044, bit fsm_monitor = 0); // specify the address of i2c slave
        make_transaction(2'b01,address,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #270000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #100000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #400000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #72000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation_read(byte address = 8'h00000045, bit fsm_monitor = 0); // specify read address of i2c slave
        make_transaction(2'b01,address,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #270000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #100000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #400000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #72000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task read_with_ack(bit fsm_monitor = 0); // read with acknowledgement
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx010,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #270000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #100000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #400000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #72000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        make_transaction(2'b01,8'bxxxxxxxx,0,0);
    endtask

    task read_with_nack(); // read with NAK
        make_transaction(2'b10,8'bxxxxx011,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        make_transaction(2'b01,8'bxxxxxxxx,0,0);
    endtask

    task write(byte write_value, bit fsm_monitor = 0); // write to i2c
        make_transaction(2'b01,write_value,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #270000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #100000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #400000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #72000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxx001,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task stop(bit fsm_monitor = 0); // stop the i2c
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx101,0,1);
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #270000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #150000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        if(fsm_monitor==1) #400000 make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    function void set_i2c_agent(ncsu_component #(i2c_transaction) agent);
        this.i2c_p1_agent = agent;
    endfunction

    function void set_wb_agent(ncsu_component #(wb_transaction) agent);
        this.wb_p0_agent = agent;
    endfunction

    task bitlevelfsm();
        $display("Init Below" );
        initialise_core();
        $display("Start Below" );
        start(1);
        $display("Address Calc Below" );
        address_calculation(8'h00000044, 1);
        $display("Write Below" );
        write(11,1);
        $display("Stop Below" );
        stop(1);
        $display("Start Below" );
        start(1);
        $display("Address Calc Below" );
        address_calculation_read(8'h00000045, 1);
        $display("Read with Ack Below" );
        read_with_ack(1);
        $display("Stop Below" );
        stop(1);
        // $display("Address Calc Below" );
       // address_calculation_read();
//        $display("Read With Ack  Below" );
//        read_with_ack(1);
//      //  $display("Write Below" );
      //  write(11,1);
//        $display("Start Below" );
//        restart(1);
      //  start(1);
       // $display("Start Below" );
       // start(1);
        //  $display("Read with Ack Below" );
       // read_with_ack(1);
       // $display("End Below" );




    endtask


endclass

