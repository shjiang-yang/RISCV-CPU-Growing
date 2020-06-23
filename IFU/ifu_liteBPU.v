//================================================
//designer: shjiang
//data: 2020-06-20
//
//description:
//to handle very simple branch prediction in IFU
//
//===============================================


module ifu_liteBPU(
    //current PC
    input   [`PC_SIZE-1:0]  pc;

    //minidecode info
    input                       dec_jal,
    input                       dec_jalr,
    input                       dec_bxx,
    input   ['X_LEN-1:0]        dec_bjp_imm,
    input   [`RFIDX_WIDTH-1:0]  dec_jalr_rs1idx,

    //the IR and OITF status to be used for checking dependency
    //**************************************
    input   oitf_empty,
    input   ir_impty,
    input   ir_rs1en,
    input   jalr_rs1idx_cam_irrdidx,

    //add op to next-pc adder
    output                  bpu_wait,
    output                  prdt_taken,
    output  [`PC_SIZE-1:0]  prdt_pc_add_op1,
    output  [`PC_SIZE-1:0]  prdt_pc_add_op2,

    input   dec_i_valid,

    //the RS1 to read regfile
    output  bpu2rf_rs1_ana,
    input   ir_valid_clr,
    input   [`X_LEN-1:0]    rf2bpu_x1,
    input   [`X_LEN-1:0]    rf2bpu_rs1,

    input   clk,
    input   rst_n
);

//the jal and jalr is always jump, bxxx backward is predicted as taken
assign prdt_taken = (dec_jal | dec_jalr | (dec_bxx & dec_bjp_imm[`X_LEN-1]));

//the jalr with rs1==x1 have dependency or xN have dependency
wire dec_jalr_rs1x0 = (dec_jarlr_rs1idx == `RFIDX_WIDTH'd0);
wire dec_jalr_rs1x1 = (dec_jarlr_rs1idx == `RFIDX_WIDTH'd1);
wire dec_jalr_rs1xn = (~dec_jalr_rs1x0) & (~dec_jalr_rs1x1);

wire jalr_rs1x1_dep = dec_i_valid & dec_jalr & dec_jalr_rs1x1 & ((~oitf_empty) | jalr_rs1idx_cam_irrdidx);//*************
wire jalr_rs1xn_dep = dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~oitf_empty) | (~ir_impty));

