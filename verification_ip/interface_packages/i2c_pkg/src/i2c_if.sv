interface i2c_if       #(
    int I2C_DATA_WIDTH = 8,
    int I2C_ADDR_WIDTH = 8
      )
(// System sigals
    inout logic scl,
    inout logic sda
);

typedef enum {READ, WRITE} i2c_op_t;

// *****************************************************************************
	task automatic wait_for_i2c_transfer (
		output i2c_op_t op,
		ref bit [I2C_DATA_WIDTH-1:0] write_data []
	);
		bit [I2C_ADDR_WIDTH-1:0] addr_slave;
		bit [I2C_DATA_WIDTH-1:0] data_slave;

		wait(!(!sda && scl)); // Start Condition Check

        // Get Address and Operation
        for(int i = 0; i < I2C_ADDR_WIDTH; i++) begin
			@posedge(scl) addr_slave[i] <= sda;
		end

		if((addr_slave[I2C_ADDR_WIDTH-1] == 0)) op = READ;
		else op = WRITE;

		@posedge(scl) sda <= 0; // Send Acknowledge

		// Get Data and Operation
	//	do begin
			for(int i = 0; i < I2C_DATA_WIDTH; i++) begin
				@posedge(scl) data_slave[i] <= sda;
			end

			@posedge(scl) sda <= 0; // Send Acknowledge

			write_data = new [write_data.size() + 1][8] (write_data);
			write_data[write_data.size() - 1] <= data_slave;

	//	end while();

		$display("START");
	endtask

// *****************************************************************************
	task provide_read_data (
		input bit [I2C_DATA_WIDTH-1:0] read_data []

	);
	endtask

// *****************************************************************************
	task monitor (	
		output bit [I2C_ADDR_WIDTH-1:0] addr, 
		output i2c_op_t op,	
		output bit [I2C_DATA_WIDTH-1:0]	data[]
	);
	endtask

endinterface
