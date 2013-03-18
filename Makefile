
all:
	g++ -O0 -m32 -O -fPIC -fno-strict-aliasing -fexceptions -DNDEBUG -DIL_STD -I/home/sat/cplex/cplex/include -I/home/sat/cplex/concert/include CWrappers/wrappers.cpp -c -o CWrappers/wrappers.o
	g++ -O0 -m32 -O -fPIC -fno-strict-aliasing -fexceptions -DNDEBUG -DIL_STD -I/home/sat/cplex/cplex/include -I/home/sat/cplex/concert/include  -c CWrappers/LP.cpp -o CWrappers/LP.o
	ghc -fffi Main.hs CWrappers/wrappers.o CWrappers/LP.o -O0 -O -fPIC -DNDEBUG -DIL_STD -I/home/sat/cplex/cplex/include -I/home/sat/cplex/concert/include  -L/home/sat/cplex/cplex/lib/x86_sles10_4.1/static_pic -L/home/sat/cplex/concert/lib/x86_sles10_4.1/static_pic -lconcert -lilocplex -lcplex -lm -lpthread -lstdc++

clean:
	rm -R *.o *.hi
