

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>      

int main() {

    char op[6];
    char lib_path[12];
    int num1, num2;

    while (scanf("%s %d %d", op, &num1, &num2) == 3) {

        // build the shared library filename: "lib<op>.so"
        
        snprintf(lib_path, sizeof(lib_path), "lib%s.so", op);

        void *handle = dlopen(lib_path, RTLD_LAZY | RTLD_LOCAL);
        if (!handle) {
            fprintf(stderr, "Could not load %s: %s\n", lib_path, dlerror());
            continue;   // keep the app alive even if one op fails
        }

        // clear any old error, then look up the function by name
        dlerror();
        typedef int (*op_func)(int, int);   // the signature all ops must have
        op_func func = (op_func) dlsym(handle, op);

        
        // literally NULL — so we check dlerror() to distinguish the two
        char *err = dlerror();
        if (err) {
            fprintf(stderr, "Could not find symbol '%s' in %s: %s\n", op, lib_path, err);
            dlclose(handle);
            continue;
        }

        // call the operation and print the result
        int result = func(num1, num2);
        printf("%d\n", result);

        // keeping two open at once would blow past the memory limit.
        dlclose(handle);
    }

    return 0;
}