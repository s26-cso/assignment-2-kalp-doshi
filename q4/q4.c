#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

int main()
{
    char op[100];
    int a, b;

    while(scanf("%s %d %d", op, &a, &b)==3){

        char libname[100] = "lib";
        strcat(libname, op);
        strcat(libname, ".so");

        char path[120] = "./";
        strcat(path, libname);

        void *handle = dlopen(path, RTLD_LAZY);
        if (!handle) {
            printf("Error: %s\n", dlerror());
            return 1;
        }

        int (*func)(int,int);
        func = dlsym(handle, op);
        if (!func) {
            printf("Error: %s\n", dlerror());
            return 1;
        }

        int result = func(a, b);

        printf("%d\n", result);

        dlclose(handle);

    }
    return 0;
}
