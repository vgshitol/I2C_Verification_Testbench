interface i2c_if #(
      int ADDR_WIDTH = 7,                                
      int DATA_WIDTH = 8                                
      )
(
	input scl,
	inout sda
);
//typedef enum bit {read=1'b0, write=1'b1} i2c_op_t;
bit start;
bit stop;
bit sda_o=1;
bit [7:0] my_addr;
bit op_check;
integer size=0;
integer k,i,j;
bit check_stop=0;
bit check_start=0;
bit restart = 0;
bit temp=0;
bit error=0;

bit [DATA_WIDTH-1:0] temp_read_data;


always @(posedge sda)
begin
	if (scl == 1 && check_stop==1)
	begin
		stop=1;
		start=0;
		check_stop=0;
		check_start=0;
		$display("STOP!!!!!");
	end
end


always @(negedge scl)
begin
	if (check_stop==1 && error==1)
	begin
		stop=1;
		start=0;
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
		
		start=1;
		stop=0;	
		check_start=0;
		check_stop=0;
		$display("START!!!!!");
	end
end

assign sda = sda_o?1'bz:1'b0;

/************************************************************************************************************************************************/
task wait_for_i2c_transfer
	(
	output bit op, 
	output bit [DATA_WIDTH-1:0] write_data []
	);
	
	check_start = 1;
	while(start == 0);
	
/******************************************/
while(!stop) 
begin
	while(check_stop==1 || check_start==1);
	$display("IN WHILE " );

	if(start==1 && stop==0) 
	begin
	$display("ADDRESS FETCH" );
		start=0; // Indicating that it is inside start
		for( i=0;i<8;i++) 
		begin
			@(posedge scl);
			my_addr[7-i]=sda;	
		end

		$display("ADDRESS:%h",my_addr);
			
		if (my_addr[0]==1) op=1;
		else op=0;
			
		@(negedge scl);
		sda_o=0;
	
		@(negedge scl);
		sda_o=1;
		
	end

	if(op==1) return;
	
	if (start==0 && stop==0 && op == 0)
	begin
	$display("DATA FETCH" );
		$display("in while"); 
		size = write_data.size();
		$display("size%d",size);
		write_data=new[size + 1](write_data);

		$display("after write data");
		for(k=0;k<DATA_WIDTH;k++) 
		begin
			@(posedge scl or stop or start);
			if(start==1 || stop==1) return;
			write_data[size][7-k]=sda;
			$display("WRITE BIT : %b", sda);		
		end

		$display("write_data=%h",write_data[size]);
		check_stop=1;
		check_start=1;
		@(negedge scl);
		sda_o=0;			
		@(negedge scl);
		sda_o=1;
		
	end
end		
endtask

/*****************************************************************************************************************************/
task provide_read_data( input bit [DATA_WIDTH-1:0] read_data []);

		size = read_data.size();

	while(!stop)
	begin
		$display("size%d",size);
		// every time read 8 bits of data into temp array
		for(i=0;i<size;++i)
		begin

			temp_read_data = read_data[i];
			$display("temp_read_data = %h",temp_read_data);
			
			// post the read 8 bits onto sda  
			for( j=0;j<8;j++)
			begin
				
				sda_o=temp_read_data[j];
				@(negedge scl or error or stop);
				if(error || stop) return;				
				$display("SDA ::::::%d" , sda_o);
			end
			check_stop=1;
			check_start=1;
			@(posedge scl);	
			sda_o = 1;

			@(negedge scl);	  // Acknowledge or Nak
			if(sda==1) error=1;
		end
	
		if(error) $display( "ERROR!!!!!!!!!!!!!!!!!!!!!");
		else $display( "NO ERROR");

	
	
	end

endtask

/*task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);
	addr=my_addr[6:0];
	op=my_addr[7];
	//if(my_sda[7]==1)
		//data=//read data
		
	//else
		//data=write_data;
end task*/
endinterface
