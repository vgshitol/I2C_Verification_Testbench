class predictor extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;
    ncsu_component #(i2c_transaction) scoreboard;
    i2c_transaction transport_trans;
    i2c_transaction i2c_trans;

    static bit start_detected,stop_detected,address_calculated,repeated_start;
    bit r_start_check,check;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
        i2c_trans=new("Expedted(Predicted) I2C transaction");
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    virtual function void nb_put(T trans);

        /******************************** Detect Start or repeated start******************************/
        if(trans.address==2'b10 && trans.data==8'b100)
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
        if(trans.address==2'b10 && trans.data==8'b101)
            begin
                stop_detected=1;
                start_detected=0;
                repeated_start=0;
                address_calculated=0;
                r_start_check=0;
                //$display("**********Predictor STOP*********");
            end
        /******************************** Address Calculation ******************************/
        if((start_detected ==1 || repeated_start==1) && trans.address==2'b01)
            begin
                address_calculated=1;
                if(trans.data[0]==0)
                    i2c_trans.monitor_op=WRITE;
                else
                    i2c_trans.monitor_op=READ;
                trans.data=trans.data>>1;
                i2c_trans.i2c_address=trans.data[6:0];
                repeated_start=0;
                start_detected=0;
            end
            /******************************** Data Calculation ******************************/
        else if(address_calculated==1 && stop_detected==0 && trans.address==2'b01)
            begin

                i2c_trans.i2c_data={i2c_trans.i2c_data,trans.data};
                r_start_check=1;

            end

        /***********************Sending the expected transaction to scoreboard ***************/

        if((stop_detected==1 || repeated_start==1))
            begin
                scoreboard.nb_transport(i2c_trans, transport_trans);
                i2c_trans=new("name");
            end
    endfunction

endclass
