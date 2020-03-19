my_name = "Alex"

greeting = "Hello, world, I'm"

def say_hello(name):
    if name == "":
        print("You can't introduce yourself if you don't have a name!")
    else:
        print(greeting, name, sep = " ")

say_hello(my_name)