// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(ncsu_component_base));

    wb_transaction wb_transaction[14];
    i2c_transaction i2c_transaction[2];

    int wb_transaction_num;
    int i2c_transaction_num;

    wb_agent wb_p0_agent;
    i2c_agent i2c_p1_agent;

    string trans_name;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        this.wb_transaction_num = 0;
        this.i2c_transaction_num = 0;
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
    endfunction

    virtual task run();
        fork
            begin
                if(this.wb_transaction_num < 14) begin

                    this.set_wb_transaction(2'b0,8'b11xxxxxx,1'b0);
                    this.set_wb_transaction(2'b01,8'h01,1'b0); //Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
                    this.set_wb_transaction(2'b10,8'bxxxxx110,1'b0,1'b1); // execute instruction and wait for interrupt
                    this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // execute instruction and wait for interrupt
                    //Start
                    this.set_wb_transaction(2'b10,8'bxxxxx100,1'b0,1'b1); // execute start instruction and wait for interrupt
                    this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
                    // Address
                    this.set_wb_transaction(2'b01,8'h44,1'b0); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
                    this.set_wb_transaction(2'b10,8'bxxxxx001,1'b0,1'b1); // execute start instruction and wait for interrupt
                    this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
                    //Data
                    this.set_wb_transaction(2'b01,8'h37,1'b0); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
                    this.set_wb_transaction(2'b10,8'bxxxxx001,1'b0,1'b1); // execute start instruction and wait for interrupt
                    this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
                    //Stop
                    this.set_wb_transaction(2'b10,8'bxxxxx101,1'b0,1'b1); // execute start instruction and wait for interrupt
                    this.set_wb_transaction(2'b10,8'bxxxxxxxx,1'b1); // Read CMDR
                end
            end

            begin
                if(this.i2c_transaction_num < 2) begin
                    this.set_i2c_transaction(8'bxxxxxxxx);
                    this.set_i2c_transaction(8'bxxxxxxxx); //Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
                end
            end

        join
    endtask

    function void set_wb_agent(wb_agent agent);
        this.wb_p0_agent = agent;
    endfunction

    function void set_i2c_agent(i2c_agent agent);
        this.i2c_p1_agent = agent;
    endfunction

    task set_wb_transaction(bit [1:0] address, bit [7:0] data, bit rw, bit intr = 1'b0);
        $cast(this.wb_transaction[this.wb_transaction_num],ncsu_object_factory::create(this.trans_name));
        this.wb_transaction[this.wb_transaction_num].address = address;
        if(data != 8'bxxxxxxxx) this.wb_transaction[this.wb_transaction_num].data = data;
        this.wb_transaction[this.wb_transaction_num].rw = rw;
        this.wb_transaction[this.wb_transaction_num].intr = intr;
        this.wb_p0_agent.bl_put(this.wb_transaction[this.wb_transaction_num]);
        $display({get_full_name()," ",this.wb_transaction[this.wb_transaction_num].convert2string()});
        $display("THIS EXECUTED %d\n", wb_transaction_num);
        this.wb_transaction_num = this.wb_transaction_num + 1;
    endtask

    task set_i2c_transaction(bit [7:0] read_data []);
        $cast(this.i2c_transaction[this.i2c_transaction_num],ncsu_object_factory::create(this.trans_name));
        if(data != 8'bxxxxxxxx) this.wb_transaction[this.i2c_transaction_num].read_data = read_data;
        this.i2c_p1_agent.bl_put(this.i2c_transaction[this.i2c_transaction_num]);
        $display({get_full_name()," ",this.i2c_transaction[this.i2c_transaction_num].convert2string()});
        $display("THIS I2C EXECUTED %d\n", i2c_transaction_num);
        this.i2c_transaction_num = this.i2c_transaction_num + 1;
    endtask

endclass

