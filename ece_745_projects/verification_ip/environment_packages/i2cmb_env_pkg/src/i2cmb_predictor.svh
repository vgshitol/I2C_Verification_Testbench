class predictor extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;
    ncsu_component #(i2c_transaction) scoreboard;
    i2c_transaction transport_trans;
    i2c_transaction i2c_trans;

    static bit start,stop, getAddress;

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

        // Start Check Condition
        // Stop Check Condition
        //Repeated Start Check Condition
        if(trans.addr==2'b10 && trans.data==8'b101) begin stop = 1; start=0; end
        else if(trans.addr==2'b10 && trans.data==8'b100 && start==1) begin start = 1; stop = 1; getAddress=1; end
        else if(trans.addr==2'b10 && trans.data==8'b100 && start==0) begin start = 1; getAddress=1; end

        if(stop==1) // putting expected prediction in scoreboard
            begin
                scoreboard.nb_transport(i2c_trans, transport_trans);
                i2c_trans=new("name");
                stop=0;
            end

        if(start==1) begin
            if(trans.addr==2'b01 && getAddress==1) // get the address
                begin
                    if(trans.data[0]==0) i2c_trans.op=WRITE;
                    else i2c_trans.op=READ;

                    trans.data=trans.data>>1;
                    i2c_trans.i2c_address=trans.data[6:0];

                    getAddress=0;
                end
            else if(trans.addr==2'b01) i2c_trans.i2c_data={i2c_trans.i2c_data,trans.data}; // get the data
        end
    endfunction
endclass
