module trafficcontroller(
    input reset, clk_in, ess, wss, els, wls, nss, nls, sls, sss, // traffic sensors, eaststraight, eastleft, weststraight, etc.
    output esl, wsl, ell, wll, nsl, nll, ssl, sll
);
// HRR = red-red following YRR; RRH = red-red following RRY;
// ZRR = 2nd cycle yellow, follows YRR, etc. 

//States correspondto initials of light state
  typedef enum {GELWL, YELWL, ZELWL, HELWL,				//East and West Left
					 GESEL, YESEL, ZESEL, HESEL,           //East Left and Straight
                GESWS, YESWS, ZESWS, HESWS, 	         // East and West Straight
                GWSWL, YWSWL, ZWSWL, HWSWL,				// West Left and Straight
					 GNLSL, YNLSL, ZNLSL, HNLSL,				// North and South Left
					 GNSNL, YNSNL, ZNSNL, HNSNL,				// North Straight and Left
					 GNSSS, YNSSS, ZNSSS, HGNSSS,				// North and South Straight
					 GSSSL, YSSSL, ZSSSL, HSSSL 				// South Straight and Left
					 } tlc_states;  // NS
  tlc_states    present_state, next_state;
  int     ctr5, next_ctr5,       //  5 sec timeout when my traffic goes away
          ctr10, next_ctr10;     // 10 sec limit when other traffic presents

// combinational part will reset or increment the counters and figure out the next_state
  always_ff @(posedge clk)
    if(reset) begin
	  present_state <= GESEL;
      ctr5          <= 0;
      ctr10         <= 0;
    end  
	else begin
	  present_state <= next_state;
      ctr5          <= next_ctr5;
      ctr10         <= next_ctr10;
    end  

// combinational part of state machine ("C1" block in the Harris & Harris Moore machine diagram)
// default needed because only 6 of 8 possible states are defined/used
  always_comb begin
    next_state = HESEL;            // default to reset state
    next_ctr5  = 0; 	         // default to clearing counters
    next_ctr10 = 0;
    case(present_state)
/* ************* Fill in the case statements ************** */
	  GESEL: begin
		next_state = GESEL;
      if(ctr5 == 0 && ctr10 == 0 && ((ess || els) && !(wss|| wls || nss || nls || sls || sss)))
		begin
			next_state = GESEL;
		end else if(!(ess || els) || ctr5 > 0) begin
			next_ctr5 = ctr5 + 1;
				if(ctr5 >= 4) begin
					if(!(wss|| wls || nss || nls || sls || sss)) begin  //Default to Green East Straight and left if no traffic in other directions
					next_state = GESEL;
					end else begin
					next_state = YESEL;
					end
				end else begin
					next_state = GESEL;
				end
			end else if((wss|| wls || nss || nls || sls || sss) || ctr10 > 0) begin
				next_ctr10 = ctr10 + 1;
				if(ctr10 >= 9) begin
					next_state = YESEL;
				end else begin
					next_state = GESEL;
				end
			end
		end
	  YESEL: begin
			next_ctr5 = 0;
			next_ctr10 = 0;
			next_state = ZESEL;
			// wait 2 clock cycles then turn red then go to RGR
		end
	  ZESEL: begin
        next_state = HESEL; // Transition to all-red before switching directions
      end
	  HESEL: begin
		if(!(wss|| wls || nss || nls || sls || sss)) begin //if none are active then default to GESEL
				next_state = GESEL;
			end else if(wss) begin
				if(!ess) begin
						next_state = GWSWL;
				end else begin
				next_state = GESWS;
				end
			end else if(nls) begin
				if(!sls) begin
					next_state = GNSNL;
				end else begin
				next_state = GNLSL;
				end
			end else if(nss) begin
				if(sss) begin
						next_state = GNSSS;
				end else begin
				next_state = GNSNL;
				end
			end else if (wls) begin
				if(!els) begin
					next_state = GWSWL;
				end else begin
				next_state = GELWL;
				end
			end
      end
	  GESWS: begin
	  YESWS: begin
	  ZESWS: begin
	  HESWS: begin
		if(!(els|| wls || nss || nls || sls || sss)) begin //if none are active then default to GESEL
				next_state = GESWS;
			end else if(wls) begin
				if(!wss && els) begin
					next_state = GELWL;
				end else begin
					next_state = GWSWL;
				end
			end else if(nls) begin
				if(!sls) begin
					next_state = GNSNL;
				end else begin
				next_state = GNLSL;
				end
			end else if(nss) begin
				if(sss) begin
						next_state = GNSSS;
				end else begin
				next_state = GNSNL;
				end
			end else if (wls) begin
				if(!els) begin
					next_state = GWSWL;
				end else begin
				next_state = GELWL;
				end
			end
      end
        next_state = HESWS; // Transition to all-red before switching directions
      end
			next_ctr5 = 0;
			next_ctr10 = 0;
			next_state = ZESWS;
			// wait 2 clock cycles then turn red then go to RGR
		end
		next_state = GESWS;
      if(ctr5 == 0 && ctr10 == 0 && ((wss || ess) && !(wss|| wls || nss || nls || sls || sss))) begin
			next_state = GESWS;
		end else if(!(ess || wss) || ctr5 > 0) begin
			next_ctr5 = ctr5 + 1;
				if(ctr5 >= 4) begin
					if(!(els|| wls || nss || nls || sls || sss)) begin  //Default to Green East Straight and left if no traffic in other directions
					next_state = GESWS;
					end else begin
					next_state = YESWS;
					end
				end else begin
					next_state = GESWS;
				end
			end else if((els || wls || nss || nls || sls || sss) || ctr10 > 0) begin
				next_ctr10 = ctr10 + 1;
				if(ctr10 >= 9) begin
					next_state = YESWS;
				end else begin
					next_state = GESWS;
				end
			end
		end
		
    endcase
  end

// combination output driver  ("C2" block in the Harris & Harris Moore machine diagram)
  always_comb begin
    str_light  = red;      // cover all red plus undefined cases
	left_light = red;	   // default to red, then call out exceptions in case
	ns_light   = red;
    case(present_state)    // Moore machine
     GRR:     str_light  = green;
	  YRR,ZRR: str_light  = yellow;  // my dual yellow states -- brute force way to make yellow last 2 cycles
	  RGR:     left_light = green;
	  RYR,RZR: left_light = yellow;
	  RRG:     ns_light   = green;
	  RRY,RRZ: ns_light   = yellow;
    endcase
  end

endmodule