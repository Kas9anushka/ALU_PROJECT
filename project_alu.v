`default_nettype none
module project_alu #(parameter width=8)(
input wire [width-1:0]opa,opb,
input wire cin,
input wire clk,
input wire rst,
input wire ce,
input wire mode,
input wire [1:0]inp_valid,
input wire [3:0]cmd,
output reg [(2*width-1):0]res,
output reg oflow,
output reg cout,
output reg g,e,l,
output reg err
);
integer shift_amt;
reg [3:0]last_cmd;
reg count;
reg signed [(2*width-1):0] next_res;
reg next_overflow;
reg [(2*width-1):0] temp_res, temp_mul;
reg [width-1:0]temp_opa, temp_opb;
reg temp_cout, temp_err,temp_g,temp_e,temp_l,temp_oflow;

always @(*) begin
    next_res = (cmd==11)? $signed(opa) + $signed(opb):(cmd==12)? $signed(opa) - $signed(opb):0;
    next_overflow = (opa[width-1] == opb[width-1]) &&
                    (next_res[width-1] != opa[width-1]);
end
always@(posedge clk, posedge rst)begin
       if(rst)
          last_cmd<=0;
        else 
          last_cmd<=cmd;
end

always @(posedge clk or posedge rst) begin
                if(rst) begin
                        count <= 0;
                end
                else if(mode ==  1 && (cmd==9||cmd==10) ) begin
                        count <= count + 1;
                end
                else if(mode == 1 && ((cmd == 9 && last_cmd != 9)||(cmd == 10 && last_cmd != 10)))begin
                        count <= 0;
                end
        end
              
    
       
always @(posedge clk,posedge rst)begin
    if(rst)begin
       temp_res<=0;
       temp_oflow<=0;
       temp_cout<=0;
       temp_g<=0;
       temp_e<=0;
       temp_l<=0;
       temp_err<=0;
       
    end else if(ce) begin
       temp_res<=0;
       temp_oflow<=0;
       temp_cout<=0;
       temp_g<=0;
       temp_e<=0;
       temp_l<=0;
       temp_err<=0;
       case(mode)
       
       1: begin
          case(cmd)
              0: begin if(inp_valid==2'b11)begin
                          {temp_cout,temp_res[width-1:0]}<=opa+opb;
                          temp_res<=opa+opb;
                       end else 
                          temp_err<=1;
                 end
              1: begin if(inp_valid==2'b11)begin
                         temp_res<=opa-opb;
                         temp_oflow<=opb>opa;
                       end else  
                          temp_err<=1;
                 end 
              2: begin if(inp_valid==2'b11)begin
                          {temp_cout,temp_res[width-1:0]}<=opa+opb+cin;
                          temp_res<=opa+opb+cin;
                     end  else
                          temp_err<=1;
                 end 
              3: begin if(inp_valid==2'b11)begin
                          temp_res<=opa-opb-cin;
                          temp_oflow <= (opa<(opb+cin))? 1:0;                         
                       end else                         
                          temp_err<=1;
                 end    
              4: begin if(inp_valid[0]==1)
                          temp_res[width-1:0]<=opa+1;                       
                       else                        
                          temp_err<=1;
                 end    
              5: begin if(inp_valid[0]==1)
                          temp_res[width-1:0]<=opa-1; 
                       else
                          temp_err<=1;
                 end    
              6: begin if(inp_valid[1]==1)
                          temp_res[width-1:0]<=opb+1;
                       else                         
                          temp_err<=1;
                 end         
              7: begin if(inp_valid[1]==1)
                          temp_res[width-1:0]<=opb-1;                         
                      else 
                          temp_err<=1;
                 end      
              8: begin if(inp_valid==2'b11)begin
                          if(opa>opb) temp_g<=1;
                          else if(opa==opb) temp_e<=1;
                          else temp_l<=1; 
                       end else                          
                          temp_err<=1;                          
                 end        
              9: begin if(inp_valid == 3) begin
                           if(count == 0) begin
                              temp_mul <= (opa + 1) * (opb + 1);
                              temp_res <= {2*width{1'bx}};                                                           
                           end else if(count == 1)
                              temp_res<=temp_mul;
                       end else
                           temp_err<=1;   
                  end
              10: begin if(inp_valid == 3) begin
                           if(count == 0) begin
                              temp_mul <= (opa<<1)*opb;
                              temp_res <= {2*width{1'bx}};                                                           
                        end else if(count == 1)
                              temp_res<=temp_mul;
                     end else
                         temp_err<=1; 
                  end    
              11: begin if(inp_valid==2'b11)begin
                            temp_res<= next_res;                      
                            temp_oflow <= next_overflow;                        
                        end else                       
                            temp_err<=1;
                  end                                                                 
              12: begin if(inp_valid==2'b11)begin
                           temp_res<= next_res;                      
                           temp_oflow <= next_overflow;                                              
                       end else                       
                           temp_err<=1;                                           
                  end     
              default:  temp_err<=1;
           endcase       
       end
       0: begin
          case(cmd)          
              0: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=opa & opb;                         
                       else                         
                          temp_err<=1;                       
                 end
              1: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=~(opa & opb);
                       else                         
                          temp_err<=1;
                 end
              2: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=opa | opb;                         
                       else                        
                          temp_err<=1;
                 end
              3: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=~(opa | opb);                         
                       else                         
                          temp_err<=1;
                 end
              4: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=opa^opb;                         
                       else                          
                          temp_err<=1;
                 end
              5: begin if(inp_valid==2'b11)
                          temp_res[width-1:0]<=~(opa^opb);
                       else                          
                          temp_err<=1;                        
                 end
              6: begin if(inp_valid[0]==1)
                          temp_res[width-1:0]<=~opa;                          
                       else                        
                          temp_err<=1;
                 end
              7: begin if(inp_valid[1]==1)
                          temp_res[width-1:0]<=~opb;                         
                       else                         
                          temp_err<=1;
                 end
              8: begin if(inp_valid[0]==1)
                          temp_res[width-1:0]<=opa>>1;                        
                       else                         
                          temp_err<=1;                                               
                 end
              9: begin if(inp_valid[0]==1)
                          temp_res[width-1:0]<=opa<<1;                         
                       else                          
                          temp_err<=1;
                 end
              10: begin if(inp_valid[1]==1)
                          temp_res[width-1:0]<=opb>>1;                       
                       else                         
                          temp_err<=1; 
                 end
              11: begin if(inp_valid[1]==1)
                          temp_res[width-1:0]<=opb<<1;
                        else 
                          temp_err<=1;
                 end
              12: begin if(inp_valid==2'b11) begin
                            temp_err<=(|opb[width-1:4])? 1'b1: 1'b0;  
                            shift_amt<=$clog2(opb);
                            temp_res<={opa<<shift_amt | opa>>(width-shift_amt)};                                                   
                        end else                               
                              temp_err<=1;
                  end
              13: begin if(inp_valid==2'b11) begin
                             temp_err<=(|opb[width-1:4])? 1'b1: 1'b0;
                             shift_amt<=$clog2(opb);
                             temp_res <= (opa >> shift_amt) | (opa << (width - shift_amt));                           
                        end else                             
                              temp_err<=1;
                  end  
              default: temp_err<=1;
           endcase
         end  
        default: temp_err<=1;
        endcase
      end
    else begin
       temp_res<=temp_res;
       temp_oflow<=temp_oflow;
       temp_cout<=temp_cout;
       temp_g<=temp_g; temp_e<=temp_e; temp_l<=temp_l;
       temp_err<=temp_err;
    end
    
    res<=temp_res; cout<=temp_cout; err<=temp_err;oflow<=temp_oflow;g<=temp_g; e<=temp_e; l<=temp_l;
 end
 endmodule      
 
