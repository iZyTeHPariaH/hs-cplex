//#include <ilcplex/ilocplex.h>

#include "wrappers.h"

extern "C" { 
double build(double* lc ){
	printf("lc[0]=%f\n",*lc);
	return lc[1];
}
Env* lpInitSolver(void){
	IloEnv* e = new IloEnv();
	return (void*) e;
}

Model* lpNewModel(int nbNumVars, int nbBoolVars, int nbIntVars,
		  int nbCtr,
		  double** bounds, double*** ctr, double** obj){

	
	
	LP* pt = new LP(*env,nbNumVars,nbBoolVars,nbIntVars);
	int i = 0;
	for (i=0; i < nbCtr; i++)
		pt->addConstraint(bounds[i][0], ctr[i][0], ctr[i][1], ctr[i][2], bounds[i][1]);
	pt->setObjective(obj[0],obj[1],obj[2],Max);
	
	printf("[C] model successfully loaded : %d numvar, %d binvar, %d intvar, %d ctrs\n",nbNumVars, nbBoolVars, nbIntVars, nbCtr);
	return (void*) pt;
}

double** solveLP(Model* model){
	LP* m = (LP*) model;
	return m->solve();

}
void lpRemoveModel(Model* model){
	LP* m = (LP*) model;
	delete m;
}
}





