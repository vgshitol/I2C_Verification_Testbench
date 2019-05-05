class predictor extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;
    ncsu_component #(i2c_transaction) scoreboard;
    i2c_transaction transport_trans;
    i2c_transaction i2c_trans;

    static bit start_flagged,stop_flagged,address_calculated,repeated_start;
    bit status, end_status,rep_start_status;

    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
        i2c_trans=new("i2c_transaction_expected");
    endfunction

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    virtual function void nb_put(T trans);

        if(trans.addr==2'b10 && trans.data==8'b101) // Stop Check Condition
            begin
                repeated_start=0;
                start_flagged=0;
                address_calculated=0;
                rep_start_status=0;
                stop_flagged=1;
            end
        if(trans.addr==2'b10 && trans.data==8'b100) // Start Check Condition
            begin
                stop_flagged=0;
                address_calculated=0;

                if(rep_start_status!=0) repeated_start=1;
                else start_flagged=1;
            end

        if(trans.addr==2'b01 && (repeated_start==1 || start_flagged ==1 ) ) // get the address
            begin
                address_calculated=1;
                if(trans.data[0]==0) i2c_trans.op=WRITE;
                else i2c_trans.op=READ;

                trans.data=trans.data>>1;
                i2c_trans.i2c_address=trans.data[6:0];
                repeated_start=0;
                start_flagged=0;
            end
        else if(trans.addr==2'b01 && address_calculated==1 && stop_flagged==0 ) // get the data
            begin
                i2c_trans.i2c_data={i2c_trans.i2c_data,trans.data};
                rep_start_status=1;
            end

        if((repeated_start==1 || stop_flagged==1)) // putting expected prediction in scoreboard
            begin
                if(repeated_start == 1) repeated_start = 0;
                if(stop_flagged == 1) stop_flagged = 0;

                scoreboard.nb_transport(i2c_trans, transport_trans);
                i2c_trans=new("name");
            end
    endfunction

endclass
