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

Model* lpNewModel(Env* env, int nbVars, int nbCtr, double** bounds, double** ctr, double* obj){
	IloEnv* e = (IloEnv*) env;
	LP* pt = new LP(*e,nbVars);
	int i = 0;
	for (i=0; i < nbCtr; i++)
		pt->addConstraint(bounds[i][0], ctr[i], bounds[i][1]);
	pt->setObjective(obj,Max);
	
	printf("[C] model successfully loaded : %d vars, %d ctrs\n",nbVars,nbCtr);
	return (void*) pt;
}

double* solveLP(Model* model){
	LP* m = (LP*) model;
	IloNumArray* a = m->solve();
	int n = m -> getNbVars();
	double* ans = (double*) malloc (n*sizeof(double));
	if (NULL == ans)
		return ans;
	int i=0;
	for (i=0; i< n; i++)
		ans[i] = (*a)[i];
	return (double*) ans;

}
}





