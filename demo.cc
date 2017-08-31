#include <GL/glew.h>

#include <cmath>
#include <fstream>

#include <boost/format.hpp>

#include <time.h>

#include "demo.h"

namespace {

uint64_t
get_cur_ms()
{
    timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return static_cast<uint64_t>(ts.tv_sec*1000) + static_cast<uint64_t>(ts.tv_nsec/1000000);
}

}

demo::demo(int width, int height, const std::string& shader_source)
    : width_ { width }
    , height_ { height }
    , vbo_ { GL_ARRAY_BUFFER }
    , start_t_ { 0 }
    , dump_frames_ { false }
    , num_frames_ { 64 }
    , cur_frame_ { 0 }
{
    init(shader_source);

    frame_pixels_.resize(width*height);
}

void
demo::dump_frames(int num_frames)
{
    dump_frames_ = true;
    num_frames_ = num_frames;
}

bool
demo::redraw()
{
    float t;

    if (dump_frames_) {
        if (cur_frame_ >= num_frames_)
            return false;

        t = static_cast<float>(cur_frame_)/num_frames_;

        ++cur_frame_;
    } else {
        const float period = 2000.;

        uint64_t now = get_cur_ms();
        if (!start_t_)
            start_t_ = now;

        uint64_t dt = now - start_t_;

        t = std::fmod(dt, period)/period;
    }

    GL_CHECK(glViewport(0, 0, width_, height_));
    GL_CHECK(glClear(GL_COLOR_BUFFER_BIT));

    render_prog_.use();

    if (time_uniform_->is_valid())
        time_uniform_->set_f(t);

    vbo_.bind();
    GL_CHECK(glDrawArrays(GL_TRIANGLE_STRIP, 0, 4));

    if (dump_frames_) {
        GL_CHECK(glReadPixels(0, 0, width_, height_, GL_RGBA, GL_UNSIGNED_BYTE, &frame_pixels_[0]));

        const auto path = boost::format { "frame-%03d.ppm" } % cur_frame_;

        std::ofstream out(path.str(), std::ios_base::binary);

        if (out.is_open()) {
            out << "P6\n" << width_ << " " << height_ << "\n255\n";

            for (auto v : frame_pixels_) {
                out.put(v & 0xff);
                out.put((v >> 8) & 0xff);
                out.put((v >> 16) & 0xff);
            }

            out.close();
        }
    }

    return true;
}

void
demo::init(const std::string& shader_source)
{
    // vert/frag shaders

    gl::shader vert_shader(GL_VERTEX_SHADER);
    vert_shader.load_source("shaders/vert.glsl");

    gl::shader frag_shader(GL_FRAGMENT_SHADER);
    if (!frag_shader.load_source(shader_source))
        panic("failed to load `%s'\n", shader_source.c_str());

    render_prog_.attach(vert_shader);
    render_prog_.attach(frag_shader);
    render_prog_.link();

    render_prog_.use();
    render_prog_.get_uniform("resolution").set_f(width_, height_);

    time_uniform_.reset(new gl::program::uniform(render_prog_.get_uniform("time")));

    // vbo

    static const GLfloat verts[] { -1, -1, -1, 1, 1, -1, 1,  1 };
    vbo_.set_data(sizeof(verts), verts);

    vbo_.bind();
    GL_CHECK(glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0));
    GL_CHECK(glEnableVertexAttribArray(0));
}
