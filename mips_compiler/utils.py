import pdb
from map import R_INST, R_INST_O, I_INST, J_INST, REG

def scan_entry(lines):
    entry = {}
    for index, line in enumerate(lines):
        name = line.strip().split(' ')[0]
        if name[-1] == ':':
            entry[name[:-1]] = index
    return entry

def _interpret_r(inst, line_index):
    inst_dict = {}
    inst_dict['inst_str'] = ' '.join(inst)
    if inst[0] in R_INST:
        inst_bin = [bin(REG[inst[2]])[2:].zfill(5), 
                    bin(REG[inst[3]])[2:].zfill(5), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    str(0).zfill(5), 
                    bin(R_INST[inst[0]])[2:].zfill(6)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in R_INST_O:
        shamt = int(inst[3])
        shamt = shamt + 32 if shamt < 0 else shamt
        inst_bin = [str(0).zfill(5),
                    bin(REG[inst[2]])[2:].zfill(5),
                    bin(REG[inst[1]])[2:].zfill(5),
                    bin(shamt)[2:].zfill(5),
                    bin(R_INST_O[inst[0]])[2:].zfill(6)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    else:
        print('Instruction not found: {}'.format(inst[0]))
        return
    inst_dict['inst_bin'] = inst_bin
    inst_dict['line_index'] = line_index
    return inst_dict

def _interpret_i(inst, line_index, entry):
    inst_dict = {}
    inst_dict['inst_str'] = ' '.join(inst)
    if inst[0] in ['lui']:
        imm = int(inst[2])
        imm = imm + 65536 if imm < 0 else imm
        inst_bin = [bin(I_INST[inst[0]])[2:].zfill(6), 
                    str(0).zfill(5), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    bin(imm)[2:].zfill(16)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['addi', 'addiu', 'andi', 'slti', 'sltiu']:
        imm = int(inst[3])
        imm = imm + 65536 if imm < 0 else imm
        inst_bin = [bin(I_INST[inst[0]])[2:].zfill(6), 
                    bin(REG[inst[2]])[2:].zfill(5), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    bin(imm)[2:].zfill(16)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['beq', 'bne']:
        imm = entry[inst[3]] - line_index - 1
        imm = imm + 65536 if imm < 0 else imm
        inst_bin = [bin(I_INST[inst[0]])[2:].zfill(6), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    bin(REG[inst[2]])[2:].zfill(5), 
                    bin(imm)[2:].zfill(16)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['blez', 'bgtz', 'bgez', 'bltz']:
        #pdb.set_trace()
        imm = entry[inst[2]] - line_index - 1
        imm = imm + 65536 if imm < 0 else imm
        temp = 1 if inst[0] == 'begz' else 0
        inst_bin = [bin(I_INST[inst[0]])[2:].zfill(6), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    str(temp).zfill(5), 
                    bin(imm)[2:].zfill(16)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['sw', 'lw']:
        offset = int(inst[2].split('(')[0])
        offset = offset + 65536 if offset < 0 else offset
        reg_name = inst[2].split('(')[1].split(')')[0]
        inst_bin = [bin(I_INST[inst[0]])[2:].zfill(6), 
                    bin(REG[reg_name])[2:].zfill(5), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    bin(offset)[2:].zfill(16)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    else:
        print('Instruction not found: {}'.format(inst[0]))
        return
    inst_dict['inst_bin'] = inst_bin
    inst_dict['line_index'] = line_index
    return inst_dict

def _interpret_j(inst, line_index, entry):
    inst_dict = {}
    inst_dict['inst_str'] = ' '.join(inst)
    if inst[0] in ['j', 'jal']:
        offset = int(entry[inst[1]])
        offset = offset + 67108864 if offset < 0 else offset
        inst_bin = [bin(J_INST[inst[0]])[2:].zfill(6), 
                    bin(offset)[2:].zfill(26)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['jr']:
        inst_bin = [str(0).zfill(6), 
                    bin(REG[inst[1]])[2:].zfill(5), 
                    str(0).zfill(15), 
                    bin(J_INST[inst[0]])[2:].zfill(6)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    elif inst[0] in ['jalr']:
        inst_bin = [str(0).zfill(6), 
                    bin(REG[inst[2]])[2:].zfill(5), 
                    str(0).zfill(5),
                    bin(REG[inst[1]])[2:].zfill(5), 
                    str(0).zfill(5), 
                    bin(I_INST[inst[0]])[2:].zfill(6)]
        inst_bin = hex(int(''.join(inst_bin), 2))[2:].zfill(8)
    else:
        print('Instruction not found: {}'.format(inst[0]))
    inst_dict['line_index'] = line_index
    inst_dict['inst_bin'] = inst_bin
    return inst_dict

def interpret(instruction, line_index, entry):
    inst_unpcs = instruction.strip().split(' ')
    inst = []
    for item in inst_unpcs:
        inst.append(item[:-1] if item[-1] == ',' else item)
    if inst[0] == 'nop':
        return None
    elif inst[0][-1] == ':':
        return interpret(instruction.strip().split(':')[1], line_index, entry)
    elif inst[0] in R_INST or inst[0] in R_INST_O:
        return _interpret_r(inst, line_index)  
    elif inst[0] in I_INST:
        return _interpret_i(inst, line_index, entry)
    elif inst[0] in J_INST:
        return _interpret_j(inst, line_index, entry)
    else:
        print('Instruction not found: {}'.format(inst[0]))
        return

def interpret_file(input_path, output_path):
    with open(input_path) as file:
        input_lines = file.readlines()
        file.close()
    entry = scan_entry(input_lines)
    output_lines = []
    for index, input_line in enumerate(input_lines):
        output = interpret(input_line, index, entry)
        if not output == None:
            output_lines.append("ROMDATA[{}] <= 32'h{};  // {} \n". \
                                 format(index, output['inst_bin'], output['inst_str']))
    with open(output_path, 'w') as file:
        file.writelines(output_lines)
        file.close()
    return
