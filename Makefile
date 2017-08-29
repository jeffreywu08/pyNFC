# location of the Python header files
PYTHON_VERSION = 2.7
PYTHON_INCLUDE = /p/home/sblair/anaconda2/include/python$(PYTHON_VERSION)
PYTHON_LIB=/p/home/sblair/anaconda2/lib
BOOST_PYLIB = py27
 
# location of the Boost Python include files and library
 
BOOST_INC = /app/COST/boost/1.58.0/gnu/include
BOOST_LIB = /app/COST/boost/1.58.0/gnu/lib

# compile mesh classes
TARGET = LBM_Interface
FILE=PyLBM_Interface
EXT=cpp

# varibles that work on local laptopt
#MPI_CC=pgc++
#MPI_CC=g++
##MPI_FLAGS=-fast  -fPIC -std=c++11 -acc -ta=tesla:cc50
#MPI_FLAGS=-fast -fPIC -std=c++11 -mp=nonuma -Minfo
#MPI_FLAGS=-O3 -fopenmp -std=c++11 -fPIC
MPI_CC=mpic++
##MPI_FLAGS=-fast  -fPIC -std=c++11 -acc -ta=tesla:cc50
MPI_FLAGS=-std=c++11 -O3 -Wall -fPIC -fopenmp

PYTHON_INCLUDE = /home/stu/anaconda2/include/python$(PYTHON_VERSION)
MPI4PY_INCLUDE = /home/stu/anaconda2/lib/python2.7/site-packages/mpi4py/include
PYTHON_LIB=/home/stu/anaconda2/lib
BOOST_INC = /usr/include
BOOST_LIB = /usr/lib/x86_64-linux-gnu

# for compilation on SHEPARD/CONRAD with PGI or CRAY compilers
ifeq ($(PE_ENV),PGI)
	MPI_CC=CC
	MPI_FLAGS= -std=c++11 -fast -fPIC \
	-mp=nonuma -Minfo
	PYTHON_INCLUDE = /p/home/sblair/anaconda2/include/python$(PYTHON_VERSION)
	PYTHON_LIB=/p/home/sblair/anaconda2/lib
        MPI4PY_INCLUDE=/p/home/sblair/anaconda2/lib/python2.7/site-packages/mpi4py/include
	BOOST_INC=/app/COST/boost/1.58.0/gnu/include
	BOOST_LIB=/app/COST/boost/1.58.0/gnu/lib
endif

ifeq ($(PE_ENV),CRAY)
	MPI_CC=CC
	MPI_FLAGS=-O3 -h omp  -hlist=m -fPIC -h std=c++11
	PYTHON_INCLUDE=/p/home/sblair/anaconda2/include/python$(PYTHON_VERSION)
	PYTHON_LIB=/p/home/sblair/anaconda2/lib
        MPI4PY_INCLUDE=/p/home/sblair/anaconda2/lib/python2.7/site-packages/mpi4py/include
	BOOST_INC=/app/COST/boost/1.58.0/gnu/include
	BOOST_LIB=/app/COST/boost/1.58.0/gnu/lib
endif

ifeq ($(PE_ENV),INTEL)
	MPI_CC=CC
	MPI_FLAGS=-O3 -std=c++11 -xHost -openmp -fPIC
	PYTHON_INCLUDE=/p/home/sblair/anaconda2/include/python$(PYTHON_VERSION)
	PYTHON_LIB=/p/home/sblair/anaconda2/lib
        MPI4PY_INCLUDE=/p/home/sblair/anaconda2/lib/python2.7/site-packages/mpi4py/include
	BOOST_INC=/app/COST/boost/1.58.0/gnu/include
	BOOST_LIB=/app/COST/boost/1.58.0/gnu/lib
endif

ifeq ($(PE_ENV),GNU)
	MPI_CC=CC
	MPI_FLAGS=-O3 -fopenmp -std=c++11 -fPIC
	PYTHON_INCLUDE=/p/home/sblair/anaconda2/include/python$(PYTHON_VERSION)
	PYTHON_LIB=/p/home/sblair/anaconda2/lib
        MPI4PY_INCLUDE=/p/home/sblair/anaconda2/lib/python2.7/site-packages/mpi4py/include
	BOOST_INC=/app/COST/boost/1.58.0/gnu/include
	BOOST_LIB=/app/COST/boost/1.58.0/gnu/lib
endif

MY_LIBS= -lboost_python-$(BOOST_PYLIB) -lpython$(PYTHON_VERSION)

SOURCES= Lattice.cpp D3Q15Lattice.cpp D3Q19Lattice.cpp D3Q27Lattice.cpp LBM_DataHandler.cpp \
	LBM_HaloData.cpp LBM_HaloDataOrganizer.cpp  
OBJECTS= Lattice.o  D3Q15Lattice.o D3Q19Lattice.o D3Q27Lattice.o LBM_DataHandler.o  \
	LBM_HaloData.o LBM_HaloDataOrganizer.o
	 

$(FILE).so: $(FILE).o $(OBJECTS)
	$(MPI_CC) $(MPI_FLAGS) -shared -Wl,--export-dynamic $(FILE).o -L$(BOOST_LIB) -lboost_python -L$(PYTHON_LIB) -lpython$(PYTHON_VERSION) -o $(TARGET).so $(OBJECTS)
 
$(FILE).o: $(FILE).cpp
	$(MPI_CC) $(MPI_FLAGS) -I$(PYTHON_INCLUDE) -I$(BOOST_INC) -I$(MPI4PY_INCLUDE) -c $(FILE).$(EXT)

%.o:%.cpp
	$(MPI_CC) $(MPI_FLAGS)  -c $^

clean:
	rm -f *.o *.so $(TARGET) *~



