import random

def gen_val():
    a = random.randrange(0, 8)
    b = random.randrange(0, 8)
    c = a + b
    return a, b, c
    
def write_val(fa, fb, fc):
    a, b, c = gen_val()
    fa.write(bin(a)[2:].zfill(3))
    fa.write('\n')
    fb.write(bin(b)[2:].zfill(3))
    fb.write('\n')
    fc.write(bin(c)[2:].zfill(4))
    fc.write('\n')
    
def write_pattern(pattern_num):
    with open('./add_in_a.dat', 'w+') as fa:
        with open('./add_in_b.dat', 'w+') as fb:
            with open('./add_out_c.dat', 'w+') as fc:
                for i in range(pattern_num):
                    write_val(fa, fb, fc)
                
    
if __name__ == '__main__':
    pattern_num = 100
    write_pattern(pattern_num)