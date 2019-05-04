//Core Parameter Definitions based on iicmb Documentation.
parameter bit [7:0] RESET_CSR='h0;
parameter bit [7:0] RESET_DPR='h0;
parameter bit [7:0] RESET_CMDR='h80;
parameter bit [7:0] RESET_FSMR='h0;
parameter bit [7:0] ENABLE_CORE='b1xxxxxxx;
parameter bit [7:0] DISABLE_CORE='h0;

typedef enum bit [7:0] { ZEROS=8'h01, ONES=8'h02, SYNC=8'h04, PARITY=8'h08, ECC=8'h16, CRC=8'h32 } trailer_type_t;

// registers in register block as referred from iicmb document
typedef enum bit [1:0] {
	CSR=2'b00,
	DPR=2'b01,
	CMDR=2'b10,
	FSMR=2'b11
} reg_type_t;

// wishbone write enable operation
typedef enum bit {
	WB_READ = 1'b0,
	WB_WRITE = 1'b1
} we_type_t;

// Byte level fsm as referred from iicmb document
typedef enum bit [3:0] {
	BYTE_FSM_START=4'b0011,
    BYTE_FSM_BUS_TAKEN=4'b0001,
    BYTE_FSM_START_PENDING=4'b0010,
    BYTE_FSM_STOP=4'b0100,
    BYTE_FSM_READ=4'b0110,
    BYTE_FSM_WRITE=4'b0101,
    BYTE_FSM_IDLE=4'b0000,
	BYTE_FSM_WAIT=4'b0111
} byte_fsm_t;

// Bit level FSM Structure as referred from iicmb document
typedef enum bit [3:0] {
    BIT_FSM_IDLE 	= 	4'b0000,
	BIT_FSM_START_A 	=  	4'b0001,
	BIT_FSM_START_B 	=  	4'b0010,
	BIT_FSM_START_C 	=  	4'b0011,

    BIT_FSM_RESTART_A 	=	4'b1100,
    BIT_FSM_RESTART_B 	=  	4'b1101,
    BIT_FSM_RESTART_C 	= 	4'b1110,

    BIT_FSM_STOP_A 	=  	4'b1001,
    BIT_FSM_STOP_B 	=  	4'b1010,
    BIT_FSM_STOP_C 	=  	4'b1011,

    BIT_FSM_RW_A 		=  	4'b0100,
	BIT_FSM_RW_B 		= 	4'b0101,
	BIT_FSM_RW_C 		=  	4'b0110,
	BIT_FSM_RW_D 		=  	4'b0111,
	BIT_FSM_RW_E 		=  	4'b1000

} bit_fsm_t;

// CMDR Commands Tell us what is the wishbone instruction
typedef enum bit [2:0] {
    CMDR_SET_BUS=3'b110,
    CMDR_START=3'b100,
    CMDR_STOP=3'b101,
    CMDR_RWACK=3'b010,
    CMDR_RWNACK=3'b011,
    CMDR_WRITE_CMD=3'b001,
    CMDR_WAIT = 3'b000,
    CMDR_INVALID = 3'b111
} cmdr_commands_t;

