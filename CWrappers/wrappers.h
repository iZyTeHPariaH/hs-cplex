#ifndef CWRAPPERS_WRAPPERS_H
#define CWRAPPERS_WRAPPERS_H
#include "LP.h" 
extern "C" {
        IloEnv* env = new IloEnv();
	typedef void Env;
	typedef void Model;
	
	double build (double*);
	//Env* lpInitSolver(void);
	Model* lpNewModel(int nbNumVars, int nbBoolVars, int nbIntVars, int nbCtr, double** bounds, double*** ctr, double** obj);
	double** solveLP(Model* model);

	void lpRemoveModel(Model* m);
}
#endif
