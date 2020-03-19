# fibonacci program

# set number
def get_fib_list_length():
    return 20

# define function for fibonacci formula
def generate_fib(num):
    result = [] # set up empty list

    for n in range(num):
        if n <= 1:
            result.append(n)

        else:
            value = result[n - 2] + result[n - 1]
            result.append(value)
    return result

# define function for printing fibonacci numbers
def display_fibs(fibs):
    for fib in fibs:
        print(fib)

# call functions to run the code
def main():
    fib_limit = get_fib_list_length()
    fibs = generate_fib(fib_limit)
    display_fibs(fibs)

main()