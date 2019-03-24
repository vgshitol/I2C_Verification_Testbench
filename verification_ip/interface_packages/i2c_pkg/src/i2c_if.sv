`timescale 1ns / 10ps

interface i2c_if #(
      int ADDR_WIDTH = 7,                                
      int DATA_WIDTH = 8                                
      )
(
	input scl,
	inout sda
);

// Start and Stop Detection Variables
bit start_byte_transfer=0;
bit stop_byte_transfer=0;
bit check_stop=0;
bit check_start=0;

/**SDA_O = 1 High Impedance; 0 pulls it down to start writing data to master**/
bit sda_o=1; 
bit [ADDR_WIDTH-1:0] slave_addr;
bit rw;

integer size=0;

integer bit_count;
integer read_byte=0;

bit error=0;

/**Variables Required for Monitoring**/
bit addr_rcvd;
bit is_read_monitor;
bit is_write_monitor;
bit [DATA_WIDTH-1:0] monitor_read_data;
bit [DATA_WIDTH-1:0] monitor_write_data;

always @(posedge sda )
begin
	if (scl == 1 && check_stop==1)
	begin
		stop_byte_transfer=1;
		start_byte_transfer=0;
		check_stop=0;
		check_start=0;
		$display("STOP!!!!!");
	end
end

always @(negedge sda)
begin
	if (scl == 1 && (check_start==1 || check_stop==1))
	begin
		if(check_stop==1) $display("RESTART!!!!!");
		else $display("START!!!!!");
	
		start_byte_transfer=1;
		stop_byte_transfer=0;	
		error=0;
		check_start=0;
		check_stop=0;
	end
end

assign sda = sda_o?1'bz:1'b0;

/*************************************************WAIT FOR I2C TRANSFER***********************************************************************************************/
task wait_for_i2c_transfer
	(
		output bit op, 
		output bit [DATA_WIDTH-1:0] write_data []
	);
	
	// Check Start Logic 
	check_start = 1;
	while(start_byte_transfer == 0); // Wait till Start Instruction is not received from Master
	
	// Loop for continuous transfer of data is not stopped or error is not shown ( NACK - by master) 
	while(!stop_byte_transfer && !error) 
	begin
		while(check_stop==1 || check_start==1); // Wait to check if the next instruction is a repeated start/ stop / Data
	
$display("I2C_TRANSACTION check Start done ");
		// Fetch Address for Repeated Start
		if(start_byte_transfer==1 && stop_byte_transfer==0) 
		begin
			start_byte_transfer=0; // Indicating that it is inside start
			for( bit_count=0;bit_count<ADDR_WIDTH;bit_count++) 
			begin
				@(posedge scl);
				slave_addr[ADDR_WIDTH-1-bit_count]=sda;	
			end

$display("I2C_TRANSACTION get address ");
			@(posedge scl);
			op=sda;
			rw =op;
			
			addr_rcvd=1;
					
			@(negedge scl);
			sda_o=0;
	
			@(negedge scl);
			sda_o=1;		
		end

$display("try once get address ");

		if(op==1) return;
	
		if (start_byte_transfer==0 && stop_byte_transfer==0 && op == 0)
		begin
			size = write_data.size();
			write_data=new[size + 1](write_data);

			for(bit_count=0;bit_count<DATA_WIDTH;bit_count++) 
			begin
				@(posedge scl or stop_byte_transfer or start_byte_transfer);
				if(start_byte_transfer==1 || stop_byte_transfer==1) return;
				write_data[size][7-bit_count]=sda;	
			end
			
			monitor_write_data=write_data[size]; 
			is_write_monitor=1;

			check_stop=1;
			check_start=1;
	
			@(negedge scl);
			sda_o=0;				

			@(negedge scl);
			sda_o=1;		
		end
	end		
endtask

/**************************************************PROVIDE_READ_DATA**************************************************************************************************/
task provide_read_data
	( 
		input bit [DATA_WIDTH-1:0] read_data []
	);

	size = read_data.size();
	
	while(!stop_byte_transfer && !error && read_byte<size)
	begin
		is_read_monitor=0;	
		monitor_read_data = read_data[read_byte];
		// post the read 8 bits onto sda  
		for( bit_count=0;bit_count<8;bit_count++)
		begin
			
			sda_o=monitor_read_data[bit_count];
			@(negedge scl or error or stop_byte_transfer);
			if(error || stop_byte_transfer) return;
		end	
		read_byte++;
		
		check_stop=1;
		check_start=1;
		
		@(posedge scl);	 // Allow master to Send Ack or Nack
		sda_o = 1;
		is_read_monitor=1;

		@(negedge scl);	  // Receive Ack or Nack		
		if(sda==1) error=1;
			
		if(error) $display( "READ WTIH NACK ");
		else $display( "READ WITH ACK");
	end

endtask

/**************************************************MONITOR************************************************************************************************************/
task monitor 
	( 
		output bit [ADDR_WIDTH-1:0] addr, 
		output bit op, 
		output bit [DATA_WIDTH-1:0] data []
	);
	
	while(!(addr_rcvd==1 || is_write_monitor==1 || is_read_monitor==1 )) begin #1; 	end 
 
	if(addr_rcvd==1)
	begin
		addr=slave_addr;
		op = rw;
		$display("SLAVE ADDRESS: 0x%0x | OPERATION: %s",addr,(op==1) ? "READ":"WRITE");
		addr_rcvd=0;
	end
	
	if(is_write_monitor==1 || is_read_monitor==1)
  	begin   
        	size = data.size();
        	data=new[size + 1](data);
                data[size] = (op==0) ? monitor_write_data : monitor_read_data;
        	$display("SLAVE ADDRESS: 0x%0x | OPERATION: %s | Data:%d", addr, (op==1) ? "READ":"WRITE" , data[size]);
		is_write_monitor=0;
		is_read_monitor=0;
    	end
	
   
endtask

endinterface

