#include <cstdio>
#include <cstdlib>
#include <cstdarg>

#include <unistd.h>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include "glutil.h"
#include "demo.h"
#include "panic.h"

namespace {

void
error_callback(int error, const char *description)
{
    panic("GLFW error: %s", description);
}

void
key_callback(GLFWwindow *window, int key, int scancode, int action, int mods)
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
}

void
usage(const char *argv0)
{
    fprintf(stderr, "Usage: %s [-w width] [-h height] [-n frames] shader\n", argv0);
    exit(EXIT_FAILURE);
}

}

int
main(int argc, char *argv[])
{
    int width = 512;
    int height = 512;
    int num_frames = -1;

    int opt;
    while ((opt = getopt(argc, argv, "w:h:n:")) != -1) {
        switch (opt) {
            case 'w':
                width = atoi(optarg);
                break;

            case 'h':
                height = atoi(optarg);
                break;

            case 'n':
                num_frames = atoi(optarg);
                break;

            default:
                usage(*argv);
        }
    }

    if (optind >= argc)
        usage(*argv);

    if (!glfwInit())
        return 1;

    glfwSetErrorCallback(error_callback);

    GLFWwindow *window = glfwCreateWindow(width, height, "test", nullptr, nullptr);
    if (!window) {
        glfwTerminate();
        return 1;
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    glewInit();

    glfwSetKeyCallback(window, key_callback);

    demo d(width, height, argv[optind]);

    if (num_frames != -1)
        d.dump_frames(num_frames);

    while (!glfwWindowShouldClose(window) && d.redraw()) {
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();
}
