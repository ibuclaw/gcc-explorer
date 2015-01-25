module sum_over_array;

int testFunction(int[] input)
{
    int sum = 0;
    for (int i = 0; i < input.length; ++i) {
        sum += input[i];
    }
    return sum;
}
