# need to generate the following  files
# 1. command.dat: Composed of 3 bit to denote CIM_en/STDW/STDR
# 2. STD_A.dat
# 3. weight_in.dat 
# 4. act_in1.dat
# 5. act_in2.dat
# 6. act_in3.dat
# 7. weight_out.dat
# 8. PSUM_out.dat

# =======test pattern =============
# || filter size      : 3x3x64   ||
# || number of filters: 8        ||
# || activation size  : 5x5x64   ||
# || output size      : 3x3x8    ||
# =================================
import random
    

def gen_val(bit):
    a = random.randrange(0, pow(2, bit))
    return a

def binarize(val, width):
    return bin(val)[2:].zfill(width)

# generate a 3-D matrix with the height "h", width "w", depth "d" and bit precision "bit"
def gen_matrix(h, w, d, bit):
    row = []
    for i in range(h):
        column = []
        for j in range(w):
            channel = []
            for k in range(d):
                num = gen_val(bit)
                channel.append(num)
            column.append(channel)
        row.append(column)
    return row

# given all filters and address, return the bit string that should stream into the array
def parse_filter(filters, addr):
    out = [[0, 0, 0], [0, 0, 0], [0, 0, 0]] # 3x3
    for i in range(8):
        filt = filters[i]
        for j in range(3):
            for k in range(3):
                out[j][k] += filt[j][k][addr] * pow(16, i)
    
    bit_str = ''
    for i in range(3):
        for j in range(2, -1, -1):
            bit_str = binarize(out[i][j], 32) + bit_str
    return bit_str

# given the activation channel (pixel), return the bit string that should stream into the module
def parse_activation(activation):
    bit_str = ''
    for val in activation:
        bit_str = binarize(val, 4) + bit_str
    return bit_str

def calc_PSUM(filters, activation, row, col):
    out = []
    # activation
    act = []
    for i in range(3):
        row_val = []
        for j in range(3):
            if (col+j < 2 or col+j > 6):
                pixel = [0] * 64
                
            else:
                pixel = activation[row+i][col-2+j]
            row_val.append(pixel)
        act.append(row_val)
        
    # filter
    out = ''
    for i in range(8):
        filt = filters[i]
        res = mult3D(filt, act)
        out = binarize(res, 18) + out
    return out
        
def mult3D(filt, act):
    val = 0
    for i in range(3):
        for j in range(3):
            for k in range(64):
                val += filt[i][j][k] * act[i][j][k]
    return val
    
    
def write_val(f_command, f_std_a, f_weight_in, f_act_in1, f_act_in2, f_act_in3, f_weight_out, f_PSUM_out):
    # ====================== STD write for 64 cycles ==============================
    # generate filters
    filters = []
    for i in range(8):
        filters.append(gen_matrix(3, 3, 64, 4))
    # store filters into array
    for i in range(64):
        # cmd
        f_command.write('010\n')
        # std_a
        f_std_a.write(binarize(i, 6) + '\n')
        # weight_in
        new_weight_in_string = parse_filter(filters, i)
        f_weight_in.write(new_weight_in_string + '\n')
        # act_in
        f_act_in1.write(binarize(0, 256) + '\n')
        f_act_in2.write(binarize(0, 256) + '\n')
        f_act_in3.write(binarize(0, 256) + '\n')
        # weight_out
        f_weight_out.write(binarize(0, 288) + '\n')
        # PSUM_out 
        f_PSUM_out.write(binarize(0, 143) + '\n')
        
        
    # =================== CIM operation ===========================================
    # generate input activations
    activation = gen_matrix(5, 5, 64, 4)
    
    for row in range(3):
        for col in range(7):
            # cmd
            f_command.write('100\n')
            # std_a
            f_std_a.write(binarize(0, 6) + '\n')
            # weight_in
            f_weight_in.write(binarize(0, 288) + '\n')
            # act_in
            if col > 4:
                act_in1 = binarize(0, 256)
                act_in2 = binarize(0, 256)
                act_in3 = binarize(0, 256)
            else:
                act_in1 = parse_activation(activation[row][col])
                act_in2 = parse_activation(activation[row+1][col])
                act_in3 = parse_activation(activation[row+2][col])
            f_act_in1.write(act_in1 + '\n')
            f_act_in2.write(act_in2 + '\n')
            f_act_in3.write(act_in3 + '\n')
            # weight_out
            f_weight_out.write(binarize(0, 288) + '\n')
            # PSUM_out
            PSUM = calc_PSUM(filters, activation, row, col)
            f_PSUM_out.write(PSUM + '\n')
        
        
        
    
    
def write_pattern(pattern_num):
    with open('./CIM_Unit_pattern/command.dat', 'w+') as f_command:
        with open('./CIM_Unit_pattern/STD_A.dat', 'w+') as f_std_a:
            with open('./CIM_Unit_pattern/weight_in.dat', 'w+') as f_weight_in:
                with open('./CIM_Unit_pattern/act_in1.dat', 'w+') as f_act_in1:
                    with open('./CIM_Unit_pattern/act_in2.dat', 'w+') as f_act_in2:
                        with open('./CIM_Unit_pattern/act_in3.dat', 'w+') as f_act_in3:
                            with open('./CIM_Unit_pattern/weight_out.dat', 'w+') as f_weight_out:
                                with open('./CIM_Unit_pattern/PSUM.dat', 'w+') as f_PSUM_out:
                                    for i in range(pattern_num):
                                        write_val(f_command, f_std_a, f_weight_in, f_act_in1, f_act_in2, f_act_in3, f_weight_out, f_PSUM_out)
                
    
if __name__ == '__main__':
    write_pattern(1)