## LVDS Loopback

This project can be used with the Efinity's Trion FPGA with the
LVDS IP. By this, LVDS working can be checked.

Proper connections for the LVDS lanes should be maintained in the
top design, if the correct data is being received in all the lanes
led[0] will go high, if proper data is not being received then it 
will be off.

The led[3] and led[4] is heartbeat rate on rx & tx clk.
