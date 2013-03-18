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
	 	LP(const IloEnv& cenv, int n, int b, int i);
		void addConstraint(double lb, double* nlc, double* blc, double* ilc, double ub);
		void setObjective(double* nlc, double* blc, double* ilc, int sense);

		int getNbNumVars(void){return nbNumVar;}
		int getNbBoolVar(void){return nbBoolVar;}
		int getNbIntVar(void){return nbIntVar;}

		double** solve(void);
	private:
		IloEnv env;
		IloModel model;

		IloNumVarArray numVar;
		IloBoolVarArray boolVar;
		IloIntVarArray intVar;

		int nbNumVar, nbBoolVar, nbIntVar;

		
};

#endif
