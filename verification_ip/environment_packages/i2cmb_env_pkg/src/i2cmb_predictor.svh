class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

    ncsu_component#(.T(i2c_transaction)) scoreboard;
    i2c_transaction transport_trans;
    i2cmb_env_configuration configuration;
    i2c_transaction i2c_trans;
    typedef enum {CHECK_START,GET_ADDRESS,GET_DATA,STOP} stage_t;
    stage_t state1 = CHECK_START;

    static bit start_detected,stop_detected,address_calculated,repeated_start;
    bit r_start_check;

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        this.i2c_trans = new("name");
        transport_trans = new("name1");
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void set_scoreboard(ncsu_component #(.T(i2c_transaction)) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    virtual function void nb_put(T trans);

        //$display({get_full_name()," ",trans.convert2string()});
     /*   case(state1)
            GET_DATA : begin
                //	$display("PREDICTOR : GET_DATA --> GET_DATA");
                if(trans.address==2'b01) begin
                    //	$display("ES\LSE PREDICTOR : GET_DATA --> GET_DATA");
                    this.i2c_trans.monitor_data ={this.i2c_trans.monitor_data, trans.data};
                end
                else if((trans.address== 2'b10 ) && (trans.data[2:0]==3'b101)) begin
                    //	$display("PREDICTOR : GET_DATA --> NB _TRANSPORT");
                    scoreboard.nb_transport(i2c_trans, transport_trans);
                    $cast(this.i2c_trans,ncsu_object_factory::create("i2c_transaction"));
                    state1=CHECK_START;
                    $display("PREDICTOR : GET_DATA --> CHECK START");

                end
                else if((trans.address==2'b10) && (trans.data[2:0]==3'b100))
                    begin
                        scoreboard.nb_transport(i2c_trans, transport_trans);
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
        */

        /******************************** Detect Start or repeated start******************************/
        if(trans.addr==2'b10 && trans.data==8'b100)
            begin
                if(r_start_check==1)
                    repeated_start=1;
                else
                    start_detected=1;
                stop_detected=0;
                address_calculated=0;
                //$display("**********Predictor START*********");
            end

        /******************************** Detect Stop******************************/
        if(trans.addr==2'b10 && trans.data==8'b101)
            begin
                stop_detected=1;
                start_detected=0;
                repeated_start=0;
                address_calculated=0;
                r_start_check=0;
                //$display("**********Predictor STOP*********");
            end
        /******************************** Address Calculation ******************************/
        if((start_detected ==1 || repeated_start==1) && trans.addr==2'b01)
            begin
                address_calculated=1;
                if(trans.data[0]==0)
                    i2c_trans.op=0;
                else
                    i2c_trans.op=1;
                trans.data=trans.data>>1;
                i2c_trans.i2c_address=trans.data[6:0];
                repeated_start=0;
                start_detected=0;
            end
            /******************************** Data Calculation ******************************/
        else if(address_calculated==1 && stop_detected==0 && trans.addr==2'b01)
            begin

                i2c_trans.i2c_data={i2c_trans.i2c_data,trans.data};
                r_start_check=1;

            end

        /***********************Sending the expected transaction to scoreboard ***************/

        if(stop_detected==1 || repeated_start==1)
            begin
                scorebrd.nb_transport(i2c_trans, transport_trans);
                i2c_trans=new("name");
            end

    endfunction

endclass
