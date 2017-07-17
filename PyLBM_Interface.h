#ifndef PYLBM_INTERFACE_H_
#define PYLBM_INTERFACE_H_

#include "Lattice.h"
#include "D3Q15Lattice.h"
#include "D3Q19Lattice.h"
#include "D3Q27Lattice.h"
#include "LBM_DataHandler.h"

#include <boost/python.hpp>

class PyLBM_Interface
{
public:
  PyLBM_Interface(const int numSpd);
  ~PyLBM_Interface();
  void set_fIn(boost::python::object obj);
  void get_fOut(boost::python::object obj);
  void computeFout();
  int get_numSpd();
  LBM_DataHandler fData;
  Lattice * myLattice;


private:
  float * fIn;
  float * fOut;
  int numSpd;
  float u_bc;
  float rho_bc;
  float omega;
  int nd_type;

};


#endif