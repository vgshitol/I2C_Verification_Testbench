
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));

    ncsu_component #(wb_transaction) wb_p0_agent;
    ncsu_component #(i2c_transaction) i2c_p1_agent;
    i2c_transaction i2c_trans;
    wb_transaction wb_trans;

    static int data_select;

    string wb_trans_name;
    string i2c_trans_name = "i2c_transaction";
    string wb_random_trans_name = "wb_transaction_random";

    bit [7:0] read_data_i2c[32];
    bit [7:0] read_alt_data[];
    bit alt;
    byte data=63;
    bit op_type = 1;
    bit sendi2c = 0;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", wb_trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", wb_trans_name);
        foreach(read_data_i2c[i]) begin read_data_i2c[i] = i+100; end
    endfunction

    virtual task run();
        fork
            begin  wishbone(); registerTesting();  wait_idle_test(1); byteRandomSeq(); end
        //    begin bitlevelfsm(); end
            begin i2c(); end
          //  begin i2c2(); end
        join_none

    endtask

    task i2c();
        forever begin
                $cast(i2c_trans,ncsu_object_factory::create(i2c_trans_name));
                if(data_select==0) begin
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

    task i2c2();
        forever begin
            if(sendi2c==1) begin
                make_i2c_transaction({data});
                data--;
                sendi2c=0;
            end
            make_i2c_transaction({data});
        end
    endtask

    task make_i2c_transaction( bit [7:0] read_data[] = {} );
        $cast(i2c_trans,ncsu_object_factory::create(i2c_trans_name));
        if(op_type == READ) i2c_trans.read_data = read_data;
        i2c_p1_agent.bl_put(i2c_trans);
    endtask

    task wishbone();
        initialise_core();
        start(1);
        address_calculation(8'h00000044,1);
        for(byte i=0;i<32;i++) begin write(i,1); end
        stop(1);
        start(1);
        address_calculation_read(8'h00000045,1);
        for(byte i=0; i<31;i++) begin read_with_ack(1); end
        read_with_nack(1);
        stop(1);
        for(byte alt=0;alt<64;alt++) begin
            start(1);
//            if(alt==0) $display("START!");
//            else $display("RESTART!");
            address_calculation(8'h00000044,1);
            write(alt+64,1);
            start(1);
            address_calculation_read(8'h00000045,1);
            read_with_nack(1);
        end
        stop(1);
        $display("STOP!!!");
    endtask

    task make_transaction( bit [1:0] addr, bit [7:0] data, bit irq_c, bit type_op, int delay = 0);
        $cast(wb_trans,ncsu_object_factory::create(wb_trans_name));
        wb_trans.addr=addr;
        wb_trans.data=data;
        wb_trans.irq_c=irq_c;
        wb_trans.type_op=type_op;
        op_type = 1 - type_op; // WB Trans Type opposite to I2c trans Type
        wb_trans.delay=delay;
        wb_p0_agent.bl_put(wb_trans);
    endtask

    /*---------------Register Transactions Coverage----------------------------------*/

    task registerTesting();
        make_transaction(2'b00,8'bxxxxxxx0,0,1);
        make_transaction(2'b00,8'bxxxxxxx0,0,1);
        make_transaction(2'b00,8'bxxxxxxx0,0,0);
        make_transaction(2'b00,8'bxxxxxxx0,0,1);
        make_transaction(2'b01,8'bxxxxxxx0,0,0);
        make_transaction(2'b00,8'bxxxxxxx0,0,1);
        make_transaction(2'b10,8'bxxxxxxx0,0,0);
        make_transaction(2'b00,8'bxxxxxxx0,0,1);
        make_transaction(2'b11,8'bxxxxxxx0,0,0);
        make_transaction(2'b00,8'b11000000,0,1);
        make_transaction(2'b00,8'b11111111,0,1);
        make_transaction(2'b01,8'b11111111,0,1);
        make_transaction(2'b10,8'b11111111,0,1);
        make_transaction(2'b11,8'b11111111,0,1);
        make_transaction(2'b00,8'b11111111,0,0);
        make_transaction(2'b01,8'b11111111,0,0);
        make_transaction(2'b10,8'b11111111,0,0);
        make_transaction(2'b11,8'b11111111,0,0);
        make_transaction(2'b00,8'b11111111,0,0);
        make_transaction(2'b00,8'b00111111,0,1);
        make_transaction(2'b00,8'b00111111,0,0);
        make_transaction(2'b00,8'b00111111,0,0);
        make_transaction(2'b01,8'b00111111,0,0);
        make_transaction(2'b01,8'b11111111,0,1);
        make_transaction(2'b01,8'b11111111,0,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        make_transaction(2'b10,8'b11111111,0,1);
        make_transaction(2'b10,8'b10000111,0,1);
        make_transaction(2'b11,8'bxxxxxxxx,0,0);
        make_transaction(2'b11,8'b11111111,0,0);
        make_transaction(2'b11,8'b00000000,0,0);
        make_transaction(2'b00,8'b11000000,0,1);
        make_transaction(2'b00,8'b11000000,0,0);
        make_transaction(2'b00,8'bxxxxxxxx,0,0);
        make_transaction(2'b01,8'b11111111,0,1);
        make_transaction(2'b01,8'b11111111,0,0);
        make_transaction(2'b01,8'b11111111,0,0);
        make_transaction(2'b10,8'b11111111,0,0);
        make_transaction(2'b10,8'b11111111,0,0);
        make_transaction(2'b11,8'b11111111,0,0);
        make_transaction(2'b11,8'b11111111,0,0);
        make_transaction(2'b11,8'b00000000,0,0);
    endtask

    /*---------------Random Transactions for Byte Level Coverage----------------------------------*/

    task byteRandomSeq();

        start(1);
        address_calculation(8'h00000044,1);

        for (byte i=0;i<10;i=i+1) begin
            $cast(wb_trans,ncsu_object_factory::create(wb_random_trans_name));
            wb_trans.randomize() with {addr == 2'b11 && type_op==0;};
            wb_p0_agent.bl_put(wb_trans);

            $cast(wb_trans,ncsu_object_factory::create(wb_random_trans_name));
            wb_trans.randomize() with {addr == 2'b10 && type_op==1;};
            wb_p0_agent.bl_put(wb_trans);

            $cast(wb_trans,ncsu_object_factory::create(wb_random_trans_name));
            wb_trans.randomize() with {addr == 2'b00 && type_op==0;};
            wb_p0_agent.bl_put(wb_trans);

            $cast(wb_trans,ncsu_object_factory::create(wb_random_trans_name));
            wb_trans.randomize() with {addr == 2'b10 && type_op==0;};
            wb_p0_agent.bl_put(wb_trans);

            $cast(wb_trans,ncsu_object_factory::create(wb_random_trans_name));
            wb_trans.randomize() with {addr == 2'b11 && type_op==0;};
            wb_p0_agent.bl_put(wb_trans);
        end
        stop(1);
    endtask

    /*---------------Main Transactions----------------------------------*/

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
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 300); // fsm Read
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 500); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task restart(bit fsm_monitor = 0); // start the i2c
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx100,0,1);
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 280); // fsm Read
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 4); // fsm Read
        if(fsm_monitor==1)  make_transaction(2'b11,8'bxxxxxxxx,0,0, 4); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation(byte address = 8'h00000044, bit fsm_monitor = 0); // specify the address of i2c slave
        make_transaction(2'b01,address,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 100); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 68); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation_read(byte address = 8'h00000045, bit fsm_monitor = 0); // specify read address of i2c slave
        make_transaction(2'b01,address,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 100); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 68); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task read_with_ack(bit fsm_monitor = 0); // read with acknowledgement
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx010,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 100); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 68); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        make_transaction(2'b01,8'bxxxxxxxx,0,0);
    endtask

    task read_with_nack(bit fsm_monitor = 0); // read with NAK
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx011,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 100); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 68); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        make_transaction(2'b01,8'bxxxxxxxx,0,0);
    endtask

    task write(byte write_value, bit fsm_monitor = 0); // write to i2c
        make_transaction(2'b01,write_value,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx001,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 100); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 68); // fsm Read
        make_transaction(2'b00,8'bxxxxx001,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task stop(bit fsm_monitor = 0); // stop the i2c
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b10,8'bxxxxx101,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0,150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 270); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 150); // fsm Read
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0, 400); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task wait_idle_test(bit fsm_monitor = 0);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b01,8'bxxxxx010,0,1);
        make_transaction(2'b10,8'bxxxxx000,0,1);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
        if(fsm_monitor==1) make_transaction(2'b11,8'bxxxxxxxx,0,0); // fsm Read
    endtask

    function void set_i2c_agent(ncsu_component #(i2c_transaction) agent);
        this.i2c_p1_agent = agent;
    endfunction

    function void set_wb_agent(ncsu_component #(wb_transaction) agent);
        this.wb_p0_agent = agent;
    endfunction

    task bitlevelfsm();
        $display("Init Below" );
     //   initialise_core();
        $display("Start Below" );
        start(1);
        $display("Address Calc Below" );
        address_calculation(8'h00000044, 1);
        $display("Write Below" );
        write(11,1);
        sendi2c=1;
        write(12,1);
        sendi2c=1;
        write(13,1);
        sendi2c=1;
        $display("Stop Below" );
        //stop(1);
        $display("Start Below" );
        //start(1);
        restart();
//        $display("Address Calc Below" );
//        address_calculation(8'h00000044, 1);
//        $display("Read with Ack Below" );
//        write(22,1);
//        write(25,1);
//        $display("Stop Below" );
//        //stop(1);
//        $display("Start Below" );
//        //start(1);
//        restart(1);
//        $display("Address Calc Below" );
        address_calculation_read(8'h00000045);
        $display("Read With Ack  Below" );
        read_with_ack();
        sendi2c=1;
        read_with_ack();
        sendi2c=1;
        read_with_ack();
        sendi2c=1;
        read_with_ack();
        sendi2c=1;
        $display("Stop Below" );
        restart();
        address_calculation(8'h00000044);
        $display("Read with Ack Below" );
        write(11);
        write(12);
        write(13);
        stop();
//        //  $display("Write Below" );
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

