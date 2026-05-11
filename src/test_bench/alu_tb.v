`include "alu_reference_model.v"
`include "alu.v"
`timescale 1ns/1ps
module tb;
    reg [7:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0]INP_VALID;
    reg [3:0] CMD;
    wire [15:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [15:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;
    reg f;
    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

   
   alu dut (
        .OPA(OPA), .OPB(OPB), .CIN(CIN),
        .CLK(CLK), .RST(RST), .CMD(CMD),
        .CE(CE), .MODE(MODE),.INP_VALID(INP_VALID),
        .COUT(COUT_dut), .OFLOW(OFLOW_dut),
        .RES(RES_dut),
        .G(G_dut), .E(E_dut), .L(L_dut),
        .ERR(ERR_dut)
    );

   
    alu_reference_model ref (
        .opa(OPA), .opb(OPB), .cin(CIN),
        .mode(MODE), .cmd(CMD), .inp_valid(INP_VALID),.ce(CE),.clk(CLK),.rst(RST),
        .res(RES_ref),
        .cout(COUT_ref), .oflow(OFLOW_ref),
        .g(G_ref), .e(E_ref), .l(L_ref),
        .err(ERR_ref)
    );

   
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        
        RST = 1; CE = 0; CIN = 0;
        OPA = 0; OPB = 0; MODE = 0; CMD = 0; INP_VALID=0;
        
        @(posedge CLK);
        RST = 0; 
           
        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();   
        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end
    
    
    task test_arithmetic();
        begin
           
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'b0000, "ADD");

           apply_test(8'hff, 8'hff, 1'b1,1'b1,2'b11, 4'b0000,"ADD");
            apply_test(8'h34, 8'hCd,1'b1,1'b1,2'b11,4'b0000, "ADD_with_carry"); 
            apply_test(8'h34, 8'h25,1'b1,1'b1,2'b11,4'b0001, "SUB");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'b00001, "SUB_OVERFLOW");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b11,4'd2,   "ADD_CIN_WITH_CARRY");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd2,   "ADD_CIN");
            apply_test(8'h34, 8'hcd,1'b1,1'b0,2'b11,4'd9,   "CE_0");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd3,   "sub_cin_overflow");
            apply_test(8'h45, 8'h45,1'b1,1'b1,2'b11,4'd3,   "sub_cin_a==b");
            apply_test(8'h34, 8'h24,1'b1,1'b1,2'b11,4'd3,   "sub_cin");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b11,4'd4,   "inc_a");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b11,4'd5,   "dec_a");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd6,   "inc_b");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd7,   "dec_b");
            apply_test(8'h34, 8'h23,1'b1,1'b1,2'b11,4'd8,   "CMP_GREATER");
            RST=1;
            apply_test(8'h34, 8'h23,1'b1,1'b1,2'b11,4'd8,   "CMP_GREATER");
            RST=0;
            apply_test(8'h34, 8'h34,1'b1,1'b1,2'b11,4'd8,   "CMP_EQUAL");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd8,   "CMP_LESS");
           
            RST=1;
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd8,   "RST_1");
            RST=0;
            
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd9,   "INC_MUL_FIRST_CLOCK");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd9,   "INC_MUL_2ND_CLOCK");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b11,4'd9,   "INC_MUL_3RD_CLOCK");
            
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd10,"SHIFT_MUL_FIRST_CLOCK");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd10,   "shift_MUL_2nd_CLOCK");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd10,   "shift_MUL_3rd_CLOCK");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd11,   "sign_add_both_+ve");
            apply_test(8'h84, 8'ha5,1'b1,1'b1,2'b11,4'd11,   "sign_add_both_-ve");
            apply_test(8'h84, 8'h45,1'b1,1'b1,2'b11,4'd11,   "sign_add_A_-ve");
            apply_test(8'h34, 8'hA5,1'b1,1'b1,2'b11,4'd11,   "sign_add_B_-ve");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd12,   "sign_sub_both_+ve");
           apply_test(8'h84, 8'ha5,1'b1,1'b1,2'b11,4'd12,   "sign_sub_both_-ve");
            apply_test(8'h84, 8'h45,1'b1,1'b1,2'b11,4'd12,   "sign_sub_A_-ve");
            apply_test(8'h34, 8'hA5,1'b1,1'b1,2'b11,4'd12,   "sign_sub_B_-ve");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b1,4'd0,   "ADD_E");
            apply_test(8'h34, 8'h25,1'b1,1'b1,2'b10,4'b0001, "SUB_E");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b1,4'd2,   "ADD_CIN_WITH_CARRY_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd3,   "sub_cin_overflow_E");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b10,4'd4,   "inc_a_E");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b0,4'd5,   "dec_a_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b01,4'd6,   "inc_b_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b00,4'd7,   "dec_b_E");
            apply_test(8'h34, 8'h23,1'b1,1'b1,2'b10,4'd8,   "CMP_GREATER_E");
            apply_test(8'hff,8'hff,1'b1,1'b1,2'b10,4'd9,     "invalid_mul");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b0,4'd10,"SHIFT_MUL_FIRST_CLOCK_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd10,   "shift_MUL_2nd_CLOCK_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd10,   "shift_MUL_3rd_CLOCK_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd11,   "sign_add_both_+ve_E");
            apply_test(8'h84, 8'ha5,1'b1,1'b1,2'b00,4'd11,   "sign_add_both_-ve_E");
            apply_test(8'h84, 8'h45,1'b1,1'b1,2'b1,4'd11,   "sign_add_A_-ve_E");
            apply_test(8'h34, 8'hA5,1'b1,1'b1,2'b10,4'd11,   "sign_add_B_-ve_E");

            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd12,   "sign_sub_both_+ve_E");
           apply_test(8'h20,8'h10,1,1,3,12, "hit");
           apply_test(8'h20, 8'h5,1'b1,1'b1,2'b11,4'd12,   "sign_sub_both_+ve_E");
           apply_test(8'h0f,8'h0f,1'b1,1'b1,2'b11,4'd12, "hit 0");
            apply_test(8'h84, 8'ha5,1'b1,1'b1,2'b00,4'd12,   "sign_sub_both_-ve_E");
            apply_test(8'h84, 8'h45,1'b1,1'b1,2'b1,4'd12,   "sign_sub_A_-ve_E");
            apply_test(8'h34, 8'hA5,1'b1,1'b1,2'b00,4'd12,   "sign_sub_B_-ve_E"); 
           apply_test(8'h34, 8'hA5,1'b1,1'b1,2'b00,4'd13,   "sign_sub_B_-ve_E");
           apply_test(8'h02, 8'h03, 0, 1, 2'b11, 4'd9,  "MUL_BEFORE_SWITCH");
           apply_test(8'h02, 8'h03, 0, 1, 2'b11, 4'd10, "SHIFTMUL_AFTER_SWITCH"); // triggers count reset
           apply_test(8'h02, 8'h03, 0, 1, 2'b11, 4'd9,  "MUL_AFTER_SWITCH_BACK"); // and again
       //toogle cases

           apply_test(8'h01, 8'h01, 0, 1, 2'b11, 4'd12, "ssub_res_00");
           apply_test(8'h10, 8'h01, 0, 1, 2'b11, 4'd12, "ssub_res_0F");
           apply_test(8'h10, 8'hF0, 0, 1, 2'b11, 4'd12, "ssub_diff_sign_no_ovf");
           apply_test(8'hF0, 8'h10, 0, 1, 2'b11, 4'd12, "ssub_diff_sign_no_ovf2");
           apply_test(8'hff,8'hff,1'b1,1'b1,2'b10,4'd9,     "invalid_mul");
      // dut coverage
           
           apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b1,4'd4,   "inc_a");
            apply_test(8'h34, 8'hcd,1'b1,1'b1,2'b1,4'd5,   "dec_a");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd6,   "inc_b");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd7,   "dec_b");
     // ref coverage
           apply_test(8'hff,8'hff,1'b1,1'b1,2'b11,4'd9,     "VALID_mul"); @(posedge CLK);
           apply_test(8'hff,8'hff,1'b1,1'b1,2'b11,4'd9,     "VALID_mul");
         

              apply_test_mul(8'd23,8'd12,3,1,0,1,9,"MUL ADD");
            apply_test_mul(8'd50,8'd225,3,1,0,1,9,"MUL ADD");
            apply_test_mul(8'd255,8'd255,3,1,0,1,9,"MUL ADD");
            apply_test_mul(8'd23,8'd12,3,1,0,1,10,"MUL SHIFT");
            apply_test_mul(8'd1,8'd3,3,1,0,1,10,"MUL SHIFT");
            apply_test_mul(8'd128,8'd1,3,1,0,1,10,"MUL SHIFT");
            apply_test_mul(8'd23,8'd12,2'b00,1,0,1,9,"MUL09_INV");
	    apply_test_mul(8'd23,8'd12,2'b00,1,0,1,10,"MUL10_INV");
                   


            
            
        end
    endtask

    task test_logical();
        begin
          
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd0, "AND");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd1, "NAND");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd2, "OR");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd3, "NOR");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd4, "XOR");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd5, "XNOR");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd6, "NOT_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd7, "NOT_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd8, "SHR1_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd9, "SHL1_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd10, "SHR1_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd11, "SHL1_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd12, "ROLA_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd13, "RORA_B");
            
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd0, "AND_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd1, "NAND_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd2, "OR_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd3, "NOR_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd4, "XOR_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd5, "XNOR_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd6, "NOT_A_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b0,4'd7, "NOT_B_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b00,4'd8, "SHR1_A_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd9, "SHL1_A_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b00,4'd10, "SHR1_B_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd11, "SHL1_B_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd12, "ROLA_B_E");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd13, "RORA_B_E");
             apply_test(8'h34, 8'h45,1'b1,1'b1,2'b11,4'd14, "RORA_B_E");

            // dut coverage
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd6, "NOT_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd7, "NOT_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd8, "SHR1_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b1,4'd9, "SHL1_A");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd10, "SHR1_B");
            apply_test(8'h34, 8'h45,1'b1,1'b1,2'b10,4'd11, "SHL1_B");
         
                     
        end
    endtask


task apply_test_mul(
        input[7:0] a,b,
        input [1:0] inp,
        input mode, cin, ce,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
	    f=0;
            @(negedge CLK);
            OPA = a;
            OPB = b;
            INP_VALID = inp;
            MODE = mode;
            CIN = cin;
            CE = ce;
            CMD = cmd;
            @(posedge CLK);
            INP_VALID = 2'b00;
	    @(posedge CLK);
	    //@(posedge CLK);
	    @(negedge CLK);
            
            if(RES_dut !== {16{1'bx}}) begin  
                f=1;
                test_count = test_count + 1;
                $display("[FAIL] %s: OPA=0x%h OPB=0x%h INP_VALID=0x%h MODE=0x%h CIN=0x%h CE=0x%h CMD=0x%h",test_name,a,b,inp,mode,cin,ce,cmd);
                fail_count = fail_count + 1;
                display_mismatch();
            end 
                @(posedge CLK);
                @(negedge CLK);
                if(f==0) begin
		    test_count = test_count + 1;
                    if(compare_outputs(COUT_dut,COUT_ref)) begin
                       $display("[PASS] %s: OPA=0x%h OPB=0x%h INP_VALID=0x%h MODE=0x%h CIN=0x%h CE=0x%h CMD=0x%h",test_name,a,b,inp,mode,cin,ce,cmd);
                        pass_count = pass_count + 1;
                        display_mismatch();
                    end else begin
                        $display("[FAIL] %s: OPA=0x%h OPB=0x%h INP_VALID=0x%h MODE=0x%h CIN=0x%h CE=0x%h CMD=0x%h",test_name,a,b,inp,mode,cin,ce,cmd);
                        display_mismatch();
                        fail_count = fail_count + 1;
                    end
                end
        end
endtask

    task apply_test(
        input [7:0] a, b,
        input cin,ce,
        input [1:0]inp_valid,
        input [3:0] cmd,
        input [80*8:1] test_name
    );
        begin
            @(posedge CLK);
            OPA = a;
            OPB = b;
            CIN=cin;
            CE=ce;
            INP_VALID=inp_valid;
            CMD = cmd;
            
            
            @(posedge CLK);
            @(posedge CLK);
            
            test_count = test_count + 1;
            
            if (compare_outputs(RES_dut,RES_ref))begin
                $display("[PASS] %s: OPA=0x%h OPB=0x%h CIN=%b CE=%B INP_VALID=%B CMD=0x%h", 
                         test_name, a, b,cin,ce,inp_valid, cmd);
                display_mismatch();        
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: OPA=0x%h OPB=0x%h CIN=%b CE=%B INP_VALID=%B CMD=0x%h", 
                         test_name, a, b,cin,ce,inp_valid, cmd);
                display_mismatch();
                fail_count = fail_count + 1;
            end
        end
    endtask

    function compare_outputs(input [15:0]RES_dut,RES_ref);
       
        begin
            if((RES_dut ==RES_ref)&&(COUT_ref==COUT_dut) && (OFLOW_ref==OFLOW_dut) 
            && (G_dut==G_ref) && (E_ref==E_dut)&& (L_dut==L_ref)&&(ERR_ref==ERR_dut))
              compare_outputs=1; 
            else 
              compare_outputs=0;
           
           
        end
    endfunction

    
   
    task display_mismatch();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, tb);
    end

endmodule
