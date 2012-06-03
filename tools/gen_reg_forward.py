def select(i, c):
    top = str(i+1)+'*'+c if i > 0 else c
    bot = '0' if i == 0 else (c if i == 1 else str(i)+'*'+c)
    return '%s-1:%s' % (top, bot)

def sel_reg(i):
    return select(i, 'REG_ADDR_WIDTH')

def sel_data(i):
    return select(i, 'DATA_WIDTH')

for i in range(8):
    print '  wire Read_Data%d = Data[i_Read_Addr[%s]];' % (i, sel_reg(i))
    print '  reg Result%d;' % i
        
print '  always @(*) begin'
for i in range(8):
    for j in range(4):
        comp = 'i_Read_Addr[%s] == i_Write_Addr[%s]' % (sel_reg(i), sel_reg(j))
        print '    Result%d <= (i_Write_Enable[%d] & (%s)) ? i_Write_Data[%s] : Read_Data%d;' % (i, j, comp, j, i)
print '  end'

res = ['Result'+str(x) for x in range(8)]
res.reverse()
print '  assign o_Read_Data = {%s};' % ', '.join(res)
