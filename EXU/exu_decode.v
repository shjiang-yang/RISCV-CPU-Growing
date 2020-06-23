//================================================
//designer: shjiang
//data: 2020-06-20
//
//description:
//to decode the instruction details
//
//===============================================


module exu_decode(
    //the signals from IFU to EXU
    input   [`INSTR_SIZE-1:0]   i_instr,
    input   [`PC_SIZE-1:0]      i_pc,
    input                       i_prdt_taken,
    input                       i_misalgn,      //instr don't align
    input                       i_buserr,
    input                       i_muldiv_b2b,

    input   dbg_mode,

    //the info decoded
    output  dec_rs1x0,
    output  dec_rs2x0,
    output  dec_rs1en,  //need to read op1
    output  dec_rs2en,
    output  dec_rdwen,  //need to write the result
    output  [`RFIDX_WIDTH-1:0]      dec_rs1idx,
    output  [`RFIDX_WIDTH-1:0]      dec_rs2idx,
    output  [`RFIDX_WIDTH-1:0]      dec_rdidx,  //result register index
    output  [`DECINFO_WIDTH-1:0]    dec_info,   //other infos
    output  [`X_LEN-1:0]            dec_imm,
    output  [`PC_SIZE-1:0]          dec_pc,
    output  dec_misalgn,
    output  dec_buserr,
    output  dec_ilegl,

    output  dec_mulhsu,
    output  dec_mul,
    output  dec_div,
    output  dec_rem,
    output  dec_divu,
    output  dec_remu,

    output  dec_rv32,
    output  dec_bjp,
    output  dec_jal,
    output  dec_jalr,
    output  dec_bxx,

    output  [`RFIDX_WIDTH-1:0]  dec_jalr_rs1idx,
    output  [`X_LEN-1:0]        dec_bjp_imm
);

wire    [32-1:0]    rv32_instr = i_instr;
wire    [16-1:0]    rv16_instr = i_instr[16-1:0];

wire    [6:0]   opcode = rv32_instr[6:0];

wire    opcode_1_0_00 = (opcode[1:0] == 2'b00);
wire    opcode_1_0_01 = (opcode[1:0] == 2'b01);
wire    opcode_1_0_10 = (opcode[1:0] == 2'b10);
wire    opcode_1_0_11 = (opcode[1:0] == 2'b11);

wire    rv32 = (~(i_instr[4:2] == 3'b111)) & opcode_1_0_11;

wire    [4:0]   rv32_rd     =   rv32_instr[11:7];
wire    [2:0]   rv32_func3  =   rv32_instr[14:12];
wire    [4:0]   rv32_rs1    =   rv32_instr[19:15];
wire    [4:0]   rv32_rs2    =   rv32_instr[24:20];
wire    [6:0]   rv32_func7  =   rv32_instr[31:25];

wire    [4:0]   rv16_rd     =   rv32_rd;
wire    [4:0]   rv16_rs1    =   rv16_rd;
wire    [4:0]   rv16_rs2    =   rv32_instr[6:2];

wire    [4:0]   rv16_rdd     =   {2'b01,rv32_instr[4:2]};
wire    [4:0]   rv16_rss1    =   {2'b01,rv32_instr[9:7]};
wire    [4:0]   rv16_rss2    =   rv16_rdd;

wire    [2:0]   rv16_func3  =   rv32_instr[15:13];

wire    opcode_4_2_000 =   (opcode[4:2] == 3'b000);
wire    opcode_4_2_001 =   (opcode[4:2] == 3'b001);
wire    opcode_4_2_010 =   (opcode[4:2] == 3'b010);
wire    opcode_4_2_011 =   (opcode[4:2] == 3'b011);
wire    opcode_4_2_100 =   (opcode[4:2] == 3'b100);
wire    opcode_4_2_101 =   (opcode[4:2] == 3'b101);
wire    opcode_4_2_110 =   (opcode[4:2] == 3'b110);
wire    opcode_4_2_111 =   (opcode[4:2] == 3'b111);

wire    opcode_6_5_00   =   (opcode[6:5] == 2'b00);
wire    opcode_6_5_01   =   (opcode[6:5] == 2'b01);
wire    opcode_6_5_10   =   (opcode[6:5] == 2'b10);
wire    opcode_6_5_11   =   (opcode[6:5] == 2'b11);

wire rv32_func3_000 = (rv32_func3 == 3'b000);
wire rv32_func3_001 = (rv32_func3 == 3'b001);
wire rv32_func3_010 = (rv32_func3 == 3'b010);
wire rv32_func3_011 = (rv32_func3 == 3'b011);
wire rv32_func3_100 = (rv32_func3 == 3'b100);
wire rv32_func3_101 = (rv32_func3 == 3'b101);
wire rv32_func3_110 = (rv32_func3 == 3'b110);
wire rv32_func3_111 = (rv32_func3 == 3'b111);

wire rv16_func3_000 = (rv16_func3 == 3'b000);
wire rv16_func3_001 = (rv16_func3 == 3'b001);
wire rv16_func3_010 = (rv16_func3 == 3'b010);
wire rv16_func3_011 = (rv16_func3 == 3'b011);
wire rv16_func3_100 = (rv16_func3 == 3'b100);
wire rv16_func3_101 = (rv16_func3 == 3'b101);
wire rv16_func3_110 = (rv16_func3 == 3'b110);
wire rv16_func3_111 = (rv16_func3 == 3'b111);

wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001); 

wire rv32_rs1_x0 = (rv32_rs1 == 5'b00000);
wire rv32_rs2_x0 = (rv32_rs2 == 5'b00000);
wire rv32_rs2_x1 = (rv32_rs2 == 5'b00001);
wire rv32_rd_x0  = (rv32_rd  == 5'b00000);
wire rv32_rd_x2  = (rv32_rd  == 5'b00010);

wire rv16_rs1_x0 = (rv16_rs1 == 5'b00000);
wire rv16_rs2_x0 = (rv16_rs2 == 5'b00000);
wire rv16_rd_x0  = (rv16_rd  == 5'b00000);
wire rv16_rd_x2  = (rv16_rd  == 5'b00010);

wire rv32_rs1_x31 = (rv32_rs1 == 5'b11111);
wire rv32_rs2_x31 = (rv32_rs2 == 5'b11111);
wire rv32_rd_x31  = (rv32_rd  == 5'b11111);