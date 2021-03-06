class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

    ncsu_component#(.T(i2c_transaction)) scoreboard;
    i2c_transaction transport_trans;
    i2cmb_env_configuration configuration;
    i2c_transaction i2c_trans;
    typedef enum {CHECK_START,GET_ADDRESS,GET_DATA,STOP} stage_t;
    stage_t state1 = CHECK_START;
    bit nak = 0;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
     //   transport_trans = new("name1");
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void set_scoreboard(ncsu_component #(.T(i2c_transaction)) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    virtual function void nb_put(T trans);

        //$display({get_full_name()," ",trans.convert2string()});
        case(state1)
            GET_DATA : begin
                //	$display("PREDICTOR : GET_DATA --> GET_DATA");
                if(trans.address==2'b01) begin
                    //	$display("ES\LSE PREDICTOR : GET_DATA --> GET_DATA");
                    this.i2c_trans.monitor_data ={this.i2c_trans.monitor_data, trans.data};
			if(nak==1) begin
 scoreboard.nb_transport(i2c_trans, transport_trans);
		    //$display({get_full_name()," ",i2c_trans.convert2string()});
                    $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
nak=0;
state1=CHECK_START;
end
                end
                else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b011)) begin
			nak = 1;
		end		
                else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b010)) begin
			nak = 0;
		end		
                else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b101)) begin
                    //	$display("PREDICTOR : GET_DATA --> NB _TRANSPORT");
                    scoreboard.nb_transport(i2c_trans, transport_trans);
		    //$display({get_full_name()," ",i2c_trans.convert2string()});
                    $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
                    state1=CHECK_START;
                    $display("PREDICTOR : GET_DATA --> CHECK START");

                end
                else if((trans.address==2'b10) && (trans.data[2:0]==3'b100))
                    begin
                        scoreboard.nb_transport(i2c_trans, transport_trans);
			//$display({get_full_name()," ",i2c_trans.convert2string()});
                        $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
                        $display("PREDICTOR : GET_DATA --> GET_ADDRESS");
                        state1=GET_ADDRESS;
                    end
            end
            GET_ADDRESS : begin
                if(trans.address==2'b01)
                    begin
                        $display("ADDRESS %x", trans.data);
                        this.i2c_trans.monitor_op = trans.data[0];
                        this.i2c_trans.monitor_address = trans.data >> 1;

                        state1=GET_DATA;
                        //$display("PREDICTOR : GET_ADDRESS --> GET_DATA");
                    end
		else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b101)) begin
                    //	$display("PREDICTOR : GET_DATA --> NB _TRANSPORT");
                    scoreboard.nb_transport(i2c_trans, transport_trans);
		    //$display({get_full_name()," ",i2c_trans.convert2string()});
                    $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
                    state1=CHECK_START;
                    $display("PREDICTOR : GET_DATA --> CHECK START");

                end
                else if((trans.address==2'b10) && (trans.data[2:0]==3'b100))
                    begin
                        scoreboard.nb_transport(i2c_trans, transport_trans);
			//$display({get_full_name()," ",i2c_trans.convert2string()});
                        $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
                        $display("PREDICTOR : GET_DATA --> GET_ADDRESS");
                        state1=GET_ADDRESS;
                    end
                //else $display("PREDICTOR : GET_ADDRESS");
            end
            CHECK_START : begin
                if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b100)) begin
                    state1=GET_ADDRESS;
                end
            end
            default: begin
                state1 = CHECK_START;
            end
        endcase
        

    endfunction

endclass
