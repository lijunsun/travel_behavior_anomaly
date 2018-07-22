#include <math.h>
#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
	double *inprob;
	double uf, xxx;
	mwSize z, n, i;

	z = 1;
	inprob = mxGetPr(prhs[0]);
	n = mxGetNumberOfElements(prhs[0]);
	
    
    xxx = 0;
    for (i=0; i<n; i++)
    {
        xxx += inprob[i];
    }
    uf = rand() * xxx / (double)RAND_MAX;
    
	for (i=0; i<n-1; i++)
	{
        uf -= inprob[i];
        if (uf > 0) 
        { 
            z += 1;
        }
        else
		{
			break;
		}
	}
	plhs[0] = mxCreateDoubleScalar(z);
	return;
}
