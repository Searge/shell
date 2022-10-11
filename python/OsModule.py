import os

tmp='temp'

print(os.getcwd())

os.chdir('../')
print(os.getcwd())

os.chdir('PythonScripting')
if tmp not in os.listdir(os.getcwd()):
    os.mkdir(tmp)
else:
    os.rmdir(tmp)

print(os.listdir(os.getcwd()))
# os.rmdir(tmp)
