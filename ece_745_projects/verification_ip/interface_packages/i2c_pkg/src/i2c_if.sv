interface i2c_if  #( int I2C_ADDR_WIDTH = 7,
	int I2C_DATA_WIDTH = 8
)
	(
		input tri scl_i2c,
		inout tri sda_i2c
	);

	// enum declarations here
	import i2c_pkg::*;
	bit sda_o = 1'b1;
	assign sda_i2c = sda_o? 'bz:'b0;



	bit start_flag;
	bit stop_flag;
	bit repeated_start_flag;

// ****************************************************************************
	task wait_for_i2c_transfer ( output i2c_op_t op,
		output bit [I2C_DATA_WIDTH-1:0] write_data []
	);

		bit [I2C_ADDR_WIDTH-1:0] adr;
		bit [I2C_DATA_WIDTH-1:0] dat;
		integer address_length;
		integer data_length;

		address_length = I2C_ADDR_WIDTH-1;
		data_length = I2C_DATA_WIDTH-1;

		if(!repeated_start_flag)
			begin
				do
				begin
					@(negedge sda_i2c);
				end
				while(!scl_i2c);
			end

		repeated_start_flag = 0;

		repeat(I2C_ADDR_WIDTH)
			begin
				@(posedge scl_i2c)
				begin
				adr[address_length] = sda_i2c;
					address_length--;
				end
			end

		@(posedge scl_i2c)
			begin
			op = sda_i2c ? READ : WRITE;
			end

		@(negedge scl_i2c)
			begin
			sda_o = 1'b0;
			end

		if(op == WRITE)
			begin
			forever
			begin
				@ (negedge scl_i2c);
				sda_o = 'b1;
				@(posedge scl_i2c);
				@(sda_i2c or negedge scl_i2c);
				if(!scl_i2c)
				begin
					dat = {dat, sda_i2c};
					for( int k=I2C_DATA_WIDTH-2;k>=0;k--)
					begin
						@(posedge scl_i2c);
						dat = {dat, sda_i2c};
						end

						write_data = {write_data, dat};
						@( negedge scl_i2c);
						sda_o = 1'b0;
						end

						else if (sda_i2c)
						begin
						stop_flag = 'b1;
						return;
						end
						else if  (!sda_i2c)                          
						begin
						repeated_start_flag = 'b1;
						return;
						end
					end
			end

	endtask


	task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data []
	);

		int i;
		int read_data_size;
		int count;
		read_data_size = read_data.size();
		i=0;count=0;
		forever
			begin
				@(posedge scl_i2c);
				@(sda_i2c or negedge scl_i2c);

				if(!scl_i2c)
				begin
					sda_o = read_data [i] [7];
					for(int j=I2C_DATA_WIDTH-2; j>=0;j--)
						begin
							@(negedge scl_i2c);
							sda_o = read_data [i] [j];
						end
						i++;

						if(i<read_data_size)
							begin
								@(negedge scl_i2c);
								sda_o =0;
							end
						else
							begin
							@(negedge scl_i2c);
							sda_o =1;
							@(posedge scl_i2c);
							end
					end

				else if (sda_i2c)
					begin
						stop_flag = 'b1;
						return;
					end

				else if  (!sda_i2c)               
					begin
						repeated_start_flag = 'b1;
						return;
					end
			end

	endtask


	task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr,
		output i2c_op_t op,
		output bit [I2C_DATA_WIDTH-1:0] data []
	);

		bit [I2C_DATA_WIDTH-1:0] dat;
		integer address_length;
		integer data_length;

		int i;
		int read_data_size;
		int count;

		address_length = I2C_ADDR_WIDTH-1;
		data_length = I2C_DATA_WIDTH-1;
		i=0;
		read_data_size = 2;


		//wait for start_flag
		if(!repeated_start_flag)
			begin
				do
					begin
						@(negedge sda_i2c);
					end
				while(!scl_i2c);
			end

		repeated_start_flag = 0;
		data.delete();

		// $display("*** START detected in monitor_task ***\n");
		repeat(I2C_ADDR_WIDTH)
			begin
				@(posedge scl_i2c)
					begin
						addr[address_length] = sda_i2c;
						address_length--;
					end
			end

		@ (posedge scl_i2c)
			begin
				op = sda_i2c ? READ : WRITE;
			end

		@ (negedge scl_i2c)
			begin

			end

		if(op == WRITE)
			begin
				forever
					begin
						@ (negedge scl_i2c);

						@(posedge scl_i2c);
						@(sda_i2c or negedge scl_i2c);

						if(!scl_i2c)
							begin
								dat = {dat, sda_i2c};
								for( int k=I2C_DATA_WIDTH-2;k>=0;k--)
									begin
										@(posedge scl_i2c);
										dat = {dat, sda_i2c};
									end

								data = {data, dat};
								//$display("*** WRITE DATA HERE(monitor_task):%p ***\n ", data);

								@ (negedge scl_i2c);

							end

						else if (sda_i2c)
							begin
								//$display ("*** STOP detected ***");
								stop_flag = 'b1;
								return;
							end
						else if  (!sda_i2c)
							begin
								//$display ("*** R_START detected***");
								repeated_start_flag = 'b1;
								return;
							end
					end

			end

		else if(op == READ)
			begin
				forever
					begin
						@ (negedge scl_i2c);

						@(posedge scl_i2c);
						@(sda_i2c or negedge scl_i2c);

						if(!scl_i2c)
							begin
								dat = {dat, sda_i2c};
								for( int k=I2C_DATA_WIDTH-2;k>=0;k--)
									begin
										@(posedge scl_i2c);
										dat = {dat, sda_i2c};
									end

								data = {data, dat};

								@ (negedge scl_i2c);


							end

						else if (sda_i2c)
							begin
								//$display ("*** STOP detected*****");
								stop_flag = 'b1;
								return;
							end

						else if  (!sda_i2c)
							begin
								//$display ("*** R_START detected ***\n");
								repeated_start_flag = 'b1;
								return;
							end
					end

			end

	endtask

endinterface
