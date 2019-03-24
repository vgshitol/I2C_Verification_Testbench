#Following are some Important Notes:

### 1.
`+GEN_TRANS_TYPE=$(GEN_TRANS_TYPE)` : Important to change this in the make file.

### 2.
`wb_transaction/i2c_transaction` : Depends on the flow of code.

### 3.
`disable scoreboard` : check the basic functionality of the wishbone and i2c 

### 4. 
`infinite monitor` : added a small delay #1 to the forever begin block to resolve the error 

### 5.
`Modify wb_if : irq_i`: the irq_i needs to be passed to wb_if in top.sv .