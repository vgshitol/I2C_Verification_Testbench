class scoreboard extends ncsu_component#(.T(i2c_transaction));
    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
    endfunction

    T trans_in[];
    T trans_out;
    int idx = 0;

    virtual function void nb_transport(input T input_trans, output T output_trans);
        if(input_trans.i2c_address !=0)
//            $display({get_full_name(),"nb_transport I2C EXPECTED RESPONSE",input_trans.convert2string()});

        this.trans_in = new[this.trans_in.size()+1](this.trans_in);
        this.trans_in[trans_in.size()-1] = input_trans;
        output_trans = trans_out;

//        $display ("Array SIZE : %d", trans_in.size());

//        foreach(this.trans_in[i]) begin
//            $display({get_full_name(),"I2C EXPECTED RESPONSE ARRAY",this.trans_in[i].convert2string()});
//        end
    endfunction

    virtual function void nb_put(T trans);
        $display({get_full_name()," nb_put RECEIVED FROM MONITOR",trans.convert2string()});
        $display({get_full_name()," nb_put EXPECTED FROM MONITOR",this.trans_in[idx].convert2string()});
//        $display("IDX = %d", idx);

        if ( this.trans_in[idx].compare(trans) ) $display(" I2C MATCH");
        else  $display(" I2C MISMATCH");

        idx = idx + 1;
    endfunction
endclass


