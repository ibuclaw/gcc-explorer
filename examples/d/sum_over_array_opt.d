module sum_over_array_opt;

int testFunction(int[] input)
{
    int sum = 0;
    foreach(i; input)
        sum += i;
    return sum;
}
