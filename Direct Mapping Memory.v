module Comparator(comparatorResult,tagCashe,tagAddress);

output comparatorResult;
input [19:0]tagCashe;
input [19:0]tagAddress;

assign comparatorResult=(tagCashe==tagAddress)?1'b1:1'b0;

endmodule

module ComparatorTb;

wire comparatorResult;
reg[19:0] tagCashe;
reg[19:0] tagAddress;
Comparator c(comparatorResult,tagCashe,tagAddress);

initial
begin
$monitor("%b %b %b",comparatorResult,tagCashe,tagAddress);
#10
tagCashe=20'b0000_0000_0000_0000_0001;
tagAddress=20'b0000_0000_0000_0000_0001;
#10
tagCashe=20'b0000_0000_0000_0000_0001;
tagAddress=20'b0000_0000_0000_0000_0011;
end
endmodule

module casheMemory(DataOutput,Hit,address,mode,DataInput);

wire Result;
reg [1023:0]cashe[52:0];
input wire[31:0]address;
input wire mode;
output reg [31:0]DataOutput;
output reg Hit;
input wire[31:0]DataInput;
wire comparatorResult;
Comparator c1(comparatorResult,cashe[address[11:2]][51:32],address[31:12]);
reg [1048576:0]Mem[7:0];
initial
begin
cashe[3][52]=1;
cashe[3][31:0]=32'b0000_0000_0000_0000_0000_0000_0000_0001;
cashe[3][51:32]=20'b0000_0000_0000_0000_0000;


cashe[1][52]=1;
cashe[1][31:0]=32'b0000_0000_0000_0000_0000_0000_0000_1111;
cashe[1][51:32]=20'b0000_0000_0000_0001_0000;


Mem[4][7:0]=8'b0000_1001;
Mem[5][7:0]=8'b0000_0000;
Mem[6][7:0]=8'b0000_0000;
Mem[7][7:0]=8'b0000_0000;
end

always @(address or mode)
begin
if(address[31:12]==cashe[address[11:2]][51:32] && cashe[address[11:2]][52]==1 && mode==1) /****************Read from Cashe**********************/
begin
 assign DataOutput=cashe[address[11:2]][31:0];
 Hit=(comparatorResult & cashe[address[11:2]][52]);
end
else if(address[31:12]!=cashe[address[11:2]][51:32] && cashe[address[11:2]][52]==1 && mode==1)
begin 

cashe[address[11:2]][7:0]=Mem[address][7:0];
cashe[address[11:2]][15:8]=Mem[address+1'b1][7:0];
cashe[address[11:2]][23:16]=Mem[address+2'b10][7:0];
cashe[address[11:2]][31:24]=Mem[address+2'b11][7:0];

cashe[address[11:2]][52]=1;
 cashe[address[11:2]][51:32]=address[31:12];
assign DataOutput=32'bx;
            
 Hit=(comparatorResult & cashe[address[11:2]][52]);

end
else
begin
 DataOutput=32'bx;
 Hit=1'bx;
end
end

always @(DataInput or address or mode) 
begin
if( cashe[address[11:2]][52]==0 && mode==0)
begin
cashe[address[11:2]][52]=1;
Mem[address][7:0]=DataInput[7:0];
Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0001][7:0]=DataInput[15:8];
Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0010][7:0]=DataInput[23:16];
Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0011][7:0]=DataInput[31:24];
cashe[address[11:2]][7:0]=Mem[address][7:0];
cashe[address[11:2]][15:8]=Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0001][7:0];
cashe[address[11:2]][23:16]=Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0010][7:0];
cashe[address[11:2]][31:24]=Mem[address+32'b0000_0000_0000_0000_0000_0000_0000_0011][7:0];
cashe[address[11:2]][51:32]=address[31:12];
Hit=(comparatorResult & cashe[address[11:2]][52]);
 
end
else
begin
 DataOutput=32'bx;
end
end
endmodule

module casheTb1;

wire[31:0]DataOutput;
wire Hit;
reg [31:0]address;
reg mode;
reg [31:0]DataInput;
casheMemory M(DataOutput,Hit,address,mode,DataInput);

initial
begin
$monitor("%b ,%b ,%b ,%b ,%b",mode,DataOutput,address,Hit,DataInput);


address=32'b0000_0000_0000_0000_0000_0000_0000_1100; /*DataOutput=9*/
mode=1;


#10
mode=0;
address=32'b0000_0000_0000_0000_0000_0000_0000_1000;
DataInput=32'b0000_0000_0000_0000_0000_0000_0000_1111;



#10
address=32'b0000_0000_0000_0000_0000_0000_0000_0100;                 /*DataOutput=9*/
mode=1;

#10
address=32'b0000_0000_0000_0000_0000_0000_0000_0000;
mode=1;


#10
address=32'b0000_0000_0000_0000_0000_0000_0000_0100;                 /*DataOutput=9*/
mode=1;



end
endmodule
