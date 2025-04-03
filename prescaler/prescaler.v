module prescaler(input clk_in, output clk_out);
wire clk_in;
wire clk_out;
    
//-- Prescaler Bits
parameter N = 22;
    
//-- Register to implement the N bits
reg [N-1:0] count = 0;
    
//-- The most significant bit
assign clk_out = count[N-1];
    
//-- The counter for the clock
always @(posedge(clk_in)) begin
  count <= count + 1;
end
    
endmodule