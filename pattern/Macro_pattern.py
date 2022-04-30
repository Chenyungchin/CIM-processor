# need to generate the following  files
# 1. command.dat: Composed of 3 bit. 1-hot-encoding to denote CIM_en/STDW/STDR
# 2. STD_A.dat: 
# 3. weight_in.dat: 
# 4. act_in.dat: 
# 5. weight_out.dat:
# 6. PSUM_out.dat: 
import random

def gen_val(bit):
    a = random.randrange(0, pow(2, bit))
    return a

def binarize(val, width):
    return bin(val)[2:].zfill(width)

def mult_and_add(act_in, weight):
    out = 0
    for i in range(64):
        w = weight[i]
        a, act_in = act_in % 16, act_in // 16
        out += w * a
    return out

def mult_and_add_8x(act_in, weight):
    out_array = []
    for i in range(8):
        w = [val % 16 for val in weight]
        weight = [val // 16 for val in weight]
        out_array.append(mult_and_add(act_in, w))
    
    out = 0
    for i in range(8):
        out += pow(2, 14*i) * out_array[i]
    return out
    
def write_val(f_command, f_std_a, f_weight_in, f_act_in, f_weight_out, f_PSUM_out):
    # ====================== STD write for 64 cycles ==============================
    weight = [0] * 64
    for i in range(64):
        # cmd
        f_command.write('010\n')
        # std_a
        f_std_a.write(binarize(i, 6) + '\n')
        # weight_in
        new_weight_in = gen_val(32)
        weight[i] = new_weight_in
        f_weight_in.write(binarize(new_weight_in, 32) + '\n')
        # act_in
        new_act_in = gen_val(256)
        f_act_in.write(binarize(new_act_in, 256) + '\n')
        # weight_out
        f_weight_out.write(binarize(0, 32) + '\n')
        # PSUM_out 
        f_PSUM_out.write(binarize(0, 112) + '\n')
        
    # ====================== STD read x 5 =========================================
    for i in range(5):
        # cmd
        f_command.write('001\n')
        # std_a
        rand_address = gen_val(6)
        f_std_a.write(binarize(rand_address, 6) + '\n')
        # weight_in
        new_weight_in = gen_val(32)
        f_weight_in.write(binarize(new_weight_in, 32) + '\n')
        # act_in
        new_act_in = gen_val(256)
        f_act_in.write(binarize(new_act_in, 256) + '\n')
        # weight_out
        f_weight_out.write(binarize(weight[rand_address], 32) + '\n')
        # PSUM_out
        f_PSUM_out.write(binarize(0, 112) + '\n')
        
    # =================== CIM operation x 100 ======================================
    for i in range(100):
        # cmd
        f_command.write('100\n')
        # std_a
        rand_address = gen_val(6)
        f_std_a.write(binarize(rand_address, 6) + '\n')
        # weight_in
        new_weight_in = gen_val(32)
        f_weight_in.write(binarize(new_weight_in, 32) + '\n')
        # act_in
        new_act_in = gen_val(256)
        f_act_in.write(binarize(new_act_in, 256) + '\n')
        # weight_out
        f_weight_out.write(binarize(0, 32) + '\n')
        # PSUM_out
        PSUM = mult_and_add_8x(new_act_in, weight)
        f_PSUM_out.write(binarize(PSUM, 112) + '\n')
        
        
        
    
    
def write_pattern(pattern_num):
    with open('./Macro_pattern/command.dat', 'w+') as f_command:
        with open('./Macro_pattern/STD_A.dat', 'w+') as f_std_a:
            with open('./Macro_pattern/weight_in.dat', 'w+') as f_weight_in:
                with open('./Macro_pattern/act_in.dat', 'w+') as f_act_in:
                    with open('./Macro_pattern/weight_out.dat', 'w+') as f_weight_out:
                        with open('./Macro_pattern/PSUM.dat', 'w+') as f_PSUM_out:
                            for i in range(pattern_num):
                                write_val(f_command, f_std_a, f_weight_in, f_act_in, f_weight_out, f_PSUM_out)
                
    
if __name__ == '__main__':
    write_pattern(1)