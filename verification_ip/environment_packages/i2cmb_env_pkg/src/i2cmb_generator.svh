// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(ncsu_component_base));

    wb_transaction wb_transaction;
    i2c_transaction i2c_tr;

    int wb_transaction_num;
    int i2c_tr_num;

    wb_agent wb_p0_agent;
    i2c_agent i2c_p1_agent;

    string trans_name;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        this.wb_transaction_num = 0;
        this.i2c_tr_num = 0;
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
    endfunction

    virtual task run();
        fork
            begin
  	 $cast(this.wb_transaction,ncsu_object_factory::create(this.trans_name));
     
 // Write 
                    this.initialise();
                    //Start
                    this.start_transfer();
                    // Address
                    this.slave_address(8'h44);
                    //Write Data
                    for(byte i = 0; i < 32; i++) begin
                        this.slave_data_transfer(i, 0);
                    end
                    //Stop
                    this.stop_transfer();

//Read
                    //Start
                    this.start_transfer();
                    // Address
                    this.slave_address(8'h45);
                    //Read Data
                    for(byte i = 0; i < 32; i++) begin
                         if(i<31) this.slave_data_transfer(i, 1);
                         else this.slave_data_transfer(i, 1, 1);
                    end

//Alternate Read and Write
                    for(byte i = 0; i < 32; i++) begin
                        //Start
                        this.start_transfer();
                        // Address
                        this.slave_address(8'h88);
                        //Read Data
                        this.slave_data_transfer(i, 0);
                        //Start
                        this.start_transfer();
                        // Address
                        this.slave_address(8'h89);
                        //Read Data
                        this.slave_data_transfer(i,1,1);
                    end

                    //Stop
                    this.stop_transfer();

                end
            

            begin
                forever begin
                    this.set_i2c_transaction();
                end
            end

        join_none
    endtask

    task initialise();
        this.set_wb_transaction(2'b0,8'b11xxxxxx,1'b0);
        this.set_wb_transaction(2'b01,8'h01,1'b0); //Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
        this.set_wb_transaction(2'b10,8'bxxxxx110,1'b0,1'b1); // execute instruction and wait for interrupt
        this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // execute instruction and wait for interrupt
    endtask

    task start_transfer();
        this.set_wb_transaction(2'b10,8'bxxxxx100,1'b0,1'b1); // execute start instruction and wait for interrupt
        this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
    endtask

    task slave_address(bit [7:0] address);
        this.set_wb_transaction(2'b01,address,1'b0); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0',
        this.set_wb_transaction(2'b10,8'bxxxxx001,1'b0,1'b1); // execute start instruction and wait for interrupt
        this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
    endtask

    task slave_data_transfer(bit [7:0] data, bit op=1'b0, bit r_nak = 1'b0);
        byte read_cmd = 8'bxxxxx010; // Read with ack

        if(r_nak==1'b1) read_cmd = 8'bxxxxx011;

        if(op==0) begin
            this.set_wb_transaction(2'b01,data, 1'b0); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0',
            this.set_wb_transaction(2'b10,8'bxxxxx001,1'b0,1'b1); // execute s instruction and wait for interrupt
            this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
        end
        else if(op==1) begin
            this.set_wb_transaction(2'b10,read_cmd,1'b0,1'b1);
            this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1);
            this.set_wb_transaction(2'b01,8'bxxxxxxxx,1'b1);
        end
    endtask

    task stop_transfer();
        this.set_wb_transaction(2'b10,8'bxxxxx101,1'b0,1'b1); // execute stop instruction and wait for interrupt
        this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
    endtask

    function void set_wb_agent(wb_agent agent);
        this.wb_p0_agent = agent;
    endfunction

    function void set_i2c_agent(i2c_agent agent);
        this.i2c_p1_agent = agent;
    endfunction

    task set_wb_transaction(bit [1:0] address, bit [7:0] data, bit rw, bit intr = 1'b0);
        this.wb_transaction.address = address;
        this.wb_transaction.data = data;
        this.wb_transaction.rw = rw;
        this.wb_transaction.intr = intr;
        this.wb_p0_agent.bl_put(this.wb_transaction);
        //  $display({get_full_name()," ",this.wb_transaction[this.wb_transaction_num].convert2string()});
        $display("THIS WB EXECUTED %d", wb_transaction_num);
        this.wb_transaction_num = this.wb_transaction_num + 1;
    endtask

    task set_i2c_transaction();
        $cast(this.i2c_tr,ncsu_object_factory::create("i2c_transaction"));
        //this.i2c_tr.read_data = {8'hxx};
        this.i2c_p1_agent.bl_put(this.i2c_tr);
        //    $display({get_full_name()," ",this.i2c_tr.convert2string()});
        $display("THIS I2C EXECUTED %d", i2c_tr_num);
        this.i2c_tr_num = this.i2c_tr_num + 1;
    endtask

endclass

