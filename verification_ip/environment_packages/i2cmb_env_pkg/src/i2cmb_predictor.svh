class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

    ncsu_component#(.T(i2c_transaction)) scoreboard;
    i2c_transaction transport_trans;
    i2cmb_env_configuration configuration;
    typedef enum {CHECK_START,GET_ADDRESS,GET_DATA,STOP} stage_t;
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
        i2c_transaction i2c_trans;

        $display({get_full_name()," ",trans.convert2string()});
        case(state1)
            GET_DATA : begin
                if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b101)) begin
                    scoreboard.nb_transport(i2c_trans, transport_trans);
                    state1=CHECK_START;
                end
                else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b100)) state1=GET_ADDRESS;
                else begin
                    i2c_trans.monitor_data = { i2c_trans.monitor_data, trans.data};
                end
            end
            GET_ADDRESS : begin
                    i2c_trans.monitor_address = trans.data[7:1];
                    state1=GET_DATA;

            end
            CHECK_START : begin
                if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b100)) state1=GET_ADDRESS;
            end
            STOP : begin


            end
            default: begin

            end
        endcase

    endfunction

endclass
