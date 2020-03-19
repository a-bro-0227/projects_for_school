# caluate and return variance of a list of numbers

def variance(numbers):
    length = len(numbers)
    mean = sum(numbers) / length

    square_differences_from_mean = []

    for number in numbers:
        square_differences_from_mean.append((number - mean) ** 2)
    sum_of_square_differences = sum(square_differences_from_mean)
    variance = sum_of_square_differences / length
    return variance

print(variance([8, 7, 20, 5]))
print(variance([8, 7, 20, 3]))