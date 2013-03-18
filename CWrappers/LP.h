#ifndef CWRAPPER_LP_H
#define CWRAPPER_LP_H

#include <ilcplex/ilocplex.h>
#include <ilconcert/ilolinear.h>
#include <iostream>
#include <map>

#define Max 1
#define Min 2

class LP{
	public:
	 	LP(const IloEnv& cenv, int n);
		void addConstraint(double lb, double* lc, double ub);
		void setObjective(double* lc, int sense);
		int getNbVars(void){return nbVars;}
		IloNumArray* solve(void);
	private:
		IloEnv env;
		IloModel model;
		IloNumVarArray numVar;
		
		int nbVars;

		
};

#endif
