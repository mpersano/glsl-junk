#pragma once

#include <cstdint>
#include <vector>
#include <memory>

#include "glutil.h"

class demo
{
public:
    demo(int width, int height, const std::string& shader_source);

    void dump_frames(int num_frames);

    bool redraw();

private:
    void init(const std::string& shader_source);

    int width_, height_;

    gl::program render_prog_;
    gl::buffer vbo_;

    std::unique_ptr<gl::program::uniform> time_uniform_;

    uint64_t start_t_;

    bool dump_frames_;
    int num_frames_;
    int cur_frame_;
    std::vector<uint32_t> frame_pixels_;
};
