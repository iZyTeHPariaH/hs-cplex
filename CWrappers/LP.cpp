#include "LP.h"

LP::LP(const IloEnv& cenv, int n, int b, int i){
	this->env = IloEnv(cenv);
	this->model = IloModel(cenv);
	this->numVar = IloNumVarArray(cenv);
	this->boolVar = IloBoolVarArray(cenv);
	this->intVar = IloIntVarArray(cenv);

	this->nbNumVar = n;
	this->nbBoolVar = b;
	this->nbIntVar=i;
	
	int k=0;
	for (k=0; k < n; k++){
		IloNumVar v = IloNumVar(cenv);
		this->numVar.add(v);

	}
	for (k=0; k <b;k++){
		IloBoolVar v = IloBoolVar(cenv);
		this->boolVar.add(v);
	}
	for(k=0; k<i; k++){
		IloIntVar v = IloIntVar(cenv);
		this->intVar.add(v);
	}
	printf("Model successfully loaded\n");
}

void LP::addConstraint(double lb, double* nlc, double* blc, double* ilc, double ub){
	IloRange r = IloRange (this->env, lb, ub);
	int i = 0;
	for (i=0; i < this->nbNumVar;i++){
		r.setLinearCoef(this->numVar[i],nlc[i]);
	}
	for(i=0; i < this->nbBoolVar; i++)
		r.setLinearCoef(this->boolVar[i],blc[i]);
	for(i=0; i < this->nbIntVar; i++)
		r.setLinearCoef(this->intVar[i],ilc[i]);

	this->model.add(r);
}
void LP::setObjective(double* nlc, double* blc, double* ilc, int sense){
	IloObjective o;
	int i = 0;
	if (Max == sense)
		o = IloMaximize(this->env);
	else
		o = IloMinimize(this->env);
	for (i=0; i < this->nbNumVar;i++)
		o.setLinearCoef(this->numVar[i],nlc[i]);
	for (i=0; i < this->nbBoolVar; i++)
		o.setLinearCoef(this->boolVar[i],blc[i]);
	for (i=0; i < this->nbIntVar; i++)
		o.setLinearCoef(this->intVar[i],ilc[i]);

	this->model.add(o);
}
double** LP::solve(void){
	
	IloCplex cplex (this->model);
	cplex.exportModel("lpex.lp");
	if (! cplex.solve()){
		this->env.error() << "Failed to optimize LP\n"; 
		throw (-1);
	}
	IloNumArray nvals = IloNumArray (this->env);
	IloNumArray bvals = IloNumArray(this->env);
	IloNumArray ivals = IloNumArray(this->env);
	double* nans = NULL;
	double* bans = NULL; 
	double* ians = NULL;
	if (this->nbNumVar > 0){
		nans = (double*) malloc(this->nbNumVar*sizeof(double));
		cplex.getValues (this->numVar,nvals);}
	if (this->nbBoolVar > 0){
		bans = (double*) malloc(this->nbBoolVar*sizeof(double));
		cplex.getValues (this->boolVar.toNumVarArray(),bvals);}
	if (this->nbIntVar > 0){
		ians = (double*) malloc(this->nbIntVar*sizeof(double));
		cplex.getValues (this->intVar.toNumVarArray(),ivals);}
	this->env.out() << "Values : " << nvals << "\n";
	double** ans = (double**) malloc (3* sizeof(double*));
	if (NULL == nans && this->nbNumVar > 0 || 
	    NULL == bans && this->nbBoolVar > 0|| 
	    NULL == ians && this->nbIntVar > 0 ||
	    NULL == ans){
		printf("[C] Erreur d'allocation méméoire. Abandon.\n");
		return NULL;
	}
	int i =0;
	for (i=0; i < this->nbNumVar; i++)
		nans[i]=nvals[i];
	for (i=0;i<this->nbBoolVar;i++)
		bans[i]=bvals[i];
	for (i=0;i<this->nbIntVar;i++)
		ians[i]=ivals[i];	
	

	ans[0] =  nans;
	ans[1] =  bans;
	ans[2] =  ians;
	return ans;
}
