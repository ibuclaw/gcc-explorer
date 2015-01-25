module max_array_opt;

void maxArray(ref double[65536] x, ref double[65536] y)
{
    foreach (i; 0 .. 65536)
        x[i] = ((y[i] > x[i]) ? y[i] : x[i]);
}
