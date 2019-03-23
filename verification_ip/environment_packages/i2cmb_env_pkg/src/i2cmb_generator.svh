// class generator #(type GEN_TRANS)  extends ncsu_component#(.T(abc_transaction_base));
class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

    wb_transaction transaction[10];
    int transaction_count = 0;
    //wb_transaction transaction;
    ncsu_component #(T) agent;
    string trans_name;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
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
        $cast(transaction[0],ncsu_object_factory::create(trans_name));
        this.set_wb_transaction(2'b0,8'b11xxxxxx,1'b0);
        agent.bl_put(transaction[transaction_count-1]);
        $display({get_full_name()," ",transaction[transaction_count-1].convert2string()});
        this.set_wb_transaction(2'b01,8'h01,1'b0); //Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
        agent.bl_put(transaction[transaction_count-1]);
        $display({get_full_name()," ",transaction[transaction_count-1].convert2string()});
        this.set_wb_transaction(2'b10,8'bxxxxx110,1'b0,1'b1); // execute instruction and wait for interrupt
        agent.bl_put(transaction[transaction_count-1]);
        $display({get_full_name()," ",transaction[transaction_count-1].convert2string()});
    endtask

    function void set_agent(ncsu_component #(T) agent);
        this.agent = agent;
    endfunction

    function void set_wb_transaction(bit [1:0] address, bit [7:0] data, bit rw, bit intr = 1'b0);
	this.transaction[transaction_count].address = address;
        this.transaction[transaction_count].data = data;
        this.transaction[transaction_count].rw = rw;
	this.transaction[transaction_count].intr = intr;
	this.transaction_count++;
    endfunction

endclass

/*
	wb_bus.master_write(2'b0,8'b11xxxxxx); //
	wb_bus.master_write(2'b01,8'h01);	//Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
	wb_bus.master_write(2'b10,8'bxxxxx110); //Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	while(irq == 1'b0);	//Wait for interrupt or until DON bit of CMDR reads '1'.
	wb_bus.master_read(2'b10,data);	

//start
	wb_bus.master_write(2'b10,8'bxxxxx100); //Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10,data);
	
// Address
	wb_bus.master_write(2'b01,8'h44); //Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10,8'bxxxxx001); //Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); //Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10,data);
	
//Data
	for(byte i = 0; i < 32; i++) begin
		wb_bus.master_write(2'b01,i); //Write byte 0x78 to the DPR. This is the byte to be written.
		wb_bus.master_write(2'b10,8'bxxxxx001);//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10,data);
	end

//stop
	wb_bus.master_write(2'b10,8'bxxxxx101);//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10,data);
		*/
