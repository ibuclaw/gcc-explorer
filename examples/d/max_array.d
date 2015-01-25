module max_array;

void maxArray(ref double[65536] x, ref double[65536] y)
{
    foreach (i; 0 .. 65536)
    {
        if (y[i] > x[i])
            x[i] = y[i];
    }
}
