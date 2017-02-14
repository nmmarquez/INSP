#include <TMB.hpp>
#include <Eigen/Sparse>
#include <vector>
using namespace density;
using Eigen::SparseMatrix;

template<class Type>
Type objective_function<Type>::operator() (){
    
    DATA_VECTOR(pop); 
    DATA_VECTOR(V1);
    DATA_IVECTOR(state_id_vec);
    DATA_VECTOR(state_yobs);
    
    PARAMETER(b0);
    PARAMETER(b1);
    
    int N = pop.size();
    int M = state_yobs.size();
    
    vector<Type> yhat(N);
    vector<Type> state_yhat(M);
    
    state_yhat = state_yhat * Type(0);
    
    int state_id;
    
    for (int i = 0; i < N; i++) {
        state_id = state_id_vec[i];
        yhat[i] = exp(b0 + b1 * V1[i]) * pop[i];
        state_yhat[state_id] += yhat[i];
    }
    
    Type nll = 0.;
    
    for (int i = 0; i < M; i++) {
        nll -= dpois(state_yobs[i], state_yhat[i], true);
    }
    
    REPORT(state_yhat);
    REPORT(yhat);
    REPORT(b0);
    REPORT(b1);
    
    return nll;
}
