
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));

    ncsu_component #(wb_transaction) wb_p0_agent;
    ncsu_component #(i2c_transaction) i2c_p1_agent;

    string wb_trans_name;
    string i2c_trans_name = "i2c_transaction";

    i2c_transaction I2C_t;

    bit [7:0] read_data_i2c[32];
    bit [7:0] read_alt_data[];
    static int data_select;
    bit alt;
    int data=63;

    wb_transaction wishbone_transaction;

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
            begin
                wishbone();
            end
            begin
                i2c();
            end
        join_none

    endtask

    task i2c();
        forever
            begin
                $cast(I2C_t,ncsu_object_factory::create(i2c_trans_name));
                if(data_select==0)begin
                    foreach(read_data_i2c[i])begin
                        read_data_i2c[i] = i+100;
                    end
                    I2C_t.read_data = read_data_i2c;
                    i2c_p1_agent.bl_put(I2C_t);
                    if(I2C_t.op==READ)
                        data_select++;
                end
                else if(data_select>0) begin
                    read_alt_data=new[1];
                    read_alt_data[0] = data;
                    I2C_t.read_data = read_alt_data;
                    i2c_p1_agent.bl_put(I2C_t);
                    if(I2C_t.op==READ)
                        begin
                            data_select++;
                            data--;
                        end
                end
            end
    endtask

    task wishbone();
        initialise_core();
        $display("\n WRITE TO I2C --> START ");
        start();
        address_calculation();
        for(byte i=0;i<32;i++) begin
            write(i);
        end
        stop();
        $display("\n WRITE TO I2C --> END ");
        $display("\n READ To I2C --> START");
        start();
        address_calculation_read();
        for(byte i=0; i<31;i++)begin
            read_with_ack();
        end
        read_with_nack();
        stop();
        $display("\n READ To I2C --> STOP");
        $display("\n ALTERNATE WRITE AND READ --> START");
        for(byte alt=0;alt<64;alt++)begin
            start();
            if(alt==0)
                $display("START!");
            else
                $display("RESTART!");

            address_calculation();
            write(alt+64);

            start();
            $display("RESTART!");
            address_calculation_read();
            read_with_nack();
        end
        stop();
        $display("STOP!!!");

    endtask


    task make_transaction( bit [1:0] addr, bit [7:0] data, bit irq_c, bit type_op);
        $cast(wishbone_transaction,ncsu_object_factory::create(wb_trans_name));
        wishbone_transaction.addr=addr;
        wishbone_transaction.data=data;
        wishbone_transaction.irq_c=irq_c;
        wishbone_transaction.type_op=type_op;
        wb_p0_agent.bl_put(wishbone_transaction);
    endtask

    task initialise_core(); // setting up the core of i2cmb
        make_transaction(2'b00,8'b11xxxxxx,0,1);
        make_transaction(2'b01,8'bxxxxxx01,0,1);
        make_transaction(2'b10,8'bxxxxx110,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task start(); // start the i2c
        make_transaction(2'b10,8'bxxxxx100,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation(); // specify the address of i2c slave
        make_transaction(2'b01,8'h00000044,0,1);
        make_transaction(2'b10,8'bxxxxx001,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task address_calculation_read(); // specify read address of i2c slave
        make_transaction(2'b01,8'h00000045,0,1);
        make_transaction(2'b10,8'bxxxxx001,0,1);
        make_transaction(2'b00,8'bxxxxxx00,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task read_with_ack(); // read with acknowledgement
        make_transaction(2'b10,8'bxxxxx010,0,1);
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

    task write(byte write_value); // write to i2c
        make_transaction(2'b01,write_value,0,1);
        make_transaction(2'b10,8'bxxxxx001,0,1);
        make_transaction(2'b00,8'bxxxxx001,1,0);
        make_transaction(2'b10,8'bxxxxxxxx,0,0);
    endtask

    task stop(); // stop the i2c
        make_transaction(2'b10,8'bxxxxx101,0,1);
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

    endtask


endclass

