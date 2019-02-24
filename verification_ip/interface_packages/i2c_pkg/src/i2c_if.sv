interface i2c_if #(
      int ADDR_WIDTH = 7,                                
      int DATA_WIDTH = 8                                
      )
(
	input scl,
	inout sda
);

typedef enum {WRITE=1'b0, READ=1'b1} i2c_op_t;

bit start_byte_transfer=0;
bit stop_byte_transfer=0;
bit sda_o=1; // Default set to 1 to read data from master

bit [7:0] my_addr;
bit op_check;
integer size=0;
integer k,i,j;
integer r=0;

bit check_stop=0;
bit check_start=0;
bit error=0;

bit addr_rcvd;
bit data_read;
bit data_write;

bit [DATA_WIDTH-1:0] temp_read_data;
bit [DATA_WIDTH-1:0] temporary_read_data;
bit [DATA_WIDTH-1:0] temp_write_data;

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
	
		// Fetch Address for Repeated Start
		if(start_byte_transfer==1 && stop_byte_transfer==0) 
		begin
			start_byte_transfer=0; // Indicating that it is inside start
			for( i=0;i<8;i++) 
			begin
				@(posedge scl);
				my_addr[7-i]=sda;	
			end
			
			addr_rcvd=1;
			
			if (my_addr[0]==1) op=1;
			else op=0;
			
			@(negedge scl);
			sda_o=0;
	
			@(negedge scl);
			sda_o=1;		
		end

		if(op==1) return;
	
		if (start_byte_transfer==0 && stop_byte_transfer==0 && op == 0)
		begin
			size = write_data.size();
			write_data=new[size + 1](write_data);

			for(k=0;k<DATA_WIDTH;k++) 
			begin
				@(posedge scl or stop_byte_transfer or start_byte_transfer);
				if(start_byte_transfer==1 || stop_byte_transfer==1) return;
				temp_write_data[7-k]=sda;
				write_data[size][7-k]=sda;	
			end

			data_write=1;
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
	
	while(!stop_byte_transfer && !error && i<size)
	begin
		data_read=0;	
		
		// post the read 8 bits onto sda  
		for( j=0;j<8;j++)
		begin
			temp_read_data = read_data[r];
			sda_o=temp_read_data[j];
			temporary_read_data[j]=temp_read_data[j];
			@(negedge scl or error or stop_byte_transfer);
			if(error || stop_byte_transfer) return;
		end	
		r=r+1;
		
		check_stop=1;
		check_start=1;
		
		@(posedge scl);	
		sda_o = 1;
		data_read=1;

		@(negedge scl);	  // Acknowledge or Nak		
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

	if(addr_rcvd==1)
	begin
		addr=my_addr>>1;
		op = my_addr[0];
		$display("SLAVE ADDRESS: 0x%0x | OPERATION: %s",addr,(op==1) ? "READ":"WRITE");
		addr_rcvd=0;
	end
	
	if(data_write==1 || data_read==1)
  	begin   
        	size = data.size();
        	data=new[size + 1](data);
                data[size] = (op==0) ? temp_write_data : temporary_read_data;
        	$display("SLAVE ADDRESS: 0x%0x | OPERATION: %s | Data:%d", addr, (op==1) ? "READ":"WRITE" , data[size]);		
		data_write=0;
		data_read=0;
    	end
   
endtask

endinterface

