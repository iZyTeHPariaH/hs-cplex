#include "LP.h"

LP::LP(const IloEnv& cenv, int n){
	this->env = IloEnv(cenv);
	this->model = IloModel(cenv);
	this->numVar = IloNumVarArray(cenv);
	this->nbVars = n;

	
	int i=0;
	for (i=0; i < n; i++){
		IloNumVar v = IloNumVar(cenv);
		this->numVar.add(v);

	}
}

void LP::addConstraint(double lb, double* lc, double ub){
	IloRange r = IloRange (this->env, lb, ub);
	int i = 0;
	for (i=0; i < this->nbVars;i++){
		r.setLinearCoef(this->numVar[i],lc[i]);
	}
	this->model.add(r);
}
void LP::setObjective(double* lc, int sense){
	IloObjective o;
	int i = 0;
	if (Max == sense)
		o = IloMaximize(this->env);
	else
		o = IloMinimize(this->env);
	for (i=0; i < this->nbVars;i++)
		o.setLinearCoef(this->numVar[i],lc[i]);
	this->model.add(o);
}
IloNumArray* LP::solve(void){
	IloCplex cplex (this->model);
	cplex.exportModel("lpex.lp");
	if (! cplex.solve()){
		this->env.error() << "Failed to optimize LP\n"; 
		throw (-1);
	}
	IloNumArray* vals = new IloNumArray (this->env);
	cplex.getValues (*vals,this->numVar);
	this->env.out() << "Values : " << *vals << "\n";
	return vals;
}
