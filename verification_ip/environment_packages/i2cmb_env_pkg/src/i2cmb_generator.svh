
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));

    wb_transaction wb_setup[5],wb_start[3],wb_address[4],wb_write[4],wb_stop[3],wb_readWAck[4],wb_readWNAck[4],wb_address_read[4];
    i2c_transaction I2C_t;
    static int data_select;bit alt;bit [7:0] read_data_i2c[32];bit [7:0] read_alt_data[];
    int data=63;

    ncsu_component #(i2c_transaction) agentI2C;
    ncsu_component #(wb_transaction) agentWB;
    string wb_trans_name;
    string i2c_trans_name = "i2c_transaction";

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
                runWB();												// Send WB transactions to WB driver
            end
            begin
                runI2C();												// Create I2C transactions and send to I2C driver
            end
        join_none

    endtask
    /*********************************************/
    task runWB();
        setup();
        $display("");
        $display("***************** Write 32(0->31) values to the I2C bus ********************");
        $display("");
        $display("START");
        start();
        address_calculation();
        for(byte i=0;i<32;i++) begin
            write(i);
        end
        stop();
        $display("STOP");
        $display("");
        $display("***************** Read 32 values(100->131) from I2C bus **********************");
        $display("");
        start();
        $display("START");
        address_calculation_read();
        for(byte i=0; i<31;i++)begin
            read_with_ack();
        end
        read_with_nack();
        stop();
        $display("STOP");
        $display("");
        $display("************ Alternate 64 writes(64->127)/Reads(63->0) values from I2C bus ***********");
        $display("");
        for(byte alt=0;alt<64;alt++)begin
            start();
            if(alt==0)
                $display("START");
            else
                $display("RESTART");
            address_calculation();
            write(alt+64);
            //stop();
            start();
            $display("RESTART");
            address_calculation_read();
            read_with_nack();
        end
        stop();
        $display("STOP");

    endtask : runWB
    /***********************************************************************/
    task runI2C();
        forever
            begin
                $cast(I2C_t,ncsu_object_factory::create(i2c_trans_name));
                if(data_select==0)begin
                    foreach(read_data_i2c[i])begin
                        read_data_i2c[i] = i+100;
                    end
                    I2C_t.read_data = read_data_i2c;
                    agentI2C.bl_put(I2C_t);
                    if(I2C_t.op==READ)
                        data_select++;
                end
                else if(data_select>0)begin
                    //$cast(I2C_t,ncsu_object_factory::create(i2c_trans_name));
                    read_alt_data=new[1];
                    read_alt_data[0] = data;
                    I2C_t.read_data = read_alt_data;
                    agentI2C.bl_put(I2C_t);
                    if(I2C_t.op==READ)
                        begin
                            data_select++;
                            data--;
                        end
                end


                //$display({get_full_name()," ",I2C_t[i].convert2string()});
            end
    endtask

    /***********************************  UTILITY FUNCTIONS ***********************************/
    task setup();
        foreach (wb_setup[i]) begin
            $cast(wb_setup[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end

        wb_setup[0].addr=2'b00;wb_setup[0].data=8'b11xxxxxx;wb_setup[0].ifIRQ=0;wb_setup[0].op_RorW=1;agentWB.bl_put(wb_setup[0]);
        wb_setup[1].addr=2'b01;wb_setup[1].data=8'bxxxxxx01;wb_setup[1].ifIRQ=0;wb_setup[1].op_RorW=1;agentWB.bl_put(wb_setup[1]);
        wb_setup[2].addr=2'b10;wb_setup[2].data=8'bxxxxx110;wb_setup[2].ifIRQ=0;wb_setup[2].op_RorW=1;agentWB.bl_put(wb_setup[2]);
        wb_setup[3].addr=2'b00;wb_setup[3].data=8'bxxxxxx00;wb_setup[3].ifIRQ=1;agentWB.bl_put(wb_setup[3]);
        wb_setup[4].addr=2'b10;wb_setup[4].data=8'bxxxxxxxx;wb_setup[4].ifIRQ=0;wb_setup[4].op_RorW=0;agentWB.bl_put(wb_setup[4]);
    endtask : setup

    task start();
        foreach (wb_start[i]) begin
            $cast(wb_start[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_start[0].addr=2'b10;wb_start[0].data=8'bxxxxx100;wb_start[0].ifIRQ=0;wb_start[0].op_RorW=1;agentWB.bl_put(wb_start[0]);
        wb_start[1].addr=2'b00;wb_start[1].data=8'bxxxxxx00;wb_start[1].ifIRQ=1;agentWB.bl_put(wb_start[1]);
        wb_start[2].addr=2'b10;wb_start[2].data=8'bxxxxxxxx;wb_start[2].ifIRQ=0;wb_start[2].op_RorW=0;agentWB.bl_put(wb_start[2]);
    endtask : start

//START
    task address_calculation();
        foreach (wb_address[i]) begin
            $cast(wb_address[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_address[0].addr=2'b01;wb_address[0].data=8'h00000044;wb_address[0].ifIRQ=0;wb_address[0].op_RorW=1;agentWB.bl_put(wb_address[0]);
        wb_address[1].addr=2'b10;wb_address[1].data=8'bxxxxx001;wb_address[1].ifIRQ=0;wb_address[1].op_RorW=1;agentWB.bl_put(wb_address[1]);
        wb_address[2].addr=2'b00;wb_address[2].data=8'bxxxxxx00;wb_address[2].ifIRQ=1;agentWB.bl_put(wb_address[2]);
        wb_address[3].addr=2'b10;wb_address[3].data=8'bxxxxxxxx;wb_address[3].ifIRQ=0;wb_address[3].op_RorW=0;agentWB.bl_put(wb_address[3]);
    endtask : address_calculation

    task address_calculation_read();
        foreach (wb_address_read[i]) begin
            $cast(wb_address_read[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_address_read[0].addr=2'b01;wb_address_read[0].data=8'h00000045;wb_address_read[0].ifIRQ=0;wb_address_read[0].op_RorW=1;agentWB.bl_put(wb_address_read[0]);
        wb_address_read[1].addr=2'b10;wb_address_read[1].data=8'bxxxxx001;wb_address_read[1].ifIRQ=0;wb_address_read[1].op_RorW=1;agentWB.bl_put(wb_address_read[1]);
        wb_address_read[2].addr=2'b00;wb_address_read[2].data=8'bxxxxxx00;wb_address_read[2].ifIRQ=1;agentWB.bl_put(wb_address_read[2]);
        wb_address_read[3].addr=2'b10;wb_address_read[3].data=8'bxxxxxxxx;wb_address_read[3].ifIRQ=0;wb_address_read[3].op_RorW=0;agentWB.bl_put(wb_address_read[3]);
    endtask : address_calculation_read

    task write(int write_value);
        //$display("in write task");
        foreach (wb_write[i]) begin
            $cast(wb_write[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_write[0].addr=2'b01;wb_write[0].data=write_value;wb_write[0].ifIRQ=0;wb_write[0].op_RorW=1;agentWB.bl_put(wb_write[0]);
        wb_write[1].addr=2'b10;wb_write[1].data=8'bxxxxx001;wb_write[1].ifIRQ=0;wb_write[1].op_RorW=1;agentWB.bl_put(wb_write[1]);
        wb_write[2].addr=2'b00;wb_write[2].data=8'bxxxxxx00;wb_write[2].ifIRQ=1;agentWB.bl_put(wb_write[2]);
        wb_write[3].addr=2'b10;wb_write[3].data=8'bxxxxxxxx;wb_write[3].ifIRQ=0;wb_write[3].op_RorW=0;agentWB.bl_put(wb_write[3]);
    endtask : write

    task stop();
        foreach (wb_stop[i]) begin
            $cast(wb_stop[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_stop[0].addr=2'b10;wb_stop[0].data=8'bxxxxx101;wb_stop[0].ifIRQ=0;wb_stop[0].op_RorW=1;agentWB.bl_put(wb_stop[0]);
        wb_stop[1].addr=2'b00;wb_stop[1].data=8'bxxxxxx00;wb_stop[1].ifIRQ=1;agentWB.bl_put(wb_stop[1]);
        wb_stop[2].addr=2'b10;wb_stop[2].data=8'bxxxxxxxx;wb_stop[2].ifIRQ=0;wb_stop[2].op_RorW=0;agentWB.bl_put(wb_stop[2]);
    endtask : stop
//STOP

    task read_with_ack();
        foreach (wb_readWAck[i]) begin
            $cast(wb_readWAck[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_readWAck[0].addr=2'b10;wb_readWAck[0].data=8'bxxxxx010;wb_readWAck[0].ifIRQ=0;wb_readWAck[0].op_RorW=1;agentWB.bl_put(wb_readWAck[0]);
        wb_readWAck[1].addr=2'b00;wb_readWAck[1].data=8'bxxxxxx00;wb_readWAck[1].ifIRQ=1;agentWB.bl_put(wb_readWAck[1]);
        wb_readWAck[2].addr=2'b10;wb_readWAck[2].data=8'bxxxxxxxx;wb_readWAck[2].ifIRQ=0;wb_readWAck[2].op_RorW=0;agentWB.bl_put(wb_readWAck[2]);
        wb_readWAck[3].addr=2'b01;wb_readWAck[3].data=8'bxxxxxxxx;wb_readWAck[3].ifIRQ=0;wb_readWAck[3].op_RorW=0;agentWB.bl_put(wb_readWAck[3]);
    endtask : read_with_ack

    task read_with_nack();
        //$display("in read with nack");
        foreach (wb_readWNAck[i]) begin
            $cast(wb_readWNAck[i],ncsu_object_factory::create(wb_trans_name));  // Create WB transactions
        end
        wb_readWNAck[0].addr=2'b10;wb_readWNAck[0].data=8'bxxxxx011;wb_readWNAck[0].ifIRQ=0;wb_readWNAck[0].op_RorW=1;agentWB.bl_put(wb_readWNAck[0]);
        wb_readWNAck[1].addr=2'b00;wb_readWNAck[1].data=8'bxxxxxx00;wb_readWNAck[1].ifIRQ=1;agentWB.bl_put(wb_readWNAck[1]);
        wb_readWNAck[2].addr=2'b10;wb_readWNAck[2].data=8'bxxxxxxxx;wb_readWNAck[2].ifIRQ=0;wb_readWNAck[2].op_RorW=0;agentWB.bl_put(wb_readWNAck[2]);
        wb_readWNAck[3].addr=2'b01;wb_readWNAck[3].data=8'bxxxxxxxx;wb_readWNAck[3].ifIRQ=0;wb_readWNAck[3].op_RorW=0;agentWB.bl_put(wb_readWNAck[3]);
    endtask : read_with_nack

    /********************************************  END UTILITY FUCNTIONS ************************************/


    function void set_i2c_agent(ncsu_component #(i2c_transaction) agent);
        this.agentI2C = agent;
    endfunction


    function void set_wb_agent(ncsu_component #(wb_transaction) agent);
        this.agentWB = agent;
    endfunction


endclass
