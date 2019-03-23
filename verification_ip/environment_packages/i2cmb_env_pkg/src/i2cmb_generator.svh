// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

    wb_transaction transaction[14];
    int transaction_num;
    //wb_transaction transaction;
    ncsu_component #(T) agent;
    string trans_name;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
	this.transaction_num = 0;
        if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
            $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
            $fatal;
        end
        $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
    endfunction

    virtual task run();
//        foreach (transaction[i]) begin
//            $cast(transaction[i],ncsu_object_factory::create(trans_name));
//            assert (transaction[i].randomize());
//            agent.bl_put(transaction[i]);
//            $display({get_full_name()," ",transaction[i].convert2string()});
//        end
        if(this.transaction_num < 14) begin
	
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
	endtask

    function void set_agent(ncsu_component #(T) agent);
        this.agent = agent;
    endfunction

    task set_wb_transaction(bit [1:0] address, bit [7:0] data, bit rw, bit intr = 1'b0);
	$cast(this.transaction[this.transaction_num],ncsu_object_factory::create(this.trans_name));
        this.transaction[this.transaction_num].address = address;
        if(data != 8'bxxxxxxxx) this.transaction[this.transaction_num].data = data;
        this.transaction[this.transaction_num].rw = rw;
	this.transaction[this.transaction_num].intr = intr;
	this.agent.bl_put(this.transaction[this.transaction_num]);
        $display({get_full_name()," ",this.transaction[this.transaction_num].convert2string()});
        $display("THIS EXECUTED %d\n", transaction_num);
        this.transaction_num = this.transaction_num + 1;
    endtask

endclass

