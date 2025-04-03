module AND(
    input A, B,
    output Z,V,W,X,Y
);
 
 wire clk;  // Wire to store the prescaled clock signal
 prescaler #(22) my_prescaler (
        .clk_in(clk_in),
        .clk_out(clk)
    );
	 assign V = 0; //LED 1
	 assign W = 0; //LED2
	 assign X = 0; //LED3
	 assign Y = 0; //LED4
   assign Z = A & B; //Green LED
endmodule