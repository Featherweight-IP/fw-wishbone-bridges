'''
Created on Dec 8, 2020

@author: mballance
'''

import cocotb
import pybfms

@cocotb.test()
async def entry(top):
    await pybfms.init()
    
    print("entry")
    i_bfm = pybfms.find_bfm(".*init_bfm")
    t_bfm = pybfms.find_bfm(".*targ_bfm")

    for i in range(10):
        await i_bfm.write(0x1000+i, 0x55AA0000+i, 0xF)
    
    for i in range(10):
        await i_bfm.read(0x1000+i)
    