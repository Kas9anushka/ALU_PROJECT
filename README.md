The Parameterized Arithmetic Logic Unit (ALU) is a configurable digital design 
developed using Verilog HDL to perform a wide range of arithmetic, logical, shift, rotate, 
and comparison operations. The design is parameterized, allowing the operand width to 
be modified easily based on system requirements, making the ALU scalable and reusable 
for different hardware applications. 
The ALU operates using synchronous clock-based processing with support for reset and 
clock enable functionality. The design accepts three parameterized operands, OPA ,OPB 
and CMD, along with control signals such as MODE,  INP_VALID, and CIN to 
determine the required operation. Depending on the selected mode, the ALU performs 
either arithmetic operations or logical operations. 
The arithmetic section supports operations such as unsigned addition, subtraction, 
increment, decrement, signed addition, signed subtraction, comparison, and 
multiplication-based operations. The logical section supports bitwise operations including 
AND, OR, XOR, NAND, NOR, XNOR, NOT operations, shift operations, and rotate 
operations. Special attention is given to signed arithmetic operations where overflow 
detection, carry generation, and comparator outputs are implemented. 
The ALU design also includes status outputs such as: 
- Carry Out (COUT)  
- Overflow (OFLOW)  
- Greater Than (G)  
- Less Than (L)  
- Equal (E)  
- Error (ERR)  
These outputs help in identifying arithmetic conditions, comparison results, and invalid 
operation scenarios.  
The design follows a multi-cycle timing behavior where input operands are applied to the 
DUT (Device Under Test), processed internally, and the corresponding outputs are 
captured after the required latency. This timing-based architecture helps in developing 
synchronized driver and monitor logic during verification. 
A dedicated verification environment is developed to validate the functionality of the 
ALU.  
The project focuses on developing a RTL design along with a robust testbench 
architecture to ensure correctness, reliability, and complete functional verification of the 
ALU operations. The design and verification process is carried out using industry
standard EDA tools such as Questa SIM.
