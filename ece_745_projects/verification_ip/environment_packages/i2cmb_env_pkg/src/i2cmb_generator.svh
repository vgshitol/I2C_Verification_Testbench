
class i2cmb_generator extends ncsu_component#(.T(i2c_transaction));



    ncsu_component #(wb_transaction) wb_p0_agent;
    ncsu_component #(i2c_transaction) i2c_p1_agent;
    string wb_trans_name;
    string i2c_trans_name = "i2c_transaction";

    i2c_transaction I2C_t;

    bit [7:0] read_data_i2c[32];bit [7:0] read_alt_data[];
    static int data_select;bit alt;
    int data=63;

    wb_transaction wb_init[5];
    wb_transaction wb_start[3];
    wb_transaction wb_address[4];
    wb_transaction wb_write[4];
    wb_transaction wb_stop[3];
    wb_transaction wb_read_with_ack[4];
    wb_transaction wb_read_with_nak[4];
    wb_transaction wb_read_addr[4];

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
                else if(data_select>0)begin
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
   
    
    task initialise_core(); // setting up the core of i2cmb
        foreach (wb_init[i]) begin
            $cast(wb_init[i],ncsu_object_factory::create(wb_trans_name)); 
        end

        wb_init[0].addr=2'b00;
	wb_init[0].data=8'b11xxxxxx;
	wb_init[0].irq_c=0;
	wb_init[0].type_op=1;
	wb_p0_agent.bl_put(wb_init[0]);
        wb_init[1].addr=2'b01;
	wb_init[1].data=8'bxxxxxx01;
	wb_init[1].irq_c=0;
	wb_init[1].type_op=1;
	wb_p0_agent.bl_put(wb_init[1]);
        wb_init[2].addr=2'b10;
	wb_init[2].data=8'bxxxxx110;
	wb_init[2].irq_c=0;
	wb_init[2].type_op=1;
	wb_p0_agent.bl_put(wb_init[2]);
        wb_init[3].addr=2'b00;
	wb_init[3].data=8'bxxxxxx00;
	wb_init[3].irq_c=1;
	wb_p0_agent.bl_put(wb_init[3]);
        wb_init[4].addr=2'b10;
	wb_init[4].data=8'bxxxxxxxx;
	wb_init[4].irq_c=0;
	wb_init[4].type_op=0;
	wb_p0_agent.bl_put(wb_init[4]);
    endtask

    task start(); // start the i2c 
        foreach (wb_start[i]) begin
            $cast(wb_start[i],ncsu_object_factory::create(wb_trans_name));  
        end
        wb_start[0].addr=2'b10;
	wb_start[0].data=8'bxxxxx100;
	wb_start[0].irq_c=0;
	wb_start[0].type_op=1;
	wb_p0_agent.bl_put(wb_start[0]);
        wb_start[1].addr=2'b00;
	wb_start[1].data=8'bxxxxxx00;
	wb_start[1].irq_c=1;
	wb_p0_agent.bl_put(wb_start[1]);
        wb_start[2].addr=2'b10;
	wb_start[2].data=8'bxxxxxxxx;
	wb_start[2].irq_c=0;
	wb_start[2].type_op=0;
	wb_p0_agent.bl_put(wb_start[2]);
    endtask 

    task address_calculation(); // specify the address of i2c slave
        foreach (wb_address[i]) begin
            $cast(wb_address[i],ncsu_object_factory::create(wb_trans_name));  
        end
        wb_address[0].addr=2'b01;
	wb_address[0].data=8'h00000044;
	wb_address[0].irq_c=0;
	wb_address[0].type_op=1;
	wb_p0_agent.bl_put(wb_address[0]);
        wb_address[1].addr=2'b10;
	wb_address[1].data=8'bxxxxx001;
	wb_address[1].irq_c=0;
	wb_address[1].type_op=1;
	wb_p0_agent.bl_put(wb_address[1]);
        wb_address[2].addr=2'b00;
	wb_address[2].data=8'bxxxxxx00;
	wb_address[2].irq_c=1;
	wb_p0_agent.bl_put(wb_address[2]);
        wb_address[3].addr=2'b10;
	wb_address[3].data=8'bxxxxxxxx;
	wb_address[3].irq_c=0;
	wb_address[3].type_op=0;
	wb_p0_agent.bl_put(wb_address[3]);
    endtask

    task address_calculation_read(); // specify read address of i2c slave 
        foreach (wb_read_addr[i]) begin
            $cast(wb_read_addr[i],ncsu_object_factory::create(wb_trans_name));  
        end
        wb_read_addr[0].addr=2'b01;
	wb_read_addr[0].data=8'h00000045;
	wb_read_addr[0].irq_c=0;
	wb_read_addr[0].type_op=1;
	wb_p0_agent.bl_put(wb_read_addr[0]);
        wb_read_addr[1].addr=2'b10;
	wb_read_addr[1].data=8'bxxxxx001;
	wb_read_addr[1].irq_c=0;
	wb_read_addr[1].type_op=1;
	wb_p0_agent.bl_put(wb_read_addr[1]);
        wb_read_addr[2].addr=2'b00;
	wb_read_addr[2].data=8'bxxxxxx00;
	wb_read_addr[2].irq_c=1;
	wb_p0_agent.bl_put(wb_read_addr[2]);
        wb_read_addr[3].addr=2'b10;
	wb_read_addr[3].data=8'bxxxxxxxx;
	wb_read_addr[3].irq_c=0;
	wb_read_addr[3].type_op=0;
	wb_p0_agent.bl_put(wb_read_addr[3]);
    endtask

    task read_with_ack(); // read with acknowledgement
        foreach (wb_read_with_ack[i]) begin
            $cast(wb_read_with_ack[i],ncsu_object_factory::create(wb_trans_name)); 
        end
        wb_read_with_ack[0].addr=2'b10;wb_read_with_ack[0].data=8'bxxxxx010;
	wb_read_with_ack[0].irq_c=0;wb_read_with_ack[0].type_op=1;wb_p0_agent.bl_put(wb_read_with_ack[0]);
        wb_read_with_ack[1].addr=2'b00;wb_read_with_ack[1].data=8'bxxxxxx00;
	wb_read_with_ack[1].irq_c=1;wb_p0_agent.bl_put(wb_read_with_ack[1]);
        wb_read_with_ack[2].addr=2'b10;wb_read_with_ack[2].data=8'bxxxxxxxx;
	wb_read_with_ack[2].irq_c=0;wb_read_with_ack[2].type_op=0;wb_p0_agent.bl_put(wb_read_with_ack[2]);
        wb_read_with_ack[3].addr=2'b01;wb_read_with_ack[3].data=8'bxxxxxxxx;
	wb_read_with_ack[3].irq_c=0;wb_read_with_ack[3].type_op=0;wb_p0_agent.bl_put(wb_read_with_ack[3]);
    endtask

    task read_with_nack(); // read with NAK

        foreach (wb_read_with_nak[i]) begin
            $cast(wb_read_with_nak[i],ncsu_object_factory::create(wb_trans_name)); 
        end
        wb_read_with_nak[0].addr=2'b10;wb_read_with_nak[0].data=8'bxxxxx011;
	wb_read_with_nak[0].irq_c=0;wb_read_with_nak[0].type_op=1;wb_p0_agent.bl_put(wb_read_with_nak[0]);
        wb_read_with_nak[1].addr=2'b00;wb_read_with_nak[1].data=8'bxxxxxx00;
	wb_read_with_nak[1].irq_c=1;wb_p0_agent.bl_put(wb_read_with_nak[1]);
        wb_read_with_nak[2].addr=2'b10;wb_read_with_nak[2].data=8'bxxxxxxxx;
	wb_read_with_nak[2].irq_c=0;wb_read_with_nak[2].type_op=0;wb_p0_agent.bl_put(wb_read_with_nak[2]);
        wb_read_with_nak[3].addr=2'b01;wb_read_with_nak[3].data=8'bxxxxxxxx;
	wb_read_with_nak[3].irq_c=0;wb_read_with_nak[3].type_op=0;wb_p0_agent.bl_put(wb_read_with_nak[3]);
    endtask

    task write(int write_value); // write to i2c 

        foreach (wb_write[i]) begin
            $cast(wb_write[i],ncsu_object_factory::create(wb_trans_name));  
        end
        wb_write[0].addr=2'b01;wb_write[0].data=write_value;
	wb_write[0].irq_c=0;wb_write[0].type_op=1;
	wb_p0_agent.bl_put(wb_write[0]);
	
	wb_write[1].addr=2'b10;
	wb_write[1].data=8'bxxxxx001;wb_write[1].irq_c=0;
	wb_write[1].type_op=1;wb_p0_agent.bl_put(wb_write[1]);
        
	wb_write[2].addr=2'b00;wb_write[2].data=8'bxxxxxx00;
	wb_write[2].irq_c=1;wb_p0_agent.bl_put(wb_write[2]);
        
	wb_write[3].addr=2'b10;	wb_write[3].data=8'bxxxxxxxx;
	wb_write[3].irq_c=0;wb_write[3].type_op=0;
	wb_p0_agent.bl_put(wb_write[3]);
    endtask

    task stop(); // stop the i2c
        foreach (wb_stop[i]) begin
            $cast(wb_stop[i],ncsu_object_factory::create(wb_trans_name));  
        end
        
	wb_stop[0].addr=2'b10;wb_stop[0].data=8'bxxxxx101;
	wb_stop[0].irq_c=0;wb_stop[0].type_op=1;
	wb_p0_agent.bl_put(wb_stop[0]);

        wb_stop[1].addr=2'b00;wb_stop[1].data=8'bxxxxxx00;
	wb_stop[1].irq_c=1;wb_p0_agent.bl_put(wb_stop[1]);

        wb_stop[2].addr=2'b10;wb_stop[2].data=8'bxxxxxxxx;
	wb_stop[2].irq_c=0;wb_stop[2].type_op=0;
	wb_p0_agent.bl_put(wb_stop[2]);
    endtask

    function void set_i2c_agent(ncsu_component #(i2c_transaction) agent);
        this.i2c_p1_agent = agent;
    endfunction

    function void set_wb_agent(ncsu_component #(wb_transaction) agent);
        this.wb_p0_agent = agent;
    endfunction


endclass

