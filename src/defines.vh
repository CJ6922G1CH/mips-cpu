`define AddrBusWidth    31:0
`define DataBusWidth    31:0

`define RegAddrBus 4:0
`define RegDataBus 31:0
`define RegDataBus_DBL 63:0
`define RegNum 32
`define OpCodeBus 7:0

`define Zero 32'h00000000
`define ZeroRegAddr 5'b00000

`define OP_LD_ST 3'b111
`define OP_Rst 3'b000

`define Ins_ADD  6'b100000
`define Ins_ADDI  6'b001000
`define Ins_ADDIU  6'b001001
`define Ins_ADDU  6'b100001
`define Ins_CLO  6'b100001
`define Ins_CLZ  6'b100000
`define Ins_LUI 6'b001111
`define Ins_SUB  6'b100010
`define Ins_SUBU  6'b100011

`define Ins_SLL 6'b000000
`define Ins_SLLV 6'b000100
`define Ins_SRA 6'b000011
`define Ins_SRAV 6'b000111
`define Ins_SRL 6'b000010
`define Ins_SRLV 6'b000110

`define Ins_AND 6'b100100
`define Ins_ANDI 6'b001100
`define Ins_NOP 6'b000000
`define Ins_NOR 6'b100111
`define Ins_OR 6'b100101
`define Ins_ORI 6'b001101
`define Ins_XOR 6'b100110
`define Ins_XORI 6'b001110

`define Ins_MOVN  6'b001011
`define Ins_MOVZ  6'b001010
`define Ins_SLT  6'b101010
`define Ins_SLTI  6'b001010
`define Ins_SLTIU  6'b001011
`define Ins_SLTU  6'b101011

`define Ins_DIV 6'b011010
`define Ins_DIVU 6'b011011
`define Ins_MADD 6'b000000
`define Ins_MADDU 6'b000001
`define Ins_MSUB 6'b000100
`define Ins_MSUBU 6'b000101
`define Ins_MUL  6'b000010
`define Ins_MULT  6'b011000
`define Ins_MULTU  6'b011001

`define Ins_MFHI  6'b010000
`define Ins_MFLO  6'b010010
`define Ins_MTHI  6'b010001
`define Ins_MTLO  6'b010011

`define Ins_BEQ  6'b000100
`define Ins_BGEZ  5'b00001
`define Ins_BGEZAL  5'b10001
`define Ins_BGTZ  6'b000111
`define Ins_BLEZ  6'b000110
`define Ins_BLTZ  5'b00000
`define Ins_BLTZAL  5'b10000
`define Ins_BNE  6'b000101
`define Ins_J  6'b000010
`define Ins_JAL  6'b000011
`define Ins_JALR  6'b001001
`define Ins_JR  6'b001000

`define Ins_LB  6'b100000
`define Ins_LBU  6'b100100
`define Ins_LH  6'b100001
`define Ins_LHU  6'b100101
`define Ins_LW  6'b100011
`define Ins_LWL  6'b100010
`define Ins_LWR  6'b100110
`define Ins_SB  6'b101000
`define Ins_SH  6'b101001
`define Ins_SW  6'b101011
`define Ins_SWL  6'b101010
`define Ins_SWR  6'b101110

`define Ins_LL  6'b110000
`define Ins_SC  6'b111000

`define Ins_SYNC 6'b001111
`define Ins_PREF 6'b110011
`define Ins_Spcl 6'b000000
`define Ins_REGIMM 6'b000001
`define Ins_Spcl2 6'b011100


`define Ins_ADD_OP  8'b00100000
`define Ins_ADDI_OP  8'b01010101
`define Ins_ADDIU_OP  8'b01010110
`define Ins_ADDU_OP  8'b00100001
`define Ins_CLO_OP  8'b10110001
`define Ins_CLZ_OP  8'b10110000
`define Ins_LUI_OP  8'b01011100
`define Ins_SUB_OP  8'b00100010
`define Ins_SUBU_OP  8'b00100011

`define Ins_SLL_OP  8'b01111100
`define Ins_SLLV_OP  8'b00000100
`define Ins_SRA_OP  8'b00000011
`define Ins_SRAV_OP  8'b00000111
`define Ins_SRL_OP  8'b00000010
`define Ins_SRLV_OP  8'b00000110

`define Ins_AND_OP   8'b00100100
`define Ins_ANDI_OP  8'b01011001
`define Ins_NOP_OP 8'b00000000
`define Ins_NOR_OP  8'b00100111
`define Ins_OR_OP 8'b00100101
`define Ins_ORI_OP  8'b01011010
`define Ins_XOR_OP  8'b00100110
`define Ins_XORI_OP  8'b01011011

`define Ins_MOVN_OP  8'b00001011
`define Ins_MOVZ_OP  8'b00001010
`define Ins_SLT_OP  8'b00101010
`define Ins_SLTI_OP  8'b01010111
`define Ins_SLTIU_OP  8'b01011000
`define Ins_SLTU_OP  8'b00101011

`define Ins_DIV_OP  8'b00011010
`define Ins_DIVU_OP  8'b00011011
`define Ins_MADD_OP  8'b10100110
`define Ins_MADDU_OP  8'b10101000
`define Ins_MSUB_OP  8'b10101010
`define Ins_MSUBU_OP  8'b10101011
`define Ins_MUL_OP  8'b10101001
`define Ins_MULT_OP  8'b00011000
`define Ins_MULTU_OP  8'b00011001

`define Ins_MFHI_OP  8'b00010000
`define Ins_MFLO_OP  8'b00010010
`define Ins_MTHI_OP  8'b00010001
`define Ins_MTLO_OP  8'b00010011

`define Ins_BEQ_OP  8'b01010001
`define Ins_BGEZ_OP  8'b01000001
`define Ins_BGEZAL_OP  8'b01001011
`define Ins_BGTZ_OP  8'b01010100
`define Ins_BLEZ_OP  8'b01010011
`define Ins_BLTZ_OP  8'b01000000
`define Ins_BLTZAL_OP  8'b01001010
`define Ins_BNE_OP  8'b01010010
`define Ins_J_OP  8'b01001111
`define Ins_JAL_OP  8'b01010000
`define Ins_JALR_OP  8'b00001001
`define Ins_JR_OP  8'b00001000

`define Ins_LB_OP  8'b11100000
`define Ins_LBU_OP  8'b11100100
`define Ins_LH_OP  8'b11100001
`define Ins_LHU_OP  8'b11100101
`define Ins_LW_OP  8'b11100011
`define Ins_LWL_OP  8'b11100010
`define Ins_LWR_OP  8'b11100110
`define Ins_SB_OP  8'b11101000
`define Ins_SH_OP  8'b11101001
`define Ins_SW_OP  8'b11101011
`define Ins_SWL_OP  8'b11101010
`define Ins_SWR_OP  8'b11101110

`define Ins_LL_OP  8'b11110000
`define Ins_SC_OP  8'b11111000

`define Ins_MFC0_OP 8'b01011101
`define Ins_MTC0_OP 8'b01100000

`define Ins_PREF_OP  8'b11110011
`define Ins_SYNC_OP  8'b00001111