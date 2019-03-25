class scoreboard extends ncsu_component#(.T(i2c_transaction));
    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
    endfunction

    T trans_in;
    T trans_out;

    virtual function void nb_transport(input T input_trans, output T output_trans);
        if(input_trans.i2c_address !=0)
            $display({get_full_name(),"nb_transport:EXPECTED TRANSACTION ",input_trans.convert2string()});
        this.trans_in = input_trans;
        output_trans = trans_out;
    endfunction

    virtual function void nb_put(T trans);
        $display({get_full_name()," nb_put:       ACTUAL TRANSACTION ",trans.convert2string()});
        if ( this.trans_in.compare(trans) ) $display(" !!!!!!!!!!!!!!!!!!!MATCH in SCOREBOARD!!!!!!!!!!!!!!!!!!!");
        else                                $display(" !!!!!!!!!!!!!!!!!!MISMATCH in SCOREBOARD!!!!!!!!!!!!!!!!!");
    endfunction
endclass


