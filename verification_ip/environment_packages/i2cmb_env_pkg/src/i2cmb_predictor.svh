class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

    ncsu_component#(.T(i2c_transaction)) scoreboard;
    i2c_transaction transport_trans;
    i2cmb_env_configuration configuration;
    typedef enum {CHECK_START,PREDICT_DATA,STOP} stage_t;
    stage_t state1 = CHECK_START;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void set_scoreboard(ncsu_component #(.T(i2c_transaction)) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    virtual function void nb_put(T trans);
        $display({get_full_name()," ",trans.convert2string()});	
	case(state1)
		CHECK_START: begin
			
		end
		PREDICT_DATA : begin
			
		end
		STOP : begin
			
		end
		default: begin
			
		end
	endcase
//        scoreboard.nb_transport(trans, transport_trans);
    endfunction

endclass
