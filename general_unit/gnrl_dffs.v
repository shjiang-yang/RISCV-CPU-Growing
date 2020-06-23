//================================================
//designer: shjiang
//data: 2020-06-20
//
//description:
//all of the general DFFs and Latchs
//
//===============================================


//==============================
//
//description:
//the module gnrl_dffer DFF with enable and reset_n
//reset value is 0
//
//==============================
module gnrl_dffer # (
    parameter DW = 32
) (
    input               clk     ,
    input               rst_n   ,
    input               en      ,
    input   [DW-1:0]    dnxt    ,
    output  [DW-1:0]    qout    
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin:gnrl_proc
    if(rst_n == 1'b0)
        qout_r <= {DW{1'b0}};
    else
        qout_r <= dnxt;
end
assign qout = qout_r;