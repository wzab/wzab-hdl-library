#!/usr/bin/python
"""
 Implementation of the class for adders' tree
"""

import sys

class Level(object):
    """
     Class level describes a single level of the adders' tree
    """
    def __init__(self, a_l, a_n, a_m, a_w):
        """
          a_l - number of the level
          a_n - number of inputs
          a_m - number of bits in the input word
          a_w - number of bits in the adder word
        """
        self.lev = a_l
        self.n_ins = a_n
        self.n_bits = a_m
        self.a_width = a_w
        self.n_outs = 0
        self.n_adders = 0
        self.bind_ins = []
        self.bind_outs = []
        #Now we proceed with building of the binding tables
        in_n = 0
        s_bit = 0
        e_bit = a_m
        max_bit = 0 # To enforce allocation of the first adder
        while in_n < self.n_ins:
            #Check if the word fits in current adder
            if e_bit > max_bit:
                # Word doesn't fit, allocate new adder
                self.n_adders += 1
                s_bit = 0
                e_bit = a_m
                max_bit = a_w-1
            nmaps = 1
            # Check if the second input is available, if not, we will
            # map only one signal!
            if in_n+1 < self.n_ins:
                nmaps = 2
            self.bind_ins.append({'n':in_n, 'a': self.n_adders-1, \
                                        's': s_bit, 'e': e_bit-1, 'ns':nmaps})
            #Map the output
            self.bind_outs.append({'n':self.n_outs, 'a':self.n_adders-1, \
                                        's':s_bit, 'e':e_bit})
            self.n_outs += 1
            #Increase numbers of bits
            s_bit += a_m+1
            e_bit += a_m+1
            #Skip to the next pair of inputs
            in_n += 2
            
    def gen_decl(self, n_indent):
        """
         This method generates the declarations section for that level
        """
        txt = ""
        # generate input signals for that level
        for i in range(0, self.n_ins):
            txt += n_indent*" "+"signal lev"+str(self.lev)+"s"+str(i)+\
                 " : unsigned("+str(self.n_bits-1)+" downto 0);\n"
        # generate adder signals for that level
        for i in range(0, self.n_adders):
            txt += n_indent*" "+"signal lev"+str(self.lev)+"a"+str(i)+\
                       ", lev"+str(self.lev)+"b"+str(i)+\
                       ", lev"+str(self.lev)+"c"+str(i)+\
                    " : unsigned("+str(self.a_width-1)+" downto 0);\n"
        return txt
    def gen_comb(self ,  n_indent):
        """
         This method generates the combinational partof
         the implementation section for that level
        """
        # for each adder we generate mappings of the input signals
        t_b = [n_indent*" "+"lev"+str(self.lev)+"b"+str(i)+ \
              " <=  (" for i in range(0,  self.n_adders)]
        t_a = [n_indent*" "+"lev"+str(self.lev)+"a"+str(i)+\
              " <=  (" for i in range(0,  self.n_adders)]
        # Now we go through the input mapping array and complete definitions
        for m_d in self.bind_ins:
            for j_a in range(m_d['s'],  m_d['e']+1):
                t_a[m_d['a']] += str(j_a) +" => lev"+\
                str(self.lev)+"s"+str(m_d['n'])+\
                "("+str(j_a-m_d['s'])+"), "
            if m_d['ns'] == 2:
                # Map next input
                for j_a in range(m_d['s'],  m_d['e']+1):
                    t_b[m_d['a']] += str(j_a)+ " => lev"+\
                    str(self.lev)+"s"+str(m_d['n']+1)+\
                    "("+str(j_a-m_d['s'])+"), "

        #All unset bits should be set to zeroes
        for i_a in range(0, self.n_adders):
            t_a[i_a] += " others => '0');\n"
            t_b[i_a] += " others => '0');\n"
        # generate mapping of output signals
        t_o = ""
        for m_d in self.bind_outs:
            t_o += n_indent*" "+\
                      "lev"+str(self.lev+1)+"s"+str(m_d['n'])+" <= "+\
                      "lev"+str(self.lev)+"c"+str(m_d['a'])+"("+\
                      str(m_d['e'])+" downto "+str(m_d['s'])+");\n"
        # Now we generate the output text
        txt = ""
        for s_a in t_a:
            txt += s_a
        for s_a in t_b:
            txt += s_a
        for s_a in t_o:
            txt += s_a
        return txt

    def gen_rst(self,  n_indent):
        """
         This method generates the reset sequence
          for sequential part of the implementation
        """
        txt = ""
        for i in range(0,  self.n_adders):
            txt += n_indent*" "+"lev"+str(self.lev)+"c"+\
                          str(i)+" <= (others => \'0\');\n"
        return txt

    def gen_seq(self,  n_indent):
        """
         This method generates the sequential part of
         the implementation section for that level
        """
        txt = ""
        for i in range(0,  self.n_adders):
            txt += n_indent*" "+"lev"+str(self.lev)+"c"+str(i)+" <= "+\
                       "lev"+str(self.lev)+"a"+str(i)+" + "+\
                       "lev"+str(self.lev)+"b"+str(i)+";\n"
        return txt
        

def main():
    """
     Main procedure generating the binary tree of adders
    """
    if len(sys.argv) != 5:
        print """
        Correct calling syntax: gen_parallel_adder.py n m k name
        n - number of input values
        m - length of input words
        k - length of input operand in the hardware adder
        name - name of the component which will be generated.
        
        The tool generates {name}.vhd file with implementation of the adders' tree
        and {name}_pkg.vhd file with necessary types, and information
        about the latency.
        """
        return
    arg_n, arg_m,  arg_k = [int(sys.argv[i]) for i in range(1, 4)]
    arg_name = sys.argv[4]
    pkg_name = arg_name.upper()+"_pkg"
    pkg_fname = arg_name.lower()+"_pkg.vhd"
    ent_fname = arg_name.lower()+".vhd"
    #Name of the type describing inputs
    in_type_name = "T_"+arg_name.upper()+"_INPUTS"
    latency_name = arg_name.upper()+"_LATENCY"
    
    levels = []
    n_of_levels = 0
    n_sigs = arg_n
    n_bits = arg_m
    #Create levels
    while n_sigs > 1:
        nxt_level = Level(n_of_levels,  n_sigs, n_bits,  arg_k)
        levels.append(nxt_level)
        n_sigs = nxt_level.n_outs
        n_bits += 1
        n_of_levels += 1
    #The output signal for the highest level is not generated in 
    # Level objects. We have to generate it now
    top_decl = "signal lev"+str(n_of_levels)+"s0 : unsigned("+\
                      str(n_bits-1)+" downto 0);\n"
    #we also generate the assignment for that signal
    top_comb = "dout <= lev"+str(n_of_levels)+"s0;\n"
    #Generate the source code for the package
    n_latency = n_of_levels # Each level introduces latency od one clock
    txt = ""
    txt += "library ieee;\n"+\
           "use ieee.std_logic_1164.all;\n"+\
           "use ieee.numeric_std.all;\n"
    txt += "package "+pkg_name+" is\n"
    txt += "type "+in_type_name+" is array("+str(arg_n - 1)+\
           " downto 0) of unsigned("+str(arg_m-1)+\
           " downto 0);\n"
    txt += "constant "+latency_name+" : integer :="+str(n_latency)+";\n"
    txt += "end "+pkg_name+";\n"
    fout = open(pkg_fname, "w")
    fout.write(txt)
    fout.close()
    #Generate the source code for our tree
    txt = ""
    txt += "library ieee;\n"+\
            "use ieee.std_logic_1164.all;\n"+\
            "use ieee.numeric_std.all;\n\n"+\
            "library work;\n"+\
            "use work."+pkg_name+".all;\n"+\
            "entity "+arg_name+" is\n\n"+\
            "  port (\n"+\
            "        din  :  in "+in_type_name+";\n"+\
            "        clk  :  in std_logic;\n"+\
            "        rst_n  :  in std_logic;\n"+\
            "        dout :  out unsigned("+str(n_bits-1)+" downto 0)\n"+\
            "        );\n"+\
            "end "+arg_name+";\n\n"
    txt +=  "architecture beh1 of "+arg_name+" is\n"
    #Now add declarations for all levels
    for lev in levels:
        txt += lev.gen_decl(10)
    txt += 10*" "+top_decl
    txt += " begin\n"
    #Now add implementation of the combinatorial part
    # Mapping of level 0 input signals
    for i_a in range(0, arg_n):
        txt += 10*" "+"lev0s"+str(i_a)+" <= din("+str(i_a)+");\n"
    for lev in levels:
        txt += lev.gen_comb(10)
    txt += 10*" "+top_comb
    #Now add declaration of the sequential process
    txt += " process (clk, rst_n)\n"
    txt += " begin\n"
    txt += " if rst_n='0' then\n"
    #Reset sequence
    for lev in levels:
        txt += lev.gen_rst(10)
    txt += " elsif clk\'event and clk=\'1\' then\n"
    for lev in levels:
        txt += lev.gen_seq(10)
    #End of process
    txt += " end if;\n"
    #End of architecture
    txt += " end process;\n"
    txt += " end architecture;\n"
    fout = open(ent_fname, "w")
    fout.write(txt)
    fout.close()        
    return None

main()
    
