#!/usr/bin/env python
"""
Data processing script for LBM binary data files.

Call this script from the same directory where the LBM input file
resides as well as all of the *.b_dat files from the simulation.

No arguments are needed.

Usage:

>>python ./process_lbm_data.py

When done, you should have a set of *.vtk files containing
pressure and velocity magnitude scalar data and velocity vector data.

"""


from mpi4py import MPI
import numpy as np

#from vtkHelper import saveVelocityAndPressureVTK_binary as writeVTK

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

import sys
sys.path.insert(1,'.')
from vtkHelper import saveVelocityAndPressureVTK_binary as writeVTK

# Information about the LBM run that produced the data - I should get this from params.lbm

# Read data from params.lbm
input_file_name = 'params.lbm'
input_data = open(input_file_name,'r')
latticeType = str(input_data.readline().rstrip())
Num_ts = int(input_data.readline())
ts_rep_freq = int(input_data.readline())
Warmup_ts = int(input_data.readline())
plot_freq = int(input_data.readline())
Cs = float(input_data.readline())
rho_lbm = float(input_data.readline())
u_lbm = float(input_data.readline())
omega = float(input_data.readline())
Nx = int(input_data.readline())
Ny = int(input_data.readline())
Nz = int(input_data.readline())
Restart_flag = int(input_data.readline())
TimeAvg_flag = int(input_data.readline())
Lx_p = float(input_data.readline())
Ly_p = float(input_data.readline())
Lz_p = float(input_data.readline())
t_conv_fact = float(input_data.readline())
l_conv_fact = float(input_data.readline())
p_conv_fact = float(input_data.readline())

input_data.close()

#u_conv_fact = l_conv_fact/t_conv_fact;
u_conv_fact = t_conv_fact/l_conv_fact;
if(rank == 0):
   print("u_conv_fact = %8.3e \n"%u_conv_fact)
nnodes = Nx*Ny*Nz

# compute geometric data only once
x = np.linspace(0.,Lx_p,Nx).astype(np.float64);
y = np.linspace(0.,Ly_p,Ny).astype(np.float64);
z = np.linspace(0.,Lz_p,Nz).astype(np.float64);
numEl = Nx*Ny*Nz
Y,Z,X = np.meshgrid(y,z,x);

XX = np.reshape(X,numEl)
YY = np.reshape(Y,numEl)
ZZ = np.reshape(Z,numEl)

# compute the number of data dumps I expect to process
nDumps = (Num_ts-Warmup_ts)/plot_freq + 1 # initial data plus Num_ts/plot_freq updates

# load obst_file.lbm to get the obstacle.  Should also zero out the velocity of
# the walls.



for i in range(rank,nDumps,size):
    # say something comforting
    print 'processing data dump number %d of %d. '%(i+1,nDumps) # make this ones-based numbering
    # filename format
    rho_fn = 'density'+str(i)+'.b_dat'
    ux_fn = 'ux'+str(i)+'.b_dat'
    uy_fn = 'uy'+str(i)+'.b_dat'
    uz_fn = 'uz'+str(i)+'.b_dat'
    ux = np.fromfile(ux_fn,dtype=np.float32).astype(np.float64)
    uy = np.fromfile(uy_fn,dtype=np.float32).astype(np.float64)
    uz = np.fromfile(uz_fn,dtype=np.float32).astype(np.float64)
    pressure = np.fromfile(rho_fn,dtype=np.float32).astype(np.float64)
    
    # convert velocity to physical units
    ux /= u_conv_fact
    uy /= u_conv_fact
    uz /= u_conv_fact
    pressure /= p_conv_fact # please check this...
    outfilename = 'velocityAndPressure'+str(i)+'.vtk'
    dims = (Nx,Ny,Nz)
    writeVTK(pressure,ux,uy,uz,XX,YY,ZZ,outfilename,dims)











