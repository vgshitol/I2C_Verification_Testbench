class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;
    wb_transaction  coverage_transaction;

    byte_fsm_t byte_fsm, byte_fsm_state;
    bit_fsm_t bit_fsm_state;
    cmdr_commands_t cmdr_cmds;

    we_type_t writeEnableBit;
    bit [1:0] addr;
    bit [3:0] data;

    we_type_t writeEnableBit_Meta;
    bit [1:0] addr_Meta;
    bit [7:0] data_Meta;

    // Bit Level FSM Coverage
    covergroup BitFSM_cg;
        option.per_instance = 1;
        option.name = get_full_name();

        bit_fsm_state: coverpoint bit_fsm_state{
            bins BIT_FSM_IDLE = {BIT_FSM_IDLE};

            bins BIT_FSM_START_A = {BIT_FSM_START_A};
            bins BIT_FSM_START_B  = {BIT_FSM_START_B};
            bins BIT_FSM_START_C  = {BIT_FSM_START_C};

            bins BIT_FSM_RESTART_A  = {BIT_FSM_RESTART_A};
            bins BIT_FSM_RESTART_B  = {BIT_FSM_RESTART_B};
            bins BIT_FSM_RESTART_C = {BIT_FSM_RESTART_C};

            bins BIT_FSM_STOP_A = {BIT_FSM_STOP_A};
            bins BIT_FSM_STOP_B = {BIT_FSM_STOP_B};
            bins BIT_FSM_STOP_C = {BIT_FSM_STOP_C};

            bins BIT_FSM_RW_A  = {BIT_FSM_RW_A};
            bins BIT_FSM_RW_B  = {BIT_FSM_RW_B};
            bins BIT_FSM_RW_C  = {BIT_FSM_RW_C};
            bins BIT_FSM_RW_D  = {BIT_FSM_RW_D};
            bins BIT_FSM_RW_E  = {BIT_FSM_RW_E};
        }

        we: coverpoint writeEnableBit{
            bins we_bin1 = (WB_READ => WB_WRITE => WB_READ);
        }

        addr: coverpoint addr{
            bins addr_bin1 = (2'b11 => 2'b10 => 2'b11 );
        }

        data: coverpoint data{
            // IDLE -> IDLE Transition with CMD STOP
            bins data_bin2 =  (BIT_FSM_IDLE => CMDR_STOP => BIT_FSM_IDLE);
            // IDLE -> IDLE Transition with CMD WRITE
            bins data_bin3 =  (BIT_FSM_IDLE => CMDR_WRITE_CMD => BIT_FSM_IDLE);
            // IDLE -> IDLE Transition with RWACK
            bins data_bin31 = (BIT_FSM_IDLE => CMDR_RWACK => BIT_FSM_IDLE);
            // IDLE -> IDLE Transition with RWNACK
            bins data_bin32 = (BIT_FSM_IDLE => CMDR_RWNACK => BIT_FSM_IDLE);

            // IDLE -> STARTA Transition with CMD START
            bins data_bin1 =  (BIT_FSM_IDLE => CMDR_START => BIT_FSM_START_A);

            // RW_E -> RESTART_A Transition with CMD START
            bins data_bin4 =  (BIT_FSM_RW_E => CMDR_START => BIT_FSM_RESTART_A);
            // RW_E -> RW_A Transition with CMD WRITE
            bins data_bin5 =  (BIT_FSM_RW_E => CMDR_WRITE_CMD => BIT_FSM_RW_A);
            // RW_E -> STOP_A Transition with CMD STOP
            bins data_bin6 =  (BIT_FSM_RW_E => CMDR_STOP => BIT_FSM_STOP_A);
            // RW_E -> RW_A Transition with CMD RWACK
            bins data_bin61 = (BIT_FSM_RW_E => CMDR_RWACK => BIT_FSM_RW_A);
            // RW_E -> RW_A Transition with CMD RWNAK
            bins data_bin62=  (BIT_FSM_RW_E => CMDR_RWNACK => BIT_FSM_RW_A);

            // START_C -> START_C Transition with CMD START
            bins data_bin7 =  (BIT_FSM_START_C => CMDR_START => BIT_FSM_START_C);
            // START_C -> STOP_A Transition with CMD STOP
            bins data_bin8 =  (BIT_FSM_START_C => CMDR_STOP => BIT_FSM_STOP_A);
            // START_C -> RW_A Transition with CMD WRITE
            bins data_bin9 =  (BIT_FSM_START_C => CMDR_WRITE_CMD => BIT_FSM_RW_A);
            // START_C -> RW_A Transition with CMD RWACK
            bins data_bin91 = (BIT_FSM_START_C => CMDR_RWACK => BIT_FSM_RW_A);
            // START_C -> RW_A Transition with CMD RWNACK
            bins data_bin92 = (BIT_FSM_START_C => CMDR_RWNACK => BIT_FSM_RW_A);
        }

        we_addr_data: cross we, addr, data{
          //  bins idle_start = binsof(data.data_bin1) ;
        } // Cross Data to cover Transitions

        we_Meta: coverpoint writeEnableBit_Meta{
            bins we_bin1_Meta = (WB_READ => WB_READ );
        }

        addr_Meta: coverpoint addr_Meta{
            bins addr_bin1_Meta = (2'b11 => 2'b11 );
        }

        data_Meta: coverpoint data_Meta {

            bins data_bin1_Meta =  (BIT_FSM_START_A  => BIT_FSM_START_B);  //START_A  => START_B
            bins data_bin2_Meta =  (BIT_FSM_START_B  => BIT_FSM_START_C);  //START_B  => START_C
            bins data_bin3_Meta =  (BIT_FSM_START_C  => BIT_FSM_START_C);  //START_B  => START_C

            bins data_bin4_Meta =  (BIT_FSM_RESTART_A  => BIT_FSM_RESTART_B);  //RESTART_A  => RESTART_C
            bins data_bin5_Meta =  (BIT_FSM_RESTART_B  => BIT_FSM_RESTART_C);  //RESTART_B  => RESTART_C
            bins data_bin6_Meta =  (BIT_FSM_RESTART_C  => BIT_FSM_START_A);   //RESTART_C  => START_A

            bins data_bin7_Meta =  (BIT_FSM_STOP_A  => BIT_FSM_STOP_B);  //STOP_A  => STOP_B)
            bins data_bin8_Meta =  (BIT_FSM_STOP_B  => BIT_FSM_STOP_C);  //STOP_B  => STOP_C
            bins data_bin9_Meta =  (BIT_FSM_STOP_C  => BIT_FSM_IDLE);   //STOP_C  => IDLE

            bins data_bin10_Meta =  (BIT_FSM_RW_A  => BIT_FSM_RW_B);  //RW_A  => RW_B
            bins data_bin11_Meta =  (BIT_FSM_RW_B  => BIT_FSM_RW_C);  //RW_B  => RW_C
            bins data_bin12_Meta =  (BIT_FSM_RW_C  => BIT_FSM_RW_D);  //RW_C  => RW_D
            bins data_bin13_Meta =  (BIT_FSM_RW_D  => BIT_FSM_RW_E);  //RW_D  => RW_E
        }

        we_addr_data_Meta: cross we_Meta, addr_Meta, data_Meta;

    endgroup

    // Byte Level FSM Coverage
    covergroup ByteFSM_cg;
        option.per_instance = 1;
        option.name = get_full_name();

        cmdr_cmds: coverpoint cmdr_cmds{
            bins INVALID   = {CMDR_INVALID};
        }

        byte_fsm_state: coverpoint byte_fsm{
            bins START_STATE         = {BYTE_FSM_START};
            bins STOP_STATE          = {BYTE_FSM_STOP};
            bins RWACK_STATE         = {BYTE_FSM_READ};
            bins RWNACK_STATE        = {BYTE_FSM_IDLE};
            bins WRITE_CMD_STATE     = {BYTE_FSM_WRITE};
            bins SET_BUS_STATE       = {BYTE_FSM_BUS_TAKEN};
            bins WAIT_STATE          = {BYTE_FSM_WAIT};
            bins START_PENDING_STARE = {BYTE_FSM_START_PENDING};
        }

        byte_fsm_start_state: coverpoint byte_fsm_state{
            bins arblost_s = (BYTE_FSM_START => BYTE_FSM_IDLE);
            bins done_s    = (BYTE_FSM_START => BYTE_FSM_BUS_TAKEN);
            illegal_bins invalid_s = (
            BYTE_FSM_START => BYTE_FSM_STOP,
            BYTE_FSM_START => BYTE_FSM_START_PENDING,
            BYTE_FSM_START => BYTE_FSM_READ,
            BYTE_FSM_START => BYTE_FSM_WRITE,
            BYTE_FSM_START => BYTE_FSM_WAIT
            );
        }

        byte_fsm_idle_state: coverpoint byte_fsm_state{
            bins wait_i = (BYTE_FSM_IDLE => BYTE_FSM_WAIT);
            bins start_i  = (BYTE_FSM_IDLE => BYTE_FSM_START_PENDING);
            illegal_bins invalid_i = (BYTE_FSM_IDLE => BYTE_FSM_STOP,
            BYTE_FSM_IDLE => BYTE_FSM_START,
            BYTE_FSM_IDLE => BYTE_FSM_READ,
            BYTE_FSM_IDLE => BYTE_FSM_WRITE,
            BYTE_FSM_IDLE => BYTE_FSM_BUS_TAKEN);
        }

        byte_fsm_stop_state: coverpoint byte_fsm_state{
            bins done_sp = (BYTE_FSM_STOP => BYTE_FSM_IDLE);
            illegal_bins invalid_sp = (BYTE_FSM_STOP => BYTE_FSM_START,
            BYTE_FSM_STOP => BYTE_FSM_START_PENDING,
            BYTE_FSM_STOP => BYTE_FSM_READ,
            BYTE_FSM_STOP => BYTE_FSM_WRITE,
            BYTE_FSM_STOP => BYTE_FSM_WAIT,
            BYTE_FSM_STOP => BYTE_FSM_BUS_TAKEN);
        }

        byte_fsm_wait_state: coverpoint byte_fsm_state{
            bins done_w = (BYTE_FSM_WAIT => BYTE_FSM_IDLE);
            illegal_bins invalid_w = (BYTE_FSM_WAIT => BYTE_FSM_STOP,
            BYTE_FSM_WAIT => BYTE_FSM_START_PENDING,
            BYTE_FSM_WAIT => BYTE_FSM_READ,
            BYTE_FSM_WAIT => BYTE_FSM_WRITE,
            BYTE_FSM_WAIT => BYTE_FSM_START,
            BYTE_FSM_WAIT => BYTE_FSM_BUS_TAKEN);
        }

        byte_fsm_bus_taken_state: coverpoint byte_fsm_state{
            bins write_bt = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_WRITE);
            bins read_bt  = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_READ);
            bins start_bt = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_START);
            bins stop_bt  = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_STOP);
            illegal_bins invalid_bt=(BYTE_FSM_BUS_TAKEN => BYTE_FSM_START_PENDING,
            BYTE_FSM_BUS_TAKEN => BYTE_FSM_IDLE,
            BYTE_FSM_BUS_TAKEN => BYTE_FSM_WAIT);
        }

        byte_fsm_write_state : coverpoint byte_fsm_state{
            bins errarblost_wb = (BYTE_FSM_WRITE => BYTE_FSM_IDLE);
            bins donenack_wb   = (BYTE_FSM_WRITE => BYTE_FSM_BUS_TAKEN);
            illegal_bins invalid_wb    = (BYTE_FSM_WRITE => BYTE_FSM_STOP,
            BYTE_FSM_WRITE => BYTE_FSM_START_PENDING,
            BYTE_FSM_WRITE => BYTE_FSM_READ,
            BYTE_FSM_WRITE => BYTE_FSM_START,
            BYTE_FSM_WRITE => BYTE_FSM_WAIT);
        }

        byte_fsm_read_state : coverpoint byte_fsm_state{
            bins errarblost_rb = (BYTE_FSM_READ => BYTE_FSM_IDLE);
            bins racknack_rb = (BYTE_FSM_READ => BYTE_FSM_BUS_TAKEN);
            illegal_bins invalid_rb = (
            BYTE_FSM_READ => BYTE_FSM_STOP,
            BYTE_FSM_READ => BYTE_FSM_START_PENDING,
            BYTE_FSM_READ => BYTE_FSM_READ,
            BYTE_FSM_READ => BYTE_FSM_START,
            BYTE_FSM_READ => BYTE_FSM_WAIT
            );
        }
    endgroup

    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        ByteFSM_cg = new;
        BitFSM_cg = new;
    endfunction

    virtual function void nb_put(T trans);
        $display({get_full_name()," ",trans.convert2string()});
        coverage_transaction = trans;

        if(trans.addr == 2'b10) begin
            cmdr_cmds = cmdr_commands_t'(trans.data[2:0]);
        end

        if(trans.addr == 2'b11)begin
            byte_fsm = byte_fsm_t'(trans.data[7:4]);
            byte_fsm_state = byte_fsm_t'(trans.data[7:4]);
        end

        if(trans.addr == 2'b11 && trans.enable == 0 ) begin
                bit_fsm_state = bit_fsm_t'(trans.data[3:0]);
        end

        writeEnableBit = we_type_t'(trans.enable);
        addr = trans.addr;
        addr_Meta = trans.addr;
        data = trans.data[3:0];
        data_Meta = trans.data[3:0];
        ByteFSM_cg.sample();
        BitFSM_cg.sample();
    endfunction

endclass
